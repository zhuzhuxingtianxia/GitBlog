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

* [SwiftUI:Label](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-Label/SwiftUI-Label.md)
* [更现代的 Swift API 设计](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%20Swift%20API%20%E8%AE%BE%E8%AE%A1/%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%20Swift%20API%20%E8%AE%BE%E8%AE%A1.md)
* [SwiftUI:PreferenceKey的reduce方法解密](https://github.com/zhuzhuxingtianxia/GitBlog/blob/master/2021/SwiftUI-PreferenceKey%E7%9A%84reduce%E6%96%B9%E6%B3%95%E8%A7%A3%E5%AF%86/SwiftUI-PreferenceKey%E7%9A%84reduce%E6%96%B9%E6%B3%95%E8%A7%A3%E5%AF%86.md)


