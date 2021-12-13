# XMPP简述

XMPP一个老掉牙的框架了，虽然古老，但对于我依然是很陌生的。

XMPP是基于XML的网络即时通讯协议。可以建立TPC/IP连接，完成C/S、C/C、S/S之间的数据传输。XMPP官网[https://xmpp.org/](http://xmpp.org)。


## Openfire服务器配置

打开官网选择Software->Servers，它有好几个服务器框架。我们选择Openfire。Openfire是一款经典的XMPP Server,用java编写并且开源。Openfire由XMPPServer+JavaWebServer组成，前者基于XMPP协议进行通信，后者是一个web管理后台。

**java环境安装：**

检查java版本
```
java -version
```
可以看到安装的信息：
```
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
```
没有安装Java环境，要首先[下载](http://www.oracle.com/technetwork/java/javase/downloads/)JDK8安装包。

**安装数据库**

我们首先下载MySQL数据库,下载[MySQL Community Server](http://www.mysql.com/downloads/)并进行安装。
安装后可以在设置中查看。
接着安装数据库管理工具[MySQLWorkbench]()


