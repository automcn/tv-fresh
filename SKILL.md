---
name: tv-fresh
version: 1.1.0
description: "小米电视(MIUI TV)改造技能：去广告、换桌面、装代理/YouTube/影视仓、批量清理预装、远程操控电视。当用户提到小米电视/Redmi电视/电视盒子去广告、换Launcher、TVBox/影视仓配置、电视装代理或YouTube、adb 操作电视时使用。需要电视与电脑同网且开启 ADB 调试。"
metadata:
  requires:
    bins: ["adb"]
---

# 小米电视改造（mitv-mod）

免 Root 改造国内 MIUI TV。**默认只读；更改前备份，单包确认后仅 `pm disable-user --user 0`，
记录原始状态并可精确恢复，不允许批量卸载系统组件。** 原作者实测 MiTV-ASTP0 / Android 9；
老款 65 寸小米 4A / MIUI TV 1.3.85 / Android 6.0.1 为待 ADB 核实的单独兼容场景。

## 前置：连接电视

```bash
adb connect <TV_IP>:5555
adb devices   # device=通 / unauthorized=电视上有授权弹窗等用户点
```

电视侧开 ADB 的路径、以及"每次重启 ADB 被复位"的应对 → 见 [`references/setup-adb.md`](references/setup-adb.md)

## 任务路由（按用户需求读对应 reference，再动手）

| 用户想做的事 | 必读 |
|---|---|
| MIUI TV 1.3.85 / Android 6 / 老款小米 4A | [`references/legacy-miui-android6.md`](references/legacy-miui-android6.md) |
| 旧版小米电视代理 / YouTube / 影视仓完全体 | [`references/android6-av-suite.md`](references/android6-av-suite.md) |
| 家庭常用/首页/推荐/方便看电影 | [`references/family-home.md`](references/family-home.md)、[`references/similar-projects.md`](references/similar-projects.md) |
| 上海电信 IPTV / 机顶盒 / HDMI | [`references/iptv-shanghai.md`](references/iptv-shanghai.md) |
| 米家 / 小爱 / 爱奇艺会员 / 其他付费应用 | [`references/compatibility.md`](references/compatibility.md) |
| 去广告 / 精简系统 | [`references/debloat.md`](references/debloat.md) |
| 换桌面（开机进第三方 Launcher） | [`references/launcher-swap.md`](references/launcher-swap.md) |
| 电视装代理（Clash Meta） | [`references/proxy-youtube.md`](references/proxy-youtube.md) |
| 电视看 YouTube | [`references/proxy-youtube.md`](references/proxy-youtube.md) |
| 装/配 影视仓、OK影视(FongMi)、TVBox | [`references/streaming-apps.md`](references/streaming-apps.md) |
| 批量卸预装 / 修权限 | [`references/cleanup-permissions.md`](references/cleanup-permissions.md) |
| **任何"在电视上输文字/点按钮/看界面"的操作** | [`references/remote-toolbox.md`](references/remote-toolbox.md) ← 强制先读 |
| **安装任何 APK 之前** | [`references/app-sources.md`](references/app-sources.md) ← 只用实测源+装后核对包名 |

## 家庭兼容性检查（只读）

[`scripts/tv-preflight.sh`](scripts/tv-preflight.sh) <TV_IP>：盘点机型、米家/语音/投屏/视频/桌面相关包。
[`scripts/tv-favorites.py`](scripts/tv-favorites.py) --ip <TV_IP>：根据真实已安装包输出家庭常用列表，
仅给出手动配置建议，不是直接导入 Projectivy 的配置。
只读结果只是候选清单，不能说明实际会员可用性或认证依赖。

## 一键脚本

[`scripts/mitv-debloat.sh`](scripts/mitv-debloat.sh)：`list` / `debloat`（只读）/
`debloat --apply <单包>`（仅核实机型 + 用户同意）/ `restore` / `sethome` / `restorehome` / `install`。
**已禁用旧式 `switchhome` 和批量 `pm grant`。**

## 硬性安全规则

1. **不得卸载/清除系统包和用户数据**：`pm uninstall`、`pm clear` 不属于本流程；单包停用前先快照，按原状态恢复。
2. **禁用/卸载任何系统包前，向用户展示清单并获确认**；执行后立刻给出对应恢复命令
3. **绝不动**：米家/米家连接服务、账号登录及授权、爱奇艺/银河奇异果等付费 App 及 DRM/牌照依赖、HDMI/输入源/机顶盒；`com.xiaomi.mitv.settings`（中文设置）、`com.xiaomi.mitv.systemui`、`com.xiaomi.mitv.tvplayer`、`com.android.packageinstaller`、`com.xiaomi.voicecontrol`（语音）、投屏相关（miplay/smartshare/airkan/wfdsink）
4. **Android 6 ≠ Android 9**：按 `ro.build.version.sdk` 和 CPU ABI 检查安装包最低要求。CleanYourTV Launcher 最低 Android 8 不能用于 Android 6；Projectivy 4.72 最低 API 23 但仍需真机测。不同固件的 `cmd package` 可能不可用，严禁用禁用 `com.android.tv.settings` 进行试错。
5. 电视上输入文字前必读 remote-toolbox，先验证实际输入法行为；不得用旧机型经验认定所有电视都会转全角。

## 验证原则

- 界面状态以 `uiautomator dump` 的 XML 为准，截图+视觉判读仅做辅助（有误读先例）
- 每步操作后 dump 复核（弹窗是否关闭/字段是否正确），不凭命令返回值推断界面
