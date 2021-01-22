# SwiftUI:Swift协议

就像其他Swift框架一样，SwiftUI严重依赖协议作为其定义的核心部分。
在这篇新文章中，我们来看看Swift标准库协议在SwiftUI中的使用:`Hashable`, `Identifiable`, 和 `Equatable`。

## Equatable

Equatable是SwiftUI中重要的协议之一。计算布局、绘制组件等都很消耗性能的，SwiftUI通过减少绘制操作来提高性能。

SwiftUI使用`Equatable`来做出这样的决定:即使对于没有声明`Equatable`一致性的视图，SwiftUI也会通过快速反射来遍历视图定义，检查每个属性的公平性，并据此决定是否需要重新绘制。

更深入的可以查看[Equatable背后的奥秘]()

## Identifiable

当`Equatable`用于检测视图状态变化(因此触发重绘)时，`Identifiable`将视图标识与其状态分离。
例如在SwiftUI中，它用于跟踪`List`和`OutlineGroup`中元素的顺序:

* 想象一个元素列表，其中可能会发生一些重新排序。如果重新排序不涉及任何其他更改，则只需要列表更新单元格顺序，而不需要重新绘制单元格。
* 另一方面，如果只有一个单元格的状态发生了变化，但是顺序没有变化，那么只需要重新绘制特定的单元格，而列表本身不需要做任何改变。

另外一个是`Identifiable`在`Picker`中使用的例子：在这种情况下，`Identifiable`用于确定可能候选元素中的哪个元素是被选中的(如果有的话)，而不考虑元素类型定义中的其他可能状态。


