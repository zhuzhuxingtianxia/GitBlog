# SwiftUI: PreferenceKey的reduce方法解密

SwiftUI的`PreferenceKey`声明如下:
```
public protocol PreferenceKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
  static func reduce(value: inout Self.Value, nextValue: () -> Self.Value)
}
```
虽然`Value`和`defaultValue`的性质和作用都很清楚，但对于`reduce(value: nextValue:)`却不能这样说,在本文中，让我们深入了解这个神秘的方法.

## 官方定义
以下是当前swiftUI的`reduce`头文件:
```
/// Combines a sequence of values by modifying the previously-accumulated
/// value with the result of a closure that provides the next value.
/// 通过修改前面积累的值和提供下一个值的闭包的结果来组合一个值序列。
///
/// This method receives its values in view-tree order. Conceptually, this
/// combines the preference value from one tree with that of its next
/// sibling.
/// 这个方法以视图树顺序接收它的值。从概念上讲，这将一个树的偏好值与它的下一个兄弟树的偏好值组
/// 合在一起
///
/// - Parameters:
///   - value: The value accumulated through previous calls to this method.
///     The implementation should modify this value.
///   - nextValue: A closure that returns the next value in the sequence.
static func reduce(value: inout Self.Value, nextValue: () -> Self.Value)
```
这个定义为`reduce`的核心功能奠定了一些基础,它用于计算视图`preference key`首选项键值，仅当多个子节点修改该键时才使用。

## NumericPreferenceKey
下面是一个简单的preference定义，它的值为整数:
```
struct NumericPreferenceKey: PreferenceKey {
  static var defaultValue: Int = 0
  static func reduce(value: inout Int, nextValue: () -> Int) { ... }
}
```
从现在开始，任何视图层次结构中的每个视图都为`NumericPreferenceKey`默认值为`0`，无论`reduce`实现如何。

## 何时调用reduce
想象一个小的视图层次结构，有一个根，两个叶子，中间没有任何东西:
```
VStack {
  Text("A")
  Text("B")
}
```
> 为清楚起见:`VStack`是根，而两个`Text`是叶。

我们将在不同的场景中使用这个层次结构。

## 没有更改/设置preference key的子选项
```
VStack {
  Text("A")
  Text("B")
}
```
这里没有视图设置自己的`NumericPreferenceKey`值,因此，所有视图都有一个`NumericPreferenceKey`值`NumericPreferenceKey.defaultvalue`，根据我们的定义，该值为`0`。
`NumericPreferenceKey.reduce`将永远不会在文本上调用，因为没有人可以将值传递给`Text`。
`reduce`也不会在`VStack`上回调，因为它的子对象没有设置/传递`NumericPreferenceKey`值给它们的父对象.

## 一个子选项更改/设置preference key
```
VStack {
  Text("A")
    .preference(key: NumericPreferenceKey.self, value: 1)
  Text("B")
}
```
在这种情况下:
* `Text("A")`将其`NumericPreferenceKey`值设置为`1`，并将其传递给其父选项
* `Text("B")`默认`NumericPreferenceKey`为`defaultValue`，不会传递任何信息给它的父对象

VStack呢?让我们再次看一下`reduce`定义:`Combines a sequence of values by modifying the previously-accumulated value with the result of a closure that provides the next value.`
因为只有设置/更改`NumericPreferenceKey`值的子选项才会把它传递给他们的父选项，所以`VStack`只会积累一个值:`Text("A")`中的`1`。
因此，再一次使用`NumericPreferenceKey.reduce`也不会在`VStack`上调用，并且与`VStack`关联的`NumericPreferenceKey`值现在是`1`。

## 多个子选项更改/设置preference key
```
VStack {
  Text("A")
    .preference(key: NumericPreferenceKey.self, value: 1)
  Text("B")
    .preference(key: NumericPreferenceKey.self, value: 3)
}
```
在这个例子中:
* 这两个`Text`分别设置和传递一个`NumericPreferenceKey`值`1`和`3`给它们的父类
* `VStack`累加两个`NumericPreferenceKey`值之和

SwiftUI不知道要给`VStack`分配哪个`NumericPreferenceKey`值，因为它的子节点提供了多个值，这就是我们的`NumericPreferenceKey.reduce`可以帮助SwiftUI将这些多个值减少为一个，然后将其分配给我们的`VStack`。
即使传入的所有值都相同，`NumericPreferenceKey.reduce`也会被调用。

那么`VStack`的值是多少呢?在回答这个问题之前，我们需要知道传递给`VStack`的值的顺序。

## Reduce调用顺序
`PreferenceKey`的`reduce`方法包含两个参数：当前的`value`,和下一个要合并的值`nextValue`。
回到我们的例子：
1. `VStack`首先从`Text("A")`接受到值`1`.由于之前没有其他的值被累计，这个值变成了`VStack`的当前值.
2. 然后`VStack`首先从`Text("B")`接受到值`3`，现在SwiftUI需要将这个值与当前值结合起来，因此调用`NumericPreferenceKey.reduce`使用`1`作为`value`参数，`3`作为`nextValue`.

这就是SwiftUI头文件中所说以视图树顺序接收其值的含义,`reduce`方法是一直回调通过声明顺序遍历我们的子视图从第一个到最后一个。

如果`VStack`有从`A`到`Z`的`Text`，它们都设置了`NumericPreferenceKey`的值，`reduce`将首先使用从`Text("A")`和`Text("B")`继承来的当前值调用，然后使用新的当前值和`Text("C")`，等等。

`reduce`只在兄弟视图之间调用累积它们的值，如果一个`VStack`子节点有它自己的子节点,同样的概念将被递归应用,然后这个子节点将把它的最终值传递给`VStack`，而不管它是如何获得的。

最后是计算`VStack`的`NumericPreferenceKey`值的时候了,为此，我们需要看一下`NumericPreferenceKey.reduce`的方法实现。

## 常见的reduce实现
每个首选项键(preference key)声明都有自己的`reduce`实现,在这一节中，让我们介绍一些最常见的问题。

### value = nextValue()
最常见的定义是将`nextValue()`赋值给`value`,则`NumericPreferenceKey`实现如下：
```
struct NumericPreferenceKey: PreferenceKey {
  static var defaultValue: Int = 0

  static func reduce(value: inout Int, nextValue: () -> Int) { 
    value = nextValue()
  }
}
```
让我们回到`Text("A")`和`Text("B")`都传递一个值的例子,计算`VStack`的`NumericPreferenceKey`:
* 首先`VStack`接受`Text("A")`传递的值,因为之前没有积累的值,所以这个值将作为`VStack`当前值的新值
* 然后`VStack`接受`Text("B")`传递的值,现在有两个值`reduce`是被回调，`VStack`的新值将是新的建议值(这就是`value = nextValue()`所做的)。

换句话说，通过这个实现，当多个子对象传递一个值时，`reduce`将丢弃所有子对象，但最后一个将成为我们视图的值。

### reduce空的实现
一个空的`reduce`实现:
```
struct NumericPreferenceKey: PreferenceKey {
  static var defaultValue: Int = 0

  static func reduce(value: inout Int, nextValue: () -> Int) { 
  }
}
```
让我们再次回到我们的例子，计算`VStack`的`NumericPreferenceKey`:
* 首先`VStack`接受`Text("A")`传递的值,因为之前没有积累的值,所以这个值将作为`VStack`当前值的新值
* 然后`VStack`接受`Text("B")`传递的值,现在有两个值`reduce`是被回调,但是什么都没发生，因为我们的`reduce`什么都没做。`VStack`保持当前值

这个实现与前面的实现相反:我们的视图将保留第一个收集的值，并忽略其余的。

### value += nextValue()
其他常见的实现使用`reduce`将所有值与一些数学运算符(如sum)组合在一起:
```
struct NumericPreferenceKey: PreferenceKey {
  static var defaultValue: Int = 0

  static func reduce(value: inout Int, nextValue: () -> Int) { 
    value += nextValue()
  }
}
```
在这种情况下，我们的视图的值将是其子视图传递的所有值的总和,即累加操作。

### 更多的操作
其他值得提及的实现是是数组或字典的操作，`reduce`方法用于将所有子值分组在一起(通过`append(contentsOf:)`或类似的方法)。
一旦我们理解了`preference key`的内部工作原理，就可以直观地阅读和理解`reduce`的效果。

## PreferenceKey是当前状态的方法
与SwiftUI视图一样，`preference key`值是当前状态的结果，不会持久存在。

例如，如果我们查看`value += nextValue()` `reduce`的实现，当前视图值就是当前传递值的总和。
如果其中一个子节点更改了传递的值，SwiftUI将从头开始重新计算视图的`preference key`值。

对于任何`preference key`值都是如此,即使是在数组或字典的情况下。

## 何时触发计算preference key？
如果我们应用中的完整视图是`VStack`的例子，那么`reduce`实际上永远不会被调用:
```
struct ContentView: View {
  var body: some View {
    VStack {
      Text("A")
        .preference(key: NumericPreferenceKey.self, value: 1)
      Text("B")
        .preference(key: NumericPreferenceKey.self, value: 3)
    }
  }
}
```
这是真的，尽管`VStack`有多个`NumericPreferenceKey`值传递:这篇文章欺骗了我们吗?
SwiftUI总是尽可能少地向最终用户展示最终结果，在这个例子中，没有人在读取或使用`preference key`,因此SwiftUI会忽略它。

我们所有的key实际上都在那里，并在视图层次结构中正确的位置出现，它们只是没有被使用，因此SwiftUI不会花任何时间来解析它们。

如果我们想看到`reduce`被调用,我们需要使用`NumericPreferenceKey`，方法就是在`VStack`中添加一个`onPreferenceChange(_:perform:)`函数:
```
struct ContentView: View {
  var body: some View {
    VStack {
      Text("A")
        .preference(key: NumericPreferenceKey.self, value: 1)
      Text("B")
        .preference(key: NumericPreferenceKey.self, value: 3)
    }
    .onPreferenceChange(NumericPreferenceKey.self) { value in
      print("VStack's NumericPreferenceKey value is now: \(value)")
    }
  }
}
```
`onPreferenceChange(_:perform:)`告诉SwiftUI我们想知道我们的`VStack`的 `NumericPreferenceKey`值是什么，以及它什么时候发生变化,这是我们看到`reduce`方法被调用所需要的全部内容。

## 为什么reduce的nextValue是一个函数
当阅读`PreferenceKey`的定义时，可能会出现一些令人困惑的事情，那就是为什么`reduce`参数是一个值和一个函数，我们把两个值结合起来，对吧?为什么SwiftUI不能直接给出下一个明确的值呢?
```
public protocol PreferenceKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
  static func reduce(value: inout Self.Value, nextValue: () -> Self.Value)
}
```
原来又是swiftUI懒惰的原因。
让我们以前面的`reduce` empty实现为例，在一个稍微复杂一些的示例中使用它:
```
struct ContentView: View {
  var body: some View {
    VStack {
      Text("A")
        .preference(key: NumericPreferenceKey.self, value: 1)

      VStack {
        Text("X")
          .preference(key: NumericPreferenceKey.self, value: 5)
        Text("Y")
          .preference(key: NumericPreferenceKey.self, value: 6)
      }
    }.onPreferenceChange(NumericPreferenceKey.self) { value in
      print("VStack's NumericPreferenceKey value is now: \(value)")
    }
  }
}

struct NumericPreferenceKey: PreferenceKey {
  static var defaultValue: Int = 0
  static func reduce(value: inout Int, nextValue: () -> Int) { 
  }
}
```
在这里我们用一个`VStack`作为根视图，这个`VStack`包含两个子视图，一个`Text("A")`和一个`VStack`,这个`VStack`子视图又有两个`Text`子视图。

所有的`Text`在试图中都设置了它们自己的`NumericPreferenceKey`,我们在根视图调用`onPreferenceChange(_:perform:)`方法。

让我们计算`NumericPreferenceKey`的值：
* 首先`VStack`接收`Text("A")`传递的值，因为之前没有积累的值，所以这个值将作为`VStack`当前值的新值
* 然后`VStack`从另一个子视图`VStack`接收到另一个值，我们的`reduce`方法被调用

在这个例子中`reduce`没有做任何事情，我们不需要知道内部子视图`VStack`传递的确切值是什么。
由于我们不访问`nextValue`, SwiftUI甚至不会计算它。

这意味着内部子视图`VStack`的`preference key`根本不计算，因为没有人读取它，因此我们的`reduce`只被调用一次，只解析根视图`VStack`的`preference key`。

这就是为什么`reduce`接受一个值和一个方法:`nextValue()`方法是SwiftUI检查是否确实需要该值的一种方法，如果不需要，则不会解析它。

SwiftUI需要尽可能快速和高效地解析整个视图层次结构，这是一种优化。

## 结论
SwiftUI的`PreferenceKey`是一种不太流行的幕后工具,但要实现某种效果，却又不可或缺:
在这篇文章中，我们探索了`PreferenceKey`的内部工作原理，并揭示了它的`reduce`方法是如何使用的以及它的用途，从而发现了更多的SwiftUI的作用。


