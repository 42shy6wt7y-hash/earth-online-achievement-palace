Windows 本地离线版修正版。

本版修复：

- 安装完成后不再自动打开页面，避免安装器阶段误触发错误的系统 URL 处理器。
- 桌面快捷方式启动时会显式调用 Chrome 或 Edge 打开本地页面，避免误打开 `chromedriver.exe`。

说明：

- Microsoft Defender SmartScreen 仍可能提示“无法识别的应用”，这是因为安装包没有代码签名证书。点击“更多信息”后选择“仍要运行”即可。
- 应用默认安装：`C:\Users\你的用户名\AppData\Local\Programs\EarthOnlineAchievementCenter`
- 成就档案保存：`C:\Users\你的用户名\AppData\Local\EarthOnlineAchievementCenter\achievement-archive`
