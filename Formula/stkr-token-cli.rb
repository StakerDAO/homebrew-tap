class StkrTokenCli < Formula
  # TODO Write proper desc and hp
  desc "Haskell to Michelson for Lorentz contract parameters"
  homepage "https://github.com/tqtezos/lorentz-contract-param"

  url "https://github.com/StakerDAO/staker-dao.git"
  version "0.6"

  head "https://github.com/serokell/staker-dao.git", :branch => "master"

  bottle do
    root_url "https://github.com/StakerDAO/staker-dao/releases/download/0.6"
    cellar :any
    sha256 "053f695d7068e8aacef50a5515b68d64603251476dd97aacbdde486a47240c64" => :catalina
  end

  resource "mac-stack" do
    url "https://github.com/commercialhaskell/stack/releases/download/v1.9.3/stack-1.9.3-osx-x86_64.tar.gz"
    sha256 "05ff745b88fb24911aa6b7e2b2e7098f04c2fdf769f00f921d44ffecbc417bc2"
  end

  depends_on "pkg-config" => :build
  depends_on "libsodium"

  def install
    (buildpath/"mac-stack").install resource("mac-stack")
    ENV.append_path "PATH", "#{buildpath}/mac-stack"

    system "cd stkr-token && stack build"

    bin_path_root = File.join `cd stkr-token && stack path --local-install-root`.chomp, "bin"
    ["stkr-token-cli"].each do |bin_name|
      bin_path = File.join bin_path_root, bin_name
      if File.exist?(bin_path) && File.executable?(bin_path)
        bin.mkpath
        bin.install bin_path
      else
        raise "#{bin_path} either missing or not executable"
      end
    end
  end

  test do
    assert_predicate bin/"stkr-token-cli", :exist?
    # system "cd stkr-token && stack test"
  end
end
