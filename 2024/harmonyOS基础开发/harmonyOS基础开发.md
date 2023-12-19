# harmonyOS: 基础开发

## 项目目录结构（Stage模型）

* AppScope > app.json5: 应用的全局配置信息

	1. bundleName: 标识应用的唯一性
	2. icon: 应用图标
	3. label: 应用名称
	4. versionCode: 应用的版本号，值为32位非负整数
	5. versionName: 标识应用版本号的文字描述，用于向用户展示。例如：'1.0.0'
	6. minAPIVersion: 标识应用运行需要的SDK的API最小版本。由build-profile.json5中的compatibleSdkVersion生成
	7. targetAPIVersion: 标识应用运行需要的API目标版本。由build-profile.json5中的compileSdkVersion生成。
  
* entry: HarmonyOS工程模块，编译构建生成一个HAP包
	* src > main > ets：用于存放ArkTS源码。
	* src > main > ets > entryability：应用/服务的入口。
	* src > main > ets > pages：应用/服务包含的页面。
	* src > main > resources：用于存放应用/服务所用到的资源文件，如图形、多媒体、字符串、布局文件等。
	* src > main > module.json5：Stage模型模块配置文件。主要包含HAP包的配置信息、应用/服务在具体设备上的配置信息以及应用/服务的全局配置信息。[module.json5配置文件](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/module-configuration-file-0000001427744540-V3)
		
	* build-profile.json5：当前的模块信息、编译信息配置项，包括buildOption、targets配置等。其中targets中可配置当前运行环境，默认为HarmonyOS。
	* hvigorfile.ts：模块级编译构建任务脚本，开发者可以自定义相关任务和代码实现。

* oh_modules：用于存放三方库依赖信息。
* build-profile.json5：应用级配置信息，包括签名、产品配置等。
* hvigorfile.ts：应用级编译构建任务脚本。

## UIAbility
UIAbility也是系统调度的单元，为应用提供窗口在其中绘制界面。一个应用可以有一个UIAbility，也可以有多个UIAbility。

**UIAbility启动模式有三种:**

* singleton: 单实例模式,也是默认启动模式。该模式下若UIAbility实例存在会进入`onNewWant`回调。该模式需要在`module.json5`文件中的`module->abilities`下`launchType`字段配置为`singleton`。
* multiton: 多实例模式,每次调用`startAbility()`都会在应用进程中创建一个新的UIAbility实例。该模式需要在`module.json5`文件中的`module->abilities`下`launchType`字段配置为`multiton`。
* specified: 指定实例模式,针对一些特殊场景使用。在其他模式下使用`context.startAbility(want)`根据唯一key来启动指定的`specified`模式的Ability。该模式需要在`module.json5`文件中的`module->abilities`下`launchType`字段配置为`specified`。


## UIAbility生命周期状态

![ability](./ability.jpeg)

UIAbility的生命周期包括Create、Foreground、Background、Destroy四个状态，WindowStageCreate和WindowStageDestroy为窗口管理器（WindowStage）在UIAbility中管理UI界面功能的两个生命周期回调。

* onCreate: 在UIAbility实例创建时触发
* onWindowStageCreate: UIAbility实例创建完成之后，在进入`Foreground`之前，系统会创建一个WindowStage。`WindowStage`为本地窗口管理器，用于管理窗口相关的内容，例如与界面相关的获焦/失焦、可见/不可见。每一个UIAbility实例都对应持有一个WindowStage实例。在`onWindowStageCreate`回调中，通过`loadContent`接口设置UI页面加载、设置WindowStage的事件订阅
* onForeground: UIAbility切换至前台时触发,此时应用处于`Foreground`状态。在`onForeground`回调中申请系统需要的资源，或者重新申请在`onBackground`中释放的资源。
* onBackground: UIAbility切换至后台时候触发。此处可以释放UI页面不可见时无用的资源，或者执行较为耗时的操作，例如状态保存等
* onWindowStageDestroy: 在UIAbility实例销毁之前调用，可在此时释放UI页面资源。
* onDestroy: 在UIAbility销毁时触发

## ArkUI状态管理

* @State: 组件内的状态管理
* @Prop: 父子组件单向同步，当子组件中的状态依赖父组件传递的数据时，需要使用@Prop装饰器
* @Link: 父子组件状态双向同步时，父组件状态使用@State装饰，子组件使用@Link装饰器，传递时使用`$`修饰表示传递的是引用
* @Watch: 监听状态变化,当状态发生变化时，会触发声明时定义的回调,例如：`@Watch('onClickIndexChanged') clickIndex: number;
`当clickIndex状态变化时，将触发onClickIndexChanged回调
* @Provide和@Consume: 跨组件层级双向同步状态。 
	* @Provide装饰的状态变量自动对其所有后代组件可用，即该变量被“provide”给他的后代组件。由此可见，@Provide的方便之处在于，开发者不需要多次在组件之间传递变量。
	* 后代通过使用@Consume去获取@Provide提供的变量，建立双向数据同步。与@State/@Link不同的是，前者可以在多层级的父子组件之间传递。
	* @Provide和@Consume可以通过相同的变量名或者相同的变量别名绑定，变量**类型**必须相同。



