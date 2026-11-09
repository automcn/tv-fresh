# 小米电视 4A / Android 6.0.1：影音完全体兼容矩阵

> 2026-11-09 上海局域网已授权 ADB 完成**只读**检查。
> 电视：MiTV4A / matrix / Android 6.0.1 (API 23) / armeabi-v7a / build 8.8.20.1275。
> 约 1.6GB 物理内存、剩余约 19.4GB 存储。未安装本页的新方案，也未执行禁用/清理。
> 安全：不得将真实家庭地址、MAC、序列号、会员凭证及原始应用清单提交仓库。

## 现有 TV 状态

- 共 92 个安装包、22 个第三方包、**0 个已禁用**。
- 原生 HOME `com.mitv.tvhome`，米家 `com.xiaomi.smarthome.tv`，小爱 `com.xiaomi.voicecontrol`。
- 视频相关包：`com.gitvdemo.video`（银河奇异果）、`com.ktcp.video`（腾讯视频）、`com.cibn.tv`（优酷）等。
- 已安装 `cn.sh.smartiptv` 3.0.0.2。**只知存在，不代表已确认能观看上海电信 IPTV**。
- HDMI 输入组件 `com.droidlogic.tvinput`、小米外部输入 `com.xiaomi.mitv.tvplayer/.ExternalSourceActivity` 均存在；
  `EXTSRC_PLAY` action 可从包表看到，但不能照搬其它机型的 HDMI 数值。
- 未检出 Projectivy、CMFA、SmartTube、影视仓；用户已有会员应用应保留。
- 原版 Android 6 系统**没有 `cmd` 命令**（`/system/bin/sh: cmd: not found`），
  所以原 Android 9 的 `cmd package set-home-activity` 流程不可执行，不得用禁用设置/桌面来补救。

## 安装兼容性优先级

| 组件 | 系统下限/官方验证线索 | 优先级 | 本机实施原则 |
| --- | --- | --- | --- |
| [SmartTube Stable](https://github.com/yuliskov/SmartTube/releases) | 官方支持 Android 4.3+；有 ARMv7 构建；中国 MIUI 建议稳定版 | P1 | 官方签名 APK，先 AVC(H.264) 720p，再测试 1080p、遥控器与网络 |
| [CMFA](https://github.com/MetaCubeX/ClashMetaForAndroid/releases) | 构建 minSdk 21、ARMv7 | P1（需要访问 YouTube 才装） | 手动授权 VPN；国内服务/局域网直连；单一代理，测内存占用；节点密钥不提交 |
| [Projectivy 4.72](https://github.com/spocky/miproja1/releases/tag/4.72) | 4.65～4.70 有小米 Android6 HDMI/启动/HTTPS 兼容修复 | P2 | 先只安装和打开 App，不自动接管 HOME；优先静态背景、5～8 个常用应用 |
| 影视仓/TVBox（旧系统兼容构建） | 各 APK 的 `minSdk`、ABI 因版本不同而异 | P2 | **仅选一个**，先在电脑上检查官方来源、Manifest、签名、权限，再由用户决定是否安装 |
| [FongMi Release](https://github.com/FongMi/Release/releases) | 新版 5.8.x 的 Android6 兼容尚未完成官方 APK Manifest 核验；旧版分支可能不同 | 暂缓 | 不自动安装原 README 的 5.8.2 链接；确认实际 minSdk 后再选 |
| CleanYourTV 自带 Launcher | 最低 Android 8.0（API26） | 不适用 | 只借鉴安全流程，不安装它的桌面 |

**下载链接与版本会变化**，安装前通过官方 Release 获取 APK，核对包名、签名、`minSdk` 和 CPU ABI；
不能因 APK 文件名包含 `32位` 就认定 Android 6 可以用。

## 代理与网络推荐

- CMFA 配置使用 DNS/分流与 `CN,DIRECT` 等规则：**国内付费应用、本地网段、米家、机顶盒的 IPTV 网络不能因代理失效**。
- 只在需要 YouTube 等服务时启动 VPN，且设置关闭后所有国内应用可继续工作；不要让“启动电视”依赖代理。
- 电视 RAM 约 1.6GB：不要长期同时保活多个影视聚合客户端、重型代理管理 UI 和后台内容抓取。
- 订阅配置、Token、代理密码放本机私有目录，不写进 GitHub、公开配置或日志。
- 不对第三方非授权影视源做预装和自动推送，不用公开 M3U 替代已订阅的上海电信 IPTV。

## 最小执行步骤（**需要用户明确允许安装才执行**）

1. 保留现有正版会员应用与米家；先录下主要功能可用状态。
2. 下载安装并用电脑校验 **SmartTube Stable ARMv7**；电视上只试运行，不覆盖其他应用。
3. 如 YouTube 需要代理，才安装 **CMFA ARMv7**，手动授予 VPN，设置国内/局域网直连并验证退出 VPN 后会员视频正常。
4. 再试 **Projectivy 4.72** 的非默认桌面启动和 HDMI 快捷入口；若异常立刻退出，原 HOME 完全保留。
5. 影视仓/TVBox 选择一款兼容 APK，先小范围验证遥控器、字幕、解码、稳定性；无需再装第二套相似软件。
6. 最后才考虑广告/遥测包精简，按 [CleanYourTV 安全流程](cleanyourtv-practices.md) 做快照、单包变更和回归。
7. 退出调试，关闭电视 ADB 5555，不把调试端口对公网开放。

## 实际验收

- IPTV 直播、回看、声音、HDMI 与 HOME 返回正常。
- 米家控制、小爱语音与投屏保持可用。
- 奇异果/爱奇艺、腾讯、优酷已付费权益及受保护影片正常。
- SmartTube 从 HDMI/正版视频切入切出正常，1080p AVC 无卡顿或音画不同步。
- CMFA 启用/关闭后国内网络均正常；重启后电视无需 VPN 即可正常工作。
- 2～3 次电视休眠/唤醒后不卡死、不循环重启。
