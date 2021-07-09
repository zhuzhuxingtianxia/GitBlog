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

这是可以真正的自定义一个`TextField`


