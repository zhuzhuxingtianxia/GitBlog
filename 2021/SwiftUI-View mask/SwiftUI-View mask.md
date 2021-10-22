# SwiftUI:View mask

在[SwiftUI:View clipped](../SwiftUI-View%20clipped/SwiftUI-View%20clipped.md)
中，我们已经探索了所有可以将剪辑蒙版应用到视图的方法。虽然剪辑功能强大，但它有两个显著的限制:

* 它要求`shape`作为`mask`
* 内容要么被遮罩，要么被修剪掉;没有灰色地带

让我们探索一下超越剪辑的SwiftUI遮罩`mask`。

## Mask
SwiftUI提供的最后一个蒙版视图修饰符是`mask(alignment:_:)`:

```
extension View {
  @inlinable public func mask<Mask: View>(
    alignment: Alignment = .center, 
    @ViewBuilder _ mask: () -> Mask
  ) -> some View
}
```
除了命名之外，这个修饰符声明和其他一些我们可能非常熟悉的视图修饰符是一样的，`overlay(alignment:_:)`和`background(alignment:_:)`:

```
extension View {
  @inlinable public func overlay<V: View>(
    alignment: Alignment = .center, 
    @ViewBuilder content: () -> V
  ) -> some View

  @inlinable public func background<V: View>(
    alignment: Alignment = .center, 
    @ViewBuilder content: () -> V
  ) -> some View
}
```
这不是巧合`.mask(alignment:_:)`定位它的蒙版就像一个`overlay`覆盖或`background`背景修改器一样:

* 修饰符将它应用到的视图的自然大小建议给它的mask
* 一旦mask大小已知，它将根据指定的`alignment`对齐方式放置在视图上

## Mask alignment


