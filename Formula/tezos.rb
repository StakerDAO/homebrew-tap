class Tezos < Formula
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
    # TODO: put patch in public place
    url "https://raw.githubusercontent.com/serokell/tezos-btc/master/patch/tezos-client.patch?token=AGDS6I6OROCEN4FFZ7CG7HC6ODQ4K"
    sha256 "8d34d1daf5963c0630b6675b500e71e9570f058380e19530f0198431e00747f4"
  end 

  # TODO update bottle
  bottle do
    root_url "https://dl.bintray.com/michaeljklein/bottles-tq"
    cellar :any
    sha256 "1ea43b32da55dfcbc3d7537b09e2144495f4fcab268587af11f472913b82ae15" => :mojave
    sha256 "01e239b1e169612516bead411a102dc805fc04d79b334be9055edf721b1a4477" => :x86_64_linux
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
