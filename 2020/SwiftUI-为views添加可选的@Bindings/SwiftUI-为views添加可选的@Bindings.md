# SwiftUI:为views添加可选的@Bindings
在WWDC20上，SwiftUI新增`DisclosureGroup`这个View。`DisclosureGroup`会根据state状态展示或隐藏view内容：
```
DisclosureGroup(isExpanded: $showingContent) {
   Text("Content")
} label: {
   Text("Tap to show content")
}

```

![tap.gif](./tap.gif)


引起我注意的是`DisclosureGroup`有几个初始化项:
有些需要`isExpanded` `Binding<Bool>`参数，有些不需要。
```
// no binding
DisclosureGroup {
  Text("Content")
} label: {
  Text("Tap to show content")
}

// with binding
DisclosureGroup(isExpanded: $showingContent) {
  Text("Content")
} label: {
  Text("Tap to show content")
}

```
视图View如何处理`@Binding`的呢？
在本文中，我们将尝试使用相同的API创建一个视图。
但首先，让我们看看`DisclosureGroup`背后的概念

## 为什么要有这些options?
在WWDC20会议的[Data Essentials in SwiftUI](https://www.wwdcnotes.com/notes/wwdc20/10040/)部分中,SwiftUI团队教我们在创建一个新的视图时问以下问题:
1. 这个视图需要什么数据?
2. 视图将如何操作这些数据?
3. 数据从何而来?
4. 谁拥有数据?

`DisclosureGroup`清楚`isExpanded`的state状态在内部外部都可以处理：
* 在内部，这个状态不影响视图层次结构的任何其他部分。
* 在外部，我们可以在其他地方访问和操作这个状态。

对于`DisclosureGroup`，处理options选项是很有必要的，
让我们看看我们自己如何模仿这种行为。

## 入门指南
尽管`isExpanded`并没有出现在所有初始化方法中，但是`Binding<Bool>`是View视图工作所必需的.
让我们创建一个需要这种绑定的视图:
```
struct MyDisclosureGroup<Label, Content>: View where Label: View, Content: View {
  @Binding var isExpanded: Bool
  var content: () -> Content
  var label: () -> Label

  @ViewBuilder
  var body: some View {
    Button(action: { isExpanded.toggle() }, label: label)
    if isExpanded {
      content()
    }
  }
}

```
我们现在用`MyDisclosureGroup`替换代码中的`DisclosureGroup`,所有的工作方式都是一样的:
```
MyDisclosureGroup(isExpanded: $showingContent) {
   Text("Content")
} label: {
   Text("Tap to show content")
}

```

![tap2.gif](./tap2.gif)

> 本文的目的是复制`DisclosureGroup`的API和行为，而不是它的UI。

## 制作可选Binding State
对于`MyDisclosureGroup`,它没有方法，所以他需要一个`Binding<Bool>`状态。
然而这个绑定来自哪里并不重要，例如，我们可以将`MyDisclosureGroup`包装到一个容器中:
作为一个公共接口，声明一个`State<Bool>`.

该容器将一个绑定状态的属性传递给`MyDisclosureGroup`,否则它将使用自己的状态:
```
struct MyDisclosureGroupContainer<Label, Content>: View where Label: View, Content: View {
  @State private var privateIsExpanded: Bool = false
  var isExpanded: Binding<Bool>?
  var content: () -> Content
  var label: () -> Label

  var body: some View {
    MyDisclosureGroup(
      isExpanded: isExpanded ?? $privateIsExpanded,
      content: content,
      label: label
    )
  }
}

```

我们能通过绑定和不绑定两种方式初始化`MyDisclosureGroupContainer`.结果将是一样的:
```
// no binding
MyDisclosureGroupContainer {
  Text("Content")
} label: {
  Text("Tap to show content")
}

// with binding
MyDisclosureGroupContainer(isExpanded: $showingContent) {
  Text("Content")
} label: {
  Text("Tap to show content")
}

```

![tap2.gif](./tap2.gif)

## API进一步优化
多亏了`MyDisclosureGroupContainer`，我们现在有了一种方法来处理传递和不传递`@Binding`的两种情况，但是这个View目前只提供了默认的初始化器:
```
init(isExpanded: Binding<Bool>? = nil, content: @escaping () -> Content, label: @escaping () -> Label)

```
有一个可选的`isExpanded`参数类型`Binding<Bool>?`是比较困惑的：`init(isExpanded: nil, ...)`做了什么？

如果我们不知道实现的细节，这肯能会被喷的！

因此，让我们重新构建两个新的初始化方法：
* 一个需要绑定属性的
* 一个不需要绑定属性

```
struct MyDisclosureGroupContainer<Label, Content>: View where Label: View, Content: View {
  @State private var myIsExpanded: Bool = false
  private var isExpanded: Binding<Bool>?
  var content: () -> Content
  var label: () -> Label

  init(isExpanded: Binding<Bool>, content: @escaping () -> Content, label: @escaping () -> Label) {
    self.init(isExpanded: .some(isExpanded), content: content, label: label)
  }

  init(content: @escaping () -> Content, label: @escaping () -> Label) {
    self.init(isExpanded: nil, content: content, label: label)
  }

  // private!
  private init(isExpanded: Binding<Bool>?, content: @escaping () -> Content, label: @escaping () -> Label) {
    self.isExpanded = isExpanded
    self.content = content
    self.label = label
  }

  var body: some View {
    MyDisclosureGroup(
      isExpanded: isExpanded ?? $myIsExpanded,
      content: content,
      label: label
    )
  }
}

```
有了这些，我们的容器现在公开了两个易于理解的初始化器:
```
// with binding
init(isExpanded: Binding<Bool>, content: @escaping () -> Content, label: @escaping () -> Label)
// without binding
init(content: @escaping () -> Content, label: @escaping () -> Label)

```
这样就好多了，使用这些API的开发人员可以立即理解他们在做什么，而不用担心组件里做了什么。

## 容器
让我们回顾一下到目前为止我们所做的：
* 我们构建了一个视图`MyDisclosureGroup`,实现UI需要一个`binding`绑定操作
* 我们构建一个`MyDisclosureGroup`的容器`MyDisclosureGroupContainer`,让开发者使用`MyDisclosureGroup`的时候，可以传入一个`@Binding`，也可以不传。

需要注意的是，开发人员其实并不需要知道组件View是如何工作的:`MyDisclosureGroupContainer`只需要使用即可。
Swift API设计准则的首要原则就是使用清晰：我们只需要提供简单的API, 而把复杂的实现进行抽取封装。

记住这一点，我们可以改进我们的代码：
```
struct MyDisclosureGroup<Label, Content>: View where Label: View, Content: View {
  @State private var myIsExpanded: Bool = false
  private var isExpanded: Binding<Bool>?
  var content: () -> Content
  var label: () -> Label

  public init(isExpanded: Binding<Bool>, content: @escaping () -> Content, label: @escaping () -> Label) {
    self.init(isExpanded: .some(isExpanded), content: content, label: label)
  }

  public init(content: @escaping () -> Content, label: @escaping () -> Label) {
    self.init(isExpanded: nil, content: content, label: label)
  }

  private init(isExpanded: Binding<Bool>?, content: @escaping () -> Content, label: @escaping () -> Label) {
    self.isExpanded = isExpanded
    self.content = content
    self.label = label
  }

  private struct OriginalDisclosureGroup<Label, Content>: View where Label: View, Content: View {
    @Binding var isExpanded: Bool
    var content: () -> Content
    var label: () -> Label

    @ViewBuilder
    var body: some View {
      Button(action: { isExpanded.toggle() }, label: label)
      if isExpanded {
        content()
      }
    }
  }

  var body: some View {
    OriginalDisclosureGroup(
      isExpanded: isExpanded ?? $myIsExpanded,
      content: content,
      label: label
    )
  }
}

```

这就是我们最终的代码实现!

## 结论
在工作中使用swift越多，就越能看到swift API的强大，同时还能使它们易于使用，甚至看起来很简单。这是Swift和SwiftUI最好的方面之一，我们也应该在自己的代码中努力做到这一点。
当然，我们不知道`DisclosureGroup`的实际实现，但只要找到一种模仿它的方法，我们就能真正欣赏Swift和SwiftUI团队为简化我们所做的巨大工作。






