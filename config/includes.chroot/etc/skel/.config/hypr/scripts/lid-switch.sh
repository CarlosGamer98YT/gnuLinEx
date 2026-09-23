#!/bin/bash
# /etc/skel/.config/hypr/scripts/lid-switch.sh
# Manejador inteligente del cierre de tapa (Lid Switch) en portátiles para gnuLinEx

ACTION="$1"

# Detectar el nombre del monitor interno del portátil (normalmente eDP-1, eDP-2, etc.)
INTERNAL_MONITOR=$(hyprctl monitors all -j 2>/dev/null | grep -o '"name": *"eDP-[^"]*"' | head -n1 | cut -d'"' -f4)
if [ -z "$INTERNAL_MONITOR" ]; then
    INTERNAL_MONITOR="eDP-1"
fi

# Contar cuántos monitores hay conectados actualmente
MONITOR_COUNT=$(hyprctl monitors -j 2>/dev/null | grep -c '"id":' || echo 1)

case "$ACTION" in
    close)
        if [ "$MONITOR_COUNT" -gt 1 ]; then
            # Si hay monitor externo conectado, simplemente apagamos la pantalla interna
            hyprctl keyword monitor "${INTERNAL_MONITOR}, disable"
        else
            # Si es la única pantalla, bloquear y suspender el sistema
            if command -v gnulinex-lock >/dev/null 2>&1; then
                gnulinex-lock &
            fi
            sleep 0.5
            systemctl suspend
        fi
        ;;
    open)
        # Al abrir la tapa, reactivamos la pantalla del portátil en su resolución nativa
        hyprctl keyword monitor "${INTERNAL_MONITOR}, preferred, auto, 1"
        ;;
    *)
        echo "Uso: $0 {close|open}"
        exit 1
        ;;
esac
