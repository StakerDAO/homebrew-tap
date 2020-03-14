class TezosClientPatched < Formula
  @all_bins = []

  class << self
    attr_accessor :all_bins
  end

  desc "Platform for distributed consensus with meta-consensus capability"
  homepage "https://gitlab.com/tezos/tezos"

  url "https://gitlab.com/tezos/tezos.git", :revision => "64c855499057fa84b41fcb9f3d7d72d4570db1a7", :branch => "master", :shallow => false

  version "2020-03-11-ledger-patched"

  head "https://gitlab.com/tezos/tezos.git", :branch => "master"

  keg_only "This formula should only be used for stkr-token-cli, and should not conflict with regular tezos-client"

  patch do
    url "https://gist.githubusercontent.com/gpevnev/3b08d7755dae17b3e5bff718dd9320af/raw/73cad4c677d85608a28cc1a6f3dbcf33c0a18ed8/tezos-client-sign.patch"
    sha256 "8d34d1daf5963c0630b6675b500e71e9570f058380e19530f0198431e00747f4"
  end 

  bottle do
    root_url "https://gpevnev-org.bintray.com/bottles-stakerdao"
    cellar :any
    rebuild 1
    sha256 "f81f3197feaa000c259e9ef65b60a1d15107d0ebe472969c4c9e4dfdf9d9b322" => :catalina
  end

  build_dependencies = %w[opam pkg-config rsync wget]
  build_dependencies.each do |dependency|
    depends_on dependency => :build
  end

  dependencies = %w[gmp hidapi libev]
  dependencies.each do |dependency|
    depends_on dependency
  end

  def install
    ENV.deparallelize

    system "opam",
           "init",
           "--bare",
           "--debug",
           "--auto-setup",
           "--disable-sandboxing"

    system "make", "build-deps"
    system ["eval $(opam env)", "make", "make install"].join(" && ")

    bin.mkpath # ensure bin folder exists
    executable_file_paths = Dir["./*"].select do |file_path|
      File.file?(file_path) && File.executable?(file_path)
    end
    executable_file_paths.each do |file_path|
      file_name = File.basename file_path
      self.class.all_bins << file_name
      bin.install file_name
    end

    system prepend_path_in_profile("~/tezos")

    bash_completion.install "src/bin_client/bash-completion.sh"
  end

  test do
    system "#{bin}/tezos-client", "man"

    self.class.all_bins.each do |file_name|
      assert_predicate bin/file_name, :exist?
    end
  end
end