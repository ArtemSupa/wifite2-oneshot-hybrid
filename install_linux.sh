#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  INSTALADOR HÍBRIDO WIFITE + ONESHOT${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Por favor ejecuta como root: sudo ./install_linux.sh${NC}"
    exit 1
fi

# Verificar que estamos en el directorio correcto
if [ ! -d "wifite2" ] || [ ! -d "OneShot" ]; then
    echo -e "${RED}[!] Error: No se encuentran los directorios wifite2 y OneShot${NC}"
    echo -e "${YELLOW}    Asegúrate de ejecutar este script desde la carpeta del híbrido${NC}"
    exit 1
fi

# Directorio de instalación
INSTALL_DIR="/opt/wifite-hybrid"

echo -e "${YELLOW}[1/7]${NC} Instalando dependencias del sistema..."
apt update > /dev/null 2>&1
apt install -y python3 python3-pip aircrack-ng reaver pixiewps wpasupplicant wireless-tools net-tools bc > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}      ✓ Dependencias instaladas${NC}"
else
    echo -e "${RED}      ✗ Error al instalar dependencias${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[2/7]${NC} Verificando Python 3.8+..."
PYTHON_VERSION=$(python3 --version | grep -oP '(?<=Python )\d+\.\d+' | head -1)
if [ -n "$PYTHON_VERSION" ]; then
    MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

    if [ "$MAJOR" -ge 3 ] && [ "$MINOR" -ge 8 ]; then
        echo -e "${GREEN}      ✓ Python $PYTHON_VERSION detectado${NC}"
    else
        echo -e "${RED}      ✗ Python $PYTHON_VERSION es menor que 3.8${NC}"
        echo -e "${YELLOW}        Continuando de todos modos...${NC}"
    fi
else
    echo -e "${RED}      ✗ No se pudo detectar la versión de Python${NC}"
fi

echo ""
echo -e "${YELLOW}[3/7]${NC} Copiando archivos a $INSTALL_DIR..."
mkdir -p $INSTALL_DIR

# Copiar archivos
cp -r wifite2 $INSTALL_DIR/
cp -r OneShot $INSTALL_DIR/

# Copiar documentación si existe
for file in README_HYBRID.md RESUMEN_FINAL.md QUICK_START.md LINUX_SETUP.md STATUS.txt; do
    if [ -f "$file" ]; then
        cp "$file" $INSTALL_DIR/
    fi
done

# Copiar scripts de verificación
for file in verify_hybrid.py test_integration.py test_oneshot_path.py; do
    if [ -f "$file" ]; then
        cp "$file" $INSTALL_DIR/
    fi
done

echo -e "${GREEN}      ✓ Archivos copiados${NC}"

echo ""
echo -e "${YELLOW}[4/7]${NC} Configurando permisos..."
chmod +x $INSTALL_DIR/wifite2/wifite.py
chmod +x $INSTALL_DIR/OneShot/oneshot.py

if [ -f "$INSTALL_DIR/verify_hybrid.py" ]; then
    chmod +x $INSTALL_DIR/verify_hybrid.py
fi

echo -e "${GREEN}      ✓ Permisos configurados${NC}"

echo ""
echo -e "${YELLOW}[5/7]${NC} Instalando dependencias Python de wifite..."
cd $INSTALL_DIR/wifite2

# Instalar desde requirements.txt si existe
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt > /dev/null 2>&1
fi

# Instalar wifite en modo desarrollo
python3 setup.py install > /dev/null 2>&1

echo -e "${GREEN}      ✓ Dependencias Python instaladas${NC}"

echo ""
echo -e "${YELLOW}[6/7]${NC} Creando comando 'wifite-hybrid'..."

# Crear wrapper script
cat > /usr/local/bin/wifite-hybrid <<'WRAPPER_EOF'
#!/bin/bash
cd /opt/wifite-hybrid/wifite2
exec python3 wifite.py "$@"
WRAPPER_EOF

chmod +x /usr/local/bin/wifite-hybrid

echo -e "${GREEN}      ✓ Comando creado en /usr/local/bin/wifite-hybrid${NC}"

echo ""
echo -e "${YELLOW}[7/7]${NC} Verificando instalación..."

cd $INSTALL_DIR
if [ -f "verify_hybrid.py" ]; then
    python3 verify_hybrid.py 2>&1 | grep -q "TODAS LAS VERIFICACIONES PASARON"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}      ✓ Verificación exitosa${NC}"
    else
        echo -e "${YELLOW}      ⚠ Advertencia: Algunas verificaciones fallaron${NC}"
        echo -e "${YELLOW}        Ejecuta: cd $INSTALL_DIR && python3 verify_hybrid.py${NC}"
    fi
else
    echo -e "${YELLOW}      ⚠ Script de verificación no encontrado${NC}"
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✓ INSTALACIÓN COMPLETADA${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${BLUE}Comandos disponibles:${NC}"
echo -e "  ${GREEN}wifite-hybrid${NC}        → Wifite con integración OneShot (tu versión modificada)"
echo -e "  ${GREEN}wifite${NC}               → Wifite original de Kali (si está instalado)"
echo ""
echo -e "${BLUE}Ejemplo de uso:${NC}"
echo -e "  ${YELLOW}sudo airmon-ng start wlan0${NC}"
echo -e "  ${YELLOW}sudo wifite-hybrid -i wlan0mon --wps${NC}"
echo ""
echo -e "${BLUE}Uso con opciones:${NC}"
echo -e "  ${YELLOW}sudo wifite-hybrid -i wlan0mon --wps -v${NC}           (modo verbose)"
echo -e "  ${YELLOW}sudo wifite-hybrid -i wlan0mon --wps-ignore-lock${NC}  (ignorar APs bloqueados)"
echo -e "  ${YELLOW}sudo wifite-hybrid -i wlan0mon -b AA:BB:CC:DD:EE:FF${NC}  (atacar BSSID específico)"
echo ""
echo -e "${BLUE}Archivos instalados en:${NC} ${GREEN}$INSTALL_DIR${NC}"
echo ""
echo -e "${BLUE}Documentación:${NC}"
echo -e "  ${GREEN}cat $INSTALL_DIR/LINUX_SETUP.md${NC}      (guía completa Linux)"
echo -e "  ${GREEN}cat $INSTALL_DIR/README_HYBRID.md${NC}    (documentación del híbrido)"
echo -e "  ${GREEN}cat $INSTALL_DIR/QUICK_START.md${NC}      (guía rápida)"
echo ""
echo -e "${BLUE}Verificar instalación:${NC}"
echo -e "  ${GREEN}cd $INSTALL_DIR && python3 verify_hybrid.py${NC}"
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ¡Listo para usar! Happy Hacking! 🚀${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Volver al directorio original
cd - > /dev/null 2>&1
