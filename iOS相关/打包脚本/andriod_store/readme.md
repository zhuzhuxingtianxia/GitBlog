
# 顶像加固

有些打包文件没有引入，这只是一个大概的脚步流程
[其他多渠道方案](https://zhuanlan.zhihu.com/p/569298807?utm_id=0)

### 多渠道自动加固工具

#### 多渠道加固
用appensys_cli.py执行自动加固和自动打渠道包任务，多了--channel-path的入参，请填写channel.txt的路径。内容为渠道名称，一行一渠道，可参考包里的channel.txt文件，具体命令也可直接看appensys_cli.py 头部的注释

- 命令参考：

```
python appensys_cli.py --package-type=android_app --host-url=http://xx.xx.xx.xx:xxxx --account=xxxx --password=xxxx --strategy-id=1021 -i  ./android-appen-tools/demo-client.apk -o ./android-appen-tools/out/protected.apk --channel-path=./android-appen-tools/channel.txt --channel-name=CHANNEL
```


  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -i INPUT,  --input=INPUT	加固前文件（输入） *.apk/zip/aar/xcarchive
  -o OUTPUT,  --output=OUTPUT	加固后文件保存位置（输出）
  --host-url=HOST_URL   加固的服务端
  --dx-saas             等价于 --host-url=http://appen.dingxiang-inc.com
  -s STRATEGY_ID, --strategy-id=STRATEGY_ID
                        策略编号，SaaS旗舰版可以随意写个数，比如strategy-id=1
  -t PACKAGE_TYPE, --package-type=PACKAGE_TYPE
                        文件类型：android_app,  ios_app
  -a ACCOUNT, 		--account=ACCOUNT 	 账户
  -p PASSWORD, 	--password=PASSWORD   密码
  -b, --keep-bitcode-in-output
                        [ios_app] 加固后是否开启bitcode, 默认不保留
  --xcode=XCODE         [ios_app] 打包使用的Xcode版本
 			   			8: Xcode 12.5
                            7: Xcode 12.0-12.1
                            6: Xcode 11.4
                            5: Xcode 11.0-11.3
                            4: Xcode 10.2-10.3
                            3: Xcode 10.0-10.1
                            2：Xcode 9.x 废弃
                            1：Xcode 9.x 废弃
  --channel-path [android_app] 自动打渠道包，提供channel.txt文件路径 如./channel.txt
  --channel-name [android_app] AndroidManifest中自定义的渠道识别名，如UMENG_CHANNEL,CHANNEL

SaaS旗舰版地址：http://appen.dingxiang-inc.com，




#### 自动签名
执行android-appen-tools中的dx-wallent-ci-apk-signer.jar自动给渠道包签名

- 命令参考：

```
java -jar -Dfile.encoding=utf-8 ./\android-appen-tools\/dx-wallent-ci-apk-signer.jar --in ./\out --o ./\out/\channel --k ./\android-appen-tools\/test_keystore.jks --v2 --s 111111 --a test --p 111111
```

也可以改写下主目录下的auto_sign.sh，改下正确的keystore

设置--v2表示开v2签名，v1签名默认必开

--in 加固后的文件目录

--o 签名后的输出目录

--k 表示签名文件路径

--s 签名文件密码

--a 别名

--p 别名密码



#### 渠道包出错

渠道包打包出错时请查看目录下生成的channel.log文件

