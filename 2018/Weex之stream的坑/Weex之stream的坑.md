# Weex之stream的坑

stream在weex中主要用于用于实现网络请求。
通过阅读stream文档，我们可以了解到一些相关信息：
## 参数options设置请求的一些选项
1. method：HTTP 方法 GET 或是 POST。是一个字符串类型
2. url：请求的 URL，是一个字符串类型
3. headers：HTTP 请求头，是一个对象类型
4. type：响应类型，json,text 或是 jsonp，是一个字符串类型。
     注意⚠️：响应类型需要特别注意，存在平台的差异性。
5. body：HTTP 请求体，是一个字符串类型。
    注意⚠️：body 参数仅支持 string 类型的参数，请勿直接传递 JSON，必须先将其转为字符串。
    
 GET 请求不支持 body 方式传递参数，请使用 url 传参。
 由于服务端的不同，有时候POST请求参数不放在body里，而是使用url 传参。
          
## 回调结果

	•	callback {Function}：响应结果回调，回调函数将收到如下的 response 对象：
	◦	status {number}：返回的状态码
	◦	ok {boolean}：如果状态码在 200~299 之间就为真。
	◦	statusText {string}：状态描述文本
	◦	data {Object | string}: 返回的数据，如果请求类型是 json 和 jsonp，则它就是一个 object ，如果不是，则它就是一个 string，即若是text，返回的则是string字符串而不是对象。测试中发现android端使用json和jsonp都不能正常返回数据，设置text则可以。
	◦	headers {Object}：响应头
	•	progressCallback {Function}：关于请求状态的回调。 这个回调函数将在请求完成后就被调用:
	◦	readyState {number}：当前状态 state:’1’: 请求连接中 opened:’2’: 返回响应头中 received:’3’: 正在加载返回数据
	◦	status {number}：响应状态码.
	◦	length {number}：已经接受到的数据长度. 你可以从响应头中获取总长度
	◦	statusText {string}：状态文本
	◦	headers {Object}：响应头
注意
	•	默认 Content-Type 是 `application/x-www-form-urlencoded`。
	•	如果你需要通过 POST json ， 需要将 Content-Type 设为 `application/json`。
案例分析
GET请求根据官方文档的说明就可以，我们下面主要说下POST的问题！

```
postLoadData: function(){
	var HTTPHeader = {}
	var jsonType = ''
	if (WXEnvironment.platform === 'Web'){
		HTTPHeader = {'Content-Type':'application/json'}
		jsonType = 'json'
	}else{
		HTTPHeader = {'Content-Type':'application/json;charset=utf-8'}
		jsonType = 'jsonp'
	}
	stream.fetch({
		method: 'POST',
		url: this.POST_URL,
		type:jsonType,
		headers:HTTPHeader,
		body:JSON.stringify({app_version:'1.0.0',os_flag:'CG_ios'})
	},function(ret){
		if(!ret.ok){
			modal.toast({
			message: 'request failed',
			duration: 0.3
			})
		}else{
			var result = JSON.stringify(ret.data);
			console.log('post:'+result);
			modal.alert({
			message:result
			},function(vaule){})
		}
	},function(response){
		console.log('get in
		progress:'+response.length);
		console.log('response:'+response);
	})
},
```
打印结果：get in progress:275

response:[object Object]
```
post:{"code":"0","op_flag":"success","versionInfo":{"android_url":"","update_flag":"false","version_info":"数据系统升级","id":"781692632634159104","version":"1.2.0","url":"https://s3.cn-north-1.amazonaws.com.cn/h5.taocai.mobi/down/pur/manifest.plist"},"info":"操作成功"}
```
然后我们使用同样的方法，换个接口和参数试试！

```
stream.fetch({
	method:'POST',
	url: this.POST_Model_URL,
	type:jsonType,
	headers:HTTPHeader,
	body:JSON.stringify({requestmodel:{os_flay:'ios'}})
	// body:JSON.stringify({app_version:'1.0.0',os_flay:'ios'})
})
```

但是这个接口就会报错！请求不到数据。

再次重新修改：
```
postLoadData: function(){
	var HTTPHeader = {}
	var jsonType = ''
	if (WXEnvironment.platform === 'Web'){
		HTTPHeader = {'Content-Type':'application/json'}
		jsonType = 'jsonp'//出现跨域问题则使用jsonp
		//jsonp会把请求转化成get请求，如果不支持get则可尝试
		
	}else{
		HTTPHeader = {'Content-Type':'application/json;charset=utf-8'}
		jsonType = 'jsonp'
	}
	stream.fetch({
		method: 'POST',
		//native端需要设置encodeURI编码,否则依然会请求出错，就是这么坑！！
		url: this.POST_Model_URL+'?'+'requestmodel='+encodeURI(JSON.stringify({os_flag:'ios'})),
		type:jsonType,
		headers:HTTPHeader
		//body:JSON.stringify({app_version:'1.0.0',os_flag:'CG_ios'})
	},function(ret){
		if(!ret.ok){
			modal.toast({
			message: 'requset fail',
			duration: 0.3
			})
		}else{
			var result = JSON.stringify(ret.data);
			console.log('post:'+result);
			modal.alert({
			message:result
			},function(vaule){})
		}
	},function(response){
		console.log('get in
		progress:'+response.length);
		console.log('response:'+response);
		})
},
```

打印：
```
post:{"op_flag":"success","info":"操作成功","code":"0","versionInfo":{"android_url":"","update_flag":"false","version_info":"1、炎炎夏日，上淘菜猫买菜，不用去菜场\r\n2、部分区域消费即送高端赠品","id":"783953830859698176","version":"3.2.11","url":"http://h5.taocaimall.net/TCM-taocaimall.html"}}
```
这样就可获取到数据了！仔细的同学会发现
get in progress:即response的回调式没有执行的！不过这已经不重要了！

有写地方还是具有平台差异性的，这还需要在实际的开发中去注意这些问题！
在post请求中android的返回类型是一个text的字符串：
```
if(WXEnvironment.platform.toLowerCase() === 'android'){
HTTPHeader = {'Content-Type':'application/json'}
jsonType = 'text' //使用json或jsonp都不能正常的返回数据。而且android默认是text模式。
}
```
具体可[参考demo](https://github.com/ZJWeex/day04)！



