# blog博客

## GitHub图片不显示问题：

Mac终端输入：`sudo vi /etc/hosts`
输入密码`enter`后，点击 `i`键，进入Insert模式,
如果hosts文件已存在，点击`e`进入然后点击 `i`键，进入Insert模式。

将下面内容拷贝进去:
```
# GitHub Start
192.30.253.112 Build software better, together
192.30.253.119 gist.github.com
151.101.184.133 assets-cdn.github.com
151.101.184.133 raw.githubusercontent.com
151.101.184.133 gist.githubusercontent.com
151.101.184.133 cloud.githubusercontent.com
151.101.184.133 camo.githubusercontent.com
151.101.184.133 avatars0.githubusercontent.com
151.101.184.133 avatars1.githubusercontent.com
151.101.184.133 avatars2.githubusercontent.com
151.101.184.133 avatars3.githubusercontent.com
151.101.184.133 avatars4.githubusercontent.com
151.101.184.133 avatars5.githubusercontent.com
151.101.184.133 avatars6.githubusercontent.com
151.101.184.133 avatars7.githubusercontent.com
151.101.184.133 avatars8.githubusercontent.com
# GitHub End
```
点击`esc`键，然后输入`:wq` 保存退出即可。刷新github

## [2021](https://github.com/zhuzhuxingtianxia/GitBlog/tree/master/2021)

* [SwiftUI:反射探究图谱](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-%E5%8F%8D%E5%B0%84%E6%8E%A2%E7%A9%B6%E5%9B%BE%E8%B0%B1/SwiftUI-%E5%8F%8D%E5%B0%84%E6%8E%A2%E7%A9%B6%E5%9B%BE%E8%B0%B1.md)

* [SwiftUI:views检查Mirror](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-views%E6%A3%80%E6%9F%A5Mirror/SwiftUI-views%E6%A3%80%E6%9F%A5Mirror.md)

* [SwiftUI:全局状态管理](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-%E5%85%A8%E5%B1%80%E7%8A%B6%E6%80%81%E7%AE%A1%E7%90%86/SwiftUI-%E5%85%A8%E5%B1%80%E7%8A%B6%E6%80%81%E7%AE%A1%E7%90%86.md)

* [SwiftUI:自定义HUDs](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-%E8%87%AA%E5%AE%9A%E4%B9%89HUDs/SwiftUI-%E8%87%AA%E5%AE%9A%E4%B9%89HUDs.md)

* [SwiftUI:刷新组件RefreshUI之桥接UIKit](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-RefreshUI/SwiftUI-RefreshUI.md)

* [SwiftUI:List下拉刷新之桥接UIKit 2](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-%E4%B8%8B%E6%8B%89%E5%88%B7%E6%96%B0%E4%B9%8B%E6%A1%A5%E6%8E%A5UIKit%202/SwiftUI-%E4%B8%8B%E6%8B%89%E5%88%B7%E6%96%B0%E4%B9%8B%E6%A1%A5%E6%8E%A5UIKit%202.md)

* [SwiftUI:下拉刷新之桥接UIKit](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-%E4%B8%8B%E6%8B%89%E5%88%B7%E6%96%B0%E4%B9%8B%E6%A1%A5%E6%8E%A5UIKit/SwiftUI-%E4%B8%8B%E6%8B%89%E5%88%B7%E6%96%B0%E4%B9%8B%E6%A1%A5%E6%8E%A5UIKit.md)

* [SwiftUI:Button styles](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-Button%20styles/SwiftUI-Button%20styles.md)

* [SwiftUI:Text约束](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-Text%E7%BA%A6%E6%9D%9F/SwiftUI-Text%E7%BA%A6%E6%9D%9F.md)

* [SwiftUI:@State原理解析](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-%40State%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90/SwiftUI-%40State%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90.md)

* [SwiftUI:navigation进阶](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-navigation%E8%BF%9B%E9%98%B6/SwiftUI-navigation%E8%BF%9B%E9%98%B6.md)

* [SwiftUI:NavigationView](./2021/SwiftUI-NavigationView/SwiftUI-NavigationView.md)
* [SwiftUI:Swift协议](./2021/SwiftUI-Swift%E5%8D%8F%E8%AE%AE/SwiftUI-Swift%E5%8D%8F%E8%AE%AE.md)

* [SwiftUI:Equatable背后的奥秘](./2021/SwiftUI-Equatable%E8%83%8C%E5%90%8E%E7%9A%84%E5%A5%A5%E7%A7%98/SwiftUI-Equatable%E8%83%8C%E5%90%8E%E7%9A%84%E5%A5%A5%E7%A7%98.md)

* [SwiftUI:Custom Button](./2021/SwiftUI-Custom%20Button/SwiftUI-Custom%20Button.md)

* [SwiftUI:自适应Views](./2021/SwiftUI-%E8%87%AA%E9%80%82%E5%BA%94Views/SwiftUI-%E8%87%AA%E9%80%82%E5%BA%94Views.md)

* [SwiftUI:可组合的视图](./2021/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE/SwiftUI-%E5%8F%AF%E7%BB%84%E5%90%88%E7%9A%84%E8%A7%86%E5%9B%BE.md)

* [SwiftUI:Label](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-Label/SwiftUI-Label.md)

* [更现代的 Swift API 设计](./2021/%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%20Swift%20API%20%E8%AE%BE%E8%AE%A1/%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%20Swift%20API%20%E8%AE%BE%E8%AE%A1.md)

* [SwiftUI:PreferenceKey的reduce方法解密](./2021/SwiftUI-PreferenceKey%E7%9A%84reduce%E6%96%B9%E6%B3%95%E8%A7%A3%E5%AF%86/SwiftUI-PreferenceKey%E7%9A%84reduce%E6%96%B9%E6%B3%95%E8%A7%A3%E5%AF%86.md)


## [2020](https://github.com/zhuzhuxingtianxia/GitBlog/tree/master/2020)

