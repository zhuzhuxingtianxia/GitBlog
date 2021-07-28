# SwiftUI：Introspect

在开发应用时，SwiftUI提高了开发效率。
SwiftUI大概可以满足任何现代应用程序需求的95%，而剩下的5%则是通过退回到以前的UI框架。
我们有两种主要的回退方法:

* SwiftUI的 `UIViewRepresentable`/`NSViewRepresentable`
* SwiftUI Introspect

## 什么是SwiftUI Introspect
SwiftUI Introspect是一个开源库。它的主要目的是获取和修改任何SwiftUI视图的底层UIKit或AppKit元素。

这是可能的，因为许多SwiftUI视图(仍然)依赖于它们的UIKit，例如:

* 在macOS中，`Button`在幕后使用`NSButton`
* 在iOS中，`TabView`在幕后使用`UITabBarController`

我们很少需要知道这样的实现细节。然而，知道这一点给了我们另一个强大的工具，我们可以在需要的时候使用。这正是SwiftUI `Introspect`发挥作用的地方。


## SwiftUI Introspect的使用
SwiftUI Introspect在`func introspectX(customize: @escaping (Y) -> ()) -> some View`模式之后提供了一系列视图修饰符，其中:

* `X`是我们的目标视图
* `Y`是底层的UIKit/AppKit视图/视图控制器类型

假设我们想要从`ScrollView`中移除弹性效果。目前，SwiftUI没有相应的API或修饰符允许我们这样做。
`ScrollView`在底层使用UIKit的`UIScrollView`。我们能使用Introspect的`func introspectScrollView(customize: @escaping (UIScrollView) -> ()) -> some View`方法获取底层的`UIScrollView`，并禁用弹性效果:
```
import Introspect
import SwiftUI

struct ContentView: View {
  var body: some View {
    ScrollView {
      VStack {
        Color.red.frame(height: 300)
        Color.green.frame(height: 300)
        Color.blue.frame(height: 300)
      }
      .introspectScrollView { $0.bounces = false }
    }
  }
}
import Introspect
import SwiftUI

struct ContentView: View {
  var body: some View {
    ScrollView {
      VStack {
        Color.red.frame(height: 300)
        Color.green.frame(height: 300)
        Color.blue.frame(height: 300)
      }
      .introspectScrollView { $0.bounces = false }
    }
  }
}
```

![scroll](./scroll.gif)

在iOS系统中，用户可以通过向下滑动表单来关闭表单。在UIKit中，我们可以通过`isModalInPresentation` `UIViewController`属性阻止这种行为，让我们的应用程序逻辑控制表单的显示。在SwiftUI中，我们还没有类似的方法。

同样，我们可以使用Introspect来抓取呈现表`UIViewController`，并设置`isModalInPresentation`属性:
```
import Introspect
import SwiftUI

struct ContentView: View {
  @State var showingSheet = false

  var body: some View {
    Button("Show sheet") { showingSheet.toggle() }
      .sheet(isPresented: $showingSheet) {
        Button("Dismiss sheet") { showingSheet.toggle() }
          .introspectViewController { $0.isModalInPresentation = true }
      }
  }
}
```

![sheet](./sheet.gif)

其他的例子:

* 列表`List`添加[下拉刷新]()
* `TextField`添加[toolbars]()

想象一下，由于SwiftUI的一个小功能缺失，我们不得不在UIKit/AppKit中重新实现一个完整的复杂功能:Introspect是一个不可思议的时间节省器。

我们已经看到了它的明显好处:接下来，让我们揭开SwiftUI Introspect是如何工作的。

## SwiftUI Introspect如何工作的
我们将采用UIKit路径:除了UI/NS前缀，AppKit的代码是相同的。

为了清晰起见，本文中所示的代码进行了轻微的调整。最初的实现可以在SwiftUI Introspect的[存储库](https://github.com/siteline/SwiftUI-Introspect)中找到。

### injection注入
正如上面的例子所示，Introspect为我们提供了各种视图修饰符。如果我们看看它们的实现，它们都遵循类似的模式。这里有一个例子:
```
extension View {
  /// Finds a `UITextView` from a `TextEditor`
  public func introspectTextView(
    customize: @escaping (UITextView) -> ()
  ) -> some View {
    introspect(
      selector: TargetViewSelector.siblingContaining, 
      customize: customize
    )
  }
}
```
所有这些公共`introspectX(customize:)`视图修饰符都是一个更通用的`introspect(selector:customize:)`的方便实现:
```
extension View {   
  /// Finds a `TargetView` from a `SwiftUI.View`
  public func introspect<TargetView: UIView>(
    selector: @escaping (IntrospectionUIView) -> TargetView?,
    customize: @escaping (TargetView) -> ()
  ) -> some View {
    inject(
      UIKitIntrospectionView(
        selector: selector,
        customize: customize
      )
    )
  }
}
```

这里我们看到另一个介绍`inject(_:)``View`试图修饰符，和第一个`Introspect`试图，`UIKitIntrospectionView`:
```
extension View {
  public func inject<SomeView: View>(_ view: SomeView) -> some View {
    overlay(view.frame(width: 0, height: 0))
  }
}
```
`inject(_:)`采用我们的原始视图，并在顶部添加一个给定视图的覆盖层，其框架最小化。

例如，如果我们有以下视图:
```
TextView(...)
  .introspectTextView { ... }
```

最后的视图将是:
```
TextView(...)
  .overlay(UIKitIntrospectionView(...).frame(width: 0, height: 0))
```

接下来让我们看看`UIKitIntrospectionView`:

```
public struct UIKitIntrospectionView<TargetViewType: UIView>: UIViewRepresentable {
  let selector: (IntrospectionUIView) -> TargetViewType?
  let customize: (TargetViewType) -> Void

  public func makeUIView(
    context: UIViewRepresentableContext<UIKitIntrospectionView>
  ) -> IntrospectionUIView {
    let view = IntrospectionUIView()
    view.accessibilityLabel = "IntrospectionUIView<\(TargetViewType.self)>"
    return view
  }

  public func updateUIView(
    _ uiView: IntrospectionUIView,
    context: UIViewRepresentableContext<UIKitIntrospectionView>
  ) {
    DispatchQueue.main.async {
      guard let targetView = self.selector(uiView) else { return }
      self.customize(targetView)
    }
  }
}
```

`UIKitIntrospectionView`是`Introspect`到UIKit的桥梁，它做两件事:

* 在`UIView`层次结构中注入一个`IntrospectionUIView`
* 对`UIViewRepresentable`具象的`updateUIView`生命周期事件做出反应

这是`IntrospectionUIView`的定义:
```
public class IntrospectionUIView: UIView {
  required init() {
    super.init(frame: .zero)
    isHidden = true
    isUserInteractionEnabled = false
  }
}
```
`IntrospectionUIView`是一个最小的、隐藏的、非交互的`UIView`:它的全部目的是给SwiftUI Introspect一个进入UIKit层次结构的入口点。

总之，所有的`.introspectX(customize:)`视图修改器覆盖了一个微小的，不可见的，非交互的视图在我们的原始视图之上，确保它不会影响我们最终的UI。


### The crawling


