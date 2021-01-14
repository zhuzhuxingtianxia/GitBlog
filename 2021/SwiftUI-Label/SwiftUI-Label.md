# SwiftUI: Label
<!--- https://fivestars.blog/swiftui/label.html --->
`Label`是SwiftUI2.0新增加的组件。`Label`将文本和图像组合在一个视图中,它还根据上下文(例如，如果它放在工具栏上)和动态类型进行调整。

![image0](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image0.png)
在本文中，让我们在基本知识之外探索这个视图。

## Initializers

`Label`带有六个初始化方法：

* 前四种格式提供了所有可能的文本组合，如`StringProtocol`或`LocalizedStringKey`,以及图片资源或SF Symbols资源。
* 最灵活的初始化方法有两个泛型视图，没有附加字符串
* 最后一个初始化方法接受一个`LabelStyleConfiguration`参数

我们将在本文中讨论所有的初始化方法。
 
## Label styles
除非我们在一个特殊的环境中(例如导航栏)，默认情况下`Label`的title和image都是显示的。

如果我们只想显示两个组件中的一个(要么只显示图片，要么只显示标题)，或者用另一种方式改变`Label`外观，我们可以通过`labelStyle(_:)`视图修饰符来实现:这个修饰符接受一个`LabelStyle`实例。

`LabelStyle`告诉SwiftUI我们希望`Label`如何绘制在屏幕上，默认情况下我们有三个选项:

* `IconOnlyLabelStyle()`
* `TitleOnlyLabelStyle()`
* `DefaultLabelStyle()`

这些内插样式是相互排斥的:如果多个应用于同一个`Label`标签，则只有最接近该`Label`标签的一个才生效。
```
// 只有 `IconOnlyLabelStyle()` 生效:
Label("Title", systemImage: "moon.circle.fill") 
  .labelStyle(IconOnlyLabelStyle())
  .labelStyle(TitleOnlyLabelStyle())
  .labelStyle(DefaultLabelStyle())
```
![image1](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image1.png)

因为`LabelStyle`是一个协议，我们可以定义自己的样式:
```
public protocol LabelStyle {
    associatedtype Body: View

    func makeBody(configuration: Self.Configuration) -> Self.Body

    typealias Configuration = LabelStyleConfiguration
}
```

类似于`ViewModifier`,`LabelStyle`需要实现`makeBody(configuration:)`方法，这使我们有机会定义自己的标签样式。

`makeBody(configuration:)`接受一个`LabelStyleConfiguration`实例，它与上面列出的最后一个`Label`初始化方法接受的参数相同。

我们不能自己定义一个全新的配置，这是SwiftUI保留的，但是我们可以访问当前`Label`标签的image图片(命名为`icon`)和title标题：
```
public struct LabelStyleConfiguration {
  /// A type-erased title view of a label.
  public var title: LabelStyleConfiguration.Title { get }

  /// A type-erased icon view of a label.
  public var icon: LabelStyleConfiguration.Icon { get }
}
```

多亏了这个配置，我们的`LabelStyle`被应用于当前样式之上。
例如，这里我们创建了一个`LabelStyle`，为整个`Label`添加阴影:

```
struct ShadowLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label(configuration)
      .shadow(color: Color.gray.opacity(0.9), radius: 4, x: 0, y: 5)
  }
}
```
> 这是我们唯一可以使用`Label`初始化的地方

由于`ShadowLabelStyle`是当前`LabelStyle`之上的一个样式，它将应用于当前的`Label`标签。
因此，例如，如果我们把它和`IconOnlyLabelStyle`一起使用，最终的结果将是一个只有图标和我们的阴影的标签:
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(ShadowLabelStyle())
  .labelStyle(IconOnlyLabelStyle())
```

![image2](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image2.png)

## Label样式的橡皮擦

`.labelStyles`声明顺序很重要,上面我们已经看到这三种回退样式是如何相互排斥的，这在它们自己的定义中真正意味着什么，它们不使用传递到`makeBody(configuration:)`中的配置，而是创建一个新的配置。
换句话说,`IconOnlyLabelStyle`, `TitleOnlyLabelStyle`,和 `DefaultLabelStyle`充当样式擦除器:一旦应用，以前的任何样式都不会继续使用。

看看我们的`ShadowLabelStyle`的例子：
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(ShadowLabelStyle())
  .labelStyle(IconOnlyLabelStyle())
```
![image2](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image2.png)

输出`Label`标签的图标是否带有阴影。
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(IconOnlyLabelStyle()) // <- the label style order has been swapped
  .labelStyle(ShadowLabelStyle())
```
![image1](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image1.png)

输出`Label`标签的图标没有阴影。
由于我们使用的是一个样式擦除器，SwiftUI甚至不会首先使用我们的样式，这可以通过在`ShadowLabelStyle`的`makeBody(configuration:)`实现中添加断点来验证:SwiftUI根本不会调用我们的方法。

## 自定义样式橡皮擦
如上所述，只有SwiftUI可以创建新的配置，然而，有一个简单的技巧可以使任何自定义样式也成为样式橡皮擦：在`makeBody(configuration:)`实现中应用一个系统样式的擦除器。
```
struct ShadowEraseLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label(configuration)
      .shadow(color: Color.gray.opacity(0.9), radius: 4, x: 0, y: 5)
      .labelStyle(DefaultLabelStyle()) // <- ✨
  }
}
```

在这个例子中，我们强制我们的标签`Label`同时显示文本和图标，以及我们的阴影，之前应用的任何其他样式都被忽略:
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(ShadowEraseLabelStyle())
  .labelStyle(TitleOnlyLabelStyle())
  .labelStyle(IconOnlyLabelStyle())
```

![image4](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image4.png)

同样，由于我们的样式现在扮演了一个样式橡皮擦的角色，所以它不会被应用到当前样式之上，而是从一个干净的`Label`开始。

## LabelStyleConfiguration的icon和title的样式

我们可能还试图通过将两个配置视图传递给一个新`Label`标签来删除样式：
```
struct ShadowLabelTryStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label(
      title: { configuration.icon },
      icon: { configuration.title }
    )
    .shadow(color: Color.gray.opacity(0.9), radius: 4, x: 0, y: 5)
  }
}
```
使用我们的视图Body:
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(ShadowLabelTryStyle())
  .labelStyle(IconOnlyLabelStyle())
```
![image2](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image2.png)

有趣的是，这是行不通的,结果是`configuration.icon`和`configuration.title`延续了整个配置风格。
在上面的例子中，`title`视图将被隐藏，尽管我们创建了一个新的`Label`而没有直接传递配置本身。
为了进一步证明这一点，让我们定义一个新的样式，它所做的只是将标签`Label`的标题`title`与图标`icon`交换:
```
struct SwapLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    Label(
      title: { configuration.icon },
      icon: { configuration.title }
    )
  }
}
```
> 新标签以原始标题作为其图标，原始图标作为其标题。

现在想象一下这个视图主体:
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(SwapLabelStyle())
  .labelStyle(IconOnlyLabelStyle())
```
我们期望的最终结果是什么?
我们首先应用`IconOnlyLabelStyle`，因此标题`title`是隐藏的，而图像`"moon.circle.fill"`显示。
我们在`SwapLabelStyle`中交换它们并没有达到效果，用户看到的还是原来的图标。

![image1](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image1.png)

## 自定义icon和title的样式
为了完整起见，我必须指出`LabelStyle`的`makeBody(configuration:)`只需要返回`some View`，而不是`Label`(或带有几个修饰符的`Label`标签)。
这意味着我们真的可以用它做任何我们想做的事情,把我们的标签变成`HStack`怎么样?
```
struct HStackLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.icon
      Spacer()
      configuration.title
    }
  }
}
```
这里我们用它作为其他`Label`:

```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(HStackLabelStyle())
```
![image5](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image5.png)

虽然这可以工作，但这是一个绝佳的机会来指出`.labelStyle`修饰符只有在应用于标签时才能工作,
由于`HStackLabelStyle`不返回`Label`标签，任何进一步应用的标签样式(包括擦除标签)都将被忽略。
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(HStackLabelStyle())
  .labelStyle(ShadowLabelStyle())
  .labelStyle(IconOnlyLabelStyle())
```
![image5](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image5.png)

在`HStackLabelStyle`之前应用它们就可以了:
```
Label("Title", systemImage: "moon.circle.fill")
  .labelStyle(ShadowLabelStyle())
  .labelStyle(IconOnlyLabelStyle())
  .labelStyle(HStackLabelStyle())
```
![image2](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image2.png)

然而，如果我们这样做，我们可能一开始就不应该使用Label。

## 可访问的Label
虽然`LabelStyle`主要用于添加新的样式，但我们也可以使用它使我们的`Label`标签更容易访问。

例如，当系统内容大小属于可访问性大小时，我们可能希望去掉任何标签效果并隐藏图标，只留下用户继续执行任务所需的最低限度例如，当系统内容大小属于可访问性大小时，我们可能希望去掉任何标签效果并隐藏图标，只留下用户继续执行任务所需的最低限度。

这是一个很好的例子，`LabelStyle`和我们的[条件修饰符扩展](https://www.jianshu.com/p/28e7c5b10128):
```
struct AccessibleLabelStyle: LabelStyle {
  @Environment(\.sizeCategory) var sizeCategory: ContentSizeCategory

  func makeBody(configuration: Configuration) -> some View {
    Label(configuration)
      .if(sizeCategory.isAccessibilityCategory) { $0.labelStyle(TitleOnlyLabelStyle()) }
  }
}
```

![image6](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image6.png)

## Label Extensions
尽管标签样式是自定义和标准化标签的主要方式，但有时我们可以通过创建一个标签扩展来代替。

例如，在今年的《SF Symbols 2》更新中，我们已经获得了其中一些颜色变体:
不幸的是，开箱即用，标签默认显示单色变体，没有办法改变它。

这可以通过标签扩展来解决:
```
extension Label where Title == Text, Icon == Image {
  init(_ title: LocalizedStringKey, colorfulSystemImage systemImage: String) {
    self.init {
      Text(title)
    } icon: {
      Image(systemName: systemImage)
        .renderingMode(.original)
    }
  }
}
```
我们可以用`colorfulSystemImage`来替换`systemImage`参数名，例如:

```
Label("Title", colorfulSystemImage: "moon.circle.fill")
  .labelStyle(ShadowLabelStyle())
```

![image7](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-Label/image7.png)

## 总结

Label是SwiftUI的另一个例子，表面上看起来非常简单，但实际上隐藏了大量的复杂性和灵活性。

