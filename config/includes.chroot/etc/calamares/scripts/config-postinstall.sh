#!/bin/bash

#/etc/calamares/scripts/config-postinstall.sh

# 1. Repositorio Flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. Asegurar fondo predeterminado corporativo (default.png)
mkdir -p /usr/share/backgrounds
if [ -f /usr/share/backgrounds/default.png ]; then
    ln -sf /usr/share/backgrounds/default.png /etc/alternatives/desktop-background 2>/dev/null || true
fi

# 3. Base Debian (cubre XFCE, LXDE, LightDM y Enlightenment)
ln -sf /usr/share/backgrounds/default.png /etc/alternatives/desktop-background

# 4. Cinnamon, Budgie y MATE (Sobrescritura de dconf/gsettings)
cat <<EOF > /usr/share/glib-2.0/schemas/99-custom-wallpaper.gschema.override
[org.gnome.desktop.background]
picture-uri="file:///usr/share/backgrounds/default.png"
picture-uri-dark="file:///usr/share/backgrounds/default.png"
[org.cinnamon.desktop.background]
picture-uri="file:///usr/share/backgrounds/default.png"
[org.mate.background]
picture-filename="/usr/share/backgrounds/default.png"
EOF
glib-compile-schemas /usr/share/glib-2.0/schemas/

# 5. Hyprland y Fondo de Pantalla (Esqueleto y Usuarios)
mkdir -p /etc/skel/.config/hypr /etc/skel/.config/backgrounds /etc/skel/Imágenes
if [ -f /usr/share/backgrounds/default.png ]; then
    cp -p /usr/share/backgrounds/default.png /etc/skel/.config/hypr/default.png
    cp -p /usr/share/backgrounds/default.png /etc/skel/.config/backgrounds/default.png
    cp -p /usr/share/backgrounds/default.png /etc/skel/Imágenes/default.png
fi

cat <<EOF > /etc/skel/.config/hypr/hyprpaper.conf
# Configuración de Hyprpaper - gnuLinEx (Grulla)
splash = false
splash_offset = 20
splash_opacity = 0.0
ipc = true

wallpaper {
    monitor =
    path = ~/.config/hypr/default.png
    fit_mode = cover
}

wallpaper {
    monitor =
    path = /usr/share/backgrounds/default.png
    fit_mode = cover
}
EOF

# Permisos de ejecución para scripts de sistema gnuLinEx
chmod +x /usr/local/bin/gnulinex-* 2>/dev/null || true
chmod +x /etc/skel/.config/hypr/scripts/* 2>/dev/null || true

# Sincronizar configuraciones completas y fondo oficial a todos los usuarios creados
for user_dir in /home/*; do
    if [ -d "$user_dir" ] && [ "$(basename "$user_dir")" != "user" ]; then
        user_name="$(basename "$user_dir")"
        mkdir -p "$user_dir/.config/hypr" "$user_dir/.config/backgrounds" "$user_dir/Imágenes"
        if [ -f /usr/share/backgrounds/default.png ]; then
            cp -p /usr/share/backgrounds/default.png "$user_dir/.config/hypr/default.png"
            cp -p /usr/share/backgrounds/default.png "$user_dir/.config/backgrounds/default.png"
            cp -p /usr/share/backgrounds/default.png "$user_dir/Imágenes/default.png"
        fi
        cp -rf /etc/skel/.config/* "$user_dir/.config/" 2>/dev/null || true
        [ -f /etc/skel/.bashrc ] && cp -f /etc/skel/.bashrc "$user_dir/.bashrc"
        chmod +x "$user_dir/.config/hypr/scripts/"* 2>/dev/null || true
        chown -R "$user_name":"$user_name" "$user_dir" 2>/dev/null || true
    fi
done

# 6. LXQt (Plantilla)
mkdir -p /etc/skel/.config/pcmanfm-qt/lxqt
cat <<EOF > /etc/skel/.config/pcmanfm-qt/lxqt/settings.conf
[Desktop]
Wallpaper=/usr/share/backgrounds/default.png
EOF

# 7. KDE Plasma 6 (Plantilla global)
mkdir -p /etc/skel/.config
cat <<EOF >> /etc/skel/.config/kdeglobals
[DesktopIcons]
Wallpaper=/usr/share/backgrounds/default.png
EOF
