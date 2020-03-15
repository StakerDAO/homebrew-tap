class TezosClientPatched < Formula
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
    rebuild 2
    sha256 "b1e99b2f65204615377eb9e571df8af62863f7d08207e1f0ba8875c97fc7bac9" => :catalina
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
    bin.install "tezos-client"

    bash_completion.install "src/bin_client/bash-completion.sh"
  end

  test do
    system "#{bin}/tezos-client", "man"
  end
end
