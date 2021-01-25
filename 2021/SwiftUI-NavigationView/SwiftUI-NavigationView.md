# SwiftUI:NavigationView

<!--- https://www.hackingwithswift.com/articles/216/complete-guide-to-navigationview-in-swiftui --->

`NavigationView`是SwiftUI应用的一个重要组件，它允许我们轻松地`push`和`pop`屏幕，以清晰、分层的方式向用户呈现信息。在本文中，我想演示在应用程序中使用`NavigationView`的所有方法，包括设置标题和添加按钮等简单的事情，但也包括编程导航、创建分割视图，甚至处理其他苹果平台，如macOS和watchOS。

## 有标题的基础NavigationView

要开始使用NavigationView，你应该把你想要显示的内容包裹在里面，像这样:
```
struct ContentView: View {
    var body: some View {
        NavigationView {
            Text("Hello, World!")
        }
    }
}
```

对于简单的导航布局应该在我们视图的顶层，但如果你在`TabView`中使用它们那么导航视图应该在标签视图中。
在学习SwiftUI时，有一件事让人感到困惑，那就是我们如何给导航视图添加标题:
```
NavigationView {
    Text("Hello, World!")
        .navigationBarTitle("Navigation")
}
```
你可能注意到，为何`navigationBarTitle()`修饰符附属到text的视图上，而不是导航视图？这是有意为之的，并且是在这里添加标题的正确方法。

您可以看到，导航视图让我们通过从右边缘滑动内容来显示新屏幕。每个屏幕都可以有自己的标题，而SwiftUI的工作就是确保标题一直显示在导航视图中——你会看到旧的标题会动画消失，而新的标题出现了。

现在想想这个，如果我们把标题直接附加到导航视图，这被说是"这是固定的标题"。通过将标题附加到导航视图内的内容，SwiftUI可以随着内容的改变而改变标题。

*提示*:你可以在导航视图中的任何视图上使用`navigationBarTitle()`,它不需要是最外层的。

通过添加`displayMode`参数，可以自定义标题的显示方式。有三种选项：

1. `.large`选项显示大标题，这对于导航堆栈的顶级视图很有用。
2. `.inline`选项显示小标题，这对于导航堆栈中的次要或后续视图很有用。
3. `.automatic`选项是默认选项，并使用前一个视图使用的任何内容。

对于大多数应用程序，你应该依赖`.automatic`选项来创建你的初始视图，你可以完全跳过`displayMode`参数:
```
.navigationBarTitle("Navigation")
```

对于所有被推到导航堆栈上的视图，你通常会使用`.inline`选项，像这样:
```
.navigationBarTitle("Navigation", displayMode: .inline)
```

## 跳转新的视图

导航视图使用`NavigationLink`显示新的屏幕，用户可以通过点击它们的内容或通过编程启用它们来触发导航视图。

`NavigationLink`功能之一是你可以push到任何视图——可以是你选择的自定义视图，也可以是SwiftUI的原始视图之一(如果你只是在创建原型的话)。
例如，它直接push到一个文本视图:
```
NavigationView {
    NavigationLink(destination: Text("Second View")) {
        Text("Hello, World!")
    }
    .navigationBarTitle("Navigation")
}
```
因为我在我的导航链接中使用了文本视图，SwiftUI会自动将文本设置为蓝色，以向用户表明它是交互式的。这是一个非常有用的功能，但它也会带来一个无用的副作用:如果你在导航链接中使用一个image图像，你可能会发现image图像变成蓝色!

要尝试一下，可以在项目的asset目录中添加两张图片——一张是照片，另一张是带有一些透明度的形状。我添加我的头像和Swift的logo，并像这样使用它们:
```
NavigationLink(destination: Text("Second View")) {
    Image("hws")
}
.navigationBarTitle("Navigation")
```
我添加的图像是红色的，但当我运行应用程序时，SwiftUI将把它涂成蓝色——这是为了帮助用户，显示图像是交互式的。然而，这张图片是不透明的，SwiftUI让透明部分保持原样，这样你仍然可以清楚地看到logo。

如果我用我的照片代替，结果会更糟:
```
NavigationLink(destination: Text("Second View")) {
    Image("Paul")
}
.navigationBarTitle("Navigation")
```
由于这是一张没有任何透明度的照片，所以SwiftUI把整个物体涂成了蓝色——现在它看起来就像一个蓝色的正方形。
如果你想让SwiftUI使用你的图像的原始颜色，你应该附加一个`renderingMode()`修饰符，像这样:
```
NavigationLink(destination: Text("Second View")) {
    Image("hws")
        .renderingMode(.original)
}
.navigationBarTitle("Navigation")
```
记住，这将禁用蓝色调，这意味着图像将不再具有交互性。

## 视图之间传递数据
当您使用`NavigationLink`将一个新视图推入导航堆栈时，您可以传递新视图工作所需的任何参数。

例如，如果我们抛硬币，并希望用户选择正面或反面，我们可能会有这样的结果视图:
```
struct ResultView: View {
    var choice: String

    var body: some View {
        Text("You chose \(choice)")
    }
}
```
然后在内容视图中，我们可以显示两个不同的导航链接:一个以“Heads”作为选择创建`ResultView`，另一个以“Tails”为选择。这些值必须在创建结果视图时传入，如下所示:
```
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("You're going to flip a coin – do you want to choose heads or tails?")

                NavigationLink(destination: ResultView(choice: "Heads")) {
                    Text("Choose Heads")
                }

                NavigationLink(destination: ResultView(choice: "Tails")) {
                    Text("Choose Tails")
                }
            }
            .navigationBarTitle("Navigation")
        }
    }
}
```
SwiftUI总是会确保你提供正确的值来初始化你的详细视图。

## 程序化的导航
SwiftUI的`NavigationLink`有第二个初始化方法，它有一个`isActive`参数，允许我们读取或写入当前导航链接是否处于活动状态。实际上，这意味着我们可以通过编程方式触发导航链接的激活，方法是将它所监视的状态设置为true。

例如，这会创建一个空的导航链接，并将其绑定到`isShowingDetailView`属性:
```
struct ContentView: View {
    @State private var isShowingDetailView = false

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Text("Second View"), isActive: $isShowingDetailView) { EmptyView() }
                Button("Tap to show detail") {
                    self.isShowingDetailView = true
                }
            }
            .navigationBarTitle("Navigation")
        }
    }
}
```
注意导航链接下面的按钮是如何在被触发时将`isShowingDetailView`设置为true的——这是导航操作发生的原因，而不是用户与导航链接本身内的任何东西进行交互。

显然，使用多个布尔值来跟踪不同的导航目的地是很困难的，所以SwiftUI提供了另一种选择:我们可以为每个导航链接添加一个标记，然后使用单个属性控制哪个链接被触发。
作为一个例子，这将显示两个细节视图中的一个，这取决于哪个按钮被按下:
```
struct ContentView: View {
    @State private var selection: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: Text("Second View"), tag: "Second", selection: $selection) { EmptyView() }
                NavigationLink(destination: Text("Third View"), tag: "Third", selection: $selection) { EmptyView() }
                Button("Tap to show second") {
                    self.selection = "Second"
                }
                Button("Tap to show third") {
                    self.selection = "Third"
                }
            }
            .navigationBarTitle("Navigation")
        }
    }
}
```
值得一提的是，你可以使用state属性来dismiss视图和present视图。例如，我们可以编写代码来创建一个显示detail屏幕的可点击导航链接，但也可以在两秒钟后将`isShowingDetailView`设为false。实际上，这意味着你可以启动应用程序，手动点击链接来显示第二个视图，然后短暂暂停后，你会自动回到上一个屏幕。

例如：
```
struct ContentView: View {
    @State private var isShowingDetailView = false

    var body: some View {
        NavigationView {
            NavigationLink(destination: Text("Second View"), isActive: $isShowingDetailView) {
                Text("Show Detail")
            }
            .navigationBarTitle("Navigation")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isShowingDetailView = false
            }
        }
    }
}
```

## 使用environment传值
`NavigationView`自动与它所呈现的任何子视图共享它的环境，这使得即使在很深的导航堆栈中也很容易共享数据。关键是要确保使用附加到导航视图本身的`environmentObject()`修饰符，而不是导航视图内部的东西。

为了演示这一点，我们可以首先定义一个简单的观察对象，它将承载我们的数据:
```
class User: ObservableObject {
    @Published var score = 0
}
```

然后我们可以创建一个细节视图来显示使用环境对象的数据，同时也提供了一种增加分数的方法:
```
struct ChangeView: View {
    @EnvironmentObject var user: User

    var body: some View {
        VStack {
            Text("Score: \(user.score)")
            Button("Increase") {
                self.user.score += 1
            }
        }
    }
}
```
最后，我们可以让我们的`ContentView`创建一个新的`User`实例，它被注入到导航视图环境中，这样它就可以在任何地方共享了:
```
struct ContentView: View {
    @StateObject var user = User()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Score: \(user.score)")
                NavigationLink(destination: ChangeView()) {
                    Text("Show Detail View")
                }
            }
            .navigationBarTitle("Navigation")
        }
        .environmentObject(user)
    }
}
```
记住，`environment`对象将被导航视图所呈现的所有视图所共享，这意味着如果`ChangeView`显示了它自己的详情视图，它也将会被注入`environment`。

*提示:*在生产应用程序中，您应该注意为视图本地创建引用类型，并且应该为它们创建一个单独的模型层。

## 添加导航栏按钮

我们可以在导航视图中同时添加leading按钮和trailing按钮，在任意一侧或两侧使用一个或多个按钮。如果你愿意，这些可以是标准的按钮视图，但是你也可以使用导航链接。

例如，这创建了一个trailing导航栏按钮，当点击时可以修改分数值:
```
struct ContentView: View {
    @State private var score = 0

    var body: some View {
        NavigationView {
            Text("Score: \(score)")
                .navigationBarTitle("Navigation")
                .navigationBarItems(
                    trailing:
                        Button("Add 1") {
                            self.score += 1
                        }
                )
        }
    }
}
```

如果你想在左边和右边都有一个按钮，只需要传递`leading`和`trailing`参数，像这样:
```
Text("Score: \(score)")
    .navigationBarTitle("Navigation")
    .navigationBarItems(
        leading:
            Button("Subtract 1") {
                self.score -= 1
            },
        trailing:
            Button("Add 1") {
                self.score += 1
            }
    )
```

如果你想把两个按钮放在导航栏的同一侧，你应该把它们放在`HStack`中，像这样:
```
Text("Score: \(score)")
    .navigationBarTitle("Navigation")
    .navigationBarItems(
        trailing:
            HStack {
                Button("Subtract 1") {
                    self.score -= 1
                }
                Button("Add 1") {
                    self.score += 1
                }
            }
    )
```
*提示:*添加到导航栏的按钮有一个非常小的可点击区域，所以在它们周围添加一些内边距是一个好主意，使它们更容易点击。

## 自定义导航栏
我们有很多方法可以自定义导航条，比如控制它的字体font、颜色color或可见性visibility。然而，现在SwiftUI内部对这一功能的支持有点不足，事实上只有两个修饰符你可以不添加到UIKit中:

* `navigationBarHidden()`修饰符让我们可以控制整个栏是可见还是隐藏。
* `navigationBarBackButtonHidden()`修饰符让我们可以控制返回按钮是隐藏还是可见，这对于你想让用户在返回之前主动做出选择很有帮助。

与`navigationBarTitle()`类似，这两个修饰符都附加在导航视图内部的视图上，而不是导航视图本身。有些令人困惑的是，这与需要放在导航视图上的`statusBar(hidden:)`修饰符不同。

为了演示这一点，这里有一些代码，当一个按钮被点击时，显示和隐藏导航栏和状态栏:
```
struct ContentView: View {
    @State private var fullScreen = false

    var body: some View {
        NavigationView {
            Button("Toggle Full Screen") {
                self.fullScreen.toggle()
            }
            .navigationBarTitle("Full Screen")
            .navigationBarHidden(fullScreen)
        }
        .statusBar(hidden: fullScreen)
    }
}
```
当需要自定义工具条本身时——它的颜色、字体等等——我们需要下拉到UIKit。这并不难，特别是如果你以前使用过UIKit，但在SwiftUI之后，这对系统有点冲击。

自定义导航栏意味着需要在AppDelegate.swift中的`didFinishLaunchingWithOptions`方法中添加一些代码。例如创建一个新的`UINavigationBarAppearance`实例，为它配置自定义的背景色、前景色和字体，然后将其分配给导航栏的appearance proxy:
```
let appearance = UINavigationBarAppearance()
appearance.configureWithOpaqueBackground()
appearance.backgroundColor = .red

let attrs: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .font: UIFont.monospacedSystemFont(ofSize: 36, weight: .black)
]

appearance.largeTitleTextAttributes = attrs

UINavigationBar.appearance().scrollEdgeAppearance = appearance
```
我不会说这在SwiftUI的世界里很好，但事实就是这样。

## 使用NavigationViewStyle创建拆分视图

`NavigationView`最有趣的行为之一是它在更大的设备上处理拆分视图的方式——通常是大尺寸的iPhones和iPads。

默认情况下，这种行为有点令人困惑，因为它可能会导致看似空白的屏幕。例如，在导航视图中显示一个单字标签:
```
struct ContentView: View {
    var body: some View {
        NavigationView {
            Text("Primary")
        }
    }
}
```
这在竖屏时看起来很棒，但如果你用iPhone11 Pro Max旋转到横屏，你会看到文本视图消失。
SwiftUI会自动考虑横向导航视图来形成一个主细节拆分视图，两个屏幕可以并排显示。同样，只有在有足够空间的情况下，这种情况才会发生在较大的iPhones和iPads上，但它仍然经常会让人感到困惑。

首先，你可以按照SwiftUI所期望的方式解决这个问题，在你的`NavigationView`中提供两个视图，像这样:
```
struct ContentView: View {
    var body: some View {
        NavigationView {
            Text("Primary")
            Text("Secondary")
        }
    }
}
```
当它在大型iPhone上横屏运行时，你会看到“Secondary”占据了所有屏幕，导航栏按钮在滑动时显示主视图。
在iPad上，大多数时候你会同时看到两个视图，但如果空间受到限制，你会得到与竖屏iPhones上相同的push/pop行为。
当使用像这样的两个视图时，主视图中的任何`NavigationLink`都会自动显示它的目的地，而不是辅助视图。

另一种解决方案是要求SwiftUI每次只显示一个视图，而不管使用的是什么设备或方向。这是通过将一个新的`StackNavigationViewStyle()`实例传递给`navigationViewStyle()`修饰符来实现的，像这样:
```
NavigationView {
    Text("Primary")
    Text("Secondary")
}
.navigationViewStyle(StackNavigationViewStyle())
```
这个解决方案在iPhone上运行得很好，但在iPad上会触发全屏push导航，这会让你的眼睛不舒服。

## 工作在macOS和watchOS
尽管SwiftUI是一个跨平台的框架，但它让你可以在任何地方应用你的技能，而不是在所有平台上复制粘贴相同的代码。区别很微妙，但对于`NavigationView`来说很重要:

* 在macOS上，`navigationBarTitle()`修饰符不存在。
* 在watchOS上`NavigationView`本身并不存在。

这两种方法都会阻止您共享代码，因为您的代码无法编译。然而，我们可以用一些小技巧轻松地绕过它们。

例如，在watchOS上，我们可以添加自己的空`NavigationView`，简单地将其内容包装在一个平凡的`VStack`中:
```
#if os(watchOS)
struct NavigationView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
    }
}
#endif
```
使用`#if os(watchOS)`限制了它的可见性，以便其他平台按照预期工作，而仅仅添加一个简单的`VStack`不会让你的UI复杂化，所以它做起来很容易。

对于macOS，我们可以创建自己的`navigationBarTitle()`修饰符，它什么也不做，就像这样:
```
#if os(macOS)
extension View {
    func navigationBarTitle(_ title: String) -> some View {
        self
    }
}
#endif
```
同样，这对我们的UI工作增加的很少，而且Swift编译器甚至可以完全优化它。

这些改变看似微不足道，但却能帮助我们在使用SwiftUI创建跨平台应用时避免不必要的麻烦。




