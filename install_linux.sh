#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  INSTALADOR WIFITE2-ONESHOT-HYBRID${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Por favor ejecuta como root: sudo ./install_linux.sh${NC}"
    exit 1
fi

# Obtener el directorio actual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Verificar que estamos en el directorio correcto
if [ ! -d "wifite" ] || [ ! -f "wifite.py" ]; then
    echo -e "${RED}[!] Error: No se encuentra la estructura correcta del proyecto${NC}"
    echo -e "${YELLOW}    Asegúrate de ejecutar este script desde la raíz del repositorio${NC}"
    echo -e "${YELLOW}    Debe existir: wifite/ y wifite.py${NC}"
    exit 1
fi

echo -e "${GREEN}[✓] Directorio correcto detectado${NC}"
echo ""

# Verificar que OneShot esté inicializado
if [ ! -d "OneShot" ] || [ ! -f "OneShot/oneshot.py" ]; then
    echo -e "${YELLOW}[!] OneShot no está inicializado. Inicializando submódulo...${NC}"
    git submodule update --init --recursive
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Error al inicializar OneShot${NC}"
        exit 1
    fi
    echo -e "${GREEN}[✓] OneShot inicializado${NC}"
fi

echo ""
echo -e "${YELLOW}[1/6]${NC} Actualizando repositorios..."
apt update
if [ $? -eq 0 ]; then
    echo -e "${GREEN}      ✓ Repositorios actualizados${NC}"
else
    echo -e "${RED}      ✗ Error al actualizar repositorios${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[2/6]${NC} Instalando dependencias del sistema..."
echo -e "${BLUE}      Esto puede tardar varios minutos...${NC}"
apt install -y python3 python3-pip aircrack-ng reaver pixiewps wpasupplicant wireless-tools net-tools bc
if [ $? -eq 0 ]; then
    echo -e "${GREEN}      ✓ Dependencias del sistema instaladas${NC}"
else
    echo -e "${RED}      ✗ Error al instalar dependencias${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[3/6]${NC} Verificando Python 3.8+..."
PYTHON_VERSION=$(python3 --version | grep -oP '(?<=Python )\d+\.\d+' | head -1)
if [ -n "$PYTHON_VERSION" ]; then
    MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

    if [ "$MAJOR" -ge 3 ] && [ "$MINOR" -ge 8 ]; then
        echo -e "${GREEN}      ✓ Python $PYTHON_VERSION detectado${NC}"
    else
        echo -e "${YELLOW}      ⚠ Python $PYTHON_VERSION detectado (recomendado 3.8+)${NC}"
    fi
else
    echo -e "${RED}      ✗ No se pudo detectar la versión de Python${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[4/6]${NC} Instalando dependencias Python..."
if [ -f "requirements.txt" ]; then
    echo -e "${BLUE}      Instalando desde requirements.txt...${NC}"
    pip3 install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}      ⚠ Algunas dependencias pueden haber fallado${NC}"
    fi
else
    echo -e "${YELLOW}      ⚠ requirements.txt no encontrado${NC}"
fi

echo ""
echo -e "${YELLOW}[5/6]${NC} Instalando Wifite2-OneShot-Hybrid..."
python3 setup.py install
if [ $? -eq 0 ]; then
    echo -e "${GREEN}      ✓ Wifite2-OneShot-Hybrid instalado${NC}"
else
    echo -e "${RED}      ✗ Error en la instalación${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[6/6]${NC} Configurando permisos y enlaces simbólicos..."

# Hacer ejecutable OneShot
if [ -f "OneShot/oneshot.py" ]; then
    chmod +x OneShot/oneshot.py

    # Crear enlace simbólico para OneShot (opcional)
    if [ ! -f "/usr/local/bin/oneshot" ]; then
        ln -s "$SCRIPT_DIR/OneShot/oneshot.py" /usr/local/bin/oneshot 2>/dev/null || true
    fi
fi

# Hacer ejecutable verify_hybrid.py
if [ -f "verify_hybrid.py" ]; then
    chmod +x verify_hybrid.py
fi

echo -e "${GREEN}      ✓ Permisos configurados${NC}"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✓ INSTALACIÓN COMPLETADA${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Verificar instalación
echo -e "${BLUE}Verificando instalación...${NC}"
echo ""

if command -v wifite &> /dev/null; then
    WIFITE_VERSION=$(wifite --version 2>&1 | head -1)
    echo -e "${GREEN}[✓] Wifite instalado: ${WIFITE_VERSION}${NC}"
else
    echo -e "${RED}[✗] Wifite no encontrado en PATH${NC}"
fi

if [ -f "OneShot/oneshot.py" ]; then
    echo -e "${GREEN}[✓] OneShot disponible en: $SCRIPT_DIR/OneShot/oneshot.py${NC}"
else
    echo -e "${RED}[✗] OneShot no encontrado${NC}"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  COMANDOS DISPONIBLES${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}Wifite (versión híbrida con OneShot):${NC}"
echo -e "  ${YELLOW}sudo wifite -i wlan0mon --wps${NC}"
echo ""
echo -e "${GREEN}OneShot (directo):${NC}"
echo -e "  ${YELLOW}sudo $SCRIPT_DIR/OneShot/oneshot.py -i wlan0mon${NC}"
if command -v oneshot &> /dev/null; then
    echo -e "  ${YELLOW}sudo oneshot -i wlan0mon${NC}  ${BLUE}(atajo)${NC}"
fi
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  PASOS SIGUIENTES${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "1. Poner interfaz en modo monitor:"
echo -e "   ${YELLOW}sudo airmon-ng start wlan0${NC}"
echo ""
echo -e "2. Ejecutar Wifite:"
echo -e "   ${YELLOW}sudo wifite -i wlan0mon --wps -v${NC}"
echo ""
echo -e "3. Verificar integración híbrida:"
echo -e "   ${YELLOW}python3 $SCRIPT_DIR/verify_hybrid.py${NC}"
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  DOCUMENTACIÓN${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "README:           ${GREEN}cat $SCRIPT_DIR/README.md${NC}"
echo -e "Créditos:         ${GREEN}cat $SCRIPT_DIR/CREDITS.md${NC}"

if [ -d "docs/hybrid" ]; then
    echo -e "Docs híbrido:     ${GREEN}ls $SCRIPT_DIR/docs/hybrid/${NC}"
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ¡Listo para usar! Happy Hacking! 🚀${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
