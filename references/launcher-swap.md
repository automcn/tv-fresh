# 小米电视更换默认桌面：安全优先

> 小米国内版 MIUI TV 的 HOME 机制随型号、固件变化。**不应为了强制使用第三方桌面而禁用系统设置或 HDMI 输入源服务。**

## 默认方案

1. 确认电视型号、固件与 ADB 授权，先执行只读盘点。
2. 确保 Projectivy Launcher 已安装并能从当前桌面正常打开。
3. 尝试无破坏的首选 HOME 设置：

```bash
bash scripts/mitv-debloat.sh sethome <电视IP> com.spocky.projengmenu/com.spocky.projengmenu.ui.home.MainActivity
```

4. 用电视实体遥控器按 HOME 验证，再重启验证。
5. 如果设定不生效，**停下，保留原厂 PatchWall、系统设置与视频播放服务**。

## 为什么不执行旧方案？

本仓库原有 MiTV-ASTP0/Android 9 逆向曾发现：
- 某固件 `cmd package set-home-activity` 报 Success 但未成为真正 HOME；
- 禁用 PatchWall 可能使 HOME 解析到 AOSP FallbackHome；
- 当时的特殊处理会禁用 `com.android.tv.settings`。

**这是特定固件历史实验，不是所有小米电视通用安全策略。** CleanYourTV 的同型号其它固件实测显示，换一个 Launcher 应用 ID 可以在保持原厂桌面启用的情况下成功成为默认 HOME。详见 [设备资料](https://github.com/Gathin23/cleanyourtv/blob/main/examples/xiaomi-mitv-astp0/README.md)。

当前脚本已停止旧式 `switchhome`，不再提供禁用 AOSP 设置的自动路径。

## 米家 / IPTV / 会员兼容验收

每次换桌面都要实测：手机米家和电视米家、小爱、投屏、输入源菜单、上海电信 IPTV 直播/回看、爱奇艺/奇异果付费片播放、系统设置、遥控器 HOME/返回/音量。

不要用 `settings put secure enabled_accessibility_services ...` 直接覆盖已有无障碍服务完整列表，否则可能误删小爱或其他家庭功能授权。需要额外无障碍服务时，先读取现有设置并由用户逐项确认。

## 恢复

若以前曾卸载用户 0 的 PatchWall 或禁用 AOSP 设置，可以**明确人工决定**后通过：

```bash
bash scripts/mitv-debloat.sh restorehome <电视IP>
```

这会重新安装/启用原厂桌面与 AOSP 设置；不会恢复其它 App 数据，也不会移除 Projectivy。请按 HOME 复查。恢复精确包禁用状态应使用对应快照的 `restore`。

参考：[兼容性红线](compatibility.md)、[HDMI 输入源](hdmi-sources.md)。
