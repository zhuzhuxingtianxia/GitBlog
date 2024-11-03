# iOS开发中CocoaPods的使用

## 安装CocoaPods前环境配置

CocoaPods是用Ruby写的，所以运行需要安装Ruby环境，Mac中自带Ruby环境。

打开终端，输入以下命令:

1. 查看ruby的版本:`ruby -v`

2. 如果需要更新ruby版本则执行:`sudo gem update --system` 需要权限，在mac15.4上却无效了

3. 或者先安装brew使用`brew install ruby 或 brew upgrade ruby`进行安装,这种方式需要配置环境变量，不会覆盖系统的ruby。

4. 查看ruby的镜像: `gem sources -l`

5. 移除Ruby镜像: `gem sources --remove https://rubygems.org/`

6. 添加新的镜像源: `gem sources --add https://mirrors.aliyun.com/rubygems/` 

   **注意**` https://gems.ruby-china.com` 已不可用

    `https://mirrors.aliyun.com/rubygems/`阿里的gem镜像

   `https://mirrors.tuna.tsinghua.edu.cn/rubygems/` 清华的gem镜像

7. `gem sources -l`重新查看镜像源是否修改或添加成功

## 安装CocoaPods

* 终端输入：`sudo gem install cocoapods`
出现：`ERROR:  While executing gem ... (Errno::EPERM)     Operation not permitted - /usr/bin/xcodeproj` 是安装路径出了问题，需要指明路径。

* 重新下载：`sudo gem install -n /usr/local/bin cocoapods`

出现Successfully installed cocoapods，下载好了。

* 或使用brew: `brew install cocoapods`
* 重置安装配置：`pod setup --verbose`
* 查看pod版本: `pod --version`
* 查看pod具体信息: `pod env`
* 查看pods镜像源: `pod repo list`
* 移除pods镜像源: `pod repo remove master`
* 修改pods镜像为清华镜像源: `pod repo add master https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git`
* 卸载命令: `sudo gem uninstall cocoapods`
* 搜索库：`pod search xxx`

	输出：Unable to find a pod with name, author, summary, or descriptionmatching 'xxx' 这时就需要继续下面的步骤了:
	
	执行：rm ~/Library/Caches/CocoaPods/search_index.json
	删除~/Library/Caches/CocoaPods目录下的search_index.json文件，重新执行搜索，就有结果了！

* 更新本地仓库: `pod repo update --verbose`
* 更新某个仓库: `pod update xxx(为第三方库名) --verbose --no-repo-update`
  
  然后再查看版本号就是最新的版本了！

## 安装homebrew

国内用户可用一键安装脚本:
`/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"`

## pod install 报错
```
xcrun: error: SDK "iphoneos" cannot be located
xcrun: error: unable to lookup item 'Path' in SDK 'iphoneos'
/Users/jion/Library/Caches/CocoaPods/Pods/External/glog/2263bd123499e5b93b5efe24871be317-1f3da/missing: Unknown `--is-lightweight' option
Try `/Users/jion/Library/Caches/CocoaPods/Pods/External/glog/2263bd123499e5b93b5efe24871be317-1f3da/missing --help' for more information
configure: WARNING: 'missing' script is too old or missing
configure: error: in `/Users/jion/Library/Caches/CocoaPods/Pods/External/glog/2263bd123499e5b93b5efe24871be317-1f3da':
configure: error: C compiler cannot create executables
See `config.log' for more details

```
**解决**:
1. 检查Xcode路径：`xcode-select --print-path`
2. 输出：`/Applications/Xcode.app/Contents/Developer`为正确路金,我这里输出的是`/Library/Developer/CommandLineTools`
3. 需要执行：`sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`

## 如何使用CococaPods

1. 先确认pods安装完成：`pod --version`
2. 新建一个项目，名字PodTest
3. cd PodTest目录,在当前目录下创建Podfile文件: `pod init`
4. Podfile文件的第一行设置pod源: `source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'` 我们这里使用的是清华的镜像源
5. Podfile文件中可以设置平台支持的最低版本：`platform :ios, '13.0'`
6. Podfile文件的target下添加依赖库: `pod 'Alamofire', '~> 5.6.0'`, 执行固定版本`pod 'Alamofire', '5.6.0'`
7. Podfile文件设置依赖本地库: `pod 'MySwiftExtension', :path => './LocalPods/MySwiftExtension/'`, :path/:podspec后面指定依赖的本地库路径或podspec文件路径
8. 依赖库指定git下载地址:`pod 'XXSDK', :git=>'https://gitee.com/XXSDK.git'`
9. 设置完成后保存文件，执行`pod install --verbose`命令来安装依赖依赖库

## 使用CococaPods客户端
先去官网[下载](https://cocoapods.org/app)最新的客户端,客户端只是GUI界面的工具。 下载安装完成即可。

如何使用这个[客户端](https://cocoapods.org/app)呢？选择一个需要引入cocoapods的工程，使用快捷键`command+N`组合键打开文件,选择要接入Pods的工程文件，打开选择.xcodeproj文件。初始化和更新的时候直接 选择`install(verbore)`就可以了。

引入的库不在pods导航栏显示，提示`[!] The 'Pods' target has transitive dependencies that include static binaries: (xx/xxx.a)`,说明库中包含有.a静态文件。注释Podfile文件中的`# use_frameworks!`这行,即不使用动态库，重新添加就可以了！

## PS问题解析

**问题:** 出现 [!] Could not automatically select an Xcode workspace. Specify one in your Podfile like so:

    workspace 'path/to/Workspace.xcworkspace'

**原因：**路径出了问题，要让Pod找到子目录中的工程文件。在Podfile文件里指定下工程目录就行了，
      比如在Podfile文件添加这行就行了：xcodeproj 'PodTest/PodTest.xcodeproj'
      
**问题：**Unable to find a specification for `xxxxx` depended upon by Podfile.
**原因：** 有可能是删除了原来的Pods，但没有清除干净。
     打开终端输入：defaults write com.apple.finder AppleShowAllFiles -boolean true ; killall Finder
显示隐藏的文件夹，打开工程删除含有Podfile字符的隐藏文件，然后重新接入Pods.
最后在终端输入：defaults write com.apple.finder AppleShowAllFiles -boolean false ; killall Finder
再次隐藏原本的隐藏文件

**问题：**[!] Invalid `Podfile` file: syntax error, unexpected ':', expecting end-of-input platform: ios,'7.0'
              ^.

**原因：**后来发现就是因为Podfile文件里面 platform 那一行 冒号和ios之间多了一个空格。其实这个错误在报错的时候ruby已经给出了，只是一开始没有好好看。

