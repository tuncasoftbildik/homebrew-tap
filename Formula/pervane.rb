class Pervane < Formula
  desc "Open-source fan control for macOS: curves, profiles, auto-switch rules"
  homepage "https://github.com/tuncasoftbildik/pervane"
  url "https://github.com/tuncasoftbildik/pervane/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "c8782d70318a2613c5ea621f8dc106ccff5ad4ae97a07425d2d9ff92c2b03425"
  license "MIT"

  depends_on xcode: ["15.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin_path = Utils.safe_popen_read("swift", "build", "-c", "release", "--show-bin-path").chomp

    bin.install "#{bin_path}/pervane"
    libexec.install "#{bin_path}/pervaned", "servis.sh"

    app = prefix/"Pervane.app/Contents"
    (app/"MacOS").mkpath
    cp "#{bin_path}/PervaneApp", app/"MacOS/Pervane"
    cp "Paket/Info.plist", app/"Info.plist"
    (app/"Resources").install "Paket/Pervane.icns"
    system "codesign", "--force", "--sign", "-", prefix/"Pervane.app"
  end

  def caveats
    <<~EOS
      Pervane needs a root service to drive the fan. Install (or update) it with:
        sudo "#{opt_libexec}/servis.sh" kur "#{opt_libexec}/pervaned"

      Then open the menu bar app:
        open "#{opt_prefix}/Pervane.app"

      Run the service command again after `brew upgrade pervane`.
      Remove the service with:
        sudo "#{opt_libexec}/servis.sh" kaldir

      Quit Macs Fan Control or any other fan tool first; two programs writing
      to the same fan keep overriding each other.
    EOS
  end

  test do
    assert_match "pervane profil", shell_output("#{bin}/pervane yardim")
  end
end
