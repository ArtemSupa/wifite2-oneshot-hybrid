#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  INSTALADOR WIFITE2-ONESHOT-HYBRID${NC}"
echo -e "${BLUE}  (Instalación paralela - no sobrescribe Wifite)${NC}"
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

# Directorio de instalación (separado de wifite original)
INSTALL_DIR="/opt/wifite-hybrid"

# Verificar que estamos en el directorio correcto
if [ ! -d "wifite" ] || [ ! -f "wifite.py" ]; then
    echo -e "${RED}[!] Error: No se encuentra la estructura correcta del proyecto${NC}"
    echo -e "${YELLOW}    Asegúrate de ejecutar este script desde la raíz del repositorio${NC}"
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
echo -e "${YELLOW}[1/7]${NC} Actualizando repositorios..."
apt update
if [ $? -eq 0 ]; then
    echo -e "${GREEN}      ✓ Repositorios actualizados${NC}"
else
    echo -e "${RED}      ✗ Error al actualizar repositorios${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[2/7]${NC} Instalando dependencias del sistema..."
echo -e "${BLUE}      Esto puede tardar varios minutos...${NC}"
apt install -y python3 python3-pip aircrack-ng reaver pixiewps wpasupplicant wireless-tools net-tools bc
if [ $? -eq 0 ]; then
    echo -e "${GREEN}      ✓ Dependencias del sistema instaladas${NC}"
else
    echo -e "${RED}      ✗ Error al instalar dependencias${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[3/7]${NC} Verificando Python 3.8+..."
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
echo -e "${YELLOW}[4/7]${NC} Copiando archivos a $INSTALL_DIR..."

# Limpiar instalación previa si existe
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${BLUE}      Eliminando instalación previa...${NC}"
    rm -rf "$INSTALL_DIR"
fi

# Crear directorio de instalación
mkdir -p "$INSTALL_DIR"

# Copiar TODO el proyecto a /opt/wifite-hybrid
cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"

# Copiar archivos ocultos también (.gitignore, etc)
cp -r "$SCRIPT_DIR"/.git* "$INSTALL_DIR/" 2>/dev/null || true

echo -e "${GREEN}      ✓ Archivos copiados a $INSTALL_DIR${NC}"

echo ""
echo -e "${YELLOW}[5/7]${NC} Configurando permisos..."

# Hacer ejecutables los scripts principales
chmod +x "$INSTALL_DIR/wifite.py"
chmod +x "$INSTALL_DIR/OneShot/oneshot.py"

if [ -f "$INSTALL_DIR/verify_hybrid.py" ]; then
    chmod +x "$INSTALL_DIR/verify_hybrid.py"
fi

echo -e "${GREEN}      ✓ Permisos configurados${NC}"

echo ""
echo -e "${YELLOW}[6/7]${NC} Instalando dependencias Python..."

cd "$INSTALL_DIR"

if [ -f "requirements.txt" ]; then
    echo -e "${BLUE}      Instalando desde requirements.txt...${NC}"
    pip3 install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}      ⚠ Algunas dependencias pueden haber fallado${NC}"
    fi
else
    echo -e "${YELLOW}      ⚠ requirements.txt no encontrado${NC}"
fi

echo -e "${GREEN}      ✓ Dependencias Python instaladas${NC}"

echo ""
echo -e "${YELLOW}[7/7]${NC} Creando comando 'wifite-hybrid'..."

# Crear wrapper script en /usr/local/bin
cat > /usr/local/bin/wifite-hybrid <<'WRAPPER_EOF'
#!/bin/bash
# Wrapper para Wifite2-OneShot-Hybrid
# Mantiene el wifite original intacto

HYBRID_DIR="/opt/wifite-hybrid"
cd "$HYBRID_DIR"
exec python3 wifite.py "$@"
WRAPPER_EOF

chmod +x /usr/local/bin/wifite-hybrid

echo -e "${GREEN}      ✓ Comando 'wifite-hybrid' creado${NC}"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ✓ INSTALACIÓN COMPLETADA${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Verificar instalación
echo -e "${BLUE}Verificando instalación...${NC}"
echo ""

# Verificar wifite original
if command -v wifite &> /dev/null; then
    WIFITE_ORIGINAL=$(which wifite)
    echo -e "${GREEN}[✓] Wifite ORIGINAL:${NC} $WIFITE_ORIGINAL"
else
    echo -e "${YELLOW}[!] Wifite original no encontrado${NC}"
fi

# Verificar wifite-hybrid
if command -v wifite-hybrid &> /dev/null; then
    WIFITE_HYBRID=$(which wifite-hybrid)
    echo -e "${GREEN}[✓] Wifite HYBRID:${NC} $WIFITE_HYBRID"
else
    echo -e "${RED}[✗] wifite-hybrid no encontrado en PATH${NC}"
fi

# Verificar OneShot
if [ -f "$INSTALL_DIR/OneShot/oneshot.py" ]; then
    echo -e "${GREEN}[✓] OneShot:${NC} $INSTALL_DIR/OneShot/oneshot.py"
else
    echo -e "${RED}[✗] OneShot no encontrado${NC}"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  COMANDOS DISPONIBLES${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${GREEN}Wifite ORIGINAL (sin modificar):${NC}"
echo -e "  ${YELLOW}sudo wifite -i wlan0mon --wps${NC}"
echo ""

echo -e "${GREEN}Wifite HYBRID (con OneShot integrado):${NC}"
echo -e "  ${YELLOW}sudo wifite-hybrid -i wlan0mon --wps${NC}"
echo ""

echo -e "${GREEN}OneShot (directo):${NC}"
echo -e "  ${YELLOW}sudo $INSTALL_DIR/OneShot/oneshot.py -i wlan0mon${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  DIFERENCIAS ENTRE COMANDOS${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${YELLOW}wifite${NC}          → Versión original de Kali (sin modificar)"
echo -e "${YELLOW}wifite-hybrid${NC}   → Versión con OneShot integrado"
echo -e "                    ✓ Detección M6 optimizada"
echo -e "                    ✓ Recuperación automática de PSK"
echo -e "                    ✓ Integración con OneShot"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  PASOS SIGUIENTES${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "1. Poner interfaz en modo monitor:"
echo -e "   ${YELLOW}sudo airmon-ng start wlan0${NC}"
echo ""

echo -e "2. Usar la versión que prefieras:"
echo -e ""
echo -e "   ${GREEN}Versión ORIGINAL:${NC}"
echo -e "   ${YELLOW}sudo wifite -i wlan0mon --wps${NC}"
echo -e ""
echo -e "   ${GREEN}Versión HYBRID (recomendada):${NC}"
echo -e "   ${YELLOW}sudo wifite-hybrid -i wlan0mon --wps -v${NC}"
echo ""

echo -e "3. Verificar integración híbrida:"
echo -e "   ${YELLOW}cd $INSTALL_DIR && python3 verify_hybrid.py${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  UBICACIONES${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "Wifite Original:  ${GREEN}$(which wifite 2>/dev/null || echo 'No instalado')${NC}"
echo -e "Wifite Hybrid:    ${GREEN}$INSTALL_DIR${NC}"
echo -e "Comando Hybrid:   ${GREEN}/usr/local/bin/wifite-hybrid${NC}"
echo -e "OneShot:          ${GREEN}$INSTALL_DIR/OneShot/oneshot.py${NC}"
echo ""

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  DOCUMENTACIÓN${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "README:           ${GREEN}cat $INSTALL_DIR/README.md${NC}"
echo -e "Créditos:         ${GREEN}cat $INSTALL_DIR/CREDITS.md${NC}"

if [ -d "$INSTALL_DIR/docs/hybrid" ]; then
    echo -e "Docs híbrido:     ${GREEN}ls $INSTALL_DIR/docs/hybrid/${NC}"
fi

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ¡Instalación completada! 🚀${NC}"
echo -e "${GREEN}  Ahora tienes AMBAS versiones disponibles${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
