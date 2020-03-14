class StkrTokenCli < Formula
  # TODO Write proper desc and hp
  desc "Haskell to Michelson for Lorentz contract parameters"
  homepage "https://github.com/tqtezos/lorentz-contract-param"

  url "https://github.com/serokell/staker-dao.git",
      :revision => "349a128d6f65c8526411398b845a5df29d8f6272"
  version "0.5"

  head "https://github.com/serokell/staker-dao.git", :branch => "master"
  
  bottle do
    root_url "https://gpevnev-org.bintray.com/bottles-stakerdao"
    cellar :any
    rebuild 1
    sha256 "cba76fdf28eb4d9a74713e90042d7b89d348b1b8842b14e97675b5799364899c" => :catalina
  end

  resource "mac-stack" do
    url "https://github.com/commercialhaskell/stack/releases/download/v1.9.3/stack-1.9.3-osx-x86_64.tar.gz"
    # url "https://github.com/commercialhaskell/stack/releases/download/v2.1.3/stack-2.1.3-osx-x86_64.tar.gz"
    # sha256 "84b05b9cdb280fbc4b3d5fe23d1fc82a468956c917e16af7eeeabec5e5815d9f"
    sha256 "05ff745b88fb24911aa6b7e2b2e7098f04c2fdf769f00f921d44ffecbc417bc2"
  end

  depends_on "pkg-config" => :build
  depends_on "libsodium"

  def install
    ENV.deparallelize

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
    # assert_predicate bin/"stkr-token-cli", :exist?
    # system "cd stkr-token && stack test"
  end
end
