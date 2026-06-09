# GUÍA DE INSTALACIÓN EN LINUX (KALI/UBUNTU/DEBIAN)

## 🚀 TRANSFERIR DE WINDOWS A LINUX

### Opción 1: Comprimir y Transferir (RECOMENDADO)

#### En Windows (Git Bash/PowerShell):

```bash
# Comprimir la carpeta completa
cd "D:\Development"
tar -czf wifite-oneshot-hybrid.tar.gz "hibrido hack"

# O si prefieres zip:
# zip -r wifite-oneshot-hybrid.zip "hibrido hack"
```

#### Transferir a Linux:

**Opción A: USB**
```bash
# Copiar el archivo .tar.gz al USB
# Luego en Linux:
cp /media/usb/wifite-oneshot-hybrid.tar.gz ~/
cd ~
tar -xzf wifite-oneshot-hybrid.tar.gz
mv "hibrido hack" wifite-oneshot-hybrid
cd wifite-oneshot-hybrid
```

**Opción B: SCP (si tienes SSH en Kali)**
```bash
# En Windows:
scp wifite-oneshot-hybrid.tar.gz user@kali-ip:~/

# En Kali:
cd ~
tar -xzf wifite-oneshot-hybrid.tar.gz
mv "hibrido hack" wifite-oneshot-hybrid
cd wifite-oneshot-hybrid
```

**Opción C: Git (MEJOR para mantener actualizado)**
```bash
# En Windows, crear repo:
cd "D:\Development\hibrido hack"
git init
git add .
git commit -m "Wifite + OneShot hybrid"

# Subir a GitHub/GitLab (privado recomendado)
# Luego en Kali:
git clone https://github.com/tuusuario/wifite-oneshot-hybrid.git
cd wifite-oneshot-hybrid
```

### Opción 2: Recrear desde Git Original

```bash
# En Kali Linux:
mkdir ~/wifite-hybrid
cd ~/wifite-hybrid

# Clonar repositorios originales
git clone https://github.com/derv82/wifite2.git
git clone https://github.com/kimocoder/OneShot.git

# Descargar el archivo modificado reaver.py
# (tendrías que subir solo el reaver.py modificado a algún lugar)
```

---

## 🔧 CONFIGURACIÓN EN LINUX

### 1. Instalar Dependencias

```bash
# Actualizar sistema
sudo apt update

# Instalar Python 3.8+ (Kali ya lo tiene)
python3 --version  # Verificar versión

# Instalar dependencias de sistema
sudo apt install -y \
    python3 python3-pip \
    aircrack-ng \
    reaver \
    pixiewps \
    wpasupplicant \
    wireless-tools \
    net-tools

# Instalar dependencias Python de wifite
cd ~/wifite-oneshot-hybrid/wifite2
sudo python3 setup.py install --user  # O sin --user para instalar globalmente

# O manualmente:
sudo pip3 install -r requirements.txt
```

### 2. Hacer Ejecutables

```bash
cd ~/wifite-oneshot-hybrid

# Hacer ejecutables
chmod +x wifite2/wifite.py
chmod +x OneShot/oneshot.py

# Crear symlink para fácil acceso (opcional)
sudo ln -s ~/wifite-oneshot-hybrid/wifite2/wifite.py /usr/local/bin/wifite-hybrid
```

### 3. Verificar Instalación

```bash
cd ~/wifite-oneshot-hybrid
python3 verify_hybrid.py
```

---

## 🎯 EJECUTAR EL WIFITE MODIFICADO (Sin conflictos con el pre-instalado)

### Método 1: Ruta Absoluta (MÁS SIMPLE)

```bash
# Ejecutar directamente con ruta completa
cd ~/wifite-oneshot-hybrid/wifite2
sudo python3 ./wifite.py

# O desde cualquier lugar:
sudo python3 ~/wifite-oneshot-hybrid/wifite2/wifite.py
```

### Método 2: Alias en .bashrc (RECOMENDADO)

```bash
# Agregar alias a tu .bashrc o .zshrc
nano ~/.bashrc

# Agregar al final:
alias wifite-hybrid='cd ~/wifite-oneshot-hybrid/wifite2 && sudo python3 wifite.py'
alias wifite-original='sudo wifite'  # El pre-instalado

# Guardar (Ctrl+O, Enter, Ctrl+X)

# Recargar configuración
source ~/.bashrc

# Ahora puedes usar:
wifite-hybrid          # Tu versión híbrida
wifite-original        # La versión pre-instalada de Kali
```

### Método 3: Script Wrapper

```bash
# Crear script wrapper
sudo nano /usr/local/bin/wifite-hybrid
```

Agregar:
```bash
#!/bin/bash
cd ~/wifite-oneshot-hybrid/wifite2
exec sudo python3 wifite.py "$@"
```

```bash
# Hacer ejecutable
sudo chmod +x /usr/local/bin/wifite-hybrid

# Usar
wifite-hybrid          # Tu versión híbrida
wifite                 # La versión pre-instalada
```

### Método 4: Reemplazar el Original (NO RECOMENDADO)

```bash
# Solo si quieres reemplazar completamente
sudo apt remove wifite  # Desinstalar el original
sudo ln -s ~/wifite-oneshot-hybrid/wifite2/wifite.py /usr/local/bin/wifite
```

---

## ⚙️ AJUSTES NECESARIOS PARA LINUX

### 1. Verificar Ruta de OneShot

El código ya está configurado para Linux, pero verifica:

```bash
cd ~/wifite-oneshot-hybrid
python3 test_oneshot_path.py
```

Debería mostrar: `[OK] oneshot.py encontrado correctamente!`

### 2. Cambiar 'python' a 'python3' (si es necesario)

En Linux, el comando correcto es `python3`. Verifica línea 358 de `reaver.py`:

```bash
nano ~/wifite-oneshot-hybrid/wifite2/wifite/tools/reaver.py
```

Buscar línea ~358:
```python
oneshot_cmd = [
    'python3',  # ← Debe ser python3 en Linux (no python)
    oneshot_path,
    '-i', Configuration.interface,
    '-b', self.target.bssid,
    '-p', self.first_half_pin,
    '-B'
]
```

Si dice `'python'`, cámbialo a `'python3'`.

---

## 🧪 PROBAR EL HÍBRIDO

### Prueba Rápida (sin atacar redes)

```bash
cd ~/wifite-oneshot-hybrid/wifite2
sudo python3 wifite.py --help
```

Debería mostrar el menú de ayuda normal de wifite.

### Prueba con Escaneo

```bash
# Poner interfaz en modo monitor
sudo airmon-ng start wlan0  # Cambia wlan0 por tu interfaz

# Ejecutar wifite híbrido
cd ~/wifite-oneshot-hybrid/wifite2
sudo python3 wifite.py -i wlan0mon

# O con el alias:
wifite-hybrid -i wlan0mon
```

### Prueba Completa (atacar red de prueba)

```bash
# Ejecutar con opciones WPS
sudo python3 wifite.py -i wlan0mon --wps -v

# El híbrido se activará automáticamente cuando detecte M6
```

---

## 📋 SCRIPT DE INSTALACIÓN AUTOMÁTICA

Guarda esto como `install_linux.sh`:

```bash
#!/bin/bash

echo "================================================"
echo "  INSTALADOR HÍBRIDO WIFITE + ONESHOT"
echo "================================================"
echo ""

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "[!] Por favor ejecuta como root (sudo)"
    exit 1
fi

# Directorio de instalación
INSTALL_DIR="/opt/wifite-hybrid"

echo "[1] Instalando dependencias del sistema..."
apt update
apt install -y python3 python3-pip aircrack-ng reaver pixiewps wpasupplicant wireless-tools net-tools

echo ""
echo "[2] Verificando Python 3.8+..."
PYTHON_VERSION=$(python3 --version | grep -oP '(?<=Python )\d+\.\d+')
if (( $(echo "$PYTHON_VERSION < 3.8" | bc -l) )); then
    echo "[!] ADVERTENCIA: Python $PYTHON_VERSION detectado. Se requiere 3.8+"
    echo "    Continuando de todos modos..."
fi

echo ""
echo "[3] Copiando archivos a $INSTALL_DIR..."
mkdir -p $INSTALL_DIR
cp -r wifite2 OneShot $INSTALL_DIR/

echo ""
echo "[4] Configurando permisos..."
chmod +x $INSTALL_DIR/wifite2/wifite.py
chmod +x $INSTALL_DIR/OneShot/oneshot.py

echo ""
echo "[5] Creando wrapper en /usr/local/bin..."
cat > /usr/local/bin/wifite-hybrid <<'EOF'
#!/bin/bash
cd /opt/wifite-hybrid/wifite2
exec python3 wifite.py "$@"
EOF

chmod +x /usr/local/bin/wifite-hybrid

echo ""
echo "[6] Verificando instalación..."
cd $INSTALL_DIR
if [ -f "verify_hybrid.py" ]; then
    python3 verify_hybrid.py
fi

echo ""
echo "================================================"
echo "  ✓ INSTALACIÓN COMPLETADA"
echo "================================================"
echo ""
echo "Comandos disponibles:"
echo "  wifite-hybrid        → Wifite con integración OneShot"
echo "  wifite               → Wifite original de Kali (si está instalado)"
echo ""
echo "Ejemplo de uso:"
echo "  sudo airmon-ng start wlan0"
echo "  sudo wifite-hybrid -i wlan0mon --wps"
echo ""
echo "Archivos instalados en: $INSTALL_DIR"
echo "================================================"
```

Ejecutar:
```bash
cd ~/wifite-oneshot-hybrid
chmod +x install_linux.sh
sudo ./install_linux.sh
```

---

## 🎯 COMPARACIÓN DE MÉTODOS

| Método | Ventajas | Desventajas |
|--------|----------|-------------|
| **Ruta Absoluta** | Simple, sin config | Comando largo |
| **Alias** | Fácil de usar | Solo para tu usuario |
| **Wrapper Script** | Disponible para todos | Requiere permisos root |
| **Reemplazar Original** | Comando corto `wifite` | Pierdes el original |

**Recomendación:** Usa **Alias** (Método 2) para tu usuario, o **Script de Instalación** para instalación global.

---

## 🔍 VERIFICAR QUE FUNCIONA

### Checklist Final:

```bash
# 1. Python 3.8+
python3 --version
# Debe ser: Python 3.8.x o superior

# 2. Dependencias instaladas
which airmon-ng reaver pixiewps wpa_supplicant
# Todas deben mostrar rutas

# 3. Estructura correcta
ls -la ~/wifite-oneshot-hybrid/
# Debe mostrar: wifite2/ OneShot/

# 4. Verificación híbrida
cd ~/wifite-oneshot-hybrid
python3 verify_hybrid.py
# Debe mostrar: [OK] TODAS LAS VERIFICACIONES PASARON

# 5. Wifite funciona
cd ~/wifite-oneshot-hybrid/wifite2
sudo python3 wifite.py --help
# Debe mostrar menú de ayuda

# 6. Interfaz en modo monitor
sudo airmon-ng start wlan0
# Debe crear wlan0mon

# 7. Ejecutar wifite híbrido
sudo python3 wifite.py -i wlan0mon
# Debe escanear redes
```

---

## 🐛 TROUBLESHOOTING LINUX

### Problema: "ModuleNotFoundError"
```bash
# Instalar dependencias Python
cd ~/wifite-oneshot-hybrid/wifite2
sudo pip3 install -r requirements.txt
```

### Problema: "wpa_supplicant not found"
```bash
sudo apt install wpasupplicant
sudo systemctl stop wpa_supplicant
sudo systemctl stop NetworkManager
```

### Problema: "Permission denied"
```bash
# Ejecutar con sudo
sudo python3 wifite.py

# O dar permisos de ejecución
chmod +x wifite.py
```

### Problema: "Interface not found"
```bash
# Verificar interfaces
iwconfig

# Poner en modo monitor
sudo airmon-ng check kill  # Matar procesos conflictivos
sudo airmon-ng start wlan0
```

### Problema: OneShot no se ejecuta
```bash
# Verificar ruta
cd ~/wifite-oneshot-hybrid
python3 test_oneshot_path.py

# Hacer ejecutable
chmod +x OneShot/oneshot.py

# Verificar que funciona
cd OneShot
sudo python3 oneshot.py --help
```

---

## 📝 RESUMEN DE COMANDOS CLAVE

```bash
# TRANSFERIR
tar -czf wifite-hybrid.tar.gz "hibrido hack"
# Copiar a Kali, luego:
tar -xzf wifite-hybrid.tar.gz

# INSTALAR
cd wifite-oneshot-hybrid
chmod +x install_linux.sh
sudo ./install_linux.sh

# USAR
sudo airmon-ng start wlan0
sudo wifite-hybrid -i wlan0mon --wps

# VERIFICAR
python3 verify_hybrid.py
```

---

¡Listo! Con esto puedes transferir y usar el híbrido en Kali Linux sin conflictos con el wifite pre-instalado.
