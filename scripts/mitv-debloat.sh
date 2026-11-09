#!/usr/bin/env bash
# Safety-first MiTV maintenance: no root, no pm uninstall, no pm clear.
set -euo pipefail

usage() {
  cat <<'HELP'
用法:
  bash scripts/mitv-debloat.sh list <IP>                      # 只读
  bash scripts/mitv-debloat.sh debloat <IP>                   # 候选清单，无修改
  bash scripts/mitv-debloat.sh debloat <IP> --apply <包名>    # MiTV-ASTP0 单包停用
  bash scripts/mitv-debloat.sh restore <IP> <快照目录>       # 精确恢复
  bash scripts/mitv-debloat.sh sethome <IP> <包/Activity>    # 首选桌面，不禁用系统包
  bash scripts/mitv-debloat.sh restorehome <IP>              # 人工恢复原厂 HOME
  bash scripts/mitv-debloat.sh install <IP>                  # 需 LAUNCHER_APK
旧命令 switchhome 已禁用：不能自动卸载原厂桌面、禁用 AOSP 设置。
HELP
}
die(){ printf '错误：%s\n' "$*" >&2; exit 2; }
CANDIDATES=( com.miui.analytics com.miui.tv.analytics com.miui.systemAdSolution com.mitv.tvad com.mitv.analysis com.mitv.shoplugin )
ACTION="${1:-}"
TV_IP="${2:-}"
TV_SERIAL=""
tvadb(){ adb -s "$TV_SERIAL" "$@"; }
sanitize(){ tr -d '\r'; }
home_component(){
  # Android 6 firmware may not implement 'cmd package resolve-activity'.
  # Treat unknown HOME as a failure to verify; never 'fix' it by disabling settings.
  local out
  out="$(tvadb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null | sanitize)" || out=""
  if printf '%s\n' "$out" | grep -Eq '^[A-Za-z0-9_.]+/[A-Za-z0-9_.$]+$'; then
    printf '%s\n' "$out" | grep -E '^[A-Za-z0-9_.]+/[A-Za-z0-9_.$]+$' | tail -1
    return 0
  fi
  return 1
}
connect(){
  command -v adb >/dev/null 2>&1 || die '找不到 adb'
  [[ "$TV_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || die '仅接受 IPv4 地址'
  local oct
  for oct in ${TV_IP//./ }; do
    [ "${#oct}" -le 3 ] && [ "$((10#$oct))" -le 255 ] || die 'IP 地址超出范围'
  done
  TV_SERIAL="$TV_IP:5555"
  adb connect "$TV_SERIAL" >/dev/null || die 'ADB 无法连接'
  [ "$(tvadb get-state 2>/dev/null || true)" = "device" ] || die 'ADB 未授权或设备离线'
}
inventory(){
  INSTALLED="$(tvadb shell pm list packages --user 0 | sanitize)" || die '读取安装包失败'
  printf '%s\n' "$INSTALLED" | grep -q '^package:' || die '空安装包清单'
  DISABLED="$(tvadb shell pm list packages -d --user 0 | sanitize)" || die '读取禁用包失败'
  MODEL="$(tvadb shell getprop ro.product.model | sanitize)"
  BUILD="$(tvadb shell getprop ro.build.version.incremental | sanitize)"
  SDK="$(tvadb shell getprop ro.build.version.sdk | sanitize)"
  ABI="$(tvadb shell getprop ro.product.cpu.abi | sanitize)"
}
has_package(){ printf '%s\n' "$INSTALLED" | grep -Fxq "package:$1"; }
was_disabled(){ printf '%s\n' "$DISABLED" | grep -Fxq "package:$1"; }
candidate(){
  local i
  for i in "${CANDIDATES[@]}"; do [ "$1" = "$i" ] && return 0; done
  return 1
}
backup_root(){
  local root="${TV_FRESH_BACKUP_DIR:-$HOME/.tv-fresh/backups}"
  (umask 077; mkdir -p "$root") || die '创建备份目录失败'
  printf '%s' "$root"
}
snapshot(){
  local root home
  # Refuse before creating any snapshot if HOME cannot be reliably queried.
  home="$(home_component)" || die '无法可靠解析 HOME（Android 6 可能不支持 cmd package），拒绝修改'
  [ -n "$home" ] || die 'HOME 为空，拒绝继续'
  root="$(backup_root)"
  SNAP="$root/${TV_IP}_$(date -u +%Y%m%dT%H%M%SZ)_$$"
  (umask 077; mkdir -p "$SNAP") || die '创建快照失败'
  printf '%s\n' "$TV_SERIAL" > "$SNAP/serial.txt"
  printf '%s\n' "$MODEL" > "$SNAP/model.txt"
  printf '%s\n' "$BUILD" > "$SNAP/build.txt"
  printf '%s\n' "$INSTALLED" > "$SNAP/installed-before.txt"
  printf '%s\n' "$DISABLED" > "$SNAP/disabled-before.txt"
  printf '%s\n' "$home" > "$SNAP/home-before.txt"
  : > "$SNAP/changed.txt"
  chmod 600 "$SNAP"/*.txt
  printf '本地快照：%s\n' "$SNAP"
}
status(){
  printf '设备：%s / %s / Android API %s / CPU %s / 固件 %s\n' "$TV_IP" "$MODEL" "$SDK" "$ABI" "$BUILD"
  echo '候选广告/统计组件（不是自动安全白名单）：'
  local p state
  for p in "${CANDIDATES[@]}"; do
    state='未找到'
    if has_package "$p"; then
      state='已启用'
      if was_disabled "$p"; then state='已禁用'; fi
    fi
    printf '  %-38s %s\n' "$p" "$state"
  done
  echo 'HOME 解析：'
  home_component || echo '系统未返回可验证的 HOME 组件：可能是旧版 Android 6，请勿强制替换或禁用系统桌面。'
  echo '仅检查包状态；米家、会员权益、HDMI/IPTV 须由用户实际验证。'
}
apply_one(){
  local pkg="${1:-}" current
  [ -n "$pkg" ] && candidate "$pkg" || die '拒绝未知包：不可停用米家/语音/投屏/视频/系统组件'
  [ "$MODEL" = 'MiTV-ASTP0' ] || die "暂只允许 MiTV-ASTP0 单包变更，实际型号是 $MODEL"
  has_package "$pkg" || die "电视未安装 $pkg"
  if was_disabled "$pkg"; then echo "${pkg} 原已禁用，不修改"; return; fi
  snapshot
  if ! tvadb shell pm disable-user --user 0 "$pkg"; then
    tvadb shell pm enable --user 0 "$pkg" || true
    die '停用失败，已尝试恢复'
  fi
  current="$(tvadb shell pm list packages -d --user 0 | sanitize)" || die '停用后无法读取状态；请立即检查'
  if ! printf '%s\n' "$current" | grep -Fxq "package:$pkg"; then
    tvadb shell pm enable --user 0 "$pkg" || true
    die '无法验证已停用，已尝试恢复'
  fi
  printf '%s\n' "$pkg" >> "$SNAP/changed.txt"
  echo "已停用 ${pkg}；现在检查 IPTV/奇异果/米家等是否正常。"
  echo "恢复：bash scripts/mitv-debloat.sh restore $TV_IP '$SNAP'"
}
restore_one(){
  local dir="${1:-}" root p
  [ -n "$dir" ] && [ -d "$dir" ] || die '缺少真实快照目录'
  root="$(cd "$(backup_root)" && pwd -P)"
  dir="$(cd "$dir" && pwd -P)"
  case "$dir" in "$root"/*) ;; *) die '快照路径不在备份目录';; esac
  local f
  for f in serial model build installed-before disabled-before home-before changed; do
    [ -f "$dir/$f.txt" ] || die "快照缺文件 $f"
  done
  [ "$(cat "$dir/serial.txt")" = "$TV_SERIAL" ] || die '快照设备不匹配'
  [ "$(cat "$dir/model.txt")" = "$MODEL" ] || die '快照型号不匹配'
  [ "$(cat "$dir/build.txt")" = "$BUILD" ] || die '固件已升级，不自动恢复旧清单'
  while IFS= read -r p || [ -n "$p" ]; do
    [ -n "$p" ] || continue
    candidate "$p" || die '快照包含未知包名'
    grep -Fxq "package:$p" "$dir/installed-before.txt" || die '快照包不在原安装清单'
    if grep -Fxq "package:$p" "$dir/disabled-before.txt"; then continue; fi
    tvadb shell pm enable --user 0 "$p"
    echo "已恢复 $p"
  done < "$dir/changed.txt"
  echo '恢复完成；原先已禁用的包不做修改。'
}
set_home(){
  local comp="${1:-}" pkg actual
  [[ "$comp" =~ ^[a-zA-Z0-9._]+/[a-zA-Z0-9._]+$ ]] || die '目标必须是 包名/Activity'
  pkg="${comp%%/*}"
  has_package "$pkg" || die "找不到 $pkg"
  snapshot
  tvadb shell cmd package set-home-activity "$comp" || die '设置首选 HOME 失败'
  actual="$(home_component)" || die '无法核对 HOME；停止操作'
  printf '%s\n' "$actual"
  if ! printf '%s\n' "$actual" | grep -Fq "$pkg"; then
    die '未能验证目标桌面成为 HOME；保留 PatchWall 和系统设置，勿强制禁用'
  fi
  echo '默认 HOME 已解析到目标包；还需实体遥控器和重启复测。'
}
[ -n "$ACTION" ] && [ -n "$TV_IP" ] || { usage; exit 2; }
[ "$ACTION" != switchhome ] || die '已禁用旧式 switchhome：禁用系统设置存在风险'
case "$ACTION" in list|debloat|restore|sethome|restorehome|install|perm) ;; *) usage; exit 2;; esac
connect
inventory
case "$ACTION" in
  list) [ "$#" -eq 2 ] || die '参数错误'; status ;;
  debloat)
    if [ "${3:-}" = '--apply' ]; then
      [ "$#" -eq 4 ] || die '只允许每次 --apply 一个明确包名'
      apply_one "$4"
    else
      [ "$#" -eq 2 ] || die '未指定合法的 --apply 包名'
      status
      echo "如明确选择某一候选：bash scripts/mitv-debloat.sh debloat $TV_IP --apply <包名>"
    fi
    ;;
  restore) [ "$#" -eq 3 ] || die '需要快照目录'; restore_one "$3" ;;
  sethome) [ "$#" -eq 3 ] || die '需要目标包/Activity'; set_home "$3" ;;
  restorehome)
    [ "$#" -eq 2 ] || die '参数错误'
    tvadb shell cmd package install-existing com.mitv.tvhome
    tvadb shell pm enable --user 0 com.mitv.tvhome
    tvadb shell pm enable --user 0 com.android.tv.settings
    echo '已恢复原厂桌面和 AOSP 设置（不清理 Projectivy）；手工验证 HOME。'
    ;;
  install)
    [ "$#" -eq 2 ] || die '参数错误'
    apk="${LAUNCHER_APK:-}"
    [ -n "$apk" ] && [ -f "$apk" ] || die '请指定已核验的 LAUNCHER_APK 路径'
    command -v unzip >/dev/null && unzip -t "$apk" >/dev/null || die 'APK 校验未通过'
    snapshot
    tvadb install -r "$apk"
    echo '完成安装；核对应用包名与遥控器焦点。'
    ;;
  perm) die '已禁用无确认的批量授权；请按单个应用问题处理' ;;
esac
