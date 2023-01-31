# 学习笔记：深入RN知识总结

### 一、RN底层实现原理

#### 1.1、 React内部核心：虚拟DOM技术+diff算法。

React框架，将JSX代码渲染至虚拟 DOM，根据diff算法，计算出需要更新的DOM节点，然后更新到真实 DOM 的过程，最后在浏览器显示出来。

#### 1.2、ReactNative实现原理

##### 1.2.1、React Native 框架构成

RN内部框架由四大部分组成：内置组件库 + 内置API接口 + iOS 平台特定组件和API + 与 Android 平台特定组件和API 。

![image-20220519173207098](../../../../Library/Application Support/typora-user-images/image-20220519173207098.png)

##### 1.2.2、ReactNative 架构设计

- 三层架构模型
  采用三层架构经典设计模型，在JS 和 Native（Java或Objective）中，引入一层C++适配层。
  其中JS层，负责构建虚拟DOM、执行解析JavaScript代码，负责前端相关。Native层专注于原生交互通信。
  最重要是C++层，其实现了动态链接库功能，起到了衔接适配前端和原生平台作用，这个衔接具体指：使用 JavaScriptCore 解析 JavaScript 代码，通过 [MessageQueue.js](https://links.jianshu.com/go?to=https%3A%2F%2Flink.zhihu.com%2F%3Ftarget%3Dhttps%3A%2F%2Fgithub.com%2Ffacebook%2Freact-native%2Fblob%2Fmaster%2FLibraries%2FBatchedBridge%2FMessageQueue.js) 实现双向通信，实际上通信格式类似 JSON-RPC。

  ![image-20220519173302692](../../../../Library/Application Support/typora-user-images/image-20220519173302692.png)

##### 1.2.3、原理理解

![image-20220519173314938](../../../../Library/Application Support/typora-user-images/image-20220519173314938.png)

- ReactNative页面组件的实现和React框架一样，也是虚拟DOM+diff算法技术实现。
  RN的底层为 React 框架，所以如果是 UI 层的变更，那么就映射为虚拟 DOM 后进行 diff 算法，diff 算法计算出变动后的 JSON 映射文件，最终由 Native 层将此 JSON 文件映射渲染到原生 App 的页面元素上，最终实现了在项目中只需要控制 state 以及 props 的变更来引起 iOS 与 Android 平台的 UI 变更。
- ReactNative架构末端采用通过 Bridge 与原生进行交互。
- React Native代码最终会打包生成一个 `main.bundle.js` 文件供 App 加载；此文件可以是APP的静态资源，也可以存储在服务器，根据需要下载，动态加载。

### 二、RN的通信

#### 2.1、与原生平台通信

- iOS端，使用JavaScriptCore原生框架，做为作为 JS-VM（js虚拟机），中间通过 JSON 文件与 Bridge 进行通信。
- android端，使用 Chrome 的 V8 引擎（其他使用Chrome 浏览器进行调试时也是如此），与原生代码通过 WebSocket 进行通信。

#### 2.2、RN组件间通信

- 父组件 -> 子组件 传递数据：通过 props 的形式。
- 子组件 -> 父组件 传递数据：通过 向子组件传递`函数参数`实现，即函数式编程。
  在父组件的定义中，在调用子组件时，同样向子组件传递了一个参数，不过这个参数是一个函数，此函数用于接收后续子组件向父组件传递过来的数据。
- 跨组件通信，即无直接关系组件间通信
  使用EventEmitter / EventTarget / EventDispatcher继承或实现接口的方式、Signals 模式或 Publish / Subscribe 的广播形式，都可以达到无直接关系组件间的通信。
- 多级组件之间的通信：
  原始做法是一级级往下传递参数实现。还可以使用如 context 对象或 global 等方式进行多级组件间的通信，但是这种方式不推荐。
  其实本质上应该从组件设计上避免这样的情况发生。

#### 相关知识

- 前端布局引擎Yoga。
  Facebook在React Native里引入了一种跨平台的基于CSS的布局系统，它实现了Flexbox规范。Yoga是基于C实现的。
- 0.60.2版本后，引入新的JS引擎Hermes 。

#### 参考

[React Native 底层原理](https://links.jianshu.com/go?to=https%3A%2F%2Fzhuanlan.zhihu.com%2Fp%2F41920417)
[为什么说现在 React Native 凉了？](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.zhihu.com%2Fquestion%2F266630840%2Fanswer%2F1719977740)

------

### 三、网络

- RN提供了和 web 标准一致的[Fetch API](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.mozilla.org%2Fen-US%2Fdocs%2FWeb%2FAPI%2FFetch_API)，用于满足开发者访问网络的需求。
- RN支持[WebSocket](https://links.jianshu.com/go?to=https%3A%2F%2Fdeveloper.mozilla.org%2Fen-US%2Fdocs%2FWeb%2FAPI%2FWebSocket)，可以在单个 TCP 连接上提供全双工的通信信道。

#### 参考

[RN中文官网-网络编程](https://links.jianshu.com/go?to=https%3A%2F%2Freactnative.cn%2Fdocs%2Fnetwork)

------

### 四、RN的优化

#### 参考

[RN中文官网-性能调优](https://links.jianshu.com/go?to=https%3A%2F%2Freactnative.cn%2Fdocs%2Fperformance)

------

### 五、RN的坑

#### RN缺陷

- 1、数据通信过程是异步的，通信成本很高。
  **RN框架设计3个线程，分别为UI-Thread、JS-Thread、Native-Thread。**分别负责ui、js解析执行、执行C++代码及与原生交互功能。
- 2、仍有部分组件和 API 并没有实现平台统一，开发者需要了解原生开发细节。
  因此，大厂内部改造维护，例如携程的 CRN（Ctrip React Native）以及美团的 MRN。
- 3、RN的 UI 更新需要在三个不同的线程进行，效率低。
- 4、启动内存占用大、应用程序大、调用效率不高等等。

#### RN的演进

新版的ReactNative采用新的架构设计，优化线程模型、简化 Bridge 实现等。

参考：https://www.jianshu.com/p/13b2ef148c9d