# 参考项目比较：优先让电视更好用，而非堆叠应用

本分支范围：**无 Root、广告与桌面治理、常用入口、上海电信 IPTV HDMI、现有付费视频与米家**。
NAS 依赖与家庭媒体服务器不进入主线，如未来确有需求则在独立分支评估。

| 项目 | 最有价值的能力 | tv-fresh 的选择 |
| --- | --- | --- |
| [CleanYourTV](https://github.com/Gathin23/cleanyourtv) | 设备/固件记录、备份、逐个禁用、安全恢复、HDMI 排错流程 | **重点借鉴工程实践**；不搬运或替换现有桌面 |
| [Projectivy Launcher](https://github.com/spocky/miproja1) | 常用分类、Inputs、可选节目频道及配置备份 | 继续默认推荐；官方 GitHub 不是完整开源桌面代码 |
| [LTvLauncher](https://github.com/leanbitlab-org/LtvLauncher) | 离线首页、遥控器焦点、继续观看、快捷输入源 | 作为 UX 参考与备选，不自动换桌面 |
| [FLauncher](https://gitlab.com/flauncher/flauncher) | 干净的应用网格、手动排序 | 借鉴少而清楚的首页，不默认安装 |
| [SmartTube](https://github.com/yuliskov/SmartTube) | 公开视频及遥控器导航 | 在网络条件适合时单独选择 |
| [影视仓 / OK影视](streaming-apps.md) | 公开与社区聚合内容入口 | 已有应用保留；不绕过版权/付费/运营商认证 |

## 家庭场景的推荐组合

- **日常看电视**：Projectivy 的常用入口 → 上海电信官方 IPTV 机顶盒对应 HDMI。
- **日常看电影/追剧**：现有银河奇异果、腾讯视频、优酷等**正版电视客户端**及其收藏/继续观看。
- **公开视频/社区影视**：只保留实际使用的入口，不装重复播放器与多个不稳定聚合源。
- **智能家居**：米家、小爱和投屏作为家庭功能保留，不做性能优化牺牲品。
- **电视维护**：只读盘点 → 本机快照 → 单包禁用 → 真实设备回归 → 需要时按快照恢复。

## 不做什么

- 不自建云端推荐系统，也不采集付费应用的私有观看历史。
- 不以“去广告”为由清数据、注销会员、删 DRM/系统输入源。
- 不建设 NAS/Jellyfin/Nova/Kodi 相关集成；独立分支仅作备选，不进入本次测试或发布。
- 不把 CleanYourTV 的其它机型清理表直接复制到小米电视。

## 推荐推进顺序

P0：完成安全清理脚本与测试，保存已有米家和会员功能。

P1：用实体遥控器配置常用分类、HDMI 输入源、常用影片 App，回归检查开机和 HOME。

P2：如有明确性能问题，再比较桌面开机时间、遥控器焦点与应用响应速度，有数据再优化。

详见 [CleanYourTV 借鉴清单](cleanyourtv-practices.md)、[家庭首页](family-home.md)、[HDMI 切源](hdmi-sources.md)。
