# Wifite2 + OneShot Hybrid

**Automated WiFi WPS attack tool with intelligent OneShot integration for faster and more complete results.**

## 🎯 What is this?

This is a modified version of [Wifite2](https://github.com/derv82/wifite2) that integrates [OneShot](https://github.com/kimocoder/OneShot) to solve two common problems:

1. **M6 Detection Optimization:** When Wifite detects M6 during PIN attacks (first 4 digits found), it automatically switches to OneShot for faster bruteforce of the remaining 3 digits (1,000 vs 11,000 attempts).

2. **Automatic PSK Recovery:** When Wifite obtains a WPS PIN but not the WiFi password (PSK), it automatically uses OneShot with that PIN to obtain the password.

## 🚀 Key Features

### Standard Wifite2 Features
- All original Wifite2 functionality intact
- WPS attacks (Pixie-Dust, NULL PIN, PIN Attack)
- WPA/WPA2 attacks (PMKID, Handshake)
- Multiple target support
- Session management
- All command-line options

### New Hybrid Features
- **Automatic M6 Optimization:** Switches to OneShot when M6 is detected during PIN attacks
- **Automatic PSK Recovery:** Uses OneShot to get PSK when only PIN is obtained
- **Seamless Integration:** Works transparently, no new commands needed
- **Dual Success Rate:** Combines Reaver/Bully reliability with OneShot speed

## 📊 Improvements

| Scenario | Original Wifite | Wifite+OneShot Hybrid |
|----------|-----------------|----------------------|
| PIN Attack after M6 | 2-8 hours (11,000 PINs) | 5-15 minutes (1,000 PINs) |
| Pixie-Dust gets PIN only | Saves PIN, PSK: N/A | Gets PSK with OneShot automatically |
| Success rate | High | Higher (two methods) |

## 🛠️ Installation

### Prerequisites

```bash
# Debian/Ubuntu/Kali
sudo apt update
sudo apt install -y python3 python3-pip aircrack-ng reaver pixiewps wpasupplicant
```

### Quick Install

```bash
# Clone this repository
git clone https://github.com/YOUR-USERNAME/wifite-oneshot-hybrid.git
cd wifite-oneshot-hybrid

# Run installer (copies to /opt/wifite-hybrid, creates wifite-hybrid command)
chmod +x install_linux.sh
sudo ./install_linux.sh
```

### Manual Install

```bash
# Clone repos
git clone https://github.com/YOUR-USERNAME/wifite-oneshot-hybrid.git
cd wifite-oneshot-hybrid

# Make sure OneShot is present
git submodule update --init --recursive

# Install dependencies
cd wifite2
sudo python3 setup.py install

# Run directly
sudo python3 wifite.py
```

## 📖 Usage

**Same as standard Wifite:**

```bash
# Put interface in monitor mode
sudo airmon-ng start wlan0

# Run wifite hybrid (if installed with install_linux.sh)
sudo wifite-hybrid -i wlan0mon --wps

# Or run directly
cd wifite2
sudo python3 wifite.py -i wlan0mon --wps
```

### Example Output

```
[+] (2/14) Starting attacks against 88:66:9F:D7:9C:20 (MyNetwork)
[+] MyNetwork WPS Pixie-Dust: [4m56s] Cracked WPS PIN: 89528648
[+] PSK/Password: N/A
[!] PSK not found, trying OneShot with PIN 89528648...
..............
[+] OneShot Success! PSK: MyPassword123
[+] saved result to cracked.json
```

## 🔧 What Was Modified

### Modified Files:

1. **`wifite2/wifite/tools/reaver.py`**
   - Added M6 detection logic
   - Added `try_oneshot_bruteforce()` method
   - Automatically switches to OneShot when M6 is detected

2. **`wifite2/wifite/attack/wps.py`**
   - Added `try_oneshot_with_pin()` method
   - Automatically attempts PSK recovery with OneShot when PIN is obtained without PSK

### Unchanged:
- All other Wifite2 functionality
- All command-line options
- All attack modes
- Session management
- Result storage

## 🎯 How It Works

### Scenario 1: M6 Detection (PIN Attack)
```
PIN Attack → M6 detected (first 4 digits: 1234)
           → Stop Reaver
           → Call OneShot: oneshot.py -i wlan0 -b MAC -p 1234 -B
           → OneShot bruteforces last 3 digits (1,000 attempts)
           → Success: PIN + PSK obtained
           → Continue to next target
```

### Scenario 2: PIN without PSK (Any WPS Attack)
```
Pixie-Dust → PIN obtained: 89528648, PSK: N/A
           → Call OneShot: oneshot.py -i wlan0 -b MAC -p 89528648
           → OneShot attempts to get PSK with PIN
           → Success: PSK obtained
           → Update result: PIN + PSK
           → Continue to next target
```

## ⚠️ Legal Disclaimer

This tool is for **educational purposes** and **authorized penetration testing only**.

- Only use on networks you own or have explicit permission to test
- Unauthorized access to computer networks is illegal
- The authors are not responsible for misuse of this tool

## 📜 License

This project maintains the original licenses:

- **Wifite2 modifications:** GPL v2 (same as original Wifite2)
- **OneShot:** MIT License (as original OneShot)
- **Integration code:** GPL v2 (to match Wifite2)

See [LICENSE](LICENSE) for full details.

## 🙏 Credits

### Original Projects

- **Wifite2** by [@derv82](https://github.com/derv82/wifite2)
  - The base automated WiFi attack tool

- **OneShot** by [@kimocoder](https://github.com/kimocoder/OneShot)
  - WPS PIN attack tool using wpa_supplicant

### This Integration

- Integration and modifications by [Your Name/Username]
- Created to solve the M6 detection bottleneck and missing PSK issue

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/YOUR-USERNAME/wifite-oneshot-hybrid/issues)
- **Original Wifite2:** [Wifite2 Issues](https://github.com/derv82/wifite2/issues)
- **Original OneShot:** [OneShot Issues](https://github.com/kimocoder/OneShot/issues)

## 🔗 Related Projects

- [Wifite2](https://github.com/derv82/wifite2) - Original automated WiFi auditing tool
- [OneShot](https://github.com/kimocoder/OneShot) - WPS PIN attack using wpa_supplicant
- [Reaver](https://github.com/t6x/reaver-wps-fork-t6x) - WPS brute force attack tool
- [Aircrack-ng](https://github.com/aircrack-ng/aircrack-ng) - WiFi security auditing tools

---

**⭐ If this project helped you, please give it a star!**

**Made with ❤️ for the security community**
