# weex开发之与web交互
在做weex开发中遇到一个需要与web交互的需求。
看了下weexSDK,在0.20以上的版本中是有与web交互的api的。所以先升级sdk，iOS和Android都通用！
## 原生sdk代码
查看sdk代码：
```
// Weex postMessage to web
- (void)postMessage:(NSDictionary *)data {
    WXSDKInstance *instance = [WXSDKEngine topInstance];

    NSString *bundleUrlOrigin = @"";

    if (instance.pageName) {
        NSString *bundleUrl = [instance.scriptURL absoluteString];
        NSURL *url = [NSURL URLWithString:bundleUrl];
        bundleUrlOrigin = [NSString stringWithFormat:@"%@://%@%@", url.scheme, url.host, url.port ? [NSString stringWithFormat:@":%@", url.port] : @""];
    }

    NSDictionary *initDic = @{
        @"type" : @"message",
        @"data" : data,
        @"origin" : bundleUrlOrigin
    };

    NSString *json = [WXUtility JSONString:initDic];

    NSString *code = [NSString stringWithFormat:@"(function (){window.dispatchEvent(new MessageEvent('message', %@));}())", json];
    [_jsContext evaluateScript:code];
}

```
这个是发送数据给web的方法，上面注释很清楚了。
这里则有个**postMessage**方法是文档中没有的！

在**WXWebViewModule**中是有个API的
```
WX_EXPORT_METHOD(@selector(postMessage:data:))
对应的方法：
- (void)postMessage:(NSString *)elemRef data:(NSDictionary *)data {
    [self performBlockWithWebView:elemRef block:^void (WXWebComponent *webview) {
        [webview postMessage:data];
    }];
}
```

```
//Weex catch postMessage event from web
    _jsContext[@"postMessage"] = ^() {

        NSArray *args = [JSContext currentArguments];

        if (args && args.count < 2) {
            return;
        }

        NSDictionary *data = [args[0] toDictionary];
        NSString *origin = [args[1] toString];

        if (data == nil) {
            return;
        }

        NSDictionary *initDic = @{ @"type" : @"message",
                                   @"data" : data,
                                   @"origin" : origin
        };

        [weakSelf fireEvent:@"message" params:initDic];
    };
```
看注释，监听来自web的数据。这里有个**message**方法是文档中没有的！
那么在weex和在html端怎么使用？
## weex端使用
```
<template>
  <div class="wrapper">
    <div style="font-size:28px;padding:20px;border-width: 1px;" @click="postMessage">向web发送数据</div>
    <text style="font-size:28px;" ref="ppt">{{param}}</text>
    <div class="web">
      <web ref="webview" id="webview" style="flex:1;" @message="onMessage" src="/dist/pages/htmlchart/index.html"></web>
    </div>
  </div>
</template>

<script>
var webview = weex.requireModule('webview');
const modal = weex.requireModule('modal')
export default {
  name: '',
  components: {},
  data () {
    return {
       param:'xx'
    }
  },
  created () {
    
  },
  mounted () {
    
  },
  methods: {
    postMessage () {
      var webElement = this.$refs.webview;
      var options = {
          title:'来自weex的数据'
      };
      if(weex.config.env.platform === 'Web'){
        // document.getElementById("webview").contentWindow.postMessage(options, "*")
          document.getElementById("webview").contentWindow.dispatchEvent(new MessageEvent('message', {
            data: options,
            lastEventId:'weexpage'
          }))
      }else{
        webview.postMessage(webElement,options)
      }
      
    },
    onMessage (e) {
      const self = this
      self.param = e.data.title
      modal.alert({message:'msg:'+JSON.stringify(e.data)},ev=>{})
    }
  }
}
</script>

<style scoped>
.web {
  width: 750px;
  height: 750px;
  background-color: #f0f0f0;
}
  .wrapper {
    justify-content: center;
    align-items: center;
  }
</style>
```
## html端使用
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="weex-viewport" content="750">
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-touch-fullscreen" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="format-detection" content="telephone=no, email=no">
    <title>weex与html</title>
</head>

<body>
    <button style="padding: 20px 40px;margin-top:30px; font-size: 28px;border-width: 1px;" onclick="postDataToWeex()">向weex发送数据</button>
    <p id="html" style="font-size: 28px;"></p>
</body>
<script type="text/javascript">
    
    var options = {
        title:'html页面'
    };
    function getWeexData() {
        //接收来自weex的数据
        window.addEventListener('message', function (e) {
            console.log("message:",e)
             alert("message:"+ JSON.stringify(e.data))
            options = e.data
            document.getElementById('html').innerHTML = options.title;
        }, false);
        // window.dispatchEvent(new MessageEvent('message', {
        //     data: options
        // }))
    }
    getWeexData();

    function postDataToWeex() {
        var isWeb = true //跑模拟器或真机时，改为false
        let data = {title:"来自html的数据"}
        if(isWeb){
            alert(JSON.stringify(data));
        }else{
            // 向weex发送数据,data必须是对象
            postMessage(data,"*");
        }
        
    }
    
</script>

</html>
```

