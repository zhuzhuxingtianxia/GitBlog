# Jinkens遇到的问题

## [Jinkens的安装和配置](https://www.bilibili.com/video/BV1zM41127hC/?spm_id_from=333.999.0.0&vd_source=9b0910a821dc69e8f6e87d1e96d7c20e)

* 安装JDK,配置环境变量
* 安装最新的LTS版本：brew install jenkins-lts
* 安装特定的LTS版本：brew install jenkins-lts@YOUR_VERSION
* 启动 Jenkins 服务：brew services start jenkins-lts
* 重新启动 Jenkins 服务：brew services restart jenkins-lts
* 更新 Jenkins 版本：brew upgrade jenkins-lts

## 遇到的问题

### 项目过大拉取代码超时

1. 在当前的构建任务下
2. 点击配置
3. 选择源码管理
4. 在git下点击新增
5. 选择Advanced clone behaviours
6. 将克隆和拉取超时时间设置为30， 默认10
7. 指定分支为`$GitBranch`时，构建时可选择分支

### 在脚本导出包时报错
`error: exportArchive: No signing certificate "iOS Development" found`

1. 检查证书和配置文件
2. 检查`ExportOptions.plist`文件，因为我们账户发生变化，teamid需要也需要修改

### xcrun altool验证ipa包不通过

1. 因为账号发生变更，`apiKey`和`apiIssuer`需要重新获取
2. 登录app connect > 用户和访问 > 集成 > 密钥 > App Store Connect API(只有账户持有人可以请求访问) > 生成密钥， 从而重新获取`apiKey`和`apiIssuer`
3. 下载api密钥`.p8`文件，将其放置到`~/private_keys`目录下

