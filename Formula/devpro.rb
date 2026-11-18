class Devpro < Formula
  include Language::Python::Virtualenv

  # Developer Keyoxide: https://keyoxide.org/wkd/benn@bennherrera.dev
  desc "Product-grade AI-assisted development process"
  homepage "https://github.com/benn-herrera/devpro"
  url "https://github.com/benn-herrera/devpro/archive/refs/tags/v0.17.5.tar.gz"
  sha256 "102d2399f5f053a46285cb0d37ac0fbd8f749d18bd6a6ce1381ee6263a825dee"
  license "MIT"
  head "https://github.com/benn-herrera/devpro.git", branch: "main"

  depends_on "python"

  # devpro has no runtime dependencies, so the venv takes no resources. Its
  # build backend, setuptools, comes from pip's isolated build environment,
  # which virtualenv_install_with_resources keeps on.
  def install
    virtualenv_install_with_resources
  end

  # `devpro --version` prints `devpro.__version__`, a bare semver. A stable
  # install was built from the tag the formula names, so the two agree; a HEAD
  # install is some other commit and may carry a version the formula does not
  # name.
  test do
    reported = shell_output("#{bin}/devpro --version").strip
    assert_match(/\A\d+\.\d+\.\d+\z/, reported)
    assert_equal version.to_s, reported if active_spec_sym == :stable
  end
end
