# Python：自动化环境配置

## 安装PyCharm

首先到[PyCharm官网](https://www.jetbrains.com/pycharm/)下载IDE

![Community](./Community.png)

专业版比较强大，可以做其他的开发但是需要付费。社区版只能开发python，适合一般的开发使用。

选择.dmg(Intel),M1的设备可选择.dmg(Apple Silicon)

也可以选择其他版本的PyCharm。

![download](./download.png)

选择直接下载，下载完成后安装即可。

启动PyCharm,

![pythonui](./pythonui.png)

可以选择创建项目或打开已有的项目。

## 配置pip镜像源

pip类似`npm`或`cocoapods`，是包管理工具。
pip默认的镜像源是：**https://pypi.org/simple/**

添加或修改镜像源:

* 进入根目录：cd ~/
* 进入.pip目录：cd .pip
* 如果不存在则新建文件：mkdir .pip
* 再次进入.pip目录：cd .pip
* 创建pip.conf文件：touch pip.conf
* 修改pip.conf文件：open pip.conf
```
[global]
index-url=https://mirrors.aliyun.com/pypi/simple/
[install]
trusted-host=mirrors.aliyun.com
```
这里我们将阿里云的镜像源添加到配置文件中。

如果修改临时镜像源，可以这么做：
```
//临时修改为清华大学的镜像
pip3 install scrapy -i https://pypi.tuna.tsinghua.edu.cn/simple/
```

## 安装Python依赖包

PyCharm创建工程后不像其他前端工具一样会生成一个`package.json`文件，可以在`package.json`文件需要的依赖包。
所以安装的时候只能一个一个执行安装，如下：
 ```
 pip install requests
 或
 pip3 install requests
 ```
 安装指定版本的依赖包：
 ```
 pip install pandas==0.23.4
 ```

同时安装多个pip包时，只需将它们以空格分隔传递可以：
```
pip install wsgiref boto 
```

## 下载ChromeDriver

[ChromeDriver](http://npm.taobao.org/mirrors/chromedriver/)可以到这里去下载。
在下载之前首先去看下你的Chrome的版本号：

![Chrome_version](./Chrome_version.png)

然后在下载中找到ChromeDriver对应的版本

![ChromeDriver](./ChromeDriver.png)

下载解压后保存到`/usr/local/bin`这个目录下。

## 自动化测试开发




