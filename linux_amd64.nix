{ 
    lib,
    steam-run-free,
    stdenv,
    makeWrapper,

    unzip,
    autoPatchelfHook,
    glib,
    webkitgtk_4_1,
    gtk3,
    glib-networking,
    gnutls,
}: let
    details = lib.importJSON ./launcher.json;
in stdenv.mkDerivation {
    pname = "hytale-launcher";
    version = details.version;

    nativeBuildInputs = [
        unzip
        makeWrapper
        autoPatchelfHook
    ];

    buildInputs = [
        glib
        webkitgtk_4_1
        gtk3
        glib-networking
        gnutls
    ];

    src = builtins.fetchurl details.download_url.linux.amd64;

    unpackPhase = ''
        mkdir -p $PWD/src
        unzip $src -d $PWD/src
    '';

    installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mkdir -p $out/resources

        # copy the main binary
        cp $PWD/src/hytale-launcher $out/resources/hytale-launcher
        chmod +x $out/resources/hytale-launcher
        runHook postInstall
    '';

    postFixup = ''
        makeWrapper ${steam-run-free}/bin/steam-run $out/bin/hytale-launcher \
        --set WEBKIT_DISABLE_DMABUF_RENDERER "1" \
        --set WEBKIT_DISABLE_COMPOSITING_MODE "1" \
        --set DESKTOP_STARTUP_ID "com.hypixel.HytaleLauncher" \
        --add-flags $out/resources/hytale-launcher
    '';

    meta = with lib; {
        description = "Hytale Launcher";
        homepage    = "https://hytale.com";
        license     = licenses.unfree;

        maintainers = with maintainers; [ akeuben ];
        platforms   = platforms.linux;
        mainProgram = "hytale-launcher";
    };
}
