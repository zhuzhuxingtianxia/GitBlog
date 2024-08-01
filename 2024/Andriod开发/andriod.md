# Andriod 开发

## 应用生命周期

#### Application生命周期

* `onCreate()`初始化: 应用初始化，多进程模式会执行多次
* `onStart()`启动: 应用开始启动
* `onResume()`运行: 应用进入前台
* `onPause()`暂停和`onStop()`停止: 应用进入后台时
* `onRestart()`重新启动: 由后台进入前台时触发
* `onDestroy()`销毁: 应用不在运行或从内存中卸载时触发

#### Activity生命周期

![Activity生命周期](./activity_life.png)

* `onCreate()`: Activity实例被创建时触发，只会调用一次，可在此进行视图、布局、组件、数据等资源的初始化
* `onStart()`: 视图首次可见时触发，只会调用一次
* `onResume()`: Activity在前台获取焦点或与用户交互时触发
* `onPause()`和`onStop()`: 当其他Activity处于前台时触发，会调用多次，先`onPause()`后`onStop()`
* `onRestart()`和`onResume()`: Activity 返回切换到前台时触发，会调用多次
* `onDestroy()`: Activity被销毁时触发，调用一次

```
public class MyActivity extends AppCompatActivity {  
    @Override  
    protected void onCreate(Bundle savedInstanceState) {  
        super.onCreate(savedInstanceState);  
        setContentView(R.layout.activity_main);  
        // 初始化 Activity 的各种资源
        Log.d("MyActivity", "onCreate() is called.");  
    }  
  
    @Override  
    protected void onStart() {  
        super.onStart();  
        // 做一些 Activity 启动时需要做的事情，例如加载数据等
        Log.d("MyActivity", "onStart() is called.");  
    }  
  
    @Override  
    protected void onResume() {  
        super.onResume();  
        // 做一些 Activity 运行时需要做的事情，例如更新 UI 等
        Log.d("MyActivity", "onResume() is called.");  
    }  
  
    @Override  
    protected void onPause() {  
        super.onPause();  
        // 做一些 Activity 暂停时需要做的事情，例如停止更新 UI 等
        Log.d("MyActivity", "onPause() is called.");  
    }  
  
    @Override  
    protected void onStop() {  
        super.onStop();  
        // 做一些 Activity 停止时需要做的事情，例如释放资源等
        Log.d("MyActivity", "onStop() is called.");  
    }  
  
    @Override  
    protected void onDestroy() {  
        super.onDestroy();  
        // 做一些 Activity 销毁时需要做的事情，例如清除数据等
        Log.d("MyActivity", "onDestroy() is called.");  
    }  
}

```

#### Activity之间的跳转

使用`startActivity`启动名为`SignInActivity`的 Activity
```
// 简单跳转
Intent intent = new Intent(this, SignInActivity.class);
startActivity(intent);
```

使用`startActivity`启动其他应用的 Activity发送电子邮件
```
// EXTRA_EMAIL对应一个包含电子邮件的收件人电子邮件地址的数组
Intent intent = new Intent(Intent.ACTION_SEND);
intent.putExtra(Intent.EXTRA_EMAIL, recipientArray);
startActivity(intent);
```

使用`startActivityForResult`实现回调通信
```
//MyActivity

button.setOnClickListener(new View.OnClickListener() {
  @Override
  public void onClick(View v) {
      // 启动 SecondActivity 并传递参数
      Intent intent = new Intent(MainActivity.this, SecondActivity.class);
      intent.putExtra("key", "This is a parameter from MainActivity");
      startActivityForResult(intent, REQUEST_CODE_SECOND_ACTIVITY);
  }
});
// 接收回调数据
@Override
protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
   super.onActivityResult(requestCode, resultCode, data);
   // 检查请求码和结果码
   if (requestCode == REQUEST_CODE_SECOND_ACTIVITY) {
       if (resultCode == RESULT_OK && data != null) {
           // 获取从 SecondActivity 返回的结果
           String result = data.getStringExtra("result_key");
           resultTextView.setText(result);
       }
   }
}


```

```
//SecondActivity

@Override
protected void onCreate(Bundle savedInstanceState) {
   super.onCreate(savedInstanceState);
   setContentView(R.layout.activity_second);

   // 获取从 MainActivity 传递的参数
   String param = getIntent().getStringExtra("key");

   Button resultButton = findViewById(R.id.set_result_button);
   resultButton.setOnClickListener(new View.OnClickListener() {
       @Override
       public void onClick(View v) {
           // 设置返回结果并附带额外数据
           Intent intent = new Intent();
           intent.putExtra("key","SecondActivity! Received param: "+param);
           setResult(RESULT_OK, intent);
           finish();
       }
   });
}

```

## Android构建工具版本

Gradle插件版本、Gradle版本、buildTool版本及ndk版本是相互关联的。需要保持对应关系，否则编译会报错。
例如：gradle plugin 4.2.0 需要gradle6.7.1、 buildTool30.0.2、ndk21.4.7075529

[对应关系可在此查看](https://developer.android.google.cn/build/releases/gradle-plugin?hl=zh-cn)及[ndk历史版本](https://github.com/android/ndk/wiki/Unsupported-Downloads)

[Android Gradle 插件和 Android Studio 兼容性](https://developer.android.google.cn/studio/releases?hl=zh-cn)

对照表如下：

| Gradle插件 | 所需Gradle 版本 | SDK Build Tools | NDK           | JDK  |
| -------- | ----------- | --------------- | ------------- | ---- |
| 8.5      | 8.7         | 34.0.0          | 26.1.10909125 | 17   |
| 8.4      | 8.6         | 34.0.0          | 25.1.8937393  | 17   |
| 8.3.x    | 8.4         | 34.0.0          | 25.1.8937393  | 17   |
| 8.2      | 8.2         | 34.0.0          | 25.1.8937393  | 17   |
| 8.1      | 8.0         | 33.0.1          | 25.1.8937393  | 17   |
| 8.0.x    | 8.0         | 30.0.3          | 25.1.8937393  | 17   |
| 7.4.x    | 7.5         | 30.0.3          | 23.1.7779620  | 11   |
| 7.3      | 7.4         | 30.0.3          | 23.1.7779620  | 11   |
| 7.2.x    | 7.3.3       | 30.0.3          | 21.4.7075529  | 11   |
| 7.1.x    | 7.2         | 30.0.3          | 21.4.7075529  | 11   |
| 7.0.x    | 7.0.2       | 30.0.2          | 21.4.7075529  | 11   |
| 4.2.0    | 6.7.1       | 30.0.2          | 21.4.7075529  | 8    |
| 4.1.0    | 6.5         | 29.0.2          | 21.1.6352462  | 8    |
| 4.0.1    | 6.1.1       | 29.0.2          | 21.1.6352462  | 8    |
| 3.6.4    | 5.6.4       | 28.0.3          | 20.1.5948944  | 8    |
| 3.5.4    | 5.4.1       | 28.0.3          | 20.1.5948944  | 8    |
|          |             |                 |               |      |



## Android版本与SDK/API版本、JDK对应关系

![Android版本与SDK/API版本、JDK对应关系](./andriod_sdk_api.jpeg)

## adb 安装apk

检查设置是否链接：`adb devices`
cd到apk所在的目录: `adb install path_to_your_apk_file.apk` 该方式只能安装生产包，无法安装测试包。

## local.properties
`local.properties` 文件是由 Android Studio 自动生成的，用于指定本地开发环境的一些配置信息，例如 Android SDK 和 NDK 的路径。
Android Studio 会根据你的本地配置自动填充这些路径。当你在 Android Studio 中配置 SDK 和 NDK 路径时，这些信息会被保存在 `local.properties` 文件中。
如果你的项目目录下没有 `local.properties` 文件，你可以手动创建一个，并根据你的本地配置填写相应的路径信息。

```
// 这种ndk配置方式即将废弃，在build.gradle的android配置这种指定ndkVersion或ndkPath即可
ndk.dir=/Users/xxx/Library/Android/ndk/android-ndk-r21e
sdk.dir=/Users/xxx/Library/Android/sdk

```

## gradlew

在Android 项目的根目录下，通常是由 Android Studio 自动生成的，并用于在命令行或终端中执行 Gradle 构建任务。
`gradlew`是 Gradle Wrapper 的一部分，Gradle Wrapper 是一个用于管理 Gradle 版本的工具。

在 Unix/Linux 或 macOS 上使用`./gradlew`,在 Windows 上使用`gradlew.bat`检查项目目录下是否存在 Gradle 可执行文件。如果没有，它会自动下载并使用与项目中配置的 Gradle 版本匹配的 Gradle 发行版。

```
//构建标准任务
./gradlew build
// 构建应用的发布版本，与 ./gradlew build 命令相比会跳过一些不必要的任务，以加快构建速度
./gradlew assembleRelease
// 构建特定的定制任务，需在build.gradle相应配置
./gradlew assemblePrd64Release
#更换包名为gkdev
./gradlew replacePackageName -PcurrentPackageName="gkapp" -PreplacePackageName="gkdev"
//清理
./gradlew clean
```

## 报错问题1.0

**Unsupported Java.  Your build is currently configured to use Java 17.0.6 and Gradle 5.5.** 

使用的java过高，而 gradle5.5对应的是java8，最新安装的编译器java版本是17。

解决办法是为项目配置低版本的JDK,如下路径，将jbr-17改为1.8
setting或Preferences -> Build,Execution,Deployment -> Build Tolls -> Gradle


## 注册推送时toast提示
`pushAgent.register方法应该在主进程和channel进程中都被调用` 如何解决

## release包闪退
升级gradle和sdk后，as打包apk没有问题，脚本`./gradlew assembleRelease`打包安装闪退：
`Unable to load script. Make sure you're either running a Metro server (run 'react-native start') or that your bundle 'index.android.bundle' is packaged correctly for release.`

**排查：**查看apk包里及assets里都没有`index.android.bundle`文件。打包没有打进去啊！
**解决：**

在脚本打包的时候需要先将Metro Bundler在终端启动`react-native start`，然后再执行脚本，似乎也是没有解决问题。尝试`./gradlew buildRelease`


## android混淆
在 build.gradle 文件中配置混淆：
```
android {
    buildTypes {
        release {
            minifyEnabled true // 开启代码混淆
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        // 可选：如果有其他构建类型（如 debug），也可以进行配置
        debug {
            minifyEnabled false // debug 模式下通常不开启混淆
        }
    }
}

```
getDefaultProguardFile('proguard-android-optimize.txt') 是默认的 Android 平台优化配置文件，'proguard-rules.pro' 是你可以自定义的 ProGuard 规则文件。

## 小米手机rn运行报错
`getLine1NumberForDisplay: Neither user 10298 nor current process has android.permission.READ_PHONE_STATE, android.permission.READ_SMS, or android.permission.READ_PHONE_NUMBERS`

需要在AndroidManifest.xml文件添加相应的权限：
```
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
//targetSdkVersion=30是小米手机必需
<uses-permission android:name="android.permission.READ_PHONE_NUMBERS" />

```


