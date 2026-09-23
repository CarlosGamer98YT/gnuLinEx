#!/bin/bash -i
VERSION=$(cat version.txt)
ARCHIVO_CAMBIOS="cambios.txt" # Define aquí el nombre de tu archivo de cambios

set -e

if ! command -v lb >/dev/null 2>&1; then
    echo "Error: live-build no está instalado. Ejecuta 'sudo apt install live-build' primero."
    exit 1
fi

echo "Limpiamos la carpeta y la caché en caso de que al terminar no se hizo"
sudo lb clean
sudo lb clean --cache

echo "Compilamos la ISO"
sudo lb config --distribution trixie --binary-images iso-hybrid --architectures amd64 --archive-areas "main contrib non-free non-free-firmware" --debootstrap-options "--include=ca-certificates,apt-transport-https" --image-name gnuLinEx-amd64-netinst

echo "Compilamos la ISO (Puede tardar un rato)"
sudo lb build

echo "Cambiamos los permisos para que puedas ejecutar la ISO"
sudo chmod 777 *.iso

echo "Copiamos el iso a Ventoy..."
xcp --fsync -r gnuLinEx*.iso /media/carlos/Ventoy/

echo "Enhorabuena, has compilado la version $VERSION"

# Bucle para preguntar al usuario
while true; do
    read -p "¿Quieres ver los cambios de la version $VERSION? (s/n): " sn
    case $sn in
        [Ss]* )
            if [ -f "$ARCHIVO_CAMBIOS" ]; then
                echo -e "\n--- Cambios de la versión $VERSION ---"
                # Extrae el texto desde [VERSION] hasta la siguiente etiqueta de versión
                sed -n "/^\[$VERSION\]/,/^\[/ { /^\[$VERSION\]/p; /^\[/!p }" "$ARCHIVO_CAMBIOS"
                echo "--------------------------------------"
            else
                echo "Archivo de cambios '$ARCHIVO_CAMBIOS' no encontrado."
            fi
            break;;
        [Nn]* )
            break;;
        * )
            echo "Por favor, responde 's' para sí o 'n' para no.";;
    esac
done
