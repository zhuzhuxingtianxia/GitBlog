# SwiftUI：四种方式自定义TextField

## TextFieldStyle
在考虑自定义之前，我们应该考虑SwiftUI提供什么。`TextField`有自己的风格，给我们提供了一些选项:

* `DefaultTextFieldStyle`
* `DefaultTextFieldStyle`
* `RoundedBorderTextFieldStyle`

![defaultstyles](./defaultstyles.png)

```
VStack {
  Section(header: Text("DefaultTextFieldStyle").font(.headline)) {
    TextField("Placeholder", text: .constant(""))
    TextField("Placeholder", text: $text)
  }
  .textFieldStyle(DefaultTextFieldStyle())

  Section(header: Text("PlainTextFieldStyle").font(.headline)) {
    TextField("Placeholder", text: .constant(""))
    TextField("Placeholder", text: $text)
  }
  .textFieldStyle(PlainTextFieldStyle())

  Section(header: Text("RoundedBorderTextFieldStyle").font(.headline)) {
    TextField("Placeholder", text: .constant(""))
    TextField("Placeholder", text: $text)
  }
  .textFieldStyle(RoundedBorderTextFieldStyle())
}
```
`DefaultTextFieldStyle`是`TextField`的默认样式，在iOS中，这匹配了`PlainTextFieldStyle`。

`PlainTextFieldStyle`和`RoundedBorderTextFieldStyle`区别似乎只是一个圆角和边框,然而一个`RoundedBorderTextFieldStyle`的`TextField`还带有一个白色/黑色背景(取决于环境外观),而`TextField` `PlainTextFieldStyle`是透明的:

![defaultstylesBackground](./defaultstylesBackground.png)

```
VStack {
  Section(header: Text("DefaultTextFieldStyle").font(.headline)) {
    TextField("Placeholder", text: .constant(""))
    TextField("Placeholder", text: $text)
  }
  .textFieldStyle(DefaultTextFieldStyle())

  Section(header: Text("PlainTextFieldStyle").font(.headline)) {
    TextField("Placeholder", text: .constant(""))
    TextField("Placeholder", text: $text)
  }
  .textFieldStyle(PlainTextFieldStyle())

  Section(header: Text("RoundedBorderTextFieldStyle").font(.headline)) {
    TextField("Placeholder", text: .constant(""))
    TextField("Placeholder", text: $text)
  }
  .textFieldStyle(RoundedBorderTextFieldStyle())
}
.background(Color.yellow)
```
这是系统的方式，下面让我们说说自定义的方式

## 方式1: swiftUI方式

没有公共的API来创建新的`TextField`的样式的，推荐的方式就是对`TextField`进行一次包装：

```
public struct FSTextField: View {
  var titleKey: LocalizedStringKey
  @Binding var text: String

  /// Whether the user is focused on this `TextField`.
  @State private var isEditing: Bool = false

  public init(_ titleKey: LocalizedStringKey, text: Binding<String>) {
    self.titleKey = titleKey
    self._text = text
  }

  public var body: some View {
    TextField(titleKey, text: $text, onEditingChanged: { isEditing = $0 })
      // Make sure no other style is mistakenly applied.
      .textFieldStyle(PlainTextFieldStyle())
      // Text alignment.
      .multilineTextAlignment(.leading)
      // Cursor color.
      .accentColor(.pink)
      // Text color.
      .foregroundColor(.blue)
      // Text/placeholder font.
      .font(.title.weight(.semibold))
      // TextField spacing.
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      // TextField border.
      .background(border)
  }

  var border: some View {
    RoundedRectangle(cornerRadius: 16)
      .strokeBorder(
        LinearGradient(
          gradient: .init(
            colors: [
              Color(red: 163 / 255.0, green: 243 / 255.0, blue: 7 / 255.0),
              Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
            ]
          ),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        ),
        lineWidth: isEditing ? 4 : 2
      )
  }
}
```

![customSwiftUI](./customSwiftUI.gif)

这是可以真正的自定义一个`TextField`。没有办法改变占位符文本的颜色，或者设置不同文本的字体的大小：我们可以通过使用外部文本甚至在跟踪TextField状态时应用掩码来绕过一些限制，但是我们会很快遇到其他的困境，例如键盘操作相关的一些内容。


## 方式2: swiftUI方式

当`TextField`不能满足我们的需求时，我们可以回到UIKit的`UITextField`.这需要创建一个`UIViewRepresentable`:
```
struct UIKitTextField: UIViewRepresentable {
  var titleKey: String
  @Binding var text: String

  public init(_ titleKey: String, text: Binding<String>) {
    self.titleKey = titleKey
    self._text = text
  }

  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField(frame: .zero)
    textField.delegate = context.coordinator
    textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
    textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textField.placeholder = NSLocalizedString(titleKey, comment: "")

    return textField
  }

  func updateUIView(_ uiView: UITextField, context: Context) {
    if text != uiView.text {
        uiView.text = text
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  final class Coordinator: NSObject, UITextFieldDelegate {
    var parent: UIKitTextField

    init(_ textField: UIKitTextField) {
      self.parent = textField
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
      guard textField.markedTextRange == nil, parent.text != textField.text else {
        return
      }
      parent.text = textField.text ?? ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
    }
  }
}
```
与SwiftUI的`TextField`使用比较：

```
struct ContentView: View {
  @State var text = ""

  var body: some View {
    VStack {
      TextField("Type something... (SwiftUI)", text: $text)
      UIKitTextField("Type something... (UIKit)", text: $text)
    }
  }
}
```

![uikitswiftui](./uikitswiftui.gif)

一旦我们有了这个基本`TextField`文本框，我们可以继续获取所有需要的UIKit功能，例如，改变占位符的文本颜色现在需要在`UIKitTextField`的`makeUIView(context:)`方法中添加以下代码:

```
textField.attributedPlaceholder = NSAttributedString(
  string: NSLocalizedString(titleKey, comment: ""),
  attributes: [.foregroundColor: UIColor.red]
)
```

![red](./red.png)

有了UIKit，我们可以做更多的事情，而不仅仅是简单的定制。例如，我们可以将日期/选择器和键盘类型与我们的`TextField`文本字段关联起来，这两种类型在SwiftUI中都不支持。更重要的是，我们可以使任何文本字段成为第一响应者。

对于一个高级的`TextField` `UIViewRepresentable`示例，我建议查看[SwiftUIX's CocoaTextField](https://github.com/SwiftUIX)。

## 自省的方式




