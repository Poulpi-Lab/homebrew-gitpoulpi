# TEMPLATE, NOT PUBLISHED. see the release-and-packaging design ("Homebrew").
#
# Formula for a tap repository (Formula/gitpoulpi.rb of a `homebrew-gitpoulpi` repo, installed with
# `brew install <owner>/gitpoulpi/gitpoulpi`). It installs the official release archives, no compilation.
# Replace 1.0.0 and the @SHA256_...@ values (first field of each archive's .sha256), then
# `brew install --build-from-source ./gitpoulpi.rb` and `brew test gitpoulpi`.
#
# A formula download is not quarantined, so Gatekeeper does not block the unsigned binaries. The programs go
# to libexec next to a `.gitpoulpi-dist` marker with channel=homebrew (the exe directory is found by
# following the bin symlink), and bin gets symlinks: GitPoulpi then runs `brew upgrade gitpoulpi` itself and
# never swaps files behind Homebrew. gitpoulpi-updater is installed with the other binaries.
class Gitpoulpi < Formula
  desc "Git client for the terminal with a clickable commit graph, a CLI and an MCP server"
  homepage "https://github.com/Poulpi-Lab/GitPoulpi"
  version "1.0.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "19ce6dd88f85a08731476fece96307f1dbf99544f81a6845af381c0cbfbfd6c7"
    end
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "efb398f2011dab20e6b0478ed4f2480b7483a1234d7cc61bf09be30995fc01e9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "1e351866bd1c595733839bc694dedcda1564599f26ddb0874259e94657037c37"
    end
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "a2d41ce8bb4e86df4edfa73b880d38ab310607e9681f7352b675e3ebb9481545"
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
