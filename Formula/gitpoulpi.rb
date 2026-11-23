# TEMPLATE, NOT PUBLISHED. see the release-and-packaging design ("Homebrew").
#
# Formula for a tap repository (Formula/gitpoulpi.rb of a `homebrew-gitpoulpi` repo, installed with
# `brew install <owner>/gitpoulpi/gitpoulpi`). It installs the official release archives, no compilation.
# Replace 1.1.1 and the @SHA256_...@ values (first field of each archive's .sha256), then
# `brew install --build-from-source ./gitpoulpi.rb` and `brew test gitpoulpi`.
#
# A formula download is not quarantined, so Gatekeeper does not block the unsigned binaries. The programs go
# to libexec next to a `.gitpoulpi-dist` marker with channel=homebrew (the exe directory is found by
# following the bin symlink), and bin gets symlinks: GitPoulpi then runs `brew upgrade gitpoulpi` itself and
# never swaps files behind Homebrew. gitpoulpi-updater is installed with the other binaries.
class Gitpoulpi < Formula
  desc "Git client for the terminal with a clickable commit graph, a CLI and an MCP server"
  homepage "https://github.com/Poulpi-Lab/GitPoulpi"
  version "1.1.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "b32e200c1eef405a6d9c5b635c978193e1b548b4ac1dfd045ff3802c1c4f31f3"
    end
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "62ba1df4afb13d97728a5e082299cca0319828894e81f1aff034907a14caa8cc"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "d03b6d3f3dafeec6dc39f1b03cf4fc41b8fb0c74ae39786ec12ed15f82af6a54"
    end
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "cb5139a6aa8582734c457acffcf584b57c28812515642689615e3edf1f49d2fb"
    end
  end

  def install
    libexec.install "gitpoulpi", "gitpoulpi-tui", "gitpoulpi-mcp", "gitpoulpi-launch", "gitpoulpi-updater"
    target = if OS.mac?
      Hardware::CPU.arm? ? "aarch64-apple-darwin" : "x86_64-apple-darwin"
    else
      Hardware::CPU.arm? ? "aarch64-unknown-linux-gnu" : "x86_64-unknown-linux-gnu"
    end
    (libexec/".gitpoulpi-dist").write "version=#{version}\ntarget=#{target}\nchannel=homebrew\n"
    %w[gitpoulpi gitpoulpi-tui gitpoulpi-mcp gitpoulpi-launch].each { |name| bin.install_symlink libexec/name }
    doc.install "README.md", "CHANGELOG.md", "INSTALL.txt"
    prefix.install "LICENSE", "THIRD-PARTY-LICENSES.txt"
  end

  def caveats
    <<~EOS
      GitPoulpi needs a system git on the PATH (the Xcode command line tools or `brew install git`).
      `gitpoulpi` with no subcommand opens the terminal UI.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gitpoulpi --version")
  end
end
