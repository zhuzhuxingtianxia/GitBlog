# SwiftUI:可组合的视图
<!--- https://fivestars.blog/swiftui/design-system-composing-views.html --->

由于SwiftUI的可组合特性，我们一开始可能想要做的一件事就是定义和使用一个设计系统:一旦我们有了一个设计系统，创建视图就变成了从系统中选择正确的元素并将它们放置到屏幕上的问题。

在本文中，让我们看看如何开始构建设计系统的核心组件之一:TextField。

## 开始
设计团队给app的text field设计了两种不同的外观，一个是`default`默认状态，另一个是`error`告诉用户出了问题。

除了外观之外，所有文本字段都有相同的组件:`title`标题、`placeholder`占位符和`border`边框。

[![image0](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image0.png)](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image0.png)
[![image1](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image1.png)](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image1.png)


> 两种TextField的外观:`default`和`error`。

有了这些知识，我们继续构建我们自己的`FSTextField`:
```
struct FSTextField: View {
  var title: LocalizedStringKey
  var placeholder: LocalizedStringKey = ""
  @Binding var text: String
  var appearance: Appearance = .default

  enum Appearance {
    case `default`
    case error
  }

  var body: some View {
    VStack {
      HStack {
        Text(title)
          .bold()
        Spacer()
      }

      TextField(
        placeholder,
        text: $text
      )
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .strokeBorder(borderColor)
      )
    }
  }

  var borderColor: Color {
    switch appearance {
    case .default:
      return .green
    case .error:
      return .red
    }
  }
}
```
`FSTextField`被定义为一个上面有一个标题(一个`Text`)的VStack，底部有一个SwiftUI的`TextField`:这个声明是清晰的，覆盖了所有已知的情况。

我们对`FSTextField`很满意:我们添加了几个预览.

## 一周之后
一周之后，我们发现设计做了两种新的变化，第一个是在右上角显示一个字形，与标题垂直对齐，另一个是在同一点显示一条消息:

![image2](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image2.png)
![image3](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image3.png)

我们定义了两个新视图,`FSGlyphTextField` 和 `FSMessageTextField`,代码设计如下：
```
struct FSGlyphTextField: View {
  var title: LocalizedStringKey
  var symbolName: String
  var systemColor: Color = Color(.label)
  var placeholder: LocalizedStringKey = ""
  @Binding var text: String
  var appearance: FSTextField.Appearance = .default

  var body: some View {
    VStack {
      HStack {
        Text(title)
          .bold()
        Spacer()
        Image(systemName: symbolName)
          .foregroundColor(systemColor)
      }

      TextField(
        ...
      )
    }
  }

  var borderColor: Color {
    ...
  }
}

struct FSMessageTextField: View {
  var title: LocalizedStringKey
  var message: LocalizedStringKey
  @Binding var text: String
  var appearance: FSTextField.Appearance = .default

  var body: some View {
    VStack {
      HStack {
        Text(title)
          .bold()
        Spacer()
        Text(message)
          .font(.caption)
      }

      TextField(
        ...
      )
    }
  }

  var borderColor: Color {
    ...
  }
}
```
我们的设计系统现在定义了三个`TextField`，而不是一个，如何做的更好呢？

## 又过了一周

设计师又修改了`TextField`的展示方式，第一个没有标题，而另一个有通常的标题并在后面的角落有一个按钮：

![image4](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image4.png)
![image5](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image5.png)

我们可以再定义两个文本字段视图(像`FSPlainTextField`和`FSButtonTextField`一样)，然而，为每个变化创建新的视图违背了设计的目的，当设计发生变化，而我们必须更新标题字体或边框颜色时，会发生什么?

我们定义的`TextField`越多，就越难管理每个组件。

## 通用的TextField核心组件

在当前的方法中，我们已经利用了SwiftUI的可组合性，因为我们在构建屏幕时使用了所有这些变体，但是为了更好，在我们的`TextField`定义中也使用可组合性。
首先，看看当前的变化，我们发现有一个常数：text field本身。让我们从上面的定义中进一步封装：

```
struct _FSTextField: View {
  var placeholder: LocalizedStringKey = ""
  @Binding var text: String
  var borderColor: Color

  var body: some View {
    TextField(
      placeholder,
      text: $text
    )
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .strokeBorder(borderColor)
    )
  }
}
```

![image7](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image7.png)
![image6](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image6.png)

> 我们的两个`_FSTextField`变体。

`_FSTextField`是SwiftUI的`TextField`的包装器，我们的应用程序设计应用于它,我们用下划线“_”前缀(`_FSTextField`)定义这个视图，以便清楚地表明不应该直接使用这个视图，而是其他视图的实现细节。

如果我们用`_FSTextField`替换之前的`TextField`定义，这已经有帮助了:

将来，当我们想要更新文本字段的角半径时，我们只需要在`_FSTextField`内更改它，所有其他视图将自动继承更改。

## 通用的TextField可组合视图

看看我们的`text fields`变体，我们可以将它们分为两类：

* 在`_FSTextField`之上有一些内容的视图(例如标题和符号)
* 只有普通的`_FSTextField`和其他字段的视图

让我们定义一个涵盖这两种变体的新通用视图`FSTextField`:
```
struct FSTextField<TopContent: View>: View {
  var placeholder: LocalizedStringKey = ""
  @Binding var text: String
  var appearance: Appearance = .default
  var topContent: TopContent

  init(
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default,
    @ViewBuilder topContent: () -> TopContent
  ) {
    self.placeholder = placeholder
    self._text = text
    self.appearance = appearance
    self.topContent = topContent()
  }

  enum Appearance {
    case `default`
    case error
  }
  
  var body: some View {
    VStack {
      topContent
      _FSTextField(
        placeholder: placeholder,
        text: $text,
        borderColor: borderColor
      )
    }
  }

  var borderColor: Color {
    switch appearance {
    case .default:
      return .green
    case .error:
      return .red
    }
  }
}
```
`FSTextField`是一个`VStack`,它包含一个通用的顶部视图`TopContent`和我们的`_FSTextField`在底部。
多亏了这个新定义，我们可以把任何视图放在`_FSTextField`之上，比如标签`Label`呢?

```
FSTextField(placeholder: "Placeholder", text: $text) {
  Label("Label Title", systemImage: "star.fill")
}
```

![imageLabel](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/imageLabel.png)

最后，我们需要注意在`_FSTextField`上面没有内容的视图变化，我们如何解决这个问题?

由于`VStacks`忽略了`EmptyViews`，如果我们想只显示`_FSTextField`而不显示其他内容，我们可以传递一个`EmptyView`实例作为`TopContent`:
```
FSTextField(
  placeholder: "Placeholder",
  text: $myText
) {
  EmptyView()
}
```

![image4](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image4.png)

它工作的原因：

* 一个带有`EmptyView`和`_FSTextField`的`VStack`(视觉上)等同于一个只有`_FSTextField`的`VStack`
* 任何只包含一个元素的堆栈(视觉上)都等价于只包含元素本身

因此：
```
var body: some View {
  VStack {
    EmptyView()
    _FSTextField(...)
  }
}
```
是一样的：
```
var body: some View {
  _FSTextField(...)
}
```
我们正在构建这个设计系统，我们知道这些技巧/细节，但是，我们不能要求我们的开发人员也有这样的深层次的知识:为了让他们的工作更简单，我们可以创建一个`FSTextField`扩展来隐藏这个`VStack` + `EmptyView`组合。

```
extension FSTextField where TopContent == EmptyView {
  init(
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default
  ) {
    self.placeholder = placeholder
    self._text = text
    self.appearance = appearance
    self.topContent = EmptyView()
  }
}
```
多亏了这个扩展，想只显示文本字段的开发人员现在可以使用这个新的初始化器，而不需要知道`FSTextField`是如何实现的:
```
FSTextField(placeholder: "Placeholder", text: $myText)
```

![image4](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image4.png)

## 通用TextField的初始化

所有其他文本字段都有某种`TopContent`要显示。
我们可以在这里停下来，每次都让开发人员自己定义内容,例如：
```
FSTextField(
  placeholder: "Placeholder",
  text: $myText
) {
  HStack {
    Text(title)
      .bold()
    Spacer()
  }
}
```

![image0](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image0.png)

然而，由于所有这些变体都有一个带有`title-space-something`模式的`TopContent`，我们可以用一个新的`FSTextField`扩展:
```
extension FSTextField {
  init<TopTrailingContent: View>(
    title: LocalizedStringKey,
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default,
    @ViewBuilder topTrailingContent: () -> TopTrailingContent
  ) where TopContent == HStack<TupleView<(Text, Spacer, TopTrailingContent)>> {
    self.placeholder = placeholder
    self._text = text
    self.appearance = appearance
    self.topContent = {
      HStack {
        Text(title)
          .bold()
        Spacer()
        topTrailingContent()
      }
    }()
  }
}
```
这个新的初始化方法让开发人员可以直接将标题文本作为初始化参数之一传递，然后有机会通过新的`topTrailingContent`参数定义放置在顶部尾部角落的其他内容。

例如，现在可以用以下代码获得我们的旧`FSMessageTextField`的效果：
```
FSTextField(
  title: "Title", 
  placeholder: "Placeholder",
  text: $text, topTrailingContent: {
  Text("Message")
    .font(.caption)
})
```

![image3](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image3.png)

如前所述，如果我们的开发人员只想显示一个`_FSTextField`和一个标题,它们不需要知道它们可以传递一个`EmptyView`实例作为`topTrailingContent`参数，因此最好创建一个新的扩展来处理这个场景:
```
extension FSTextField {
  init(
    title: LocalizedStringKey,
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default
  ) where TopContent == HStack<TupleView<(Text, Spacer, EmptyView)>> {
    self.init(
      title: title,
      placeholder: placeholder,
      text: text,
      appearance: appearance,
      topTrailingContent: EmptyView.init
    )
  }
}
```
同样，这是由于当放置在堆栈中时`EmptyView`会被忽略。
由于这个定义，一个简单的`text field + title`组合(没有顶部尾随视图)可以通过以下方式获得:
```
FSTextField(title: "Title", placeholder: "Placeholder", text: $myText)
```

![image0](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image0.png)

我们以前用新视图定义的所有其他变量现在都可以通过`FSTextField`直接获得。

完整代码如下：
```
struct _FSTextField: View {
  var placeholder: LocalizedStringKey = ""
  @Binding var text: String
  var borderColor: Color

  var body: some View {
    TextField(
      placeholder,
      text: $text
    )
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 8, style: .continuous)
        .strokeBorder(borderColor)
    )
  }
}

/* FSTextField */
struct FSTextField<TopContent: View>: View {
  var placeholder: LocalizedStringKey = "Placeholder"
  @Binding var text: String
  var appearance: Appearance = .default
  var topContent: TopContent

  init(
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default,
    @ViewBuilder topContent: () -> TopContent
  ) {
    self.placeholder = placeholder
    self._text = text
    self.appearance = appearance
    self.topContent = topContent()
  }

  enum Appearance {
    case `default`
    case error
  }
  
  var body: some View {
    VStack {
      topContent
      _FSTextField(
        placeholder: placeholder,
        text: $text,
        borderColor: borderColor
      )
    }
  }

  var borderColor: Color {
    switch appearance {
    case .default:
      return .green
    case .error:
      return .red
    }
  }
}


extension FSTextField where TopContent == EmptyView {
  init(
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default
  ) {
    self.placeholder = placeholder
    self._text = text
    self.appearance = appearance
    self.topContent = EmptyView()
  }
}

extension FSTextField {
  init<TopTrailingContent: View>(
    title: LocalizedStringKey,
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default,
    @ViewBuilder topTrailingContent: () -> TopTrailingContent
  ) where TopContent == HStack<TupleView<(Text, Spacer, TopTrailingContent)>> {
    self.placeholder = placeholder
    self._text = text
    self.appearance = appearance
    self.topContent = {
      HStack {
        Text(title)
          .bold()
        Spacer()
        topTrailingContent()
      }
    }()
  }
}

extension FSTextField {
  init(
    title: LocalizedStringKey,
    placeholder: LocalizedStringKey = "",
    text: Binding<String>,
    appearance: Appearance = .default
  ) where TopContent == HStack<TupleView<(Text, Spacer, EmptyView)>> {
    self.init(
      title: title,
      placeholder: placeholder,
      text: text,
      appearance: appearance,
      topTrailingContent: EmptyView.init
    )
  }
}

```

使用如下：

```
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        Group {
              FSTextField(
                placeholder: "Placeholder",
                text: .constant("")
              ) {
                Text("Title Centered")
                  .bold()
              }

              FSTextField(
                placeholder: "Placeholder",
                text: .constant("")
              )

              FSTextField(
                title: "Title",
                text: .constant(""),
                topTrailingContent: {
                Text("Message")
                  .font(.caption)
              })
            }
    }
}
```


![image10](https://github.com/zhuzhuxingtianxia/GitBlog/raw/master/2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/image10.jpeg)


## 总结
多亏了Swift和SwiftUI，我们才得以构建一个坚实、灵活、直观的设计系统，帮助我们以前所未有的速度构建、组合和更新整个屏幕。

SwiftUI在很多定义上都使用了同样的方法:

* `Button`的`init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void)`就是`init(action: @escaping () -> Void, label: () -> Label)`的快捷初始化方法
* 我们还学习到了SwiftUI是如何在不需要的时候隐藏可选绑定的


