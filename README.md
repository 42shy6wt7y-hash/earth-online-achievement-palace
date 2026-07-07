# 地球online成就殿堂

一个本地离线的黑金 Steam 风人生成就殿堂，内置 36 个默认人生梗系成就。

## 普通用户

下载发布页里的 `EarthOnlineAchievementPalace-Setup.exe`，双击安装。安装完成后桌面会自动生成 `地球online成就殿堂` 快捷方式，图标使用项目徽章图。

应用默认安装在：

```text
C:\Users\<你的用户名>\AppData\Local\Programs\EarthOnlineAchievementPalace
```

用户成就档案默认保存在：

```text
C:\Users\<你的用户名>\AppData\Local\EarthOnlineAchievementPalace\achievement-archive
```

界面里的删除只是写入删除事件，不会移除旧文件。


第一次打开时会自动创建 36 个默认成就，初始状态全部为未达成。它们和用户自己创建的成就一样，都可以修改、删除、切换达成状态；删除只写入删除事件，不会移除底层旧文件。

本版本和第一版 `地球online成就中心` 使用不同安装目录、不同本地档案目录、不同本地端口段，可以同时安装使用，数据不互通。
## 开发启动

运行本地网页服务：

```powershell
npm start
```

然后打开：

```text
http://localhost:3317
```

## 开发模式本地档案

网页服务开发模式的数据保存在项目里的 `achievement-archive/`：

- `events/`：创建、修改、删除事件，只增不删
- `assets/`：上传过的图片，只增不删

## 打包 Windows 安装包

```powershell
npm run build:windows
```

产物会生成在 `dist/EarthOnlineAchievementPalace-Setup.exe`。
