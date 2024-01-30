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
* 终端登录code-push login https://codepush-uat.xxx.com 这将启动浏览器打开登录界面登录获取token
* 终端直接登录：`code-push login https://codepush-uat.xxx.com —accessKey <token>`
* 查看登录状态: `code-push whoami`
* 退出：`code-push logout`
* 添加应用：`code-push app add <appName> <os> react-native`
* 查看创建的app: `code-push app list`
* 查询各个环境 Key: `code-push deployment ls <appName> -k`
* 配置	Deployment Key时，iOS在	info.plist，android在 `android/app/build.gradle` 中，配置 `buildTypes`
* 查询状态：`code-push deployment ls <appName>`
* 推送更新测试环境：`code-push release-react <appName> ios/android`
* 推送更新生产环境：`code-push release-react <appName> ios/android -d Production`










