# Andriod 开发

## andriod构建工具

Gradle插件版本、Gradle版本、buildTool版本及ndk版本是相互关联的。需要保持对应关系，否则编译会报错。
例如：gradle plugin 4.2.0 需要gradle6.7.1、 buildTool30.0.2、ndk21.4.7075529

[对应关系可在此查看](https://developer.android.google.cn/build/releases/past-releases?hl=zh-cn)

## 报错问题

*Unsupported Java. 
Your build is currently configured to use Java 17.0.6 and Gradle 5.5.*

使用的java过高，而 gradle5.5对应的是java8，最新安装的编译器java版本是17。

解决办法是为项目配置低版本的JDK,如下路径，将jbr-17改为1.8
setting -> Build,Execution,Deployment -> Build Tolls -> Gradle


