#!/bin/bash
# Fabrique un .dmg macOS (lancé par GitHub Actions, sur un vrai Mac). Non signé par Apple : signature locale seulement,
# au premier lancement il faut faire clic droit > Ouvrir.
# Usage : package-mac.sh <Nom appli> <script.py> <version> [options PyInstaller...]
set -e
NAME=$1; ENTRY=$2; VER=$3; shift 3
ARCH=$(uname -m)
python -m PyInstaller --name "$NAME" --onedir --windowed --noconfirm --clean \
  --osx-bundle-identifier "fr.f4lps.$(echo "$NAME" | tr -d '_' | tr 'A-Z' 'a-z')" \
  --hidden-import PyQt5.QtWebEngineWidgets --hidden-import serial.tools.list_ports --hidden-import xmlrpc.client \
  --exclude-module tensorflow --exclude-module keras --exclude-module matplotlib --exclude-module torch \
  --exclude-module transformers --exclude-module IPython --exclude-module pandas --exclude-module sklearn \
  "$@" "$ENTRY"
APP="dist/$NAME.app"
[ -d "$APP" ] || { echo "ECHEC : $APP absent"; exit 1; }
# macOS refuse le micro (donc toute réception audio) sans cette phrase
/usr/libexec/PlistBuddy -c "Add :NSMicrophoneUsageDescription string Reception audio de la radio (carte son)" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VER" "$APP/Contents/Info.plist" || true
codesign --force --deep -s - "$APP"
mkdir -p dist-mac
hdiutil create -volname "$NAME $VER" -srcfolder "$APP" -ov -format UDZO "dist-mac/$NAME-$VER-mac-$ARCH.dmg"
ls -la dist-mac
# Essai : le programme doit tenir 25 s sans s'arrêter
BIN="$APP/Contents/MacOS/$NAME"
QT_QPA_PLATFORM=offscreen HOME="$(mktemp -d)" "$BIN" > start.log 2>&1 &
PID=$!
sleep 25
if kill -0 $PID 2>/dev/null; then
  echo "ESSAI OK : $NAME tourne depuis 25 s"
  kill $PID || true
else
  echo "ESSAI ECHEC : $NAME s'est arrete"; tail -40 start.log; exit 1
fi
