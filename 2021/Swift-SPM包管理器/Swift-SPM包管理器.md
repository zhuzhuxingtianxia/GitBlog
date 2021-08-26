# Swift: SPM包管理器

<!--- https://www.jianshu.com/p/b9ba7154f4c2 --->
<!--- https://juejin.cn/post/6855440272424173576 --->

**SPM**,Swift Package Manager（swift包管理器）,管理Swift代码分发的工具,用于处理模块代码的下载、编译和依赖关系。类似`CocoaPods`,不过比`CocoaPods`更简洁，代码的侵入性更小，也不需要额外安装工具。

## SPM依赖安装

Xcode自带SPM,终端上可查看SPM版本：
```
$ swift package --version
Swift Package Manager - Swift 5.3.0
```

新建项目`SPMTest`,添加SPM依赖,File -> Swift Package -> Add Package Dependency... 

![add_spm](./add_spm.png)

或者点击到 PROJECT -> Swift Packages 点击加号添加依赖

![add_spm1](./add_spm1.png)


输入需要添加的第三方库的链接：

![add_lab](./add_lab.png)

点击next等待验证成功后直，根据自己的实际需要选择版本，如下图：

![package_version](./package_version.png)

有三个选项：

	* Version: 对应库的Release版本, 这里可选择版本规则，它会自动下载这个规则内最新的版本
		
		* Up to Next Major: 指定一个主要版本的范围，例如：5.4.2~6.0.0
		* Up to Next Minor: 指定一个小版本范围,例如：5.4.2~5.5.0
		* Range: 指定一个版本范围, 例如：5.4.1～5.5.1
		* Exact: 指定一个确切的版本，例如：5.4.1
		
	* Branch: 直接下载某个分支的代码
	* Commit: 根据某一次提交记录的 Id下载

添加完成之后，项目中会出现`Swift Package Dependencies`这样一个目录：

![add_dependencies](./add_dependencies.png)

这样就可以在项目中直接使用这个第三方依赖库了。

如果你要更新SPM中的依赖，选择 `File -> Swift Packages -> Update to Latest Package Versions` 即可。

如果想要修改某个第三方库的版本策略，可以双击第三方库即可出现修改面板进行相应的修改。

