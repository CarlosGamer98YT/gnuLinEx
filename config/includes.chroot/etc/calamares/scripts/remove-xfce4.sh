#!/bin/bash
# Comprueba si se ha instalado un entorno diferente a XFCE o si es modo servidor (sin DE)
# Si es así, elimina XFCE4 que viene preinstalado en el LiveCD de forma limpia y segura.

export DEBIAN_FRONTEND=noninteractive

is_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# Verificar si XFCE4 está presente
if ! is_installed xfce4 && [ ! -f /usr/bin/startxfce4 ]; then
    echo "[remove-xfce4] XFCE4 no está instalado, nada que hacer."
    exit 0
fi

# Detectar si se eligió otro entorno o modo servidor
OTRO_ENTORNO=false

if is_installed hyprland || [ -f /usr/bin/Hyprland ] || [ -f /usr/bin/hyprland ] || \
   is_installed sway || [ -f /usr/bin/sway ] || \
   is_installed gnome-core || is_installed gnome-shell || [ -f /usr/bin/gnome-shell ] || \
   is_installed kde-plasma-desktop || is_installed plasma-desktop || [ -f /usr/bin/plasmashell ] || \
   is_installed cinnamon-core || is_installed cinnamon || [ -f /usr/bin/cinnamon ] || \
   is_installed mate-desktop-environment || [ -f /usr/bin/mate-session ] || \
   is_installed lxqt || [ -f /usr/bin/startlxqt ] || \
   is_installed lxde || [ -f /usr/bin/startlxde ] || \
   is_installed budgie-desktop || [ -f /usr/bin/budgie-desktop ] || \
   is_installed enlightenment || [ -f /usr/bin/enlightenment_start ] || \
   is_installed tmux || is_installed ufw; then
    OTRO_ENTORNO=true
fi

if [ "$OTRO_ENTORNO" = true ]; then
    echo "[remove-xfce4] Se detectó otro entorno. Eliminando XFCE4..."

    # Proteger paquetes compartidos esenciales que pueden ser usados por otros entornos (ej. Thunar en Hyprland)
    if [ -f /usr/bin/thunar ]; then
        apt-mark manual thunar thunar-data 2>/dev/null || true
    fi

    # Eliminar explícitamente el núcleo de XFCE4 sin tocar librerías compartidas necesarias
    XFCE_PKGS="xfce4 xfce4-session xfdesktop4 xfwm4 xfce4-panel xfce4-settings xfce4-appfinder xfce4-goodies"
    apt-get purge -y $XFCE_PKGS 2>&1 || true

    # Eliminar archivos .desktop de sesión de XFCE para que ningún display manager los vuelva a listar
    rm -f /usr/share/xsessions/xfce.desktop /usr/share/wayland-sessions/xfce-wayland.desktop

    # Si se instaló SDDM o GDM3, eliminar LightDM
    if is_installed sddm || is_installed gdm3 || is_installed gdm; then
        systemctl disable lightdm 2>/dev/null || true
        apt-get purge -y lightdm lightdm-gtk-greeter 2>&1 || true
        rm -rf /etc/lightdm
    fi

    # Limpiar paquetes huérfanos de XFCE4 de forma desatendida
    apt-get autoremove -y --purge
    echo "[remove-xfce4] XFCE4 eliminado con éxito."
else
    echo "[remove-xfce4] XFCE4 es el entorno seleccionado o predeterminado. Conservando."
fi

