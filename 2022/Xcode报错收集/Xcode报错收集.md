# Xcode报错问题收集

## 升级Xcode16 rn编译报错
```
unexpected service error: The Xcode build system has crashed. Build again to continue.
```
**解决方案**: 目前官方还没有给出解决方案，临时解决方案就是[Xcode降级到15.4](https://xcodereleases.com/?scope=release)
无法降级的则查看是否用到这个库`react-native-image-crop-picker`,在pods->RNImageCropPicker->ImageCropPicker.h中有一个空的`#import` 删除重新编译或升级到`0.41.2`

## xcode16编译报错1:
升级后报错：
```
Undefined symbols for architecture x86_64:_OBJC_CLASS_$_AFHTTPSessionManager

Undefined symbols for architecture x86_64:_OBJC_CLASS_$_RCTEventEmitter
```
**解决：** 因为设备是[M系列架构](https://blog.csdn.net/w13776024210/article/details/121857456)，在Intel芯片上没有问题。
修改Build Settings -> Excluded Architectures选项，添加Any iOS Simulator SDK选项，并设置值为arm64。将默认的armv7移除

## xcode16编译报错2:
```
Library 'Pods-xxx' not found
```

## Xcode14三方库签名报错

今天更新升级了一下Xcode14，打开项目运行居然报错了:

`Signing for "ESPullToRefresh-ESPullToRefresh" requires a development team. Select a development team in the Signing & Capabilities editor.`

这是什么情况，三方库也需要设置一个开发团队了。

## 如何解决

**解决方案1:**

修改Podfile文件，在Podfile中添加如下内容：

```
post_install do |installer|
        installer.generated_projects.each do |project|
            project.targets.each do |target|
                target.build_configurations.each do |config|
                        config.build_settings["DEVELOPMENT_TEAM"] = "Your Team ID"
                end
            end
        end
end

```

或使用下面这种：
```
installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
    end
end

```

**解决方案2:**

1. 终端执行`sudo gem install cocoapods-pod-sign`
2. 执行`bundle init`,此时生成一个Gemfile文件，看输出路径`Writing new Gemfile to /Users/xxx/Gemfile`
3. 修改Gemfile文件，将这两行代码复制粘贴到文件末尾

 	```
 	gem 'cocoapods-pod-sign'
	gem 'cocoapods'
 	```
 ![Gemfile](./Gemfile.png)

4. 执行`bundle install`,让文件的修改生效
5. cd 到项目目录执行`pod install --verbose`

