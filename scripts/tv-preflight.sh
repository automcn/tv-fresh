#!/usr/bin/env bash
# Read-only Xiaomi/MIUI TV compatibility inventory; does not delete, disable or clear applications.
set -euo pipefail
ADB_BIN="${ADB_BIN:-adb}"
TARGET="${1:-}"

usage() {
  echo "用法: bash scripts/tv-preflight.sh <电视IP[:ADB端口]>" >&2
  echo "只读检查：米家/付费视频/小爱/桌面/系统输入源相关包，不改变电视配置。" >&2
  exit 2
}
[ "$#" -eq 1 ] && [ -n "$TARGET" ] || usage
case "$TARGET" in
  *[!a-zA-Z0-9.:-]* | -* | :* | *:) usage ;;
esac
command -v "$ADB_BIN" >/dev/null 2>&1 || { echo "找不到 ADB: $ADB_BIN" >&2; exit 3; }

SERIAL="$TARGET"
case "$TARGET" in
  *:*) ;;
  *) SERIAL="$TARGET:5555" ;;
esac

if ! "$ADB_BIN" connect "$SERIAL" >/dev/null 2>&1; then
  echo "无法连接 $SERIAL：请在电视端启用 ADB、检查同网段及授权。" >&2
  exit 4
fi
STATE="$("$ADB_BIN" -s "$SERIAL" get-state 2>/dev/null || true)"
if [ "$STATE" != "device" ]; then
  echo "ADB 状态为 ${STATE:-unknown}（应为 device），未执行设备检查。" >&2
  exit 5
fi

remote() { "$ADB_BIN" -s "$SERIAL" shell "$@" 2>/dev/null | tr -d '\r'; }
installed="$(remote pm list packages --user 0)"
disabled="$(remote pm list packages -d --user 0 || true)"
if ! printf '%s\n' "$installed" | grep -q '^package:'; then
  echo "未能读取已安装包清单；停止，避免错误判断。" >&2
  exit 6
fi

show_candidates() {
  local label="$1" pattern="$2"
  echo
  echo "== ${label}（仅候选，不能根据名字直接卸载）"
  local matched
  matched="$(printf '%s\n' "$installed" | sed -n 's/^package://p' | grep -Ei "$pattern" || true)"
  if [ -n "$matched" ]; then printf '%s\n' "$matched"; else echo "（未检出；不代表功能不存在）"; fi
}
package_status() {
  local name="$1"
  if printf '%s\n' "$installed" | grep -Fxq "package:$name"; then
    if printf '%s\n' "$disabled" | grep -Fxq "package:$name"; then
      printf '%-44s 已安装但已禁用\n' "$name"
    else
      printf '%-44s 已安装\n' "$name"
    fi
  else
    printf '%-44s 未在当前用户安装列表找到\n' "$name"
  fi
}

echo "电视：$SERIAL"
echo "型号：$(remote getprop ro.product.model || true)"
echo "系统：Android $(remote getprop ro.build.version.release || true)"
echo "CPU：$(remote getprop ro.product.cpu.abi || true)"
echo "已安装包：$(printf '%s\n' "$installed" | grep -c '^package:' || true)"
echo
echo "== 关键基础组件（具体包名因固件而异）"
for p in \
  com.xiaomi.mitv.settings com.xiaomi.mitv.systemui com.xiaomi.voicecontrol \
  com.android.packageinstaller com.xiaomi.mitv.tvplayer \
  com.mitv.tvhome com.android.tv.settings com.spocky.projengmenu
do
  package_status "$p"
done

show_candidates "米家/小爱/家庭设备/投屏" '(^|[.])(mi(o|home|ot|io)|smarthome|voice|miplay|airkan|smartshare|cast|screen|wfdsink|account|passport)([.]|$)'
show_candidates "付费视频/播放授权/电信 IPTV" '(iqiyi|qiyi|gitv|ktcp|youku|mgtv|bestv|telecom|iptv|shanghai|drm|widevine|video|player|cibn|newtv)'
show_candidates "桌面/输入源/系统设置" '(tvhome|projengmenu|launcher|fallback|input|settings|hdmi|source)'

echo
echo "== 检查结论"
echo "此脚本只枚举安装状态，不读取米家账号/会员令牌，不验证真实会员权益。"
echo "请人工验证：米家手机/电视联动、小爱语音、奇异果会员付费片、HDMI 电信 IPTV 直播/回看。"
echo "未做卸载、禁用、清数据、改路由器或修改账号等操作。"
