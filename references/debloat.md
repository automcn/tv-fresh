# 去广告与系统精简（家庭安全模式）

> 必须先读 [兼容性](compatibility.md) 与 [CleanYourTV 工程实践](cleanyourtv-practices.md)。
> Android 6.0.1 的 MIUI TV 1.3.85 **尚未通过 ADB 验证，默认不执行精简**。

## 推荐步骤

1. 只读盘点：`bash scripts/tv-preflight.sh <电视IP>`，记录 Android API、型号/固件、包状态。
2. 家庭先验证：上海电信 IPTV、HDMI、米家、小爱、投屏、奇异果/爱奇艺等会员视频。
3. 只读预览：`bash scripts/mitv-debloat.sh debloat <电视IP>`。
4. 在已验证机型、用户明确决定**某一个包**并确保 HOME 可备份时，才允许
   `bash scripts/mitv-debloat.sh debloat <电视IP> --apply <单个候选包名>`。
5. 脚本创建只读快照后只执行 `pm disable-user --user 0`，并验证结果。
6. 每次执行后检查家庭功能；出现异常立即使用输出的 `restore <电视IP> <快照目录>`。

## 候选不等于安全名单

脚本候选为少量广告与统计包，例如 `com.miui.analytics`、`com.miui.tv.analytics`、
`com.miui.systemAdSolution`、`com.mitv.tvad`、`com.mitv.analysis`、`com.mitv.shoplugin`。
**只有核对具体设备且明确不会影响在用功能时，才能考虑停用。**

名称带广告、统计也可能与其它服务有联系，停用不保证去掉所有系统或视频 App 广告。
**禁止**未核对就批量停用米家、小爱、投屏、系统播放器/HDMI 输入、账户/会员/DRM、应用商店或固件更新服务。
牌照方（CIBN/银河奇异果、NewTV、腾讯等）不得作为“冗余预装”自动卸载。

## OTA 后与旧设备

固件升级后包状态可能变化，**仅重新运行只读检查**，不可自动重放历史禁用列表。
Android 6 的 `cmd package` 可能没有 HOME 查询能力，脚本需在变更前取得可靠快照；
若做不到便停止，不允许通过禁用 PatchWall/`com.android.tv.settings` 试错。

详见：[Android 6 兼容](legacy-miui-android6.md)。
