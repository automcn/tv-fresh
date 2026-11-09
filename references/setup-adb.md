# 小米电视连接：开发模式与 ADB（无 Root）

## 电视侧操作

老款小米电视 4A 65 寸、MIUI TV 1.3.85 的相关历史经验：
1. 设置 → 关于 → **产品型号**，遥控器连续按确定约 7 次。
2. 返回 → **账号与安全** → ADB 调试 → 允许。
3. 如屏幕出现计算机指纹授权，遥控器选择允许。

此路径因具体型号和固件不同可能稍有变化。仅授权同一可信局域网内的本机电脑，操作完应关闭 ADB。

## 上海 Mac 只读联机

```bash
adb connect <TV_IP>:5555
adb -s <TV_IP>:5555 get-state
adb -s <TV_IP>:5555 shell getprop ro.product.model
adb -s <TV_IP>:5555 shell getprop ro.build.version.sdk
adb -s <TV_IP>:5555 shell getprop ro.product.cpu.abi
adb -s <TV_IP>:5555 shell getprop ro.build.version.incremental
bash scripts/tv-preflight.sh <TV_IP>
```

- `Connection refused`：电视网络可达，但 ADB 5555 没有监听，优先检查电视 ADB 开关。
- `unauthorized`：电视还没批准电脑指纹。
- 超时：确认电视已唤醒、与电脑同一非隔离局域网。
- Android 6 的某些 `cmd package` 子命令可能不可用。不得用禁用系统包试图“修复” ADB 或 HOME。
- 若重启后 ADB 自动关闭，按设备自己的设置重新启用。

局域网自动发现可参考 mDNS/AirPlay 广播，但**发现名称不能代替 ADB 读取真实 `ro.product.model`**。
不要扫描非本人管理的网络，也不要向路由器公网映射 TCP 5555。

参考：[老款 Android 6 兼容](legacy-miui-android6.md)。
