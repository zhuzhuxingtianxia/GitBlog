# 更现代的 Swift API 设计
[本文转载自这里](https://mp.weixin.qq.com/s/DhtYVLNq5IRu2eUEktXgJg)

## 前言
Swift 是一门简洁同时富有表现力的语言，这其中隐藏着众多的设计细节。
本文通过提出一个 Struct 的语义问题，在寻找答案的过程中逐步介绍这些概念：

* DynamicMemberLookup 应用
*	PropertyWrapper 的实现原理
*	SwiftUI DSL 中 PropertyWrapper 的应用
来一起看看更现代的 API 背后的设计过程。

```
WWDC19 部分 sessions 和示例代码中的 PropertyDelegate 即是 PropertyWrapper，后续会统一命名为 PropertyWrapper
```
## Clarity at the point of use
最大化使用者的清晰度是 API 设计的第一要义:

*	Swift 的模块系统可以消歧义
*	Swift-only Framework 命名不再有前缀
*	C & Objective-C 符号都是全局的
```
提醒：
每一个源文件都会将所有 import 模块汇总到同一个命名空间下。你依旧应该谨慎的对待命名，以确保同一命名在复杂上下文依旧有清晰的语义。
```

## 选择 Struct 还是 Class？
相很多类似问题一样，你需要重新思考二者的语义。
默认情况下，你应该优先选择 Struct。除非你必须要用到 Class 的特性。
比如这些需要使用 Class 的场景：

*	需要引用计数或者关心析构过程
*	数据需要集中管理或共享
*	比较操作很重要，有类似 ID 的独立概念 
很多文章有过讨论，这里不作过多介绍，下面我们看看实际问题。

## Struct 中嵌套 Class 的拷贝问题
无论是基于历史问题还是要对不同类型数据组合使用，常常碰到 Struct 和 Class 组合嵌套的情况。

*	Class 中存在 Struct，这种情况再正常不过，使用时也不会带来什么问题，不必讨论
*	Struct 中存在 Class，这种情况破坏了 Struct 的语义，运行时拷贝也可能带来不符合预期的情况，下面重点讨论这个问题。 
定义如代码所示，Struct Material 有一个成员属性 texture 是 Class 类型：

```
struct Material { 
 public var roughness: Float 
 public var color: Color 
 public var texture: Texture 
} 

class Texture { 
 var isSparkly: Bool
} 
```
当 Material 实例发生拷贝时，会发生什么?

![texture](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%20Swift%20API%20%E8%AE%BE%E8%AE%A1/texture.png)

很显然，两个 Material 实例持有同一个的 texture，所有 texture 引用所做的任何修改都会对两个 Struct 产生影响，这破坏了 Struct 本身的语义。
今天我们重点看看如何解决这个问题。

### 一个思路：把 texture 设为不可变类型？
![640](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%20Swift%20API%20%E8%AE%BE%E8%AE%A1/640.jpeg)

如图所示，并没有什么作用。
texture 对象的属性依旧可以被修改，一个标记 immutable 的实例属性还能被修改，这会带来更多困扰。

### 另一个思路：修改时拷贝
```
struct Material { 
 private var _texture: Texture 

 public var texture { 
  get { _texture } 
  set { _texture = Texture(copying: newValue) }
 } 
}
```
隐藏存储属性，开放计算属性。在计算属性被赋值时进行拷贝。
针对修改 Material 实例的 texture 属性这一场景，的确会生成单独的拷贝。然而除此之外，有太多的问题。

*	texture 实例的内部属性，依旧可能被意外修改
*	Material 发生写时拷贝时，被拷贝的存储属性 _texture 依旧是同一个

### 再一个思路：模仿 Copy On Write
既然我们连 Texture 的内部属性都要控制，开放 texture 访问带来太多问题，索性完全禁用 texture 的外部访问，把 texture 的属性（如 isSparkly）提升到 Material 属性层级，在访问 isSparkly 时，确保 _texture 引用唯一。

```
struct Material { 
 private var _texture: Texture 

 public var isSparkly: Bool { 
  get { 
      if !isKnownUniquelyReferenced(&amp;_texture) { // 确保 _texture 引用计数为 1
    _texture = Texture(copying: _texture) 
   } 
      return _texture.isSparkly 
    } 
  set { 
   _texture.isSparkly = newValue 
  } 
 } 
}
```
这样的确完整实现了 Struct Material 语义。哪怕 Material 写时拷贝有多个 _texture 引用，在访问 isSparkly 属性时也会发生拷贝，确保每个 Material 实例的 _texture 属性唯一。
唯一（而且是很重要）的问题是如果 Class Texture 属性很多，会引入大量相似代码。『可行』不代表『可用』。
没关系，我们再试试引入 DynamicMemberLookup。

## 初试 DynamicMemberLookup
> DynamicMemberLookup 具体概念可以参考卓同学的这篇文章：细说 Swift 4.2 新特性：[Dynamic Member Lookup](https://juejin.im/post/5b24c9896fb9a00e69608a71)

DynamicMemberLookup 是 Swift4.2 引入的新特性，使用在什么场景一度让人困惑。这里恰好能解决我们的问题。先上代码：
```
@dynamicMemberLookup
struct Material {

 public var roughness: Float
 public var color: Color

 private var _texture: Texture

 public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Texture, T>) -> T {
  get { _texture[keyPath: keyPath] }
  set {
   if !isKnownUniquelyReferenced(&amp;_texture) { _texture = Texture(copying: _texture) }
   _texture[keyPath: keyPath] = newValue
  }
 }
}
```
实现思路与之前的代码完全一致，只是引入 dynamicMemberLookup 动态提供对 Texture 的属性访问，这样无论 Class Texture 有多少属性，几行代码轻松支持。
需要留意的是 Xcode 11 完全支持 dynamicMemberLookup，代码提示也毫无压力

![dynamicMemberLookup](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%20Swift%20API%20%E8%AE%BE%E8%AE%A1/dynamicMemberLookup.png)

至此，似乎『完美解决』了Struct 中嵌套 Class 的拷贝问题。
此处卖个关子，后面还有更简洁的实现。先来看看 PropertyWrapper。

## PropertyWrapper

实际项目中有些属性的初始化性能开销较大，我们常常会用到懒加载：
```
public lazy var image: UIImage = loadDefaultImage()
```
如果不用`lazy`关键字，我们也可以这样实现：
```
public struct MyType {
 private var imageStorage: UIImage? = nil
  public var image: UIImage {
    mutating get {
   if imageStorage == nil {
    imageStorage = loadDefaultImage()
   }
      return imageStorage!
    }
  set { imageStorage = newValue }
 }
}
```
基于同样的思路，也会有另一些场景，比如需要的是延迟外部赋值，期望未赋值调用时抛出错误：
```
public struct MyType {
 
 var textStorage: String? = nil
 
 public var text: String {
  get {
   guard let value = textStorage else {
    fatalError("text has not yet been set!")
   }
   return value
  }
  set { textStorage = newValue }
 }
}
```
看起来不错。支持延迟外部赋值又有检查机制。唯一（而且是很重要）的问题是实现太臃肿。每个有同样逻辑的属性都需要大段重复代码。
还记得我们说过的：保持使用者的清晰度是 API 设计的第一要义

我们更倾向于使用者看到这样的代码：
```
@LateInitialized public var text: String
```
非常棒！定义本身清晰说明语义。更棒的是，这里的属性注解，完全支持自定义。
PropertyWrapper 顾名思义：属性包装器，没错，从 Swift5.1 开始，属性用这种方式支持自定义注解。
我们看看如何实现：

实现 `@LateInitialized` 注解，我们需要定义一个打上`@propertyWrapper`注解的 `struct LateInitialized<Value>` 😂，代码如下：
```
// Implementing a Property Wrapper 
@propertyWrapper
public struct LateInitialized<Value> {
 
 private var storage: Value? 

 public var value: Value {
  get {
   guard let value = storage else {
    fatalError("value has not yet been set!")
   }
    return value
  }
   set { storage = newValue }
 }
}
```
实现原理也不复杂。
用 `@LateInitialized` 修饰属性定义时，如：
```
@LateInitialized public var text: String
```

编译器会把属性代码展开，生成如下代码：
```
// Compiler-synthesized code… 
var $text: LateInitialized<String> = LateInitialized<String>()
public var text: String {
 get { $text.value }
 set { $text.value = newValue }
}
```
二者完全等价。

你可以把 `$text` 看成 `wrappedText`，又一次为了代码更清晰，苹果把 `$` 专用在属性注解场景，表达 wrapped 语义。

除此之外，PropertyWrapper 还支持自定义构造器：
```
@UserDefault(key: "BOOSTER_IGNITED", defaultValue: false)
static var isBoosterIgnited: Bool 

@ThreadSpecific
var localPool: MemoryPool 

@Option(shorthand: "m", documentation: "Minimum value", defaultValue: 0) // 命令行参数
var minimum: Int
```
还记得前面 Struct Material 中嵌套 Class 的拷贝问题 的例子吗？

### @CopyOnWrite：用 PropertyWrapper 带来的思路
通过自定义 `@CopyOnWrite` 注解，我们可以更优雅的解决这个问题：
```
@propertyWrapper
struct CopyOnWrite<Value: Copyable> {
    init(initialValue: Value) {
        store = initialValue
    }

    private var store: Value

    var value: Value {
        mutating get {
            if !isKnownUniquelyReferenced(&store) {
                store = store.copy()
            }
            return store
        }
        set { store = newValue }
    }
}

struct Material { 
 public var roughness: Float 
 public var color: Color 
 @CopyOnWrite public var texture: Texture 
} 

extension Texture: Copyable { ... }

// Copyable 具体实现略
```

代码不必过多解释，相信大家都能看懂。

### PropertyWrapper 在 SwiftUI DSL 中的应用
SwiftUI 是 WWDC19 的最大亮点，来看一个典型的 View 声明：
```
struct Topic {
  var title: String = "Hello World"
  var content: String = "Hello World"
}

struct TopicViewer: View {

 @State private var isEditing = false
 @Binding var topic: Topic
 
 var body: some View {
  VStack {
   Text("Title: #\(topic.title)")
   if isEditing {
    TextField($topic.content) 
   }
  }
  }
}

```
`@State`, `@Binding`, `$topic.title`？是不是似曾相识？
这些属性都是基于 PropertyWrapper 来实现的（或者说再加上 dynamicMemberLookup）。

这里以 `@Binding`的大致实现为例：
```
@propertyWrapper @dynamicMemberLookup

public struct Binding<Value> {

 public var value: Value {
  get { ... }
  nonmutating set { ... }
 }
 
 public subscript<Property>(dynamicMember keyPath: WritableKeyPath<Value, Property>) {
  ...
 }
}
```
属性定义展开过程如下：
```
@Binding var topic: Topic 

// 等价于

var $topic: Binding<Topic> = Binding<Topic>()
public var topic: Topic {
 get { $topic.value }
 set { $topic.value = newValue }
}
```
再来看看使用时的区别：
```
topic                // Topic instance 
topic.title          // String instance 

$topic      // Binding<Topic> instance 
$topic.title      // Binding<String> instance 
$topic[dynamicMember: \Topic.title]  // Binding<String> instance 
```
留意最后几行实例对应的类型：

*	看到`$`不要意外，这是取属性注解类型的实例，会想刚提到的代码展开`$topic`语义就是 `wrappedTopic`
*	Struct Binding 实现了 dynamicMemberLookup，`$topic.title` 可以正常调用，并且与 `$topic[dynamicMember: \Topic.title]` 完全等价
*	属性注解是 Struct，对应方法，属性，以及其它协议都可以支持，这里有很多的可能性还有待挖掘

我迫不及待把 PropertyWrapper 用在我们项目中，至少简化几百行属性相关的模板代码，更关键的是，这会带来能清晰的属性定义。

## 如何使用协议和泛型，让代码更少困扰

这里用新推出的[向量数据](https://developer.apple.com/documentation/swift/simd)做示例，通用性不是很强，这里不赘述。大体思想是：

*	不要无脑的从协议开始 Coding
*	从实际的使用场景开始分析问题，从尝试合并重复代码开始下手
*	优先尝试组合已有的协议，新协议会有新的理解成本
*	更多的在协议中使用泛型，解决通用问题 
## 总结
讨论了这么多，还记得最前面提到的吗：保持使用者的清晰度是 API 设计的第一要义！ 这个 session 讨论的问题和新概念无不围绕着这一目标：

*	DynamicMemberLookup 简化动态成员属性调用
*	PropertyWrapper 让属性可以自定义注解，统一属性模板代码并且提供文档化的书写方式
*	设计`$value`表达`wrappedValue`语义 
简洁的背后往往蕴涵着复杂的探索和巧妙的设计过程。
这个 session 更侧重介绍 Swift 语言细节的的设计理念，希望这些理念能帮助你用 Swift 在项目中设计出更现代、清晰度更高的 API。

