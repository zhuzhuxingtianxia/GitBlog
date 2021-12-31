# SwiftUI:循环播放视频

![cloud](./cloud.png)

在我的研究中，我发现了两种概念上不同的播放视频的方式。这两种方法都使用**AVFoundation**，但它们采用了非常不同的方法。

我发现的[第一个方法](https://stackoverflow.com/questions/59937756/in-swiftui-how-can-i-add-a-video-on-loop-as-a-fullscreen-background-image)是使用一个单一视频的`AVPlayer`，并将在视频结束时倒带(重置)视频到开始。我找到的大多数讨论SwiftUI中循环视频的论坛都使用了这种方法，但这并不是理想的方式。视频会断断续续(即使在去掉音轨之后)，而且这不是苹果推荐的方式。

第二种方法使用带有`AVPlayerLooper`的`AVQueuePlayer`来不断地将视频添加到队列的末尾。这种方法在2016年的WWDC演讲中得到了认可，我发现这种方法比倒带视频效果好得多。这也帮助我理解我在使用倒带方法时遇到的所有问题。

因为我想让这篇文章包含所有内容，所以我将介绍这两种方法。如果您正在寻找一个快速的解决方案，请跳到`AVQueuePlayer`部分。


## 基本设置

在开始循环播放视频之前，让我们先找一个要循环播放的视频。

我将使用pixabay的这段视频。我播放这段视频，并在视频循环之前添加一个绿色框这样你就可以看到视频循环的位置。加上方框对于判定是否循环是非常有帮助的。

新建Assets文件夹分组，将视频资源导入（确保选中了目标复选框）到这个资源文件夹中。当使用这个资源时，您通常会通过它的URL引用它。

您可以使用`Bundle.main.url`获取资源的URL，并传递这个资产名称(VideoWithBlock)和它的类型(mov)作为参数。这是我第一次需要获取本地资源的URL，所以这花了我一些时间。

```
let fileUrl = Bundle.main.url(forResource: "VideoWithBlock", withExtension: "mov")!
```

## AVPlayer

如上所述，这不是苹果认可的方法。我想说一下这个，因为这是我发现的第一个解决方案，很多人都推荐这个。这种方式并不适合我，它给我带来了巨大的悲伤。

这是一个带有`UIViewRepresentable`包装的`AVPlayer`。和SwiftUI中的很多东西一样，这个的核心将不是SwiftUI。在`AVPlayer`的基础之上，我们需要添加监听视频结束时的功能。我们可以侦听`AVPlayerItemDidPlayToEndTime`通知，这将调用一个函数，将我们的播放器回放到视频的开始。

```
import SwiftUI
import AVKit
import AVFoundation

struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero)
    }
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 获取资源路径
        let fileUrl = Bundle.main.url(forResource: "VideoWithBlock", withExtension: "mov")!
        
        // 初始化 player
        let player = AVPlayer(url: fileUrl)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        // 设置循环
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        // 开始播放movie
        player.play()
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
```

你看到这个在绿盒子后面有点不连贯了吗?这显然不是无缝的回放。

## AVPlayerLooper

首先，我们需要将视频加载到`AVPlayerItem`中。`AVPlayerLooper`将接受这个项目，并重用它，这样我们就不必多次加载相同的视频。

接下来我们要做的是创建一个`AVQueuePlayer`。这是一种特殊类型的`AVPlayer`，它有是一个视频队列，它预加载视频，这样我们就不用担心视频结束时播放中断。

最后，我们用我们想要播放的视频设置一个`AVPlayerLooper`。`AVPlayerLooper`将处理所有的队列，以便我们的`AVQueuePlayer`将继续循环视频。我们还需要保持对该对象的引用，以避免它被清理。

```
import SwiftUI
import AVKit
import AVFoundation

struct PlayerView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(frame: .zero)
    }
}


class LoopingPlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // 加载资源路径
        let fileUrl = Bundle.main.url(forResource: "VideoWithBlock", withExtension: "mov")!
        let asset = AVAsset(url: fileUrl)
        let item = AVPlayerItem(asset: asset)
        
        // 初始化player
        let player = AVQueuePlayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
         
        // 使用队列播放器和模板项创建一个新的播放器循环器
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        // 开始播放
        player.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
```

这样就比较完美了！

## 修复视频的不连贯

当我第一次实施这个方法的时候，我总是不连贯的。我一开始以为这是某种延迟，这把我逼疯了。我使用的一个资源在我使用的其他程序中完全没问题，但没有使用`AVPlayer`。

我在StackOverflow上看到过几次这篇文章，最后我遇到了一个回复，说[音频可能比视频稍微长一点](https://stackoverflow.com/questions/53876456/avplayerloop-not-seamlessly-looping-swift-4)。我通过解析删除了音频轨道的视频，并修复了它。在WWDC16的演讲中也提到了这个问题，他们说你可以通过编程来实现这一点，方法是将播放时间设置为所有轨道中最短的。

注意:如果你使用`AVPlayer`而不是`AVQueuePlayer`方法，你可能仍然会遇到不连贯。然而，这会减少很多。

<!--- https://schwiftyui.com/swiftui/playing-videos-on-a-loop-in-swiftui/ ---->

