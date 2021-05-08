# SwiftUI: 有条件的视图修饰符view modifiers

当使用SwiftUI开发时，有时我们希望根据条件/状态应用不同的`modifiers`修饰符:
```
var body: some view {
  myView
    // if X
    // .padding(8)
    // if Y
    // .background(Color.blue)
}

```
在许多情况下,可以根据条件传递不同的修饰符参数，就像下面这个样子来解决问题：

```
var body: some view {
  myView
    .padding(X ? 8 : 0)
    .background(Y ? Color.blue : Color.clear)
}

```
虽然这个方法在这里有效，但还有其他修饰符，例如`.hidden()`，在这些地方这个解决方案将不起作用。
在本文中，我们将探讨如何处理这种情况。

## if view extension

最常见的解决方案是定义一个新的`if`的`View`扩展:
```
extension View {
  @ViewBuilder
  func `if`<Transform: View>(
    _ condition: Bool, 
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
```
当`condition`为`true`时，这个函数将应用`transform`到我们的视图,否则，它将保持原始视图不变。
回到我们的例子,使用这种方法：

```
var body: some view {
  myView
    .if(X) { $0.padding(8) }
    .if(Y) { $0.background(Color.blue) }
}

```

## If else view extension
根据我们想要声明的紧凑程度，根据`condition`条件`true`/`false`的值应用不同的修饰符会让我们至少花费两个修饰符:
```
var body: some view {
  myView
    .if(X) { $0.padding(8) }
    .if(!X) { $0.background(Color.blue) }
}
```
然而，如果我们真的想要使用`View extensions`视图扩展，我们可以定义一个新的`if`重载，让我们也可以修改`else`分支:
```
extension View {
  @ViewBuilder
  func `if`<TrueContent: View, FalseContent: View>(
    _ condition: Bool, 
    if ifTransform: (Self) -> TrueContent, 
    else elseTransform: (Self) -> FalseContent
  ) -> some View {
    if condition {
      ifTransform(self)
    } else {
      elseTransform(self)
    }
  }
}
```
这将使我们的例子使用一个单独的修饰符:
```
var body: some view {
  myView
    .if(X) { $0.padding(8) } else: { $0.background(Color.blue) }
}
```

## IfLet view extension
与条件类似，有时我们希望仅在另一个值不是`nil`时应用修饰符，类似于Swift `if let`的工作方式，并在修饰符本身中使用该值。

在这种情况下，我们可以定义一个新的视图扩展，让我们这样做：
```
extension View {
  @ViewBuilder
  func ifLet<V, Transform: View>(
    _ value: V?, 
    transform: (Self, V) -> Transform
  ) -> some View {
    if let value = value {
      transform(self, value)
    } else {
      self
    }
  }
}
```
这个新功能与以前不同的是:
* 接受一个可选的泛型值`V`，而不是`Bool`条件
* 将这个泛型值`V`作为转换函数的参数传递

这里有一个例子，当设置了`optionalColor`时，视图`View`应用前景色:
```
var body: some view {
  myView
    .ifLet(optionalColor) { $0.foregroundColor($1) }
}
```

## iOS可用性修饰符
现在，我们在SwiftUI上遇到了版本兼容性的问题，新版本引入了新的修改器，我们想发布一款与iOS13早期版本兼容的应用。
不幸的是，在这些情况下，我们不能使用刚才介绍的通用扩展：
* Swift的`#available` 和 `@available` 不能作为参数在`if`修饰符中传递
* 我们不能保证编译器`transform`函数只适用于iOS 14/13.4及以后版本

克服这个问题的一种方法是为每个用例定义一个不同的视图修饰符。
例如，这里有一个View视图扩展，可以忽略布局中的键盘:
```
extension View {
  @ViewBuilder
  func ignoreKeyboard() -> some View {
    if #available(iOS 14.0, *) {
      ignoresSafeArea(.keyboard)
    } else {
      self // iOS 13 always ignores the keyboard
    }
  }
}
```

如何在ios13和ios14中都有`InsetGroupedList`样式:
```
extension List {
  @ViewBuilder
  func insetGroupedListStyle() -> some View {
    if #available(iOS 14.0, *) {
      self
        .listStyle(InsetGroupedListStyle())
    } else {
      self
        .listStyle(GroupedListStyle())
        .environment(\.horizontalSizeClass, .regular)
    }
  }
}
```
使用如下：
```
var body: some view {
  myView
    .ignoreKeyboard()
}

// ...

var body: some view {
  myView
    .insetGroupedListStyle()
}
```
## 可用性属性
在未来的某个时候，我们的代码库将放弃对iOS13的支持，这样我们的扩展就没有必要了.

类似于`libraries/frameworks`如何定义API可用性,我们也可以在新的扩展中使用`@availability`属性:
```
@available(
  iOS, introduced: 13, deprecated: 14,
  message: "Use .ignoresSafeArea(.keyboard) directly"
) 
extension View {
  @ViewBuilder
  func ignoreKeyboard() -> some View {
    ...
  }
}

/// ...

@available(
  iOS, introduced: 13, deprecated: 14, 
  message: "Use .listStyle(InsetGroupedListStyle()) directly"
)
extension List {
  @ViewBuilder
  func insetGroupedListStyle() -> some View {
    ...
  }
}
```
添加这个`@available`属性会在所有使用这些函数的地方触发一个弃用警告.我们还可以添加一条可选消息，提醒我们在触发警告后应该做什么.

## 结论
SwiftUI声明式API让视图定义变得轻而易举,当我们的视图需要根据某些条件应用不同的修饰符时,我们可以定义我们自己的条件视图修饰符，让我们保持我们习惯的声明性。


