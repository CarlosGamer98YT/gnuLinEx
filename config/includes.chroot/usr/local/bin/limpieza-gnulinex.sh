#!/bin/bash
# /usr/local/bin/limpieza-gnulinex.sh
# Script de limpieza y post-instalación de gnuLinEx

export DEBIAN_FRONTEND=noninteractive

LOGFILE="/var/log/limpieza-gnulinex.log"
mkdir -p /var/log
exec > >(tee -a "$LOGFILE") 2>&1

echo "===================================================================="
echo "Iniciando limpieza y configuración de gnuLinEx: $(date)"
echo "===================================================================="

# Función auxiliar para comprobar paquetes instalados
is_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# 1. Borrar las herramientas exclusivas del LiveCD y limpiar accesos directos
echo "[1/6] Eliminando paquetes exclusivos del entorno Live..."
apt-get purge -y calamares calamares-settings-debian live-boot live-boot-doc live-config live-config-systemd live-tools || true
userdel -r user 2>/dev/null || true
rm -f /etc/lightdm/lightdm.conf.d/01_autologin.conf

# Eliminar el icono de instalación de los escritorios de los usuarios y de la plantilla skel
rm -f /home/*/{Escritorio,Desktop}/instalar.desktop 2>/dev/null || true
rm -f /etc/skel/{Escritorio,Desktop}/instalar.desktop 2>/dev/null || true

# 2. Detectar entorno y definir su gestor de sesión
echo "[2/6] Detectando entorno de escritorio instalado..."
if is_installed hyprland || [ -f /usr/bin/Hyprland ] || [ -f /usr/bin/hyprland ]; then
    SABOR="hyprland"
    GESTOR="sddm"
    SESSION="hyprland"
elif is_installed sway || [ -f /usr/bin/sway ]; then
    SABOR="sway"
    GESTOR="sddm"
    SESSION="sway"
elif is_installed gnome-core || is_installed gnome-shell || [ -f /usr/bin/gnome-shell ]; then
    SABOR="gnome"
    GESTOR="gdm3"
    SESSION="gnome"
elif is_installed kde-plasma-desktop || is_installed plasma-desktop || [ -f /usr/bin/plasmashell ]; then
    SABOR="kde"
    GESTOR="sddm"
    SESSION="plasma"
elif is_installed cinnamon-core || is_installed cinnamon || [ -f /usr/bin/cinnamon ]; then
    SABOR="cinnamon"
    GESTOR="lightdm"
    SESSION="cinnamon"
elif is_installed mate-desktop-environment || [ -f /usr/bin/mate-session ]; then
    SABOR="mate"
    GESTOR="lightdm"
    SESSION="mate"
elif is_installed lxqt || [ -f /usr/bin/startlxqt ]; then
    SABOR="lxqt"
    GESTOR="sddm"
    SESSION="lxqt"
elif is_installed lxde || [ -f /usr/bin/startlxde ]; then
    SABOR="lxde"
    GESTOR="lightdm"
    SESSION="LXDE"
elif is_installed budgie-desktop || [ -f /usr/bin/budgie-desktop ]; then
    SABOR="budgie"
    GESTOR="lightdm"
    SESSION="budgie-desktop"
elif is_installed enlightenment || [ -f /usr/bin/enlightenment_start ]; then
    SABOR="enlightenment"
    GESTOR="lightdm"
    SESSION="enlightenment"
elif is_installed tmux || is_installed ufw; then
    SABOR="servidor"
    GESTOR=""
    SESSION=""
elif is_installed xfce4 || [ -f /usr/bin/xfce4-session ]; then
    SABOR="xfce"
    GESTOR="lightdm"
    SESSION="xfce"
else
    # Fallback si no se detecta nada gráfico
    SABOR="servidor"
    GESTOR=""
    SESSION=""
fi

echo "Sabor detectado: $SABOR | Gestor de sesión: $GESTOR | Sesión: $SESSION"

# 3. Blindar paquetes críticos del entorno elegido antes de eliminar o autoremove
echo "[3/6] Marcando paquetes del entorno seleccionado como manuales..."
case "$SABOR" in
    hyprland)
        apt-mark manual hyprland hyprland-guiutils sddm xwayland waybar kitty wofi hyprpaper swaybg mako-notifier \
            wlogout swaylock swayidle brightnessctl playerctl blueman bluez \
            thunar thunar-volman tumbler gvfs gvfs-backends \
            fonts-font-awesome fonts-inter fonts-jetbrains-mono papirus-icon-theme bibata-cursor-theme \
            starship libnotify-bin pavucontrol network-manager-gnome mate-polkit grim slurp \
            xdg-desktop-portal-hyprland xdg-desktop-portal-gtk pipewire pipewire-pulse wireplumber || true
        ;;
    sway)
        apt-mark manual sway sddm xwayland waybar kitty wofi || true
        ;;
    gnome)
        apt-mark manual gnome-core gnome-shell gdm3 || true
        ;;
    kde)
        apt-mark manual kde-plasma-desktop plasma-desktop plasma-workspace sddm || true
        ;;
    cinnamon)
        apt-mark manual cinnamon cinnamon-core task-cinnamon-desktop lightdm || true
        ;;
    mate)
        apt-mark manual mate-desktop-environment mate-desktop-environment-extras lightdm || true
        ;;
    lxqt)
        apt-mark manual lxqt sddm || true
        ;;
    lxde)
        apt-mark manual lxde lightdm || true
        ;;
    budgie)
        apt-mark manual budgie-desktop lightdm || true
        ;;
    enlightenment)
        apt-mark manual enlightenment terminology lightdm || true
        ;;
    xfce)
        apt-mark manual xfce4 xfce4-goodies lightdm || true
        ;;
    servidor)
        apt-mark manual openssh-server sudo tmux ufw || true
        ;;
esac

# 4. Eliminar XFCE4 y otros entornos no correspondientes
echo "[4/6] Eliminando entornos no elegidos..."

# Si el sabor NO es xfce, eliminar XFCE4 por completo
if [ "$SABOR" != "xfce" ]; then
    echo "Eliminando XFCE4 preinstalado..."
    if [ -x /etc/calamares/scripts/remove-xfce4.sh ]; then
        /etc/calamares/scripts/remove-xfce4.sh
    else
        apt-get purge -y xfce4 xfce4-session xfdesktop4 xfwm4 xfce4-panel xfce4-settings xfce4-appfinder xfce4-goodies || true
        rm -f /usr/share/xsessions/xfce.desktop /usr/share/wayland-sessions/xfce-wayland.desktop
    fi
fi

# Eliminar otros entornos que no correspondan
PKGS_TO_PURGE=""
[ "$SABOR" != "cinnamon" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE cinnamon cinnamon-core task-cinnamon-desktop"
[ "$SABOR" != "gnome" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE gnome-core gnome-shell"
[ "$SABOR" != "kde" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE kde-plasma-desktop plasma-desktop plasma-workspace"
[ "$SABOR" != "mate" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE mate-desktop-environment mate-desktop-environment-extras"
[ "$SABOR" != "lxqt" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE lxqt"
[ "$SABOR" != "lxde" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE lxde"
[ "$SABOR" != "budgie" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE budgie-desktop"
[ "$SABOR" != "enlightenment" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE enlightenment terminology"
[ "$SABOR" != "hyprland" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE hyprland"
[ "$SABOR" != "sway" ] && PKGS_TO_PURGE="$PKGS_TO_PURGE sway"

# Eliminar Xorg SOLAMENTE en modo servidor (en Wayland como Hyprland/Sway se necesita para XWayland y SDDM)
if [ "$SABOR" = "servidor" ]; then
    PKGS_TO_PURGE="$PKGS_TO_PURGE xorg xserver-xorg xserver-xorg-video-all xserver-xorg-input-all"
fi

# Gestores de pantalla no usados
if [ "$GESTOR" != "lightdm" ]; then
    systemctl disable lightdm 2>/dev/null || true
    PKGS_TO_PURGE="$PKGS_TO_PURGE lightdm lightdm-gtk-greeter"
    rm -rf /etc/lightdm
fi

if [ "$GESTOR" != "sddm" ]; then
    systemctl disable sddm 2>/dev/null || true
    PKGS_TO_PURGE="$PKGS_TO_PURGE sddm"
    rm -rf /etc/sddm.conf /etc/sddm.conf.d
fi

if [ "$GESTOR" != "gdm3" ]; then
    systemctl disable gdm3 2>/dev/null || true
    PKGS_TO_PURGE="$PKGS_TO_PURGE gdm3"
fi

for pkg in $PKGS_TO_PURGE; do
    if is_installed "$pkg"; then
        apt-get purge -y "$pkg" || true
    fi
done

# Autoremove para paquetes huérfanos
apt-get autoremove -y --purge || true

# 5. Configurar el gestor de sesión o modo servidor
echo "[5/6] Configurando gestor de inicio y sesión predeterminada..."
if [ "$SABOR" = "servidor" ]; then
    systemctl disable lightdm sddm gdm3 2>/dev/null || true
    systemctl set-default multi-user.target
else
    echo "${GESTOR} shared/default-x-display-manager select ${GESTOR}" | debconf-set-selections
    dpkg-reconfigure -f noninteractive ${GESTOR} 2>/dev/null || true

    mkdir -p /etc/X11
    echo "/usr/sbin/${GESTOR}" > /etc/X11/default-display-manager

    # Configuración explícita de la sesión en el gestor
    if [ "$GESTOR" = "sddm" ] && [ -n "$SESSION" ]; then
        mkdir -p /etc/sddm.conf.d
        cat <<EOF > /etc/sddm.conf.d/10-session.conf
[Autologin]
Session=${SESSION}

[Last]
Session=${SESSION}
EOF
    elif [ "$GESTOR" = "lightdm" ] && [ -n "$SESSION" ]; then
        if [ -f /etc/lightdm/lightdm.conf ]; then
            sed -i -e "s/^.*user-session=.*/user-session=${SESSION}/" /etc/lightdm/lightdm.conf
        fi
    fi

    systemctl enable ${GESTOR}.service -f || true
    systemctl set-default graphical.target
fi

# 6. Información de la distribución y Flatpak
echo "[6/6] Configurando /etc/os-release y repositorios..."
cat <<EOF > /etc/os-release
PRETTY_NAME="gnuLinEx (Grulla)"
NAME="gnuLinEx"
VERSION_ID="1"
VERSION="1 (Grulla)"
VERSION_CODENAME=grulla
DEBIAN_VERSION_FULL=13.4
ID=gnuLinEx
HOME_URL="https://gnulinex.vercel.app"
SUPPORT_URL=""
BUG_REPORT_URL=""
EOF

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

echo "===================================================================="
echo "Limpieza completada con éxito: $(date)"
echo "===================================================================="