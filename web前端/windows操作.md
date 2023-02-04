# windows操作

## 常用指令
* `win+E`: 打开文件资源管理器
* `win+i`: 打开设置
* `win+r`输入cmd: 打开终端对话框
* `win+r`输入powershell: 打开PowerShell对话框
* `win+x`: 右键开始（用于快速选择）

## 终端命令
* `dir`: 显示裸目录
* `dir /a`: 显示所有目录包括隐藏目录
* `dir /a:h`: 仅显示隐藏目录，例如：AppData目录
* `start C:\Windows\System32\Drivers\etc`: 打开某个文件夹或文件
* `md xxx`或`mkdir xxx`:创建文件夹
* `rd /s /q xxx`:删除文件夹，rd职能删除空文件夹
* `type nul>test.txt`: 创建空文件test.txt
* `echo xxx>a.txt`:创建非空文件a.txt，并将xxx写入文件中
* `del a.txt`: 删除文件
* `D:`:切换到D盘目录

## Windows包管理器Scoop
`win+x`管理员身份打开PowerShell，
为了让PowerShell可以执行脚本，首先需要设置PowerShell执行策略，通过输入以下命令即可。（如果之前已开启，可忽略。）:
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

安装Scoop:
```
iwr -useb get.scoop.sh|iex
```
iwr是PowerShell下的一款工具，这个指令是下载一个sh脚本并执行，其他例子`iwr -Uri http://www.test.com/vps.exe -OutFile vps.exe -UseBasicParsing`。

安装报错：iwr: 未能解析此远程名称：'raw.githubusercontent.com'
测试： ping raw.githubusercontent.com 无法ping通
解决：[查看raw.githubusercontent.com的IP](https://www.ipaddress.com/)，修改host非管理员权限执行`code C:\Windows\System32\drivers\etc`,管理员权限执行`code drivers\etc`,在host文件添加一下内容：
```
185.199.109.133 raw.githubusercontent.com
```
保存后命令行重新执行：ping raw.githubusercontent.com
重新安装Scoop就可以了。如果出现禁用管理员身份运行安装程序的提示就切换到用户身份。

如果你需要[更改默认的安装目录](https://zhuanlan.zhihu.com/p/463284082)，则需要在执行以上命令前添加环境变量的定义，通过执行以下命令完成：
```
$env:SCOOP='D:\Applications\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

```
其中目录D:\Applications\Scoop可根据自己的情况修改

## 安装工具
安装node管理工具nvm
```
scoop install nvm
```
查看`nvm --version`
查看可用的node版本：

```
nvm list available
```

修改镜像源：
```
nvm node_mirror https://npm.taobao.org/mirrors/node/
nvm npm_mirror https://npm.taobao.org/mirrors/npm/
```

安装多个版本node:
```
nvm install 18.13.0
nvm install 16.15.0
```
卸载指定版本：
```
nvm uninstall 16.15.0
```

查看安装的node版本：
```
nvm ls
```

切换版本：
```
nvm use 16.15.0
```
全局安装yarn:
```
npm install -g yarn
```

## 查看环境变量
`win+x`->系统->高级系统设置->环境变量


