class Devpro < Formula
  # Developer Keyoxide: https://keyoxide.org/wkd/benn@bennherrera.dev
  desc "Product-grade AI-assisted development process"
  homepage "https://github.com/benn-herrera/devpro"
  url "https://github.com/benn-herrera/devpro/archive/refs/tags/v0.11.1.tar.gz"
  sha256 "0a61608180791bdcb004e7c500272f5b47fe3f3039b16ddccade871751c456cd"
  license "MIT"
  head "https://github.com/benn-herrera/devpro.git", branch: "main"

  depends_on "python" => :build

  def install
    system "python", "build", *std_python_args, "."
  end

  # `devpro --version` prints exactly internal/version's Current, which is a bare
  # semver. A stable install was built from the tag the formula names, so the
  # two agree; a HEAD install is some other commit and may carry a version the
  # formula does not name.
  test do
    reported = shell_output("#{bin}/devpro --version").strip
    assert_match(/\A\d+\.\d+\.\d+\z/, reported)
    assert_equal version.to_s, reported if active_spec_sym == :stable
  end
end
