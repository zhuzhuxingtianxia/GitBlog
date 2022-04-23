# MediaPipe学习

[MediaPipe](https://google.github.io/mediapipe/getting_started/install.html#installing-on-macos)是谷歌开源的机器学习框架，用于处理视频、音频等时间序列数据。
MediaPipe Solutions提供了16个Solutions: 人脸检测、Face Mesh(面部网格)、虹膜、手势、姿态、人体、人物分割、头发分割、目标检测、Box Tracking、Instant Motion Tracking、3D目标检测、特征匹配等。


## 环境安装

### macOS环境
* 安装Homebrew
```
/bin/bash -c "$(curl -fsSL \
https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```
* 安装Xcode及命令行工具`xcode-select --install`
* 安装Bazelisk，`brew install bazelisk`
* 克隆**MediaPipe**库文件
 ```
 git clone https://github.com/google/mediapipe.git
 cd mediapipe
 ```
* 安装OpenCV和FFmpeg,FFmpeg将通过OpenCV安装
```
brew install opencv@3
//glog依赖项导致了一个已知问题,卸载glog
brew uninstall --ignore-dependencies glog
```
若有下载依赖报错，则先下载依赖
```
brew install openexr
brew install libvmaf
brew install libx11
brew install libarchive
brew install opencv@3
//glog依赖项导致了一个已知问题,卸载glog
brew uninstall --ignore-dependencies glog
```
查看opencv的版本及信息`brew info opencv@3`:
opencv@3: stable 3.4.16 (bottled) [keg-only]

* 查看python版本`python -V`,将python3设置为默认的python版本，并安装`six`库，这是**TensorFlow**的需要：
 ```
 pip3 install --user six
 ```

* 查看安装结果：
```
export GLOG_logtostderr=1
// 需要bazel设置环境变量'MEDIAPIPE_DISABLE_GPU=1'，因为桌面GPU当前不受支持
bazel run --define MEDIAPIPE_DISABLE_GPU=1 \
    mediapipe/examples/desktop/hello_world:hello_world
```
打印：Hello World!
Hello World!
表示安装完成！

### iOS环境

* 安装Xcode命令行工具`xcode-select --install`
	* 查看是否成功: `gcc -v`
	* 删除旧工具: 
	```
	sudo xcode-select --switch /Library/Developer/CommandLineTools/
	或：
	sudo rm -rf /Library/Developer/CommandLineTools
	// 这两个命令没尝试过
	```
* brew安装Bazel：
```
brew install bazel
//查看版本
bazel --version
//更新
brew upgrade bazel
```
如果报错：
```
ERROR: The project you're trying to build requires Bazel 5.0.0 (specified in /Users/jion/Desktop/MyGithub/GitBlog/2022/MediaPipe/mediapipe/.bazelversion), but it wasn't found in /usr/local/Cellar/bazel/5.1.1/libexec/bin.
```
则按照提示执行：
```
(cd "/usr/local/Cellar/bazel/5.1.1/libexec/bin" && curl -fLO https://releases.bazel.build/5.0.0/release/bazel-5.0.0-darwin-x86_64 && chmod +x bazel-5.0.0-darwin-x86_64)
```

* 安装TensorFlow依赖的Python库**six**: `pip3 install --user six`
* 克隆**MediaPipe**库：`git clone https://github.com/google/mediapipe.git`
* 设置唯一的bundle ID前缀，可通过运行命令来获得这个唯一前缀：
```
python3 mediapipe/examples/ios/link_local_profiles.py
```

## Bazel
bazel是一个多平台编译和构建工具。使用bazel构建项目，在项目根目录下必须包含一个`WORKSPACE`文件，然后在该文件中做相应的配置。WORKSPACE包含bazel资源，是项目的根。

**WORKSPACE**：用于描述项目所需的构建规则；
**BUILD**：描述文件，一个`BUILD`描述文件即为一个package包

Bazel把代码划分成package包,package包可以理解为一个目录，这个目录里面包含了源文件和一个描述文件，描述文件就是`BUILD`文件。一个包需包含一个`BUILD`描述文件。

构建应用：`bazel build //app:hello-world` 
构建应用指定架构：`bazel build -c opt --config=ios_arm64 //app:hello-world`
运行应用：`bazel run //app:hello-world`

`//`: 表示根目录，上面指令表示构建根目录中app文件目录`BUILD`的name为hello-world的应用或包。
`visibility:public` 表示我们的可见域

模拟器构建：`bazel build --features=apple.skip_codesign_simulator_bundles //your/target`
注意：需要使用受权限保护的API，则不能使用模拟器构建，也需要签名打包才可以。

## 创建Xcode项目

* 我们将使用一个工具名为`Tulsi`，来生成Xcode项目用`Bazel`来build Configuration。
```
//cd 到 mediapipe文件的同级目录
git clone https://github.com/bazelbuild/tulsi.git
cd tulsi
# remove Xcode version from Tulsi's .bazelrc (see http://github.com/bazelbuild/tulsi#building-and-installing):
sed -i .orig '/xcode_version/d' .bazelrc
# build and run Tulsi:
sh build_and_run.sh
```
这将安装一个`Tulsi.app`在你的home文件的`Applications`文件中，如何使[Tulsi.app](https://tulsi.bazel.build/docs/gettingstarted.html)。

* 使用`Tulsi.app`打开`mediapipe/Mediapipe.tulsiproj`。注意：如果`Tulsi`显示错误说“Bazel could not be found”,在选项中点击“Bazel…”按钮，选择`bazel`执行在homebrew `/bin/`文件中。
* 在配置选项卡中选择MediaPipe配置，然后按下下面的`Generate`生成按钮。
* 输入项目名称，为项目选择`WORKSPACE`文件。
 
 WORKSPACE文件：
 
 ```
 load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_bazel_rules_apple",
    sha256 = "4161b2283f80f33b93579627c3bd846169b2d58848b0ffb29b5d4db35263156a",
    url = "https://github.com/bazelbuild/rules_apple/releases/download/0.34.0/rules_apple.0.34.0.tar.gz",
)

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:extras.bzl",
    "swift_rules_extra_dependencies",
)

swift_rules_extra_dependencies()

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()
 ```

BUILD文件:

```
# @build_bazel_rules_apple//apple:ios.bzl 表示构建iOS平台的bundle
# ios_application 表示iOS应用，
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")

# objc库文件
objc_library(
    name = "Lib",
    srcs = glob([
        "**/*.h",
        "**/*.m",
    ]),
    data = [
        ":Main.storyboard",
    ],
)

# 将“deps”中的代码链接到可执行文件中，收集和编译“deps”中的资源，并将其与可执行文件一起放在.app bundle里， 然后输出一个.ipa应用程序包在他的Payload文件中。
ios_application(
    name = "App",
    bundle_id = "com.example.app",
    families = ["iphone", "ipad"],
    infoplists = [":Info.plist"],
    minimum_os_version = "15.0",
    deps = [":Lib"],
)
```
打包应用是需要对应的配置文件，从开发者中心下载通用的`profile.mobileprovision`配置文件,
例如:
`profile.mobileprovision`对应的bunld_id是`com.companyname.*`,
则需要打开`mediapipe/examples/ios/bundle_id.bzl`文件
将`BUNDLE_ID_PREFIX = "*SEE_IOS_INSTRUCTIONS*.mediapipe.examples"`修改为`BUNDLE_ID_PREFIX = "com.companyname"`

然后将您的配置文件符号链接或复制到`mediapipe/mediapipe`路径下，下载的文件在`~/Downloads
`目录下，文件名为`Profile_common.mobileprovision`。则执行命令把它做一个符号链接：
```
cd mediapipe
ln -s ~/Downloads/Profile_common.mobileprovision mediapipe/provisioning_profile.mobileprovision
```

## MediaPipe On iOS
在官方的`Hello World! On iOS`的[事例](https://google.github.io/mediapipe/getting_started/hello_world_ios.html)中，添加相关依赖时，在`BUILD`文件`data`中添加：
```
"//mediapipe/graphs/edge_detection:mobile_gpu_binary_graph",
```
改为：
```
 "//mediapipe/graphs/edge_detection:mobile_gpu.binarypb",
```

## 搞了那么多还是搞不定，怎么打frameWork？
首先将`mediapipe/objc`目录下的BUILD文件`package(default_visibility = ["//visibility:public"])`中的`private`改为`public`。
要打包的BUILD文件:
```
# bazel build -c opt --config=ios_arm64 mediapipe/examples/ios/myfacemesh:FaceMeshSDK

load(
    "@build_bazel_rules_apple//apple:ios.bzl",
    "ios_framework",
)

MIN_IOS_VERSION = "10.0"

ios_framework(
    name = "FaceMeshSDK",
    hdrs = [
        "FaceMesh.h",
    ] + select({
        "//mediapipe:ios": [
            "//mediapipe/objc:MPPInputSource.h",
            "//mediapipe/objc:MPPCameraInputSource.h",
            "//mediapipe/objc:MPPPlayerInputSource.h",
            "//mediapipe/objc:MPPGLViewRenderer.h",
            "//mediapipe/objc:MPPLayerRenderer.h",
        ],
        "//conditions:default": [],
    }),
    bundle_id = "com.btn.hf.FaceMeshSDK",
    families = [
        "iphone",
        "ipad",
    ],
    infoplists = [
        "Info.plist",
    ],
    minimum_os_version = MIN_IOS_VERSION,
    deps = [
        ":FaceMeshLib",
        "@ios_opencv//:OpencvFramework",
    ],
)

objc_library(
    name = "FaceMeshLib",
    srcs = [
        "FaceMesh.mm",
    ],
    hdrs = [
        "FaceMesh.h",
    ],
    copts = ["-std=c++17"],
    visibility = ["//mediapipe:__subpackages__"],
    sdk_frameworks = [
        "AVFoundation",
        "CoreGraphics",
        "CoreMedia",
        "CoreVideo",
    ],
    data = [
        "//mediapipe/graphs/face_mesh:face_mesh_mobile_gpu.binarypb",
        "//mediapipe/modules/face_detection:face_detection_short_range.tflite",
        "//mediapipe/modules/face_landmark:face_landmark_with_attention.tflite",
    ],
    deps = [
        "//mediapipe/objc:mediapipe_framework_ios",
        "//mediapipe/objc:mediapipe_input_sources_ios",
        "//mediapipe/objc:mediapipe_layer_renderer",
    ] + select({
        "//mediapipe:ios_i386": [],
        "//mediapipe:ios_x86_64": [],
        "//conditions:default": [
            "//mediapipe/graphs/face_mesh:mobile_calculators",
            "//mediapipe/framework/formats:landmark_cc_proto",
        ],
    })

)

```


## 相关参考文章

[Mediapipe – 全身包含身体、手部、面部所有关键点标注位置对应图](https://www.stubbornhuang.com/1916/)

[Mediapipe - 将Mediapipe handtracking封装成动态链接库dll/so,实现在桌面应用中嵌入手势识别功能](https://blog.csdn.net/HW140701/article/details/119675282)



