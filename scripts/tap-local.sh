#!/usr/bin/env bash
# Installs the working tree through a scratch formula: tars every tracked file
# at its working-tree content (uncommitted edits included, untracked files left
# out) under dist/tap/, copies the tap's formula to dist/tap/${TAP_PRODUCT}.rb, points that
# copy at the tarball, reinstalls ${TAP_FORMULA} from it. The tap clone and Homebrew's
# own tap checkout are read or touched by nothing here.
#
# Needs macOS tar (bsdtar, for -s), git, cargo, shasum and brew.
set -euo pipefail

: "${TAP_FORMULA:?TAP_FORMULA is not set: the name of the formula}"
for tool in brew cargo shasum; do
  command -v "${tool}" >/dev/null || { printf 'tap-local: %s not on PATH\n' "${tool}" >&2; exit 1; }
done

script_dir="$(cd "$(dirname "${0}")" && pwd)" || exit 1
cd "${script_dir}"
tap_dir=$(cd .. && pwd)
cd "${tap_dir}"
while [[ -d Formula || ! -d .git ]] && [[ "$(pwd)" != "/" ]]; do
  cd ".."
done

project_dir=$(pwd)

src="${tap_dir}/Formula/${TAP_FORMULA}.rb"
if [[ ! -f "${src}" ]]; then
  printf 'tap-local: no formula at %s; run `just tap`\n' "${src}" >&2
  exit 1
fi

lang=$(awk -F\" '/^[ \t]*depends_on/ { print $2; exit(0); }' "${src}")
case "${lang}" in
  rust) ver=v"$(cargo run -- --version)";;
  go) ver=v"$(go run ./cmd --version)";;
  python*) ver="v$(PYTHONPATH="$(pwd)" python3 -m ${TAP_FORMULA} --version)";;
  *) printf '%s not supported. only go and rust.\n' "${lang}" 1>&2; exit 1;;
esac
tarball="${project_dir}/dist/tap/${ver}.tar.gz"
formula="${project_dir}/dist/tap/${TAP_FORMULA}.rb"

mkdir -p "${project_dir}/dist/tap"
git ls-files -z | tar -czf "${tarball}" --null -T - -s ",^,${ver}/,"
sha="$(shasum -a 256 "${tarball}" | cut -d' ' -f1)"
cp "${src}" "${formula}"
"${script_dir}"/tap-formula-set.sh "${formula}" "file://${tarball}" "${sha}"

# `brew list --versions` prints nothing and fails only when ${TAP_FORMULA} is not installed.
if [[ -n "$(brew list --versions ${TAP_FORMULA} || true)" ]]; then
  brew uninstall ${TAP_FORMULA}
fi
# Homebrew installs formulae only by name from a tap, never from a path, so the
# scratch formula goes into a local tap of its own; the real tap is not touched.
scratch_tap="local/${TAP_FORMULA}-dev"
scratch_dir="$(brew --repository "${scratch_tap}")"
[[ -d "${scratch_dir}" ]] || brew tap-new --no-git "${scratch_tap}"
cp "${formula}" "${scratch_dir}/Formula/${TAP_FORMULA}.rb"
brew install --formula "${scratch_tap}/${TAP_FORMULA}"
