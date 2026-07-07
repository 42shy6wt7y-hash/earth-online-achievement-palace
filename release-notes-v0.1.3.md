Windows 安装器修正版。

本版修复：

- 修复 v0.1.2 安装器提示 `Missing embedded payload` 的问题。
- 安装器现在会自动查找内嵌的 `payload.zip` 资源，不再依赖固定资源名。

说明：

- Microsoft Defender SmartScreen 仍可能提示“无法识别的应用”，这是因为安装包没有代码签名证书。
- 点“更多信息 -> 仍要运行”后会执行本地安装。
