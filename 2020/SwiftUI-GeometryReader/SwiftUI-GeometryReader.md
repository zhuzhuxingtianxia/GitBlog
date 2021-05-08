# SwiftUI: GeometryReader

SwiftUI视图布局取决于每个视图状态。这种状态由内部属性、外部环境值等组成。

当涉及到高级自定义布局时，有时视图还需要其子视图的信息(直接的或非直接的)。

一个常见的例子是，当祖先(ancestors view)需要知道他们的孩子(children view)的大小:在本文中，我们将探讨如何做到这一点。

## 获取view size

当我们需要获取位置信息时，我们在SwiftUI中只有一个选择:`GeometryReader`.
`GeometryReader`包含着一个视图View的所有位置信息，无论水平方向还是垂直方向，它会返回一个`GeometryProxy`实例，这使我们能够访问其容器的大小和坐标。
```
var body: some View {
  GeometryReader { geometryProxy in
    ...
    // Use geometryProxy to get space information here.
  }
}
```
在本例中，我们不希望直接使用`GeometryReader`,相反，我们要看下特定视图view的空间信息。
SwiftUI提供了`.overlay()`和`.background()`,分别在前面和后面添加一个额外的视图.
最重要的是，这些视图的建议大小等于它们所应用的视图的大小，这使它们成为我们所寻找的完美候选对象:
```
var body: some View {
  childView
    .background(
      GeometryReader { geometryProxy in
        ...
        // Use geometryProxy to get childView space information here.
      }
    )
}
```
`GeometryReader`仍然需要我们在它的主体中声明一个视图，我们可以使用`Color.clear`创建一个隐形层:
```
var body: some View {
  childView
    .background(
      GeometryReader { geometryProxy in
        Color.clear
        // Use geometryProxy to get childView space information here.
      }
    )
}
```
好了!现在我们有了自己的空间信息，是时候让我们的子视图(childView)学习如何与他们的祖先视图(ancestorsView)交流了.

## 父子组件交互

SwiftUI提供了`PreferenceKey`的功能，这是SwiftUI通过视图树传递信息的方式。
我们开始自定义一个`PreferenceKey`,即`SizePreferenceKey`:
```
struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
```
`PreferenceKey`是一个通用协议，需要一个静态函数和一个静态默认值：
* `defaultValue`是被使用，当视图没有该属性的显式值时
* `reduce(value:nextValue:)`将渲染树中找到的value值与新的value值组合在一起。

我们将使用`PreferenceKey`来存储我们的子元素的测量大小，回到我们的示例:
```
var body: some View {
  childView
    .background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
}
```
现在子视图的大小就在渲染树的层次结构中了！我们怎么读取呢?
SwiftUI提供了一个`View`的extension,`onPreferenceChange(_:perform:)`它让我们指定一个PreferenceKey，当该PreferenceKey发生变化时就会触发回调方法：
```
var body: some View {
  childView
    .background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self) { newSize in
      print("The new child size is: \(newSize)")
    }
}
```
由于`onPreferenceChange`，任何对此PreferenceKey感兴趣的父组件都可以提取值并在值更改时得到通知。

## Extension
这种获取子视图大小的方法非常方便，我发现自己多次使用它，我为它编写了一个视图扩展，而不是反复复制粘贴：

```
extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}
```
这个扩展接受一个函数，当视图大小被更新时调用。修改上述代码：
```
var body: some View {
  childView
    .readSize { newSize in
      print("The new child size is: \(newSize)")
    }
}

```
这样就好多了



