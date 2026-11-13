#!/usr/bin/env bash
# After a release is pushed: points the tap's formula at the v<version> source
# tarball and its sha256, commits that change in the tap where the formula changed (pushing nothing), then
#
# repository's root.
set -euo pipefail

: "${TAP_FORMULA:?TAP_FORMULA is not set: the name of the formula}"

script_dir="$(cd "$(dirname "${0}")" && pwd)" || exit 1
cd "${script_dir}"
tap_dir=$(cd .. && pwd)
cd "${tap_dir}"
while [[ -d Formula || ! -d .git ]] && [[ "$(pwd)" != "/" ]]; do
  cd ".."
done

f="${tap_dir}/Formula/${TAP_FORMULA}.rb"
lang=$(awk -F\" '/^[ \t]*depends_on/ { print $2; exit(0); }' "${f}")
case "${lang}" in
  rust) ver=v"$(cargo run -- --version)";;
  go) ver=v"$(go run ./cmd --version)";;
  python*) ver="v$(PYTHONPATH="$(pwd)" python3 -m ${TAP_FORMULA} --version)";;
  *) printf '%s not supported. only go and rust.\n' "${lang}" 1>&2; exit 1;;
esac

url="https://github.com/benn-herrera/${TAP_FORMULA}/archive/refs/tags/${ver}.tar.gz"
sha="$(curl -fsSL "${url}" | shasum -a 256 | cut -d' ' -f1)" || \
  { printf 'ensure %s tag %s was created and pushed to github\n' "${TAP_FORMULA}" "${ver}"; exit 1; }
"${script_dir}"/tap-formula-set.sh "${f}" "${url}" "${sha}"
git -C "${tap_dir}" pull
if ! git -C "${tap_dir}" diff --quiet HEAD -- Formula/${TAP_FORMULA}.rb; then
    git -C "${tap_dir}" commit -S -m "${TAP_FORMULA} ${ver}" -- Formula/${TAP_FORMULA}.rb
    git show --show-signature HEAD
fi
