# SwiftUI: Searchable

苹果推出了`Searchable`，允许用户从`List`列表中进行搜索。
这个过程是一个相当简单和直接的方式，将使编写代码更容易。但要求Xcode13和iOS15以上。

## 设置List列表

你的新餐厅推出了一个新的应用程序，你正在考虑利用苹果发布的新技术，实现`Searchable`，允许用户搜索他们最喜欢的食物。

首先，你需要列出你的餐厅提供的食物。
```
private var foods = ["Chicken Chop", "Fish n Chip", "Fried Noodle", "Fried Rice", "Bread"]
NavigationView {
    List {
        ForEach(foods, id: \.self) { food in
            Text(food)
        }
    }
}.navigationBarTitle(Text("Foods"))

```

##  设置Searchable
接下来，您将添加一个功能，让用户能够搜索他们喜爱的菜单。在此之前，您将创建一个新变量，该变量将保存搜索的值。

```
@State private var searchFood = ""
```
并实现`List`的`searchable`修饰器
```
List {
	...
}.searchable(text: $searchFood)
```

## 配置Searchable
有多种方式来配置`Searchable`

### Placement
你可以设置`Searchable`在用户滚动时始终可见:

```
.searchable(text: $searchFood, placement: SearchFieldPlacement.navigationBarDrawer(displayMode: .always))
```

或者在滚动时隐藏`Searchable`:

```
.searchable(text: $searchFood, placement: SearchFieldPlacement.toolBar)
```

### 设置占位符

接下来，您可以将占位符更改为不同的文本。

```
.searchable(Text("Search food"), text: $searchFood)
```

### 建议
如果你想通过在用户进入搜索模式时显示他们来提升某些食物的销量，你可以这么做：

```
.searchable(Text("Search food"), text: $searchFood) {
        Text("Chicken Chop").searchCompletion("Chicken Chop")
        Text("Fish n Chip").searchCompletion("Fish n Chip")
    }
```

## 搜索结果
显示搜索文本的结果。如果用户没有输入任何内容，下面的代码将简单地返回所有的食物。如果用户开始输入，它将根据所输入的内容返回。
```
var searchResults: [String] {
    return searchFood.isEmpty ? foods : foods.filter { $0.contains(searchFood) }
}
```

用`searchResults`替换`ForEach`中的参数:

```
ForEach(searchResults, id: \.self){
}

```

## 结语
SwiftUI在过去几年里确实增长了很多。在我看来，如果你的项目使用ios13作为最小操作系统，SwiftUI应该被应用到你的项目中。


