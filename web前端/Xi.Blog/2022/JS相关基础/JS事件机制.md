# JS事件机制

> 个人心得：三个事件都是可控的，熟练掌握事件机制原理可以以更小的代价去处理监听事件。如在React中的事件机制是经过二次包装JS事件机制实现的，统一整合了事件处理在document层处理回调。

js的事件机制和flash差不多，都是三个阶段：捕获、目标和冒泡

#### 1.事件冒泡

微软提出了名为事件冒泡的事件流。事件冒泡可以形象地比喻为把一颗石头投入水中，泡泡会一直从水底冒出水面。也就是说，事件会从最内层的元素开始发生，一直向上传播，直到document对象。

因此、在事件冒泡的概念下发生click事件的顺序应该是如**p -> div -> body -> html -> document**

#### 2.事件捕获

网景提出另一种事件流名为事件捕获与事件冒泡相反，事件会从最外层开始发生，直到最具体的元素。

在事件捕获的概念下发生click事件的顺序应该是**document -> html -> body -> div -> p**

#### 3.W3C事件阶段(event phase)：

当一个DOM事件被触发的时候，他并不是只在它的起源对象上触发一次，而是会经历三个不同的阶段。简而言之：事件一开始从文档的根节点流向目标对象(捕获阶段)，然后在目标对向上被触发(目标阶段)，之后再回溯到文档的根节点(冒泡阶段)如图所示（图片来自W3C）：

[![image](https://images0.cnblogs.com/blog/707050/201507/181443001888733.png)](http://images0.cnblogs.com/blog/707050/201507/181442594707820.png)

 

w3c事件的传递是先捕获从外到内-》目标-》冒泡逆向回流，一般情况下我们只在冒泡阶段处理回调，addEventListener有三个参数，第一个是事件类型，第二个是回调处理，第三个就是是否在捕获阶段处理

举个例子(不考虑IE678这种大哥大式的手机)

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
　　　　　　　var parent = document.getElementById("mydiv");
            parent.addEventListener("click",function(){
                console.log("parent");
            },false);
            var child = document.getElementById("child");
            child.addEventListener("click",function(){
                console.log("child");
            },false);
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

点击child输出：

![img](https://img2018.cnblogs.com/blog/1365095/201811/1365095-20181127110703720-501301354.png)

如果把最后一个参数改成true，则输出

![img](https://img2018.cnblogs.com/blog/1365095/201811/1365095-20181127110807757-1125382355.png)

一般情况下我们不在捕获阶段做处理回调，只在目标阶段做处理！有些特殊情况比如禁用child的事件等需要可能会用到！event.preventDefault()禁用事件的默认处理，比如鼠标点击输入文本框文本框会获得焦点的默认处理，event.stopPropagation()阻止事件继续传递，该方法在目标处理结束后事件传递即停止，事件不会继续捕获或冒泡，这个方法可以避免多个父节点添加同一事件出现多处理的弊端！

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
　　　　　　  var parent = document.getElementById("mydiv");
            parent.addEventListener("click",function(evt){
                evt.stopPropagation();
                console.log("parent");
            },true);
            var child = document.getElementById("child");
            child.addEventListener("click",function(evt){
                console.log("child");
            },true);
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

点击child输出：

![img](https://img2018.cnblogs.com/blog/1365095/201811/1365095-20181127112345946-267179824.png)

因为事件是在捕获阶段触发的，所以事件在parent就停止传递了，child没有接收事件

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
 　　　　　　 var parent = document.getElementById("mydiv");
            parent.addEventListener("click",function(evt){
                console.log("parent");
            },false);
            var child = document.getElementById("child");
            child.addEventListener("click",function(evt){
                evt.stopPropagation();
                console.log("child");
            },false);
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

点击child输出

![img](https://img2018.cnblogs.com/blog/1365095/201811/1365095-20181127112623913-1078864233.png)

这个是在目标阶段处理的，所以parent没有接收到事件！

总结下来，js事件的三个阶段几乎都是可控的，这也给开发带来很多方便！

### 事件代理

事件代理用到了两个在JavaSciprt事件中两个特性：事件冒泡以及目标元素。使用事件代理，我们可以把事件处理器添加到一个元素上，等待一个事件从它的子级元素里冒泡上来，并且可以得知这个事件是从哪个元素开始的。

```
<div id="mydiv"><div id="child"><div id="child1">点击我！</div></div></div>
　　　　　　  var parent = document.getElementById("mydiv");
            parent.addEventListener("click",function(evt){
                console.log(evt.target.id);
            },false);
```

知道点击child1，child以及mydiv分别输出什么呢？

![img](https://img2018.cnblogs.com/blog/1365095/201811/1365095-20181127113811523-940641572.png)

其实上面的事件代理解释没怎么看懂，然后自己测试了下发现了神奇的领悟，也就是说parent的事件处理只能代理其当前最深层次的child，这就是为什么点击child1，没有输出child的原因，这刚好也是事件的目标阶段的target，这是个很好的机制，假如一个parent有很多孩子都需要监听事件，那么只需给parent添加事件监听即可，通过evt.target来判断当前事件的child！这个其实在as3中经常用到，但是flash的死亡标志着以前做flash的大部分人不得不面向转行，而js恰好与flash最能完美匹配！

### 事件类型

之前写过一篇自定义事件的随笔，其中的createEvent方法有点意思，这里就来看下这些事件的一个大致关系

事件类型有：UI（用户界面）事件，用户与页面上元素交互时触发 ；焦点事件：当元素获得或失去焦点时触发 ； 文本事件：当在文档中输入文本时触发；键盘事件：当用户通过键盘在页面上执行操作时触发；鼠标事件：当用户通过鼠标在页面上执行操作时触发；滚轮事件：当使用鼠标滚轮（或类似设备）时触发。它们之间是继承的关系，如下图：

[![936a856eb8d9456ebf60b89d2cdc0dfc](https://images0.cnblogs.com/blog/707050/201507/181443007822619.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443005489391.jpg)

1.

[![a7275e5c067e4af6a2d1c5c5d49dbdee](https://images0.cnblogs.com/blog/707050/201507/181443016261962.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443011417575.jpg)

常用：window、image。例如设置默认的图片：

```
<img src="photo" alt="photo.jpg" onerror="this.src='defualt.jpg'">
```

2.

[![23f6429ea5424d3db6032c3f92ffd591](https://images0.cnblogs.com/blog/707050/201507/181443024858831.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443021412403.jpg)

3.

[![268737333e2e44c4b6de2a14618409c9[4\]](https://images0.cnblogs.com/blog/707050/201507/181443030489960.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443027984504.jpg)

4.

[![af69ef8af9be4843973c2474dae0888a](https://images0.cnblogs.com/blog/707050/201507/181443039077830.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443033764160.jpg)

5.

[![21a63f831af24baabf5d41bd8afed5fd](https://images0.cnblogs.com/blog/707050/201507/181443047353944.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443042203503.jpg)

6.

[![1e921fb859e74a7ea37fb0e5f6e2e72e](https://images0.cnblogs.com/blog/707050/201507/181443053133601.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443050325387.jpg)

> **MouseEvent 顺序**
> 从元素A上方移过
> -mousemove-> mouseover (A) ->mouseenter (A)-> mousemove (A) ->mouseout (A) ->mouseleave (A)
> **点击元素**
> -mousedown-> [mousemove]-> mouseup->click

7.

[![0c7bb276b6fc441190a0637c808ea23f](https://images0.cnblogs.com/blog/707050/201507/181443058601501.jpg)](http://images0.cnblogs.com/blog/707050/201507/181443056268272.jpg)