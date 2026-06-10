#!/usr/bin/env python3
"""
Script de verificación para Wifite2-OneShot-Hybrid

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
        print(f"  [✓] {color_text(description, 'green')}")
        return True
    else:
        print(f"  [✗] {color_text(f'{description} (NO ENCONTRADO)', 'red')}")
        print(f"       Ruta esperada: {path}")
        return False

def check_command_exists(command, description):
    """Verifica si un comando existe"""
    try:
        result = subprocess.run([command, '--version'],
                              capture_output=True,
                              timeout=5)
        print(f"  [✓] {color_text(description, 'green')}")
        return True
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        print(f"  [✗] {color_text(f'{description} (NO ENCONTRADO)', 'yellow')}")
        return False

def check_reaver_modifications():
    """Verifica que las modificaciones en reaver.py se aplicaron"""
    reaver_path = os.path.join(os.path.dirname(__file__), 'wifite', 'tools', 'reaver.py')

    if not os.path.exists(reaver_path):
        print(f"  [✗] {color_text('reaver.py no encontrado', 'red')}")
        print(f"       Ruta esperada: {reaver_path}")
        return False

    with open(reaver_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Modificaciones para M6 detection
    checks = [
        ('try_oneshot_bruteforce', 'Método try_oneshot_bruteforce agregado'),
        ('oneshot_attempted', 'Flag oneshot_attempted agregado'),
        ('M6 detected', 'Detección de M6 implementada'),
    ]

    all_ok = True
    for check_str, description in checks:
        if check_str in content:
            print(f"  [✓] {color_text(description, 'green')}")
        else:
            print(f"  [✗] {color_text(description, 'red')}")
            all_ok = False

    return all_ok

def check_wps_modifications():
    """Verifica que las modificaciones en wps.py se aplicaron"""
    wps_path = os.path.join(os.path.dirname(__file__), 'wifite', 'attack', 'wps.py')

    if not os.path.exists(wps_path):
        print(f"  [✗] {color_text('wps.py no encontrado', 'red')}")
        print(f"       Ruta esperada: {wps_path}")
        return False

    with open(wps_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # Modificaciones para PSK recovery
    checks = [
        ('try_oneshot_with_pin', 'Método try_oneshot_with_pin agregado'),
        ('PSK not found, trying OneShot', 'Recuperación automática de PSK implementada'),
    ]

    all_ok = True
    for check_str, description in checks:
        if check_str in content:
            print(f"  [✓] {color_text(description, 'green')}")
        else:
            print(f"  [✗] {color_text(description, 'red')}")
            all_ok = False

    return all_ok

def main():
    print("\n" + "="*70)
    print(color_text("VERIFICACIÓN DE WIFITE2-ONESHOT-HYBRID", 'blue'))
    print("="*70 + "\n")

    base_dir = os.path.dirname(os.path.abspath(__file__))
    all_checks_passed = True

    # 1. Verificar estructura de carpetas
    print(color_text("1. Estructura de Carpetas", 'yellow'))
    checks = [
        (os.path.join(base_dir, 'wifite'), 'Carpeta wifite'),
        (os.path.join(base_dir, 'OneShot'), 'Carpeta OneShot'),
        (os.path.join(base_dir, 'wifite.py'), 'wifite.py principal'),
        (os.path.join(base_dir, 'OneShot', 'oneshot.py'), 'oneshot.py principal'),
        (os.path.join(base_dir, 'wifite', 'tools', 'reaver.py'), 'reaver.py'),
        (os.path.join(base_dir, 'wifite', 'attack', 'wps.py'), 'wps.py'),
        (os.path.join(base_dir, 'setup.py'), 'setup.py'),
        (os.path.join(base_dir, 'requirements.txt'), 'requirements.txt'),
    ]

    for path, desc in checks:
        if not check_file_exists(path, desc):
            all_checks_passed = False

    print()

    # 2. Verificar modificaciones en reaver.py (M6 Detection)
    print(color_text("2. Modificaciones en reaver.py (M6 Detection)", 'yellow'))
    if not check_reaver_modifications():
        all_checks_passed = False

    print()

    # 3. Verificar modificaciones en wps.py (PSK Recovery)
    print(color_text("3. Modificaciones en wps.py (PSK Recovery)", 'yellow'))
    if not check_wps_modifications():
        all_checks_passed = False

    print()

    # 4. Verificar dependencias del sistema (solo en Linux)
    if sys.platform.startswith('linux'):
        print(color_text("4. Dependencias del Sistema", 'yellow'))

        # Verificar Python
        if not check_command_exists('python3', 'Python 3'):
            all_checks_passed = False

        # Verificar herramientas de WiFi (no crítico, solo informativo)
        print(color_text("\n   Herramientas WiFi (opcional):", 'blue'))
        wifi_tools = [
            ('airmon-ng', 'Airmon-ng'),
            ('reaver', 'Reaver'),
            ('wpa_supplicant', 'wpa_supplicant'),
            ('pixiewps', 'PixieWPS'),
        ]

        for cmd, desc in wifi_tools:
            check_command_exists(cmd, desc)

        print()
    else:
        print(color_text("4. Plataforma Detectada", 'yellow'))
        print(f"  [!] {color_text('No estás en Linux', 'yellow')}")
        print(f"      Este proyecto está diseñado para Linux (Kali, Ubuntu, etc.)")
        print()

    # 5. Verificar submódulo OneShot
    print(color_text("5. Submódulo OneShot", 'yellow'))
    oneshot_path = os.path.join(base_dir, 'OneShot', 'oneshot.py')
    if os.path.exists(oneshot_path) and os.path.getsize(oneshot_path) > 1000:
        print(f"  [✓] {color_text('OneShot está correctamente inicializado', 'green')}")
    else:
        print(f"  [✗] {color_text('OneShot no está inicializado', 'red')}")
        print(f"      Ejecuta: git submodule update --init --recursive")
        all_checks_passed = False

    print()

    # 6. Resumen
    print("="*70)
    if all_checks_passed:
        print(color_text("✓ TODAS LAS VERIFICACIONES PASARON", 'green'))
        print("\n" + color_text("Instalación:", 'blue'))
        print(f"  sudo ./install_linux.sh")
        print("\n" + color_text("Uso:", 'blue'))
        print(f"  sudo airmon-ng start wlan0")
        print(f"  sudo wifite -i wlan0mon --wps -v")
    else:
        print(color_text("✗ ALGUNAS VERIFICACIONES FALLARON", 'red'))
        print("\nRevisa los errores arriba.")
        print("\nSi OneShot no está inicializado:")
        print("  git submodule update --init --recursive")
    print("="*70 + "\n")

    return 0 if all_checks_passed else 1

if __name__ == '__main__':
    sys.exit(main())
