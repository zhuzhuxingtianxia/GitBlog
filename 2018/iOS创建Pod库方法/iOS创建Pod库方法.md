# iOS创建Pod库方法

## 本地Pod库

#### 新建lib库
在工程目录新建文件夹，名称XXXLib（随便什么名字，最好可读性较强，带有集成库的含义即可）

#### 新建同名文件夹
在上述库中新建与你想要集成库**同名**文件夹
我要集成的文件是`NTalkerSDK`，所以新建了该文件夹

#### 创建 .podspec 文件
pod 命令会生成 `.podspec` 文件
```
cd NTalkerSDK
pod spec create NTalkerSDK
```

#### 配置 .podspec 文件
```
Pod::Spec.new do |spec|

  spec.name         = "NTalkerSDK"
  spec.version      = "2.6.5"
  spec.summary      = "NTalkerSDK小能客服"

  spec.description  = <<-DESC
  DOTO: NTalkerSDK实时在线客服聊天服务系统
                   DESC

  spec.homepage     = "http://doc3.xiaoneng.cn/ntalker.php"
  # spec.screenshots  = "www.example.com/screenshots_1.gif"
  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "作者" => "作者邮箱" }
  spec.platform     = :ios, "8.0"

  # spec.ios.deployment_target = "8.0"

  spec.source       = { :git => "https://github.com/NTalkerSDK.git", :tag => "#{spec.version}" }

  # spec.source_files  = "NTalkerSDK*"
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes*.h"

  # spec.resource  = "icon.png"
  spec.resources = "NTalkerSDK/NTalkerColorful.bundle", "NTalkerSDK/NTalkerDefault.bundle", "NTalkerSDK/NTalkerGuest.bundle"
  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # 使用了第三方静态库
  # spec.vendored_libraries = 'TalkingData/libTalkingData.a'
  spec.vendored_frameworks = 'NTalkerSDK/NTalkerGuestIMKit.framework', 'NTalkerSDK/NTalkerIMCore.framework'

  spec.frameworks = 'AVFoundation', 'Contacts', 'CoreTelephony', 'AddressBook'
  spec.libraries = 'sqlite3.0','xml2.2','stdc++','c++'

  # spec.requires_arc = true
  spec.static_framework  =  true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"
# 添加子依赖，可以让库实现两级目录
  #
  #s.subspec 'NSURLSession' do |ss|
  #    ss.dependency 'AFNetworking/Serialization'
  #    ss.dependency 'AFNetworking/Security'
     
  #     ss.source_files = 'AFNetworking/AF{URL,HTTP}SessionManager.{h,m}', 'AFNetworking/AFCompatibilityMacros.h'
  #     ss.public_header_files = 'AFNetworking/AF{URL,HTTP}SessionManager.h', 'AFNetworking/AFCompatibilityMacros.h'
  #    ss.frameworks = 'SystemConfiguration'
  #end

  # 添加spec.pod_target_xcconfig，执行pod lib lint --skip-import-validation 否则不支持i386和x86_64编译
   spec.pod_target_xcconfig = { 'VALID_ARCHS[sdk=iphonesimulator*]' => '' }

end
```

#### 检查 .podspec
切换到`NTalkerSDK.podspec` 路径，执行命令：
```
pod lib lint
```
会出现一些问题，可根据提示排查

**问题：**模拟器下编译不通过问题
在`pod lib lint --verbose` 阶段就不能通过，直接报错！

`Ld /Users/jion/Library/Developer/Xcode/DerivedData/App-dphkvfphtohrwobsykxtcixkolaq/Build/Intermediates.noindex/App.build/Release-iphonesimulator/App.build/Objects-normal/i386/App normal i386 (in target: App)`
或
`Ld /Users/jion/Library/Developer/Xcode/DerivedData/App-dphkvfphtohrwobsykxtcixkolaq/Build/Intermediates.noindex/App.build/Release-iphonesimulator/App.build/Objects-normal/x86_64/App normal x86_64 (in target: App)`

解决方法：

1. 在 `podspec` 文件中添加 `s.pod_target_xcconfig = { 'VALID_ARCHS[sdk=iphonesimulator*]' => '' }`，如果项目已经设置 `pod_target_xcconfig`，添加到已有值的后面。设置此处将在 模拟器编译时不产生二进制文件。
2. `pod lib lint`命令添加 `--skip-import-validation`参数，lint 将跳过验证 pod 是否可以导入。
3. 如果上传则 `pod repo push` 命令添加 `--skip-import-validation` 参数，push 将跳过验证 pod 是否可以导入。 

**编译报错：** `(maybe you meant: ___llvm_profile_runtime_user)`
 解决：Other Linker Flags中添加`-fprofile-instr-generate`

## 公共Pod库



