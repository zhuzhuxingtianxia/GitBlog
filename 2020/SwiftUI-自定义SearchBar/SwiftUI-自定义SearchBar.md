# SwiftUI：自定义SearchBar(内有学习文章)

文章学习：
https://www.zhihu.com/column/c_1242412078326702080
https://juejin.cn/post/6850418104456085511
https://juejin.im/post/6856276793817563144/
https://www.zhihu.com/people/springday-18/posts?page=2
https://swiftui-lab.com/

使用SwiftUI的TextField进一步封装的自定义组件 
基于Xcode11.3，iOS13的项目

![searchbar.png](./searchbar.png)

## 使用
收起键盘时调用`onCommit`方法
```
struct SearchView: View {
  @State fileprivate var searchText: String = ""

  var body: some View {
      VStack {
        SearchBar(placeholder: "请输入标题/正文名称") { (search) in
                self.searchText = search
                // do something ,example: Request
            }
            .frame(height:34)
            .background(RoundedRectangle(cornerRadius: 17).foregroundColor(.hexString(hex: "#EBF2FF")))
            .padding()
      }
     Spacer()
  }
}
```
实时获取输入内容`onChange`方法

![实时输入.png](./实时输入.png)

```
struct ContentView: View {
    
    @State var searchText: String = "猪猪行天下"
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(placeholder: "请输入内容", searchText: searchText) { (text) in
                    print("onChange:\(text)")
                    self.searchText = text
                } onCommit: { (text) in
                    print("onCommit:\(text)")
                    self.searchText = text
                }
                .frame(height:34)
                .background(RoundedRectangle(cornerRadius: 17).foregroundColor(Color.hexString("#EBF2FF")))
                .padding()
                
                Text(searchText)
                    .padding()
                Spacer()
            }
        }
        .navigationTitle("SearchBar")
    }
}

```

## SearchBar源码

```
import SwiftUI

extension View {
   fileprivate func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchBar : View {
    var placeholder:String
    
    @State var searchText: String
    var onChange: ((String) -> Void)?
    var onCommit: ((String) -> Void)?
    
    init(placeholder: String = "Search",searchText: String="",onChange:((String)->Void)? = nil ,onCommit:((String)->Void)? = nil) {
        
        self.placeholder = placeholder
        
        _searchText = State(initialValue: searchText)
        
        self.onChange = onChange
        self.onCommit = onCommit
    }
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.searchText
        }, set: {
            self.searchText = $0
            if self.onChange != nil {
                self.onChange!(self.searchText)
            }
        })
        
       return HStack {
            Image(systemName: "magnifyingglass")
                .padding(.leading, 0)
                .foregroundColor(.secondary)
            TextField(searchText=="" ? placeholder : "", text: binding, onEditingChanged: { (isEditing) in
                if(isEditing) {
                    
                }
            }) {
                if self.onCommit != nil {
                    self.onCommit!(self.searchText)
                }
                UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
            }
            .keyboardType(.default)
            .padding(.leading, 10)
            .onTapGesture {}
            .onLongPressGesture(pressing: { (isPressed) in
                if isPressed {
                    self.endEditing()
                }
            }) {
                //perform
            }
            Button(action: {
                self.searchText = ""
                if self.onCommit != nil {
                    self.onCommit!(self.searchText)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .opacity(searchText == "" ? Double(0) : Double(0.8))
            }
        }.padding(.horizontal)
    }
}

```
遗留问题：
1、TextField不能设置returnKeyType属性(也许是没找到)。如果要使用这个属性的话，可以封装UITextField给swiftUI用。
2、SearchBar设置初始值时，在init方法给@State 修饰的searchText赋值时无效,已解决。
解决方法：**重新初始化State**
```
@State var searchText: String
init(searchText: String="") {
  _searchText = State(initialValue: searchText)
}
```
3、上面实时获取输入内容依然采用的命令式的写法，如果使用相应式需配合`Combine`,可以参考这个[项目https://github.com/teaualune/swiftui_example_wiki_search](https://github.com/teaualune/swiftui_example_wiki_search)

