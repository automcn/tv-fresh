# 实测设备：小米电视 4A / MIUI TV 1.3.85 / Android 6.0.1

> 2026-11-09 通过上海 Mac 与授权的 ADB 进行只读核验。
> 本文刻意不记录家庭 IP、MAC、设备序列号、账号或会员令牌。
> 与原仓库 MiTV-ASTP0 / Android 9 的操作策略**不能直接混用**。

## 已确认设备事实

| 项 | 已验证值 |
| --- | --- |
| 品牌/型号 | Xiaomi / `MiTV4A`（用户说明 65 寸） |
| 设备代号 | `matrix` |
| Android | 6.0.1 / API 23 |
| CPU | `armeabi-v7a`（32 位） |
| 系统 Build | `8.8.20.1275`（版本增量 `1275`） |
| MIUI TV 版本 | 1.3.85（电视设置页面提供，未从 Android 系统属性单独验证） |
| 内存 | 约 1.6 GB，盘点时 MemAvailable 约 540 MB |
| 数据分区 | 约 26.4 GB，盘点时剩余约 19.4 GB |
| 应用包 | 92 个，第三方包 22 个，已禁用 0 个 |
| 当前 HOME | `dumpsys activity` 显示 `com.mitv.tvhome` |
| HOME 控制 | `cmd package` 返回 `/system/bin/sh: cmd: not found` |
| Projectivy | 未检测到安装，未尝试替换系统桌面 |

## 现有家庭应用和输入源（只读核对）

| 需求 | 存在的包名 | 说明 |
| --- | --- | --- |
| 上海 IPTV 客户端候选 | `cn.sh.smartiptv`（3.0.0.2） | 有 ChinaNet/CTC 相关 Activity；**尚未验证实际播放或订阅权益** |
| 爱奇艺/银河奇异果 | `com.gitvdemo.video`（Gala 视频组件） | 会员功能和 DRM 不作改动 |
| 腾讯视频 | `com.ktcp.video` | 保留原账号数据 |
| 优酷/CIBN | `com.cibn.tv`（Youku 组件） | 保留原账号数据 |
| 米家 | `com.xiaomi.smarthome.tv` | 保留配对与设备控制 |
| 小爱 | `com.xiaomi.voicecontrol` | 不停用语音服务 |
| 电视系统播放器 | `com.xiaomi.mitv.tvplayer` | 保留小米输入源与播放服务 |
| HDMI 输入服务 | `com.droidlogic.tvinput` | 当前登记 HDMI1/HW5 和 HDMI2/HW6 |
| 原生桌面 | `com.mitv.tvhome` | 继续启用，不强制停用 |

已确认厂商播放器注册 `com.xiaomi.mitv.tvplayer.EXTSRC_PLAY` 动作，但实际 HDMI 数字参数还未核实，**不能将其他机型的 23/24 直接用于这台电视**。

## 安全推荐方案

1. **先看已有 IPTV App 是否可正常直播/回看**；可用则放在常用入口，不可用则保留上海电信原机顶盒 HDMI。
2. 现有银河奇异果/腾讯/优酷继续承担正版电影、收藏与继续观看；不搞跨 App 历史数据抓取。
3. 已安装的米家、小爱和投屏组件必须保留。
4. Projectivy 官方 4.73 版本更新记录修复了 Android 6 输入源崩溃和小米 Android 6 HDMI 显示问题，且有 Android 6（API23）变体。其官方 GitHub APK 已在上海 Mac 下载、ZIP 完整性校验通过，**未安装到电视，不能宣称真机兼容验证成功**。
5. 保留原厂桌面，后续如安装 Projectivy，先手动启动测试遥控器、性能、HDMI、会员视频；不要修改 HOME，直至确认 Android 6 固件的回滚路径。
6. 当前 TV 的任意自动停用仍被 `mitv-debloat.sh` 的机型保护拒绝；清理前须另行核对机型/依赖、用户明确批准。

## 实际做过与没有做过

**完成**：ADB 授权连接，读取机型/SDK/架构、包列表和版本、HOME 进程、HDMI 输入服务、硬件资源；在电视上运行只读 `tv-preflight.sh` 与 `tv-favorites.py`。

**未做**：启动/登录 IPTV 应用、观看付费影片、切 HDMI、安装 APK、修改系统包、禁用广告、修改 HOME、重启或刷机。功能验收仍需现场遥控器实测。

## 参考

- [Projectivy 官方 4.73](https://github.com/spocky/miproja1/releases/tag/4.73)
- [CleanYourTV 小型电视设备实践](https://github.com/Gathin23/cleanyourtv)
- [原有 Android 9 路线](../README.md)
