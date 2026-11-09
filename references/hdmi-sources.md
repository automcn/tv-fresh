# 小米电视 HDMI 输入源：家庭 IPTV 使用说明

优先实现的体验：**从 Projectivy 快捷打开连接上海电信 IPTV 机顶盒的 HDMI**，并能按 HOME 返回。

## 两种不同机制

1. **标准 Android TV 输入源**：设备支持时由 Launcher 的 Inputs/HDMI 快捷入口调用。
2. **小米厂商播放器入口**：部分 MIUI TV 固件只接受 `com.xiaomi.mitv.tvplayer.EXTSRC_PLAY` 和整数 `input`。例如 CleanYourTV 对一台 MiTV-ASTP0 的外部验证，参考 HDMI1=23、HDMI2=24、HDMI3=25；**这些数字必须逐台重新验证，不能自动发给所有小米电视**。

## 只读检查（ADB 授权后）

```bash
adb -s <电视IP>:5555 shell dumpsys tv_input
adb -s <电视IP>:5555 shell pm list packages | grep -E 'tvinput|tvplayer|input'
adb -s <电视IP>:5555 shell cmd package resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME
```

记录端口硬件 ID、可用输入源、对应的用户可见名称及固件版本，再通过**实体遥控器**验证能否切入 HDMI、能否显示真实画面和声音。

如果 Projectivy 无法一键打开 HDMI，应先使用电视自带“输入源”功能，而不是为了修复快捷入口禁用小米播放服务。

## 不改运营商业务

保留电信 IPTV 机顶盒、认证、光猫端口、组播以及现有网络连接。不要以第三方 M3U 播放表代替正式订阅。

详见 [上海电信 IPTV](iptv-shanghai.md)、[家庭兼容性](compatibility.md)。
