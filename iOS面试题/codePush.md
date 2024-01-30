# CodePush

## 部署私有服务

* 首先[安装code-push-server](https://www.jianshu.com/p/ca4beb5973bb): `npm install code-push-server -g`
* 安装mysql数据库，可用dmg安装包安装或brew安装，安装完成后启动服务器，记录登录密码
* 初始化mysql数据库: `code-push-server-db init --dbhost localhost --dbuser root --dbpassword`
	
	可以通过`code-push-server-db -h`查看相关参数：
	1. `--dbname`: 数据库名称，默认 'codepush'
	2. `--dbhost`: 数据库地址，默认'localhost'
	3. `--dbuser`: 数据库用户名，默认'root'
	4. `--dbpassword`: 数据库登录密码， 默认null


## [CodePush](https://zhuanlan.zhihu.com/p/42751434)

* 安装配置好code-push-server，并能正常启动登陆获取token
* 安装code-push必须指定版本号: `npm i -g code-push-cli@2.1.9`
* 查看版本号: `code-push -v`
* 终端登录code-push login https://codepush-uat.xxx.com 这将启动浏览器打开登录界面登录获取token
* 终端直接登录：`code-push login https://codepush-uat.xxx.com --accessKey <token>`
* 查看登录状态: `code-push whoami`
* 退出：`code-push logout`
* 添加应用：`code-push app add <appName> <os> react-native`
* 查看创建的app: `code-push app list`
* 查询各个环境 Key: `code-push deployment ls <appName> -k`
* 配置	Deployment Key时，iOS在	info.plist，android在 `android/app/build.gradle` 中，配置 `buildTypes`
* 查询状态：`code-push deployment ls <appName>`
* 推送更新测试环境：`code-push release-react <appName> ios/android`
* 推送更新生产环境：`code-push release-react <appName> ios/android -d Production`

**CodePush-CLI is deprecated and no longer supported!**

## [AppCenter-CLI](https://learn.microsoft.com/zh-cn/appcenter/distribution/codepush/cli)

* 安装 App Center CLI: `npm install -g appcenter-cli`
* 发布应用更新: `appcenter codepush release-react -a <ownerName>/MyApp`
* 登录需关联GitHub账户：`appcenter login`
* 查看用户名和显示名称：`appcenter profile list`
* 退出：`appcenter logout`
* 创建访问令牌：`appcenter tokens create -d "Azure DevOps Integration"`
* 访问令牌生成密钥仅显示一次，因此请记得根据需要将其保存到某个位置
* 令牌登录：`appcenter login --token <accessToken>`
* 创建安卓应用：`appcenter apps create -d MyApp-Android -o Android -p React-Native`
* 创建iOS应用：`appcenter apps create -d MyApp-iOS -o iOS -p React-Native`
* 添加推送环境：`appcenter codepush deployment add -a <ownerName>/<appName> Production`
* 访问密钥：`appcenter codepush deployment list --displayKeys`
* 应用重命名: `appcenter apps update -n <newName> -a <ownerName>/<appName>` 48小时内可能出现意外
* 查看所有应用：`appcenter apps list`
* 删除某个应用：`appcenter apps delete -a <ownerName>/<appName>`







