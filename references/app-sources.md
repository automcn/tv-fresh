# 电视应用来源与安装兼容性

> 不下载未知网盘重打包 APK。**下载 ZIP 完整性检查不等同于 APK 签名验证或真机兼容证明。**
> 本文中的 Android 9 “已实测”与 Android 6 “已下载待测试”明确区分。

## Projectivy（当前推荐候选）

| 项目 | 来源与状态 |
| --- | --- |
| 候选版本 | [Projectivy Launcher 4.73（作者官方 GitHub）](https://github.com/spocky/miproja1/releases/tag/4.73) |
| 官方文件 | `ProjectivyLauncher-4.73-c98-xda-release.apk` |
| 官方下载 | `https://github.com/spocky/miproja1/releases/download/4.73/ProjectivyLauncher-4.73-c98-xda-release.apk` |
| 包名 | `com.spocky.projengmenu` |
| Android 最低要求 | 根据 4.73 发行渠道的 Android 6.0+ 变体元数据，API 23；安装前还要独立复核当前下载文件 |
| Android 6 特别修复 | 官方 4.73 修复部分 Android 6 设备启动输入源崩溃、小米 Android 6 输入源端口显示问题 |
| 下载校验（2026-11-09） | 上海 Mac 已下载官方 APK，ZIP 完整；本机 SHA-256: `74e33af1e5e13831a69a0669d2b68b02150bf9df1ae1df437dc67e3f8d52c790` |
| 实际电视 | **未安装，未做兼容测试** |

之前锁定的 [4.72](https://github.com/spocky/miproja1/releases/tag/4.72) 仍是旧版参考，但对 Android 6 + HDMI 场景建议优先评估 4.73。

## 原仓库 Android 9 已有经验（不直接用在 Android 6）

- [Clash Meta for Android](https://github.com/MetaCubeX/ClashMetaForAndroid/releases) — Android 9 上曾实测；API 23 支持情况、权限以及系统 VPN 影响须另查。
- [SmartTube](https://github.com/yuliskov/SmartTube) — 国外公开视频；按需使用，不替代国内付费视频权益。
- [FongMi/OK影视](https://github.com/FongMi/Release) / 影视仓 / TVBox — 老系统兼容性随各分支变化，需分别核对 APK minSdk/ABI，勿自动安装多个重复播放器。
- [ADBKeyboard](https://github.com/senzhk/ADBKeyboard) — 仅在真实输入法无法完成网址输入时按需使用，别改变默认输入法后忘记恢复。

**安装前最低核对**：来源与签名、文件完整性、`minSdk <= 23`、支持 `armeabi-v7a`、遥控器可操作、正常卸载/回滚路径，以及米家、会员播放、IPTV HDMI 是否仍正常。

## Android 6 旧机型特别提醒

- 目前 65 寸小米 4A/MIUI TV 1.3.85 已确认是 Android 6.0.1/API 23、ARMv7，不是上表的 Android 9 机型。
- SmartTube 官方支持 Android 4.3+，优先稳定版 ARMv7；CMFA 项目 minSdk=21 并提供 ARMv7。
- Projectivy 4.72 可作为候选（官方在 4.65～4.70 有 Android 6 相关修复），但只安装测试、不立即替换系统 HOME。
- **FongMi 5.8.2 的旧 Release URL 不保证仍可用**；新版本也未在此确认 Android 6 minSdk，请勿直接安装。影视仓先检查 APK。
- 详细分层策略见 [Android 6 影音完全体](android6-av-suite.md)。
