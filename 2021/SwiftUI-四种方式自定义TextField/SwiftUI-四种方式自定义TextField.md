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


