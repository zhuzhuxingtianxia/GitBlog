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
timeout=600
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

[ChromeDriver](http://npm.taobao.org/mirrors/chromedriver/)可以到这里去下载。该工具用于驱动Chrome浏览器。
在下载之前首先去看下你的Chrome的版本号：

![Chrome_version](./Chrome_version.png)

然后在下载中找到ChromeDriver对应的版本

![ChromeDriver](./ChromeDriver.png)

下载解压后保存到`/usr/local/bin`这个目录下。

在终端查看chromedriver版本，执行：
```
chromedriver
```

也可通过命令行安装,这个需要之前有安装homebrew才可以：
```
brew cask install chromedriver
```
这种方式能不能指定版本暂没找到方法？？

这是另外一篇相关的[文章](https://www.cnblogs.com/wxhou/p/chromedriver-py.html)


验证一下，终端输入：
```
python3
>>> from selenium import webdriver
>>> browser = webdriver.Chrome()
```

执行上面的代码后就会打开Chrome浏览器，说明安装成功了！

## 自动化测试开发

### 1.创建工程
打开PyCharm，新建项目：

![createpro](./createpro.png)

其他的不多说，我们来看下`New environment using`选项，我们点开这个下拉框可以看到，虚拟环境可以使用三种工具，Virtualenv、pipnev、conda。 

* Virtualenv: 本身是一款Python工具，具有Python所必须的依赖库，用于创建独立的Python虚拟环境，方便管理不同版本的python模块。零基础就选它。 
* pipenv: 可以说是`virtualenv`和`pip`的结合体，它不但会自动为你的项目创建和管理virtualenv（就是第一个选项），而且在安装/卸载软件包时通过`Pipfile`文件自动添加/删除软件包。所以对于管理包来说是非常好用的。但暂时作为初入门的人来说东西有点多，短时间是用不上的。
* conda: conda非常强大，conda是一个不仅支持Python，它还支持C或C ++库等许多语言的软件包、依赖库和环境管理的工具。 如果你选择conda的话，项目文件夹会在.conda下面，同时你还可以用Anaconda的非常受欢迎的数据科学、机器学习和AI框架的软件包。 这个暂时也不适用于新手 

我们选择`Virtualenv`,并设置项目名称和路径，然后点击create，至此我们的项目就创建完成了。
运行控制台将打印：`Hi, PyCharm`。

打开项目终端，安装用于测试网站的自动化测试工具`selenium`:
```
pip3 install selenium
```

### 2. 如何用Chrome打开一个网站


