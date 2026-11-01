#!/bin/bash
# Fabrique les paquets Linux de MultiDigi et de CW Terminal (.deb et .tar.gz), dans WSL, en root.
# Compilation dans un Ubuntu 22.04 isolé (/srv/f4lps-jammy) : un programme compilé sur un système récent ne démarre pas sur
# les distributions plus anciennes (glibc). Pas d'AppImage : son dossier disparaît avec le programme, et le gardien
# d'émission, qui doit lui survivre pour remettre la radio en réception, disparaîtrait avec lui.
# Usage : bash package-linux.sh md|cw|all     Résultat : <dossier du programme>/dist-linux/
set -e
R=/mnt/c/Users/14frs/Documents/radio
J=/srv/f4lps-jammy

prepare() {
  if [ ! -x "$J/usr/bin/python3.10" ] || [ ! -f "$J/.pret" ]; then
    apt-get install -y -qq debootstrap >/dev/null
    [ -d "$J/usr" ] || debootstrap --variant=minbase --components=main,universe jammy "$J" http://archive.ubuntu.com/ubuntu
    cat > "$J/etc/apt/sources.list" <<EOF
deb http://archive.ubuntu.com/ubuntu jammy main universe
deb http://archive.ubuntu.com/ubuntu jammy-updates main universe
EOF
  fi
  mountpoint -q "$J/proc" || mount -t proc proc "$J/proc"
  mountpoint -q "$J/dev" || mount --bind /dev "$J/dev"
  cp /etc/resolv.conf "$J/etc/resolv.conf"
  if [ ! -f "$J/.pret" ]; then
    chroot "$J" bash -c '
      export DEBIAN_FRONTEND=noninteractive
      apt-get update -qq
      apt-get install -y -qq python3.10 python3.10-venv python3.10-dev portaudio19-dev build-essential binutils \
        libgl1 libegl1 libglib2.0-0 libdbus-1-3 libfontconfig1 libxkbcommon-x11-0 libxcb-xinerama0 libxcb-icccm4 \
        libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 libxcb-shape0 libnss3 libnspr4 libxcomposite1 \
        libxdamage1 libxrandr2 libxtst6 libasound2 libxkbfile1 libxss1 >/dev/null
      python3.10 -m venv /venv
      /venv/bin/pip install -q --upgrade pip
      /venv/bin/pip install -q pyinstaller PyQt5 PyQtWebEngine numpy scipy pyaudio pyserial requests deep-translator \
        SpeechRecognition pyqtgraph
    '
    touch "$J/.pret"
  fi
}

# deb <nom paquet> <nom affiché> <dossier compilé> <exécutable> <version> <description> <icône png ou vide> <sortie>
make_packages() {
  local pkg=$1 title=$2 dist=$3 exe=$4 ver=$5 desc=$6 icon=$7 out=$8
  mkdir -p "$out"
  local W; W=$(mktemp -d)
  mkdir -p "$W/DEBIAN" "$W/opt/$pkg" "$W/usr/bin" "$W/usr/share/applications"
  cp -a "$dist/." "$W/opt/$pkg/"
  ln -s "/opt/$pkg/$exe" "$W/usr/bin/$pkg"
  [ -n "$icon" ] && [ -f "$icon" ] && { mkdir -p "$W/usr/share/pixmaps"; cp "$icon" "$W/usr/share/pixmaps/$pkg.png"; }
  cat > "$W/usr/share/applications/$pkg.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$title
Comment=$desc
Exec=/opt/$pkg/$exe
Icon=$pkg
Terminal=false
Categories=HamRadio;Network;
EOF
  cat > "$W/DEBIAN/control" <<EOF
Package: $pkg
Version: $ver
Section: hamradio
Priority: optional
Architecture: amd64
Maintainer: F4LPS <developpement@lesf4.fr>
Depends: libc6 (>= 2.35), libxcb-xinerama0, libxkbcommon-x11-0, libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-render-util0, libnss3
Recommends: espeak-ng, xdg-utils
Description: $desc
EOF
  dpkg-deb --root-owner-group -Zxz --build "$W" "$out/${pkg}_${ver}_amd64.deb" >/dev/null
  tar -C "$(dirname "$dist")" -czf "$out/$title-$ver-linux-x86_64.tar.gz" "$(basename "$dist")"
  rm -rf "$W"
  ls -la "$out" | tail -n 2
}

build_md() {
  local S="$R/miltidigi" V
  V=$(grep -m1 '^PROGRAM_VERSION_TAG' "$S/MultiDigi_FINAL_JS8_20260904.py" | cut -d'"' -f2)
  rm -rf "$J/build/md"; mkdir -p "$J/build/md"
  cp "$S/MultiDigi_FINAL_JS8_20260904.py" "$J/build/md/"
  chroot "$J" bash -c 'cd /build/md && /venv/bin/pyinstaller --name MultiDigi --onedir --windowed --noconfirm --clean \
    --hidden-import PyQt5.QtWebEngineWidgets --hidden-import serial.tools.list_ports --hidden-import xmlrpc.client \
    --exclude-module tensorflow --exclude-module keras --exclude-module matplotlib --exclude-module torch \
    --exclude-module transformers --exclude-module IPython --exclude-module pandas --exclude-module sklearn \
    MultiDigi_FINAL_JS8_20260904.py > /build/md/pyi.log 2>&1' || { tail -20 "$J/build/md/pyi.log"; exit 1; }
  make_packages multidigi MultiDigi "$J/build/md/dist/MultiDigi" MultiDigi "$V" \
    "Terminal radioamateur multi-modes numeriques (PSK, JS8, Olivia, RTTY, CW...)" "" "$S/dist-linux"
}

build_cw() {
  local S="$R/CW_Terminal_Dev" V
  V=$(grep -m1 '^APP_VERSION' "$S/cw_terminal.py" | cut -d'"' -f2)
  rm -rf "$J/build/cw"; mkdir -p "$J/build/cw"
  cp "$S/cw_terminal.py" "$S/cw_callbook.py" "$S/cw_tracker.py" "$S/cw_fit_decoder.py" "$J/build/cw/"
  cp -r "$S/assets" "$J/build/cw/"
  chroot "$J" bash -c 'cd /build/cw && /venv/bin/pyinstaller --name CW_Terminal --onedir --windowed --noconfirm --clean \
    --add-data "assets/Mise_en_route_CW_Terminal.html:." \
    --hidden-import cw_fit_decoder --hidden-import cw_callbook --hidden-import cw_tracker \
    --hidden-import PyQt5.QtWebEngineWidgets --hidden-import pyqtgraph --hidden-import scipy.signal --hidden-import scipy.fft \
    --hidden-import serial.tools.list_ports --hidden-import speech_recognition --hidden-import xmlrpc.client \
    --exclude-module tensorflow --exclude-module keras --exclude-module matplotlib --exclude-module torch \
    --exclude-module transformers --exclude-module IPython --exclude-module pandas --exclude-module sklearn \
    cw_terminal.py > /build/cw/pyi.log 2>&1' || { tail -20 "$J/build/cw/pyi.log"; exit 1; }
  make_packages cw-terminal CW_Terminal "$J/build/cw/dist/CW_Terminal" CW_Terminal "$V" \
    "Decodage et envoi CW pour radioamateurs" "$S/assets/CW_Terminal_icon.png" "$S/dist-linux"
}

prepare
case "${1:-all}" in
  md) build_md ;;
  cw) build_cw ;;
  all) build_md; build_cw ;;
esac
