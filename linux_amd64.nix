{ 
    lib,
    steam-run-free,
    stdenv,
    makeWrapper,
    makeDesktopItem,
    copyDesktopItems,

    unzip,
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
        copyDesktopItems
    ];

    buildInputs = [
        glib
        webkitgtk_4_1
        gtk3
        glib-networking
        gnutls
    ];

    src = builtins.fetchurl details.download_url.linux.amd64;
    icons = ./icons;

    unpackPhase = ''
        mkdir -p $PWD/src
        unzip $src -d $PWD/src
    '';

    installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mkdir -p $out/resources
        mkdir -p $out/share

        cp -r $icons $out/share/icons

        # copy the main binary
        cp $PWD/src/hytale-launcher $out/resources/hytale-launcher
        chmod +x $out/resources/hytale-launcher

        # write the wrapper script 
        cat << EOF > $out/bin/hytale-launcher 
        #!/usr/bin/env bash 
        # Launcher fixes
        export WEBKIT_DISABLE_DMABUF_RENDERER='1'
        export WEBKIT_DISABLE_COMPOSITING_MODE='1'
        export DESKTOP_STARTUP_ID='com.hypixel.HytaleLauncher'
        # Launcher Runtime Directory
        export LAUNCHER_DIR=\$XDG_DATA_HOME/Hytale/install/release/package/launcher/current
        export LAUNCHER=\$LAUNCHER_DIR/hytale-launcher
        export LD_LIBRARY_PATH="${webkitgtk_4_1}/lib:\$LD_LIBRARY_PATH"
        mkdir -p \$LAUNCHER_DIR
        # Copy file to user home directory if it does not yet exist 
        if [ ! -f \$LAUNCHER ]; then 
            echo "Copying launcher to user directory..."
            cp $out/resources/hytale-launcher \$LAUNCHER
            echo "Done. Launcher copied to \$LAUNCHER"
        fi
        cd \$LAUNCHER_DIR
        exec ${steam-run-free}/bin/steam-run "./hytale-launcher" "\$@"
        EOF

        chmod +x $out/bin/hytale-launcher
        runHook postInstall
    '';

    desktopItems = [
        (makeDesktopItem {
            name = "Hytale Launcher";
            exec = "hytale-launcher";
            icon = "hytale-launcher";
            desktopName = "Hytale Launcher";
            comment = "Official Hytale launcher by Hypixel Studios";
            categories = ["Game"];
        })
    ];

    meta = with lib; {
        description = "Hytale Launcher";
        homepage    = "https://hytale.com";
        license     = licenses.unfree;

        maintainers = with maintainers; [ akeuben ];
        platforms   = platforms.linux;
        mainProgram = "hytale-launcher";
    };
}
