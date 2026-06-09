# Guía para Subir a GitHub

## 📋 Checklist Antes de Subir

### 1. Archivos Necesarios (✅ Ya Creados)
- [x] README.md - Documentación principal
- [x] CREDITS.md - Créditos a proyectos originales
- [x] .gitignore - Archivos a ignorar
- [ ] LICENSE - Archivo de licencia (crear manualmente)

### 2. Limpiar Datos Sensibles
- [ ] Revisar que no haya contraseñas guardadas
- [ ] Eliminar archivos .cap, .pcap de pruebas
- [ ] Eliminar cracked.json con resultados reales
- [ ] Verificar que no haya IPs o MACs reales en logs

### 3. Estructura Recomendada

```
wifite-oneshot-hybrid/
├── .gitignore
├── README.md
├── CREDITS.md
├── LICENSE
├── GITHUB_GUIDE.md (este archivo)
├── install_linux.sh
├── verify_hybrid.py
├── docs/
│   ├── LINUX_SETUP.md
│   ├── QUICK_START.md
│   ├── QUE_CAMBIA_Y_QUE_NO.md
│   ├── NUEVO_CAMBIO_ONESHOT.md
│   └── ES_WIFITE_NORMAL.txt
├── wifite2/              (código modificado)
└── OneShot/              (como submódulo de Git)
```

---

## 🚀 Opción 1: Nuevo Repositorio (RECOMENDADO)

### Paso 1: Preparar el Repositorio Local

```bash
cd "D:\Development\hibrido hack"

# Inicializar Git (si no está inicializado)
git init

# Configurar usuario (si es primera vez)
git config user.name "Tu Nombre"
git config user.email "tu@email.com"
```

### Paso 2: Agregar OneShot como Submódulo

```bash
# Si OneShot ya está como carpeta normal, eliminarlo primero
rm -rf OneShot

# Agregar OneShot como submódulo
git submodule add https://github.com/kimocoder/OneShot.git OneShot
```

### Paso 3: Crear Archivo LICENSE

Copia el contenido de GPL v2:
```bash
# Descargar GPL v2
curl https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt -o LICENSE

# O crear manualmente con el texto de GPL v2
```

### Paso 4: Revisar y Limpiar

```bash
# Ver qué archivos se van a subir
git status

# Si hay archivos sensibles, agregarlos a .gitignore
echo "archivo_sensible.txt" >> .gitignore
```

### Paso 5: Commit Inicial

```bash
# Agregar archivos
git add .

# Crear commit
git commit -m "Initial commit: Wifite2 + OneShot hybrid integration

- Integrated OneShot for M6 detection optimization
- Added automatic PSK recovery when PIN is obtained
- Added comprehensive documentation
- Modified wifite2/wifite/tools/reaver.py for M6 handling
- Modified wifite2/wifite/attack/wps.py for PSK recovery

Credits to original projects:
- Wifite2: https://github.com/derv82/wifite2
- OneShot: https://github.com/kimocoder/OneShot"
```

### Paso 6: Crear Repositorio en GitHub

1. Ve a https://github.com/new
2. Nombre del repositorio: `wifite-oneshot-hybrid`
3. Descripción: `Wifite2 with OneShot integration for faster WPS attacks`
4. **NO** inicializar con README (ya lo tienes)
5. Licencia: GPL-2.0 (seleccionar GPL v2)
6. Crear repositorio

### Paso 7: Conectar y Subir

```bash
# Agregar remote
git remote add origin https://github.com/TU-USUARIO/wifite-oneshot-hybrid.git

# Subir
git branch -M main
git push -u origin main

# Subir submódulos
git submodule update --init --recursive
```

---

## 🔄 Opción 2: Fork de Wifite2

### Paso 1: Fork en GitHub

1. Ve a https://github.com/derv82/wifite2
2. Click en "Fork"
3. Crear fork en tu cuenta

### Paso 2: Clonar Tu Fork

```bash
cd "D:\Development"
git clone https://github.com/TU-USUARIO/wifite2.git wifite2-oneshot
cd wifite2-oneshot
```

### Paso 3: Aplicar Modificaciones

```bash
# Copiar tus archivos modificados
cp "D:\Development\hibrido hack\wifite2\wifite\tools\reaver.py" wifite/tools/
cp "D:\Development\hibrido hack\wifite2\wifite\attack\wps.py" wifite/attack/

# Agregar documentación
mkdir docs/hybrid
cp "D:\Development\hibrido hack"/*.md docs/hybrid/
```

### Paso 4: Agregar OneShot

```bash
# Como submódulo
git submodule add https://github.com/kimocoder/OneShot.git OneShot
```

### Paso 5: Commit y Push

```bash
git add .
git commit -m "Add OneShot integration for M6 detection and PSK recovery"
git push origin main
```

---

## 📝 Mejores Prácticas

### 1. Descripción Clara en GitHub

En la página del repositorio, agregar:

**Descripción corta:**
```
Wifite2 with OneShot integration - Automated WiFi WPS attacks with M6 optimization
```

**Topics (tags):**
- `wifite`
- `oneshot`
- `wifi-security`
- `wps-attack`
- `penetration-testing`
- `kali-linux`
- `security-tools`

### 2. README Badges (Opcional)

Agregar al inicio del README.md:

```markdown
![License](https://img.shields.io/badge/license-GPL--2.0-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)
```

### 3. Issues Template

Crear `.github/ISSUE_TEMPLATE.md`:

```markdown
## Issue Type
- [ ] Bug report
- [ ] Feature request
- [ ] Question

## Description
[Describe your issue here]

## Environment
- OS: [e.g., Kali Linux 2024]
- Python version: [e.g., 3.10]
- Command used: [e.g., sudo wifite-hybrid -i wlan0mon --wps]

## Expected behavior
[What you expected to happen]

## Actual behavior
[What actually happened]

## Logs
```
[Paste relevant logs here]
```
```

### 4. Pull Request Template

Crear `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
## Description
[Describe your changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Testing
- [ ] Tested on Kali Linux
- [ ] Tested on Ubuntu
- [ ] No errors in verbose mode

## Checklist
- [ ] Code follows project style
- [ ] Documentation updated
- [ ] Credits added if applicable
```

---

## ⚠️ IMPORTANTE: Qué NO Subir

### Archivos a Excluir (ya en .gitignore):

- ❌ Archivos de resultados reales (`cracked.json`, `*.cap`)
- ❌ Wordlists grandes (`rockyou.txt`)
- ❌ Logs con información sensible
- ❌ Archivos compilados (`*.pyc`, `__pycache__`)
- ❌ Configuraciones personales
- ❌ Archivos temporales

### Scripts Personales:

Estos archivos son útiles localmente pero NO deben ir a GitHub:
- `compress_for_linux.bat` (específico de Windows)
- `test_oneshot_path.py` (solo para testing local)
- Archivos `.txt` con instrucciones personales

**Mantener en GitHub:**
- ✅ Código fuente modificado
- ✅ Documentación
- ✅ Scripts de instalación
- ✅ Scripts de verificación
- ✅ README, LICENSE, CREDITS

---

## 🔒 Seguridad y Privacidad

### Antes de cada commit:

```bash
# Revisar cambios
git diff

# Revisar archivos a agregar
git status

# Buscar posibles contraseñas o datos sensibles
grep -r "password\|passwd\|secret\|key" .

# Verificar que .gitignore funciona
git check-ignore -v archivo_que_no_debe_subir
```

### Si accidentalmente subiste algo sensible:

```bash
# Eliminar archivo del historial
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch archivo_sensible.txt" \
  --prune-empty --tag-name-filter cat -- --all

# Forzar push (¡CUIDADO!)
git push origin --force --all
```

---

## 📢 Después de Subir

### 1. Configurar el Repositorio

- [ ] Agregar descripción y topics
- [ ] Configurar GitHub Pages si quieres (para docs)
- [ ] Habilitar issues
- [ ] Configurar protección de rama main

### 2. Anunciar (Opcional)

- Reddit: r/Kalilinux, r/netsec (con cuidado, leer reglas)
- Twitter/X: Con hashtags #infosec #pentesting
- Foros de seguridad: Null Byte, etc.

### 3. Mantener Actualizado

```bash
# Cuando hagas cambios
git add .
git commit -m "Descriptive message"
git push

# Actualizar submódulo OneShot
cd OneShot
git pull origin master
cd ..
git add OneShot
git commit -m "Update OneShot to latest version"
git push
```

---

## 🤝 Contribuciones

Si otros quieren contribuir:

1. Deben hacer fork de tu repo
2. Crear branch para su feature
3. Hacer pull request
4. Tú revisas y merges

---

## ✅ Checklist Final Antes de Publicar

- [ ] README.md completo y claro
- [ ] CREDITS.md con todos los créditos
- [ ] LICENSE correcto (GPL v2)
- [ ] .gitignore apropiado
- [ ] No hay datos sensibles
- [ ] Código funciona y está probado
- [ ] Documentación actualizada
- [ ] OneShot como submódulo (no copia)
- [ ] Links a proyectos originales
- [ ] Disclaimer legal incluido

---

**¿Todo listo? ¡Es hora de compartir tu trabajo con la comunidad! 🚀**
