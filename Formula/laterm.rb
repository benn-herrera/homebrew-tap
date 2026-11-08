class Laterm < Formula
  # Developer Keyoxide: https://keyoxide.org/wkd/benn@bennherrera.dev
  desc "Claude code sidecar rendering session LaTeX expressions in separate terminal"
  homepage "https://github.com/benn-herrera/laterm"
  url "https://github.com/benn-herrera/laterm/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "05eac70edb8e09f288c220aa95bc5d0403370127c2651ddd750d92381e3d0d7d"
  license "MIT"
  head "https://github.com/benn-herrera/laterm.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end
  # `laterm --version` prints exactly internal/version's Current, which is a bare
  # semver. A stable install was built from the tag the formula names, so the
  # two agree; a HEAD install is some other commit and may carry a version the
  # formula does not name.
  test do
    reported = shell_output("#{bin}/laterm --version").strip
    assert_match(/\A\d+\.\d+\.\d+\z/, reported)
    assert_equal version.to_s, reported if active_spec_sym == :stable
  end
end
