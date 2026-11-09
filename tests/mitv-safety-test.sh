#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/adb" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$ADB_LOG"
case "$*" in
  "connect 192.168.1.4:5555") echo 'connected' ;;
  "-s 192.168.1.4:5555 get-state") echo "${MOCK_STATE:-device}" ;;
  "-s 192.168.1.4:5555 shell getprop ro.product.model") echo "${MOCK_MODEL:-MiTV-ASTP0}" ;;
  "-s 192.168.1.4:5555 shell getprop ro.build.version.incremental") echo "${MOCK_BUILD:-23.2.15.1886}" ;;
  "-s 192.168.1.4:5555 shell getprop ro.build.version.sdk") echo "${MOCK_SDK:-28}" ;;
  "-s 192.168.1.4:5555 shell getprop ro.product.cpu.abi") echo "armeabi-v7a" ;;
  "-s 192.168.1.4:5555 shell pm list packages --user 0")
    printf 'package:com.miui.analytics\npackage:com.miui.tv.analytics\npackage:com.mitv.shoplugin\npackage:com.mitv.tvhome\npackage:com.spocky.projengmenu\npackage:com.xiaomi.smarthome.tv\n' ;;
  "-s 192.168.1.4:5555 shell pm list packages -d --user 0")
    printf 'package:com.mitv.shoplugin\n'
    if [ -f "$MOCK_ACTIVE_DISABLED" ]; then printf 'package:com.miui.analytics\n'; fi ;;
  "-s 192.168.1.4:5555 shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME")
    echo 'com.mitv.tvhome/.MainActivityUserMode' ;;
  "-s 192.168.1.4:5555 shell pm disable-user --user 0 com.miui.analytics")
    touch "$MOCK_ACTIVE_DISABLED"; echo 'new state: disabled-user' ;;
  "-s 192.168.1.4:5555 shell pm enable --user 0 com.miui.analytics")
    rm -f "$MOCK_ACTIVE_DISABLED"; echo 'new state: enabled' ;;
  *) echo "Unexpected mock ADB request: $*" >&2; exit 70 ;;
esac
MOCK
chmod +x "$TMP/adb"
export PATH="$TMP:$PATH"
export ADB_LOG="$TMP/adb-log"
export MOCK_ACTIVE_DISABLED="$TMP/disabled-miui-analytics"
export TV_FRESH_BACKUP_DIR="$TMP/backups"
export MOCK_MODEL='MiTV-ASTP0'
if bash "$ROOT/scripts/mitv-debloat.sh" switchhome 192.168.1.4 com.spocky.projengmenu/.ui.home.MainActivity --confirm-legacy-home > "$TMP/legacy" 2>&1; then
  echo 'ERROR: legacy HOME takeover was allowed' >&2; exit 1
fi
[ ! -f "$ADB_LOG" ] || { echo 'ERROR: legacy command touched ADB' >&2; exit 1; }
bash "$ROOT/scripts/mitv-debloat.sh" debloat 192.168.1.4 > "$TMP/preview"
grep -q 'com.miui.analytics' "$TMP/preview"
! grep -Eq 'disable-user|uninstall|pm clear|pm enable' "$ADB_LOG"
if bash "$ROOT/scripts/mitv-debloat.sh" debloat 192.168.1.4 --apply com.xiaomi.smarthome.tv > "$TMP/protected" 2>&1; then
  echo 'ERROR: Mi Home disabled' >&2; exit 1
fi
! grep -Eq 'disable-user|uninstall|pm clear|pm enable' "$ADB_LOG"
export MOCK_MODEL='MiTV-UNKNOWN'
if bash "$ROOT/scripts/mitv-debloat.sh" debloat 192.168.1.4 --apply com.miui.analytics > "$TMP/unknown" 2>&1; then
  echo 'ERROR: unvalidated model was allowed' >&2; exit 1
fi
! grep -Eq 'disable-user|uninstall|pm clear|pm enable' "$ADB_LOG"
export MOCK_MODEL='MiTV-ASTP0'
bash "$ROOT/scripts/mitv-debloat.sh" debloat 192.168.1.4 --apply com.miui.analytics > "$TMP/applied"
[ -f "$MOCK_ACTIVE_DISABLED" ] || { echo 'ERROR: not disabled' >&2; exit 1; }
SNAP="$(find "$TV_FRESH_BACKUP_DIR" -maxdepth 1 -type d -name '192.168.1.4_*' | head -1)"
[ -d "$SNAP" ] || { echo 'ERROR: snapshot not found' >&2; exit 1; }
grep -Fxq 'com.miui.analytics' "$SNAP/changed.txt"
grep -Fxq 'package:com.mitv.shoplugin' "$SNAP/disabled-before.txt"
bash "$ROOT/scripts/mitv-debloat.sh" restore 192.168.1.4 "$SNAP" > "$TMP/restored"
[ ! -f "$MOCK_ACTIVE_DISABLED" ] || { echo 'ERROR: package not restored' >&2; exit 1; }
! grep -q 'pm enable --user 0 com.mitv.shoplugin' "$ADB_LOG"
! grep -q 'uninstall' "$ADB_LOG"
export MOCK_BUILD='99.99.99'
if bash "$ROOT/scripts/mitv-debloat.sh" restore 192.168.1.4 "$SNAP" >/dev/null 2>&1; then
  echo 'ERROR: firmware drift accepted' >&2; exit 1
fi
if bash "$ROOT/scripts/mitv-debloat.sh" list '192.168.1.4;rm -rf /' >/dev/null 2>&1; then
  echo 'ERROR: untrusted IP accepted' >&2; exit 1
fi
echo 'PASS: read-only preview, protected-package block, model guard, snapshot, precise restore, firmware guard, invalid IP'
