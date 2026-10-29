cask "mpv-wrapper" do
  version "1.0.0"
  sha256 "b2b7dbffd819bc7230694daaffa43d823def960d9f665cfb59a1dcd8fd18fe92"

  url "https://github.com/GuMengSama/mpv-wrapper/releases/download/v#{version}/mpv-wrapper-#{version}.tar.gz"
  name "mpv"
  desc "App bundle for the Homebrew mpv formula"
  homepage "https://github.com/GuMengSama/mpv-wrapper"

  conflicts_with cask: "stolendata-mpv"
  depends_on formula: "mpv"
  depends_on :macos

  app "app/mpv.app"

  # Contents/MacOS/mpv-formula links to the formula's stable opt/ path, so
  # `brew upgrade mpv` needs no rebuild. Contents/MacOS/mpv is src/launcher.c
  # from the mpv-wrapper repo, compiled here, which puts mpv in app mode.
  postflight_steps do
    # Gatekeeper kills the app if the download's quarantine flag stays on it.
    # Runs before the symlink exists so it never reaches the formula's files.
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/mpv.app"],
        writable_paths: ["mpv.app"],
        writable_base:  :appdir

    mkdir_p "mpv.app/Contents/MacOS", base: :appdir
    symlink "bin/mpv", "mpv.app/Contents/MacOS/mpv-formula",
            source_formula: "mpv", source_base: :formula_opt_prefix, target_base: :appdir
    run "/usr/bin/cc",
        args:           ["-O2", "-o", "{{appdir}}/mpv.app/Contents/MacOS/mpv", "{{staged_path}}/src/launcher.c"],
        writable_paths: ["mpv.app/Contents/MacOS"],
        writable_base:  :appdir
  end

  zap trash: [
    "~/Library/Logs/mpv.log",
    "~/Library/Preferences/io.mpv.plist",
    "~/Library/Saved Application State/io.mpv.savedState",
  ]

  caveats <<~EOS
    mpv.app runs the Homebrew mpv formula, so `brew upgrade mpv` updates it too.
    Your config in ~/.config/mpv is shared by the app and the mpv command.

    To make mpv the default player for a file type: Finder → select a file →
    Get Info → Open with → mpv → Change All…
  EOS
end
