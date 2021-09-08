# SwiftUI:制作评价按钮

以下是我们今天要创建的内容。在本教程中，你将能够在你的应用程序中使用这个弹出评论按钮，根据需求对类似服务或质量进行评价。

![Popup_Review_Button_SwiftUI_Crop](./Popup_Review_Button_SwiftUI_Crop.png)

## 开始

创建一个新的名为`ReviewButton`的SwiftUI文件来生成一个模板,这个视图将把所有东西联系在一起。一旦我们完成了按钮的构建，我们将把它添加到我们的应用程序中。
```
import SwiftUI

struct ReviewButton: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ReviewButton_Previews: PreviewProvider {
    static var previews: some View {
        ReviewButton()
    }
}
```

## 视图分解
我们将把这个`ReviewButton`分解为两部分。第一个是星`Image`和“Rate This”`Text`，第二个是弹出的5颗星。

![Decomposition_SwiftUI-1](./Decomposition_SwiftUI-1.png)

很明显，在这个项目中会有很多Star出现，所以让我们继续创造一个对我们有利的Star按钮。

1. 再创建一个SwiftUI视图命名为`StarIcon`
2. 为`StarIcon`添加一个属性变量`filled`
  	```
  	var filled: Bool = false
	```

3. 用一个`Image`替换模版中的代码，用于显示一个star。这里的关键是改变使用系统提供的`star.fill`或`star`图标。我们将使用刚才定义的属性来决定。
	```
	Image(systemName: filled ? "star.fill" : "star")
	```

4. 然后我们设置StarIcon中的Image是否填充颜色
 	```
 	Image(systemName: filled ? "star.fill" : "star")
    .foregroundColor(filled ? Color.yellow : Color.black.opacity(0.6))
	```

组合一下代码，如下：
```
import SwiftUI

struct RatingIcon: View {
    
    var filled:Bool = true
    
    var body: some View {
        Image(systemName: filled ? "star.fill" : "star")
            .foregroundColor(filled ? Color.yellow : Color.black.opacity(0.6))
    }
}

struct RatingIcon_Previews: PreviewProvider {
    static var previews: some View {
        RatingIcon(filled: true)
    }
}
```

![image](./image.png)

## 使用Star

就像我之前说的，我们要先创建Star星号和Label标签，然后是Popup。

回到`ReviewButton`，让我们开始第一部分。

替换body中的代码：
```
Button(action: {
    // Empty for now...
}) {
    VStack(alignment: .center, spacing: 8) {
        //Star Icon and Label Here...
        StarIcon()
        Text("Rate This")
            .foregroundColor(Color.black)
            .font(Font.system(size: 11, weight: .semibold, design: .rounded))
    }
}
```

![ReviewButton_Part1](./ReviewButton_Part1.png)

## 创建Popup
现在我们要创建一个显示5颗星组的弹出窗口。我们将重用之前创建的`StarIcon`。


