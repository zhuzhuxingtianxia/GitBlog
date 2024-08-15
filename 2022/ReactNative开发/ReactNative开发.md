# ReactNative开发
## 创建React Native项目
rn0.72版本
```
//之前全局安装过旧的先卸载
npm uninstall -g react-native-cli @react-native-community/cli

// 创建最新版本项目
npx react-native@latest init ProjectName
// 0.73开始使用
npx @react-native-community/cli@latest init ProjectName

//或expo app可扫码预览
npx create-expo-app@latest
```

指定版本或项目模板， 0.71开始默认支持ts
```
npx react-native@0.70.2 init MyApp --template react-native-template-typescript
// 0.73
npx @react-native-community/cli@X.XX.X init ProjectName --version X.XX.X
//或
npx create-expo-app --template
```

rn0.73版本需node18.x, 创建项目命令也有所不同。
也可使用[Expo](https://docs.expo.dev/)创建新项目，网络原因不建议国内用户使用expo。

## 搭建RN库

使用[create-react-native-library](https://qdfish.github.io/sakamoto.blog/2024/04/03/rn/create_library/)来构建，或使用[create-react-native-module](https://github.com/brodycj/create-react-native-module)**(推荐)**， `create-react-native-module`基于`ative-create-library`的。

```
npx create-react-native-library@latest libray_name
// 可以添加参数
react-native-create-library --package-identifier com.quenice.libray_name --platforms android,ios libray_name
// 重命名项目
mv libray_name react-native-libray_name

//或全局安装
npm install -g create-react-native-module
create-react-native-module libray_name

```
因为利用`react-native-create-library`生产的项目, 组件相关的名称或者类会默认加上react-native或者RN前缀。所以上面先不加前缀，然后使用`mv`重命名项目。

## RN报错问题

在rn的tabs的第三个tab点击跳转到二级界面，然后在二级界面`navigate`到第二个tab页。报错如下：

![bug](./bug-info.jpeg)

然后测试跳转三级界面，结果得到的也是同样的错误。这是什么原因呢？
而且在iOS中一切都是正常的，真是郁闷的不行。android坑是真的多啊！

## 分析问题
**假设1**
跳转的页面有问题，这个界面嵌套了react-native-webview,难道是webview或其中的交互有问题？
跳转另外一个项目的webview界面却是正常的。
那就跳转rn原生界面呢？结果也是有的界面正常，有的也是不行。

**假设2**
在第四个tab点击跳转到二级界面，然后在二级界面`navigate`到第二个tab页。结果正常，
猜测第三个tab界面或组件有问题？

检查每一个组件，发现`PointGoods`有问题导致的。这个组件使用了`React.forwardRef`,内部引用的组件`Popover`也使用了`React.forwardRef`,是嵌套导致的问题吗？

`PointGoods`组件去除`React.forwardRef`，问题依然存在。去掉`Popover`问题不存在了，难道是`Popover`使用`React.forwardRef`导致有问题。

`Popover`组件去除`React.forwardRef`，问题依然存在。说明并不是`React.forwardRef`有问题。继续细化定位代码位置。

**假设3**

发现不传`getContainer`的时候没有问题，

![bug-code](./bug-code.jpg)

说明问题在这段代码里了，`UIManager.measure`接口被废弃，难道是android中已经移除了这个api了吗？但是其他地方也有使用，并没有什么问题啊。所以猜测错误。

在`useEffect`中添加`getContainer`监听，则没有问题但是不能获取到getContainer的真实高度。


查了一下资料说是`UIManager.measure`可以替换成`onLayout`，或需要在组件`onLayout`之后调用。说明要在组件渲染完成后才能调用，在`useEffect`中并没有做属性值的监听，组件的任何变化都会触发该钩子函数。多次交互跳转后`getContainer`元素被卸载但并没有销毁，只是不在界面上渲染。这就导致`findNodeHandle`无法找到`node`节点而报错。


传递`getContainer`目的是为了获取dom元素的高度。最后改为在元素的`onLayout`中获取高度,直接将高度传递即可。

总结：在react-native中操作dom要谨慎，iOS和android端底层处理视图的逻辑并不完全相同，所以`findNodeHandle`方法查找的dom的id并非实时的动态绑定。


## RN对View做高度动画报错
**Error: Style property 'height' is not supported by  native animated module**

源代码：
```
const adjustHeight = (height)=> {
   if(height == animHeight.__getValue()) return;
   Animated.timing(animHeight, {
       toValue: height,
       duration: 100,
       useNativeDriver: true,
   }).start();
   
}
```
**解决：**
```
Animated.timing(animHeight, {
  toValue: height,
  duration: 300,
  useNativeDriver: false, // 改为false
}).start();
```

## 小米手机rn运行闪退
`getLine1NumberForDisplay: Neither user 10298 nor current process has android.permission.READ_PHONE_STATE, android.permission.READ_SMS, or android.permission.READ_PHONE_NUMBERS`

**解决：**
需要在AndroidManifest.xml文件添加相应的权限：
```
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
//targetSdkVersion=30是小米手机必需
<uses-permission android:name="android.permission.READ_PHONE_NUMBERS" />

```

## android 引入三方库报错
android使用`@react-native-community/masked-view`库报错：
`requiredNativeComponent: "RNCMaskedView" was not found in the UIManager`
**解决：**
需要在android项目中添加对应的包：
```
@Override
protected List<ReactPackage> getPackages() {
  List<ReactPackage> packages = new LocalPackageList(this).getPackages();
  packages.add(...其他包)
  packages.add(new RNCMaskedViewPackage());
  return packages;
}

```

## android studio运行报错
真机运行无法直接安装，
```
Unable to determine application id: com.android.tools.idea.run.ApkProvisionException: Error loading build artifacts from: /Users/jion/Desktop/公司项目/gktapp/android/app/build/outputs/apk/dev/debug/output-metadata.json
```

在该目录`build/outputs/apk/dev/debug`下未发现`output-metadata.json`文件而是一个`output.json`文件。

**解决：**


