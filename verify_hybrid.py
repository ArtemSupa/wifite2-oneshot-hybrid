#!/usr/bin/env python3
"""
Script de verificación para el híbrido Wifite2 + OneShot

Verifica que:
1. La estructura de carpetas es correcta
2. Los archivos necesarios existen
3. Las modificaciones se aplicaron correctamente
4. Las dependencias están instaladas
"""

import os
import sys
import subprocess

def color_text(text, color_code):
    """Colorea el texto en la terminal"""
    colors = {
        'red': '\033[91m',
        'green': '\033[92m',
        'yellow': '\033[93m',
        'blue': '\033[94m',
        'reset': '\033[0m'
    }
    return f"{colors.get(color_code, '')}{text}{colors['reset']}"

def check_file_exists(path, description):
    """Verifica si un archivo existe"""
    if os.path.exists(path):
        print(f"  [OK] {color_text(description, 'green')}: {path}")
        return True
    else:
        print(f"  [FAIL] {color_text(description, 'red')}: {path} (NO ENCONTRADO)")
        return False

def check_command_exists(command, description):
    """Verifica si un comando existe"""
    try:
        result = subprocess.run([command, '--version'],
                              capture_output=True,
                              timeout=5)
        print(f"  [OK] {color_text(description, 'green')}: {command}")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        print(f"  [FAIL] {color_text(description, 'red')}: {command} (NO ENCONTRADO)")
        return False

def check_reaver_modifications():
    """Verifica que las modificaciones en reaver.py se aplicaron"""
    reaver_path = os.path.join(os.path.dirname(__file__), 'wifite2', 'wifite', 'tools', 'reaver.py')

    if not os.path.exists(reaver_path):
        print(f"  ✗ {color_text('reaver.py no encontrado', 'red')}")
        return False

    with open(reaver_path, 'r', encoding='utf-8') as f:
        content = f.read()

    checks = [
        ('import json', 'Import de json agregado'),
        ('try_oneshot_bruteforce', 'Método try_oneshot_bruteforce agregado'),
        ('oneshot_attempted', 'Flag oneshot_attempted agregado'),
        ('oneshot_path =', 'Ruta de oneshot configurada'),
        ('Switching to OneShot', 'Mensaje de switch a OneShot presente')
    ]

    all_ok = True
    for check_str, description in checks:
        if check_str in content:
            print(f"  [OK] {color_text(description, 'green')}")
        else:
            print(f"  [FAIL] {color_text(description, 'red')}")
            all_ok = False

    return all_ok

def main():
    print("\n" + "="*70)
    print(color_text("VERIFICACIÓN DEL HÍBRIDO WIFITE2 + ONESHOT", 'blue'))
    print("="*70 + "\n")

    base_dir = os.path.dirname(__file__)
    all_checks_passed = True

    # 1. Verificar estructura de carpetas
    print(color_text("1. Estructura de Carpetas", 'yellow'))
    checks = [
        (os.path.join(base_dir, 'wifite2'), 'Carpeta wifite2'),
        (os.path.join(base_dir, 'OneShot'), 'Carpeta OneShot'),
        (os.path.join(base_dir, 'wifite2', 'wifite.py'), 'wifite.py principal'),
        (os.path.join(base_dir, 'OneShot', 'oneshot.py'), 'oneshot.py principal'),
        (os.path.join(base_dir, 'wifite2', 'wifite', 'tools', 'reaver.py'), 'reaver.py modificado'),
    ]

    for path, desc in checks:
        if not check_file_exists(path, desc):
            all_checks_passed = False

    print()

    # 2. Verificar modificaciones en reaver.py
    print(color_text("2. Modificaciones en reaver.py", 'yellow'))
    if not check_reaver_modifications():
        all_checks_passed = False

    print()

    # 3. Verificar dependencias del sistema
    print(color_text("3. Dependencias del Sistema", 'yellow'))

    # Verificar Python
    python_cmd = 'python3' if sys.platform != 'win32' else 'python'
    if not check_command_exists(python_cmd, f'Python ({python_cmd})'):
        all_checks_passed = False

    # Verificar herramientas de WiFi
    wifi_tools = [
        ('airmon-ng', 'Airmon-ng (aircrack-ng suite)'),
        ('reaver', 'Reaver'),
        ('wpa_supplicant', 'wpa_supplicant (para OneShot)'),
    ]

    for cmd, desc in wifi_tools:
        check_command_exists(cmd, desc)
        # No marcar como fallo crítico porque pueden no estar en PATH en Windows

    print()

    # 4. Verificar configuración para Windows
    if sys.platform == 'win32':
        print(color_text("4. Configuración Windows/MINGW64", 'yellow'))
        print(f"  [WARN] {color_text('Estás en Windows', 'yellow')}")
        print(f"    Si 'python3' no funciona, edita reaver.py línea ~358:")
        print(f"    Cambiar 'python3' por 'python'")
        print()

    # 5. Resumen
    print("="*70)
    if all_checks_passed:
        print(color_text("[OK] TODAS LAS VERIFICACIONES PASARON", 'green'))
        print("\nPuedes ejecutar wifite con:")
        print(f"  cd wifite2")
        print(f"  sudo {python_cmd} wifite.py")
    else:
        print(color_text("[FAIL] ALGUNAS VERIFICACIONES FALLARON", 'red'))
        print("\nRevisa los errores arriba y consulta README_HYBRID.md")
    print("="*70 + "\n")

    return 0 if all_checks_passed else 1

if __name__ == '__main__':
    sys.exit(main())
