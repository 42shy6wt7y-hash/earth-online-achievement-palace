Windows 安装器修正版。

本版改动：

- 替换旧的 IExpress 自解压壳，改为真正的 C# 安装器 exe。
- 点“仍要运行”后只执行安装：复制文件到本地应用目录、创建桌面快捷方式、创建开始菜单快捷方式。
- 安装过程不再自动打开网页、不调用浏览器、不触发 `chromedriver.exe`。

说明：

- Microsoft Defender SmartScreen 仍可能提示“无法识别的应用”，这是因为安装包没有代码签名证书。
- 应用默认安装：`C:\Users\你的用户名\AppData\Local\Programs\EarthOnlineAchievementCenter`
- 成就档案保存：`C:\Users\你的用户名\AppData\Local\EarthOnlineAchievementCenter\achievement-archive`
