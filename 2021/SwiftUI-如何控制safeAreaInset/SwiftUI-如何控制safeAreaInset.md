# SwiftUI:如何控制safeAreaInset

WWDC21已经结束，`safeAreaInset()`是一个全新的SwiftUI视图修饰符，它允许我们定义成为观察安全区的一部分的视图。让我们深入研究这个新的、强大的特性。

## 滚动视图

最常见的`safeAreaInset`用例可能是滚动视图。以下面的屏幕为例，我们有一个带有一些内容的`ScrollView`和一个按钮:

![button](./button.png)

```
struct ContentView: View {
  var body: some View {
    ScrollView {
      ForEach(1..<30) { _ in
        Text("Five Stars")
          .font(.largeTitle)
      }
      .frame(maxWidth: .infinity)
    }
    .overlay(alignment: .bottom) {
      Button {
        ...
      } label: {
        Text("Continue")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
      .controlSize(.large)
      .controlProminence(.increased)
      .padding(.horizontal)
    }
  }
}
```
> 注意：`.buttonStyle(.bordered)` `.controlSize(.large)` `.controlProminence(.increased)`是iOS15的视图修饰符

因为按钮只是一个覆盖，滚动视图不受它的影响，当我们滚动底部时，这就成为一个问题:

![no](./no.gif)

`ScrollView`中的最后一个元素被遮挡在按钮下面!
现在我们把`.overlay(alignment: .bottom)`和`.safeAreaInset(edge: .bottom)`交换:
```
struct ContentView: View {
  var body: some View {
    ScrollView {
      ForEach(1..<30) { _ in
        Text("Five Stars")
          .font(.largeTitle)
      }
      .frame(maxWidth: .infinity)
    }
    .safeAreaInset(edge: .bottom) { // 👈🏻
      Button {
        ...
      } label: {
        Text("Continue")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
      .controlSize(.large)
      .controlProminence(.increased)
      .padding(.horizontal)
    }
  }
}
```

`ScrollView`观察通过`safeAreaInset`传递下来的新区域，最后的元素现在可见了:

![yes](./yes.gif)

接下来，让我们看看它是如何工作的。

## 定义
这个修饰符有两种变体，每个轴上有一个(水平/垂直):
```
/// Horizontal axis.
func safeAreaInset<V: View>(
  edge: HorizontalEdge,
  alignment: VerticalAlignment = .center,
  spacing: CGFloat? = nil,
  @ViewBuilder content: () -> V
) -> some View

/// Vertical axis.
func safeAreaInset<V: View>(
  edge: VerticalEdge, 
  alignment: HorizontalAlignment = .center, 
  spacing: CGFloat? = nil, 
  @ViewBuilder content: () -> V
) -> some View
```
它们有四个参数:

* `edge`-指定目标区域的边缘，垂直方向上`.top` 或 `.bottom`,水平方向`.leading`或`.trailing`
* `alignment` - 当`safeAreaInset`内容不适合可用空间时，我们指定如何对齐
* `spacing` - 在那里我们可以进一步移动安全区超出`safeAreaInset`内容的边界，默认情况下，这个参数有一个非零值，基于我们的目标平台约定
* `content`- 在这里定义`safeAreaInset`的内容

让我们在实践中使用它来理解这是怎么回事。

## 案例


