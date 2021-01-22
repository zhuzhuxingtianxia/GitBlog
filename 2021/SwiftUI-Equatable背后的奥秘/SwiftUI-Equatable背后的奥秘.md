# SwiftUI:Equatable背后的奥秘

在写这篇文章的时候，如果你在谷歌上寻找“EquatableView”，你可能没太大收获。所以我决定自己研究一下。

在这篇的文章中，我们将探讨View equality的几个方面。我们将看到当我们使一个视图符合`Equatable`时会发生什么，以及`EquatableView`和修饰符`.equatable()`的目的是什么。就让我们一探究竟吧。

## 视图Body的计算能力

你可能已经注意到，SwiftUI在确定何时需要计算视图主体方面做得很好。它主要监视视图属性的任何更改。如果检测到更改，则计算一个新的body。

在某些情况下，视图状态可能会改变，但主体不一定需要重新计算。幸运的是，有一种方法可以防止不必要的body体计算。

假设您有一个接收整数作为参数的视图。如果数字是奇数，则显示文本“ODD”，如果数字是偶数，则显示文本“EVEN”。很简单,对吧?为了增加趣味，我们将添加一个漂亮的连续旋转：
```
extension Int {
    var isEven: Bool { return self % 2 == 0 }
    var isOdd: Bool { return self % 2 != 0 }
}

struct ContentView: View {
    @State private var n = 3
    
    var body: some View {
        VStack {
            NumberParity(number: n)
            
            Button("New Random Number") {
                self.n = Int.random(in: 1...1000)
            }.padding(.top, 80)
            
            Text("\(n)")
        }
    }
}

struct NumberParity: View {
    let number: Int
    @State private var flag = false
    
    var body: some View {
        let animation = Animation.linear(duration: 3.0).repeatForever(autoreverses: false)
        
        return VStack {
            if number.isOdd {
                Text("ODD")
            } else {
                Text("EVEN")
            }
        }
        .foregroundColor(.white)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10).fill(self.number.isOdd ? Color.red : Color.green))
        .rotationEffect(self.flag ? Angle(degrees: 0) : Angle(degrees: 360))
        .onAppear { withAnimation(animation) { self.flag.toggle() } }
    }
}
```

这个例子运行得很好。每次按下按钮，都会生成一个新的随机数，视图会适当地反映该数字的奇偶性。我想你已经知道我要去哪里了。如果新数字与前一个数字具有相同的奇偶性，那么如果我们可以防止它的body计算，那不是很好吗?毕竟，这并不影响结果。这就是让我们的视图遵守`Equatable`协议的原因。

## 使用Equatable

```
struct NumberParity: View, Equatable {
    
    let number: Int
    @State private var flag = false
    
    var body: some View {
        let animation = Animation.linear(duration: 3.0).repeatForever(autoreverses: false)

        print("Body computed for number = \(number)")
        
        return VStack {
            if number.isOdd {
                Text("ODD")
            } else {
                Text("EVEN")
            }
        }
        .foregroundColor(.white)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10).fill(self.number.isOdd ? Color.red : Color.green))
        .rotationEffect(self.flag ? Angle(degrees: 0) : Angle(degrees: 360))
        .onAppear { withAnimation(animation) { self.flag.toggle() } }
    }
    
    static func == (lhs: NumberParity, rhs: NumberParity) -> Bool {
        return lhs.number.isOdd == rhs.number.isOdd
    }
}
```
我们将`Equatable`协议名添加到第一行，并实现`static func == (lhs, rhs)`方法。为了确保只在奇偶性发生变化时才计算body体，我们还添加了一个“print”打印语句。

在那里，我们优化了视图，只在严格必要时才计算它的body体。现在SwiftUI将能够确定何时需要进行body计算。

现在我看到了结果，我真的不喜欢那种旋转，咱们把它丢掉吧：
```
struct NumberParity: View, Equatable {
    
    let number: Int
    
    var body: some View {
        print("Body computed for number = \(number)")
        
        return VStack {
            if number.isOdd {
                Text("ODD")
            } else {
                Text("EVEN")
            }
        }
        .foregroundColor(.white)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10).fill(self.number.isOdd ? Color.red : Color.green))
    }
    
    static func == (lhs: NumberParity, rhs: NumberParity) -> Bool {
        return lhs.number.isOdd == rhs.number.isOdd
    }
}
```
如果我们运行修改后的版本，您会注意到现在视图每次都会触发计算!即使数字奇偶性不变。`==`方法永远不会被调用!为什么呢?好的，我们稍后会解决这个问题……但在所有情况下，改变行为的是视图中属性的类型。

你看，那个动画是别有用心的。我把它放在那里只是为了让它触发`==`函数。然而，一旦我删除了动画(和它的状态变量)，我们就会发现是有问题的。那么我们能做什么呢?

不管没有触发我们的`==`方法的原因是什么，解决方案总是有的： `EquatableView`和`.equatable()`。

## 使用EquatableView

事实证明，强制SwiftUI使用我们的`==`函数实现来比较视图非常简单，只需替换即可:
```
NumberParity(number: n)
```
为这个：
```
EquatableView(content: NumberParity(number: n))
```
再次运行该示例，您将注意到现在正确地调用了我们的`==`方法，并且只在严格必要时才计算body。

## 使用.equatable()

如果我们看一下修饰符`.equatable()`的定义，就会发现这是直接使用`EquatableView`的一个很好的捷径:
```
extension View {
    public func equatable() -> EquatableView<Self> {
        return EquatableView(content: self)
    }
}
```
下面两行具有相同的效果，但是第二个选项更容易阅读，而且简短：
```
EquatableView(content: NumberParity(number: n))
```
```
NumberParity(number: n).equatable()
```

当然，使用`EquatableView`(或`equatable()`)需要满足Equatable协议!

## 那么我什么时候需要EquatableView呢?

我们现在知道，根据视图拥有的属性类型，我们可能需要使用`EquatableView`，否则，我们的`==`方法将被忽略。但我们怎么知道什么时候需要这样做呢?

为了安全起见，我想说答案是:永远。这是唯一能确保无论发生什么事，我们都能被保护的办法。如果苹果后来决定改变策略，确保我们得到一致结果的唯一方法，是确保我们在视图中使用`.equatable()`。此外，它使代码的意图更加清晰，这在其他人(或未来的您)以后回来维护它时尤其重要。

然而，如果你想知道SwiftUI目前是如何判断是否使用了==的策略，它对每个字段进行比较时，相同的规则递归地应用到每个字段(选择直接比较或如果定义了==)。

## 总结

这篇文章旨在解释SwiftUI框架中另一个未被记录的部分。当您的视图开始变得太复杂时，您的应用程序可以从实践中获益。

