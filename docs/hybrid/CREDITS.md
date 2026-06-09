# Credits and Acknowledgments

## Original Projects

This project is built upon and integrates two excellent open-source projects:

### Wifite2
- **Project:** https://github.com/derv82/wifite2
- **Author:** [@derv82](https://github.com/derv82) and contributors
- **License:** GPL v2
- **Description:** Automated wireless attack tool for Linux
- **Usage in this project:** Core functionality, modified to integrate OneShot

### OneShot
- **Project:** https://github.com/kimocoder/OneShot
- **Author:** [@kimocoder](https://github.com/kimocoder) and contributors
- **License:** MIT
- **Description:** WPS PIN attack tool using wpa_supplicant
- **Usage in this project:** Called automatically when M6 is detected or when PIN is obtained without PSK

## Integration Work

### Modifications and Integration
- **Created by:** [Your Name/GitHub Username]
- **Date:** June 2026
- **Purpose:** Solve M6 detection bottleneck and automatic PSK recovery

### What Was Added

1. **M6 Detection Integration (`wifite2/wifite/tools/reaver.py`)**
   - Automatic detection of M6 message during PIN attacks
   - Seamless switching from Reaver to OneShot
   - Optimized bruteforce of last 3 digits

2. **PSK Recovery Integration (`wifite2/wifite/attack/wps.py`)**
   - Automatic PSK recovery when only PIN is obtained
   - OneShot execution with complete PIN
   - Result updating with obtained PSK

3. **Documentation and Scripts**
   - Comprehensive documentation
   - Installation scripts for Linux
   - Verification and testing utilities

## Dependencies and Tools

This project also depends on these excellent tools:

### Aircrack-ng Suite
- **Project:** https://github.com/aircrack-ng/aircrack-ng
- **Components used:** airmon-ng, airodump-ng, aireplay-ng
- **License:** GPL v2

### Reaver
- **Project:** https://github.com/t6x/reaver-wps-fork-t6x
- **Description:** WPS brute force attack tool
- **License:** GPL v2

### Pixiewps
- **Description:** Offline WPS PIN attack tool
- **Used by:** Reaver for Pixie-Dust attacks

### wpa_supplicant
- **Description:** WiFi authentication client
- **Used by:** OneShot for WPS authentication

### Python Libraries
- **scapy:** Packet manipulation
- **subprocess, os, re, time:** Standard Python libraries

## Community

Special thanks to:

- The WiFi security research community
- All contributors to Wifite2 and OneShot
- Beta testers of this integration
- Everyone who reported issues and suggestions

## Disclaimer

This integration:
- Respects all original licenses
- Maintains GPL v2 compatibility for Wifite2 modifications
- Gives full credit to original authors
- Is provided for educational and authorized security testing only

## License

- **Wifite2 modifications:** GPL v2 (to match original)
- **OneShot:** MIT (as original)
- **Integration code:** GPL v2
- **Documentation:** CC BY 4.0

See [LICENSE](LICENSE) file for complete license text.

---

**If we forgot to credit someone or something, please open an issue!**
