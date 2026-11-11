class Kbase < Formula
  # Developer Keyoxide: https://keyoxide.org/wkd/benn@bennherrera.dev
  desc "Build, maintain, navigate, visualize, render a knowledge base"
  homepage "https://github.com/benn-herrera/kbase"
  url "https://github.com/benn-herrera/kbase/archive/refs/tags/v0.11.1.tar.gz"
  sha256 "0a61608180791bdcb004e7c500272f5b47fe3f3039b16ddccade871751c456cd"
  license "MIT"
  head "https://github.com/benn-herrera/kbase.git", branch: "main"

  depends_on "go" => :build
  # Every stage of a kb build commits its boundary through git, so a KB needs the
  # repository's own git.
  depends_on "git"
  # graphviz dot is required for rendering claim graph diagrams
  depends_on "graphviz"
  # pandoc is required for build and export-latex operations.
  depends_on "pandoc"

  def install
    system "go", "build", *std_go_args, "./cmd"
  end

  # `kbase --version` prints exactly internal/version's Current, which is a bare
  # semver. A stable install was built from the tag the formula names, so the
  # two agree; a HEAD install is some other commit and may carry a version the
  # formula does not name.
  test do
    reported = shell_output("#{bin}/kbase --version").strip
    assert_match(/\A\d+\.\d+\.\d+\z/, reported)
    assert_equal version.to_s, reported if active_spec_sym == :stable
  end
end
