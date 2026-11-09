#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/mock-adb" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$ADB_LOG"
case "$*" in
  "connect 192.168.1.4:5555") echo 'connected to 192.168.1.4:5555' ;;
  "-s 192.168.1.4:5555 get-state") echo "${MOCK_STATE:-device}" ;;
  "-s 192.168.1.4:5555 shell pm list packages --user 0")
    printf 'package:com.xiaomi.voicecontrol\r\npackage:com.spocky.projengmenu\r\npackage:com.gitv.video\r\npackage:com.xiaomi.smarthome\r\n' ;;
  "-s 192.168.1.4:5555 shell pm list packages -d --user 0") : ;;
  "-s 192.168.1.4:5555 shell getprop ro.product.model") echo 'MiTV-TEST' ;;
  "-s 192.168.1.4:5555 shell getprop ro.build.version.release") echo '9' ;;
  "-s 192.168.1.4:5555 shell getprop ro.product.cpu.abi") echo 'armeabi-v7a' ;;
  *) echo "unexpected adb call: $*" >&2; exit 43 ;;
esac
EOF
chmod +x "$TMP/mock-adb"
export ADB_LOG="$TMP/adb.log" ADB_BIN="$TMP/mock-adb"
bash "$ROOT/scripts/tv-preflight.sh" 192.168.1.4 > "$TMP/output"
grep -q 'MiTV-TEST' "$TMP/output"
grep -q 'com.xiaomi.smarthome' "$TMP/output"
grep -q 'com.gitv.video' "$TMP/output"
grep -q '未做卸载' "$TMP/output"
if grep -Ei '(uninstall|disable-user| pm clear|grant |reboot)' "$TMP/adb.log"; then
  echo 'ERROR: unexpected write command sent to device' >&2
  exit 1
fi
export MOCK_STATE=unauthorized
if bash "$ROOT/scripts/tv-preflight.sh" 192.168.1.4 > "$TMP/unauth-output" 2>&1; then
  echo 'ERROR: unauthorized ADB connection accepted' >&2
  exit 1
fi
if bash "$ROOT/scripts/tv-preflight.sh" '192.168.1.4;rm -rf /' > /dev/null 2>&1; then
  echo 'ERROR: unsafe host input accepted' >&2
  exit 1
fi
echo "PASS: inventory output, no write calls, unauthorized/unsafe-input rejection"
