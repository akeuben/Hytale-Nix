{ pkgs }: let
    lib = pkgs.lib;
    details = lib.importJSON ./launcher.json;
in pkgs.stdenv.mkDerivation {
        pname = "hytale-launcher";
        version = details.version;

        nativeBuildInputs = with pkgs; [
            unzip
            makeWrapper
            autoPatchelfHook
        ];

        buildInputs = with pkgs; [
            glib
            webkitgtk_4_1
            gtk3
            icu
            SDL2
            wayland
            wayland-protocols
            libx11
        ];

        src = pkgs.fetchurl details.download_url.linux.amd64;

        unpackPhase = ''
    mkdir -p $PWD/src
    unzip $src -d $PWD/src
    '';

        installPhase = ''
    mkdir -p $out/bin

    # copy the main binary
    cp $PWD/src/hytale-launcher $out/bin/hytale-launcher
    chmod +x $out/bin/hytale-launcher

    # wrap the binary and set environment variables for WebKitGTK
    wrapProgram $out/bin/hytale-launcher \
    --prefix PATH : "${pkgs.glib}/bin:${pkgs.gtk3}/bin:${pkgs.webkitgtk_4_1}/bin" \
    --prefix LD_LIBRARY_PATH : "${pkgs.icu}/lib:${pkgs.SDL2}/lib:${pkgs.wayland}/lib:${pkgs.libx11}/lib:${pkgs.mesa}/lib" \
    --set WEBKIT_DISABLE_DMABUF_RENDERER "1" \
    --set WEBKIT_DISABLE_COMPOSITING_MODE "1" \
    --set GDK_BACKEND "x11" \
    --set SDL_VIDEODRIVER "x11" \
    --set DISPLAY ":0" \
    --set DESKTOP_STARTUP_ID "com.hypixel.HytaleLauncher"
    '';
    }
