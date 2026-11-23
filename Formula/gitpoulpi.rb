# TEMPLATE, NOT PUBLISHED. see the release-and-packaging design ("Homebrew").
#
# Formula for a tap repository (Formula/gitpoulpi.rb of a `homebrew-gitpoulpi` repo, installed with
# `brew install <owner>/gitpoulpi/gitpoulpi`). It installs the official release archives, no compilation.
# Replace 1.2.0 and the @SHA256_...@ values (first field of each archive's .sha256), then
# `brew install --build-from-source ./gitpoulpi.rb` and `brew test gitpoulpi`.
#
# A formula download is not quarantined, so Gatekeeper does not block the unsigned binaries. The programs go
# to libexec next to a `.gitpoulpi-dist` marker with channel=homebrew (the exe directory is found by
# following the bin symlink), and bin gets symlinks: GitPoulpi then runs `brew upgrade gitpoulpi` itself and
# never swaps files behind Homebrew. gitpoulpi-updater is installed with the other binaries.
class Gitpoulpi < Formula
  desc "Git client for the terminal with a clickable commit graph, a CLI and an MCP server"
  homepage "https://github.com/Poulpi-Lab/GitPoulpi"
  version "1.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "2a8eb574e56d83fe22c33497fe245de6d616e4a9c91521168255a3e3431816f3"
    end
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "0c242cf495e898a015523e52bb9ee31467da7580f58f7a90a9dcf0f528d0bbcf"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "540b4df9ee9ba8288a5dd315e22151970aa37a26299be0c1af0d2a6d4d600590"
    end
    on_arm do
      url "https://github.com/Poulpi-Lab/GitPoulpi/releases/download/releases/v#{version}/gitpoulpi-#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f7f2876eb43c7de9d083865466379e635e979972ff29d6ef32d9c9dec66a8112"
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
