# iframe跨域通信


## iframe
利用`iframe`可以在当前网页中嵌入另一个完成的网页，类似小程序、iOS、android中的webview。

## iframe同源

如果iframe嵌套的网页不存在跨域问题即是同源的，那么可以直接获取iframe的dom进行相应的操作它相当于一个普通的DOM节点，他们的window是相同的（`window.parent == window`）。

需要注意的是iframe需要加载完成后才能获取到它的window(`iframe.contentWindow`)和document(`iframe.contentDocument`)。

如果嵌入iframe的二级域名一致，也可实现同源策略。例如当前网站域名`test.a.com`,iframe中嵌入的网站是`prd.a.com`,可以利用`document.domain`使浏览器忽略该差异，使得它们可以被作为“同源”的来对待，以便进行跨窗口通信,那么在这个网站中都设置`document.domain='a.com'`相同的域之后就可达到同源的效果了。

## iframe跨域通信
如果域名完全不同则可使用`postMessage`进行相关通信操作。当然要等到iframe加载完成使用它的contentWindow来进行postMessage。

跨域是无法获取iframe的document的,否则报错如下：

[error](./error-info.jpg)

所以我们直接通过iframe的document来appendChild的方式注入脚本。只能通过发送消息。
```
<button 
 style={{height: 40}}
 onClick={()=>{
     webViewRef.current.sendMessage('SendMessageToJsPayResult',{a:'a',b:'n'});
}}>按钮</button>
<WebView 
 ref={webViewRef}
 onLoadFinsh={()=>{
     if(webViewRef.current) {
         webViewRef.current.injectScript(`alert('Hello, world!');`)
     }
 }}
 onMessage={data => {
     console.log('接收消息：',data);
 }}
/>

```

webView的实现如下：
```webView.js
/**
 * @description 自定义webview
 * @example 其他h5项目发送消息举例:
 * if(window.parent && window.parent !== window) {
        window.parent.postMessage(JSON.stringify({
            type: 'GMember',
            body: {
            data: '中国嘻嘻'
            }
        }),'*')
    }else {
        console.log('此处不在iframe中')
    }
 * @example 其他web项目接收消息举例:
    window.addEventListener('message', (event)=> {
        if(event.data && event.data.type == 'injectScript') {
            eval(event.data.script);
        }else if(event.data && event.data.type == 'GMember') {
            console.log(event.data)
        }
    })
 * @returns 
    <button 
        style={{height: 40}}
        onClick={()=>{
            webViewRef.current.sendMessage('SendMessageToJsPayResult',{a:'a',b:'n'});
    }}>按钮</button>
    <WebView 
        ref={webViewRef}
        onLoadFinsh={()=>{
            if(webViewRef.current) {
                webViewRef.current.injectScript(`alert('Hello, world!');`)
            }
        }}
        onMessage={data => {
            console.log('接收消息：',data);
        }}
    />
*/

import React, {useEffect, useRef } from "react";

const WebView = React.forwardRef((props, ref) => {

    const {
        src="",
        style={},
        onMessage,
        onLoadFinsh
    } = props;

    React.useImperativeHandle(ref, () => ({
        // postMessage 防止冲突
        sendMessage: (type,data)=>{
            if(webRef.current) {
                try {
                    getIframeContentWindow(webRef.current).postMessage({type,data}, '*')
                } catch (error) {
                    
                }
                
            }else {
                throw new Error('无法获取 iframe 的对象');
            }
        },
        injectScript: (scriptString)=> {
            try {
                getIframeContentWindow(webRef.current).postMessage({
                    type: 'injectScript',
                    script: scriptString
                }, '*')
            } catch (error) {
                
            }
            
        },
        // 同源策略
        same_injectScript: (scriptString)=> {
            try {
                // 跨域时无法获取到document,
                if(window.location.origin == getIframeContentWindow(webRef.current).location.origin) {
                    const script = document.createElement('script');
                    script.innerHTML = scriptString;
                    // script.textContent = scriptString;
                    getIframeContentWindow(webRef.current).document.head.appendChild(script);
                }
                
            } catch (error) {
                
            }
            
        }

    }));

    const webRef = useRef(null);

    useEffect(()=>{
        const messageListener = (event)=> {
        		if (window == event.source) return;
            if(event.data) {
                const data = JSON.parse(event.data);
                if(data.type == 'GMember') {
                    console.log(data)
                }
                onMessage && onMessage(data);
            }
            // 可以使用 event.source.postMessage(...) 向回发送消息
        }
        window.addEventListener('message', messageListener);
        return ()=> {
            window.removeEventListener('message', messageListener);
        }
    },[])

    const getIframeContentWindow = (iframe)=> {
        if (iframe.contentWindow) {
          return iframe.contentWindow;
        } else if (iframe.contentDocument && iframe.contentDocument.defaultView) {
          return iframe.contentDocument.defaultView;
        } else {
          throw new Error('无法获取 iframe 的内容窗口');
        }
      }

    return (
        <div style={{display: 'flex',width: '100vw', height: '100vh',...style}}>
            <iframe 
                style={{flex:1, border: 'none'}} 
                scrolling="no"
                sandbox={'allow-forms allow-scripts'}
                src={src}
                ref={webRef}
                onLoad={(e)=>{
                    onLoadFinsh && onLoadFinsh(e);
                    console.log('>>>>>>>>>>>>>>>>iframe 加载完成<<<<<<<<<<<<<<<<<')
                    
                }}
                onError={err => {
                    console.log(err)
                }}
            />
        </div>
    )
})

export {
    WebView
}

```




