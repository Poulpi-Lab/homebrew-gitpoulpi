# TEMPLATE, NOT PUBLISHED. see the release-and-packaging design ("Homebrew").
#
# Formula for a tap repository (Formula/gitpoulpi.rb of a `homebrew-gitpoulpi` repo, installed with
# `brew install <owner>/gitpoulpi/gitpoulpi`). It installs the official release archives, no compilation.
# Replace 1.3.0 and the @SHA256_...@ values (first field of each archive's .sha256), then
# `brew install --build-from-source ./gitpoulpi.rb` and `brew test gitpoulpi`.
#
# A formula download is not quarantined, so Gatekeeper does not block the unsigned binaries. The programs go
# to libexec next to a `.gitpoulpi-dist` marker with channel=homebrew (the exe directory is found by
# following the bin symlink), and bin gets symlinks: GitPoulpi then runs `brew upgrade gitpoulpi` itself and
# never swaps files behind Homebrew. gitpoulpi-updater is installed with the other binaries.
class Gitpoulpi < Formula
  desc "Git client for the terminal with a clickable commit graph, a CLI and an MCP server"
  homepage "https://github.com/Poulpi-Lab/GitPoulpi"
  version "1.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "50ebcad823f5b5c57fa7f0a4aa7a2b942eba15b321c8906fcb31f8261b8dc9e7"
    end
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "6d7c1cd6b93b35acefba5b5d24eebb92d664923fb0625c642bed822ddfe4f17b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "8c9e05bb54bcd7ecf89a35494a605713a82c0e36b4cf8dada33a8712d8476b62"
    end
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "ba3e9cd62f1efef52ac3f15101c901c018c1b4375360143630aa5c0c8bdf75e7"
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
