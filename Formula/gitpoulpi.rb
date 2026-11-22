# TEMPLATE, NOT PUBLISHED. see the release-and-packaging design ("Homebrew").
#
# Formula for a tap repository (Formula/gitpoulpi.rb of a `homebrew-gitpoulpi` repo, installed with
# `brew install <owner>/gitpoulpi/gitpoulpi`). It installs the official release archives, no compilation.
# Replace 1.1.0 and the @SHA256_...@ values (first field of each archive's .sha256), then
# `brew install --build-from-source ./gitpoulpi.rb` and `brew test gitpoulpi`.
#
# A formula download is not quarantined, so Gatekeeper does not block the unsigned binaries. The programs go
# to libexec next to a `.gitpoulpi-dist` marker with channel=homebrew (the exe directory is found by
# following the bin symlink), and bin gets symlinks: GitPoulpi then runs `brew upgrade gitpoulpi` itself and
# never swaps files behind Homebrew. gitpoulpi-updater is installed with the other binaries.
class Gitpoulpi < Formula
  desc "Git client for the terminal with a clickable commit graph, a CLI and an MCP server"
  homepage "https://github.com/Poulpi-Lab/GitPoulpi"
  version "1.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "bad9e0789c394144f1052f6e7c8d247d87666542a9eea36a51db807e1428cb7f"
    end
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "3e114b7aeb6d77ec660efa708d622c8da71ce4818e2430c98a733da41c83ae77"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "132beb08274a83cd0cffb1e7e5fd745b3f7332a430992947a111bf980407fe1c"
    end
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "609cb87135019c2625e066036a04ddca6f7de621646534d45d0466d55d7cc168"
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
