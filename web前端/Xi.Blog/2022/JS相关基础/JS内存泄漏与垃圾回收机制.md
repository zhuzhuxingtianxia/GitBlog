# JS内存泄漏与垃圾回收机制

> 个人心得：目前虽然绝大部分都是自动回收，但应明白有些时候还是应该注意内存泄漏问题，标记清除的处理机制需要了解内存释放的时机和一个变量的声明周期，比如一个函数执行完成后就是“脱离环境”，完成了它的生命周期。

### **什么是内存泄漏？**

程序的运行需要[内存](https://so.csdn.net/so/search?q=内存&spm=1001.2101.3001.7020)，只要程序提出要求，操作系统或者运行是就必须供给内存。

对于持续运行的服务进程，必须及时释放内存，否则，内存占用越来越高，轻则影响系统性能，重则导致进程崩溃。

不再用到的内存，没有及时释放，就叫做内存泄漏。

有些语言（比如c语言）必须手动释放内存，程序员负责内存管理。

这很麻烦，所以大多数语言提供自动内存管理，减轻程序员的负担，这被称为"[垃圾回收](https://so.csdn.net/so/search?q=垃圾回收&spm=1001.2101.3001.7020)机制"。

### **javascript垃圾回收机制原理：**

解决内存的泄露，垃圾回收机制会定期（周期性）找出那些不再用到的内存（变量），然后释放其内存。

现在各大浏览器通常采用的垃圾回收机制有两种方法：**标记清除，引用计数**。

### 标记清除：

js中最常用的垃圾回收方式就是标记清除。当变量进入环境时，例如，在一个函数中声明一个变量，就将这个变量标记为"进入环境"，从逻辑上讲，永远不能释放进入环境变量所占用的内存，因为只要执行流进入相应的环境，就可能会用到它们。而当变量离开环境时，则将其标记为"离开环境"。

```javascript
function test(){
    var a = 10;    //被标记"进入环境"
    var b = "hello";    //被标记"进入环境"
}
test();    //执行完毕后之后，a和b又被标记"离开环境"，被回收
```

垃圾回收机制在运行的时候会给存储再内存中的所有变量都加上标记（可以是任何标记方式），然后，它会去掉处在环境中的变量及被环境中的变量引用的变量标记（闭包）。而在此之后剩下的带有标记的变量被视为准备删除的变量，原因是环境中的变量已经无法访问到这些变量了。最后垃圾回收机制到下一个周期运行时，将释放这些变量的内存，回收它们所占用的空间。

到目前为止，IE、Firefox、Opera、Chrome、Safari的js实现使用的都是标记清除的垃圾回收策略或类似的策略，只不过垃圾收集的时间间隔互不相同。

### 引用计数：

语言引擎有一张"引用表"，保存了内存里面所有资源（通常是各种值）的引用次数。如果一个值的引用次数是0，就表示这个值不再用到了，因此可以将这块内存释放。

![img](http://www.ruanyifeng.com/blogimg/asset/2017/bg2017041703.png)

上图中，左下角的两个值，没有任何引用，所以可以释放。

如果一个值不再需要了，引用数却不为0，垃圾回收机制无法释放这块内存，从而导致内存泄漏。

```html
const arr = [1,2,3,4];
console.log("hello world");
```

上面的代码中，数组[1,2,3,4]是一个值，会占用内存。变量arr是仅有的对这个值的引用，因此引用次数为1。尽管后面的代码没有用到arr，它是会持续占用内存。

如果增加一行代码，解除arr对[1,2,3,4]引用，这块内存就可以被垃圾回收机制释放了。

```javascript
let arr = [1,2,3,4];
console.log("hello world");
arr = null;
```

上面代码中，arr重置为null，就解除了对[1，2，3，4]的引用，引用次数变成了0，内存就可以释放出来了。

因此，并不是说有了垃圾回收机制，程序员就轻松了。你还是需要关注内存占用：那些很占空间的值，一旦不再用到，你必须检查是否还存在对它们的引用。如果是的话，就必须手动解除引用

## 内存泄漏的识别方法

怎样可以观察到内存泄漏呢？

[经验法则](https://www.toptal.com/nodejs/debugging-memory-leaks-node-js-applications)是，如果连续五次垃圾回收之后，内存占用一次比一次大，就有内存泄漏。这就要求实时查看内存占用。

### 1 浏览器

Chrome 浏览器查看内存占用，按照以下步骤操作。

![img](http://www.ruanyifeng.com/blogimg/asset/2017/bg2017041704.png)

> 1. 打开开发者工具，选择 Timeline 面板
> 2. 在顶部的`Capture`字段里面勾选 Memory
> 3. 点击左上角的录制按钮。
> 4. 在页面上进行各种操作，模拟用户的使用情况。
> 5. 一段时间后，点击对话框的 stop 按钮，面板上就会显示这段时间的内存占用情况。

如果内存占用基本平稳，接近水平，就说明不存在内存泄漏。

![img](http://www.ruanyifeng.com/blogimg/asset/2017/bg2017041705.png)

反之，就是内存泄漏了。

![img](http://www.ruanyifeng.com/blogimg/asset/2017/bg2017041706.png)

### 2 命令行

命令行可以使用 Node 提供的[`process.memoryUsage`](https://nodejs.org/api/process.html#process_process_memoryusage)方法。

> ```javascript
> console.log(process.memoryUsage());
> // { rss: 27709440,
> //  heapTotal: 5685248,
> //  heapUsed: 3449392,
> //  external: 8772 }
> ```

`process.memoryUsage`返回一个对象，包含了 Node 进程的内存占用信息。该对象包含四个字段，单位是字节，[含义](http://stackoverflow.com/questions/12023359/what-do-the-return-values-of-node-js-process-memoryusage-stand-for)如下。

![img](http://www.ruanyifeng.com/blogimg/asset/2017/bg2017041702-1.png)

> - rss（resident set size）：所有内存占用，包括指令区和堆栈。
> - heapTotal："堆"占用的内存，包括用到的和没用到的。
> - heapUsed：用到的堆的部分。
> - external： V8 引擎内部的 C++ 对象占用的内存。

判断内存泄漏，以`heapUsed`字段为准。

## WeakMap

前面说过，及时清除引用非常重要。但是，你不可能记得那么多，有时候一疏忽就忘了，所以才有那么多内存泄漏。

最好能有一种方法，在新建引用的时候就声明，哪些引用必须手动清除，哪些引用可以忽略不计，当其他引用消失以后，垃圾回收机制就可以释放内存。这样就能大大减轻程序员的负担，你只要清除主要引用就可以了。

ES6 考虑到了这一点，推出了两种新的数据结构：[WeakSet](http://es6.ruanyifeng.com/#docs/set-map%23WeakSet) 和 [WeakMap](http://es6.ruanyifeng.com/#docs/set-map%23WeakMap)。它们对于值的引用都是不计入垃圾回收机制的，所以名字里面才会有一个"Weak"，表示这是弱引用。

![img](http://www.ruanyifeng.com/blogimg/asset/2017/bg2017041707.jpg)

下面以 WeakMap 为例，看看它是怎么解决内存泄漏的。

> ```javascript
> const wm = new WeakMap();
> const element = document.getElementById('example');
> wm.set(element, 'some information');
> wm.get(element) // "some information"
> ```

上面代码中，先新建一个 Weakmap 实例。然后，将一个 DOM 节点作为键名存入该实例，并将一些附加信息作为键值，一起存放在 WeakMap 里面。这时，WeakMap 里面对`element`的引用就是弱引用，不会被计入垃圾回收机制。

也就是说，DOM 节点对象的引用计数是`1`，而不是`2`。这时，一旦消除对该节点的引用，它占用的内存就会被垃圾回收机制释放。Weakmap 保存的这个键值对，也会自动消失。

基本上，如果你要往对象上添加数据，又不想干扰垃圾回收机制，就可以使用 WeakMap。

## WeakMap 示例

WeakMap 的例子很难演示，因为无法观察它里面的引用会自动消失。此时，其他引用都解除了，已经没有引用指向 WeakMap 的键名了，导致无法证实那个键名是不是存在。

我一直想不出办法，直到有一天贺师俊老师[提示](https://github.com/ruanyf/es6tutorial/issues/362#issuecomment-292109104)，如果引用所指向的值占用特别多的内存，就可以通过`process.memoryUsage`方法看出来。

根据这个思路，网友 vtxf 补充了下面的[例子](https://github.com/ruanyf/es6tutorial/issues/362#issuecomment-292451925)。

首先，打开 Node 命令行。

> ```ruby
> $ node --expose-gc
> ```

上面代码中，`--expose-gc`参数表示允许手动执行垃圾回收机制。

然后，执行下面的代码。

> ```javascript
> // 手动执行一次垃圾回收，保证获取的内存使用状态准确
> > global.gc(); 
> undefined
> 
> // 查看内存占用的初始状态，heapUsed 为 4M 左右
> > process.memoryUsage();
> { rss: 21106688,
>   heapTotal: 7376896,
>   heapUsed: 4153936,
>   external: 9059 }
> 
> > let wm = new WeakMap();
> undefined
> > let b = new Object();
> undefined
> > global.gc();
> undefined
> 
> // 此时，heapUsed 仍然为 4M 左右
> > process.memoryUsage(); 
> { rss: 20537344,
>   heapTotal: 9474048,
>   heapUsed: 3967272,
>   external: 8993 }
> 
> // 在 WeakMap 中添加一个键值对，
> // 键名为对象 b，键值为一个 5*1024*1024 的数组  
> > wm.set(b, new Array(5*1024*1024));
> WeakMap {}
> 
> // 手动执行一次垃圾回收
> > global.gc();
> undefined
> 
> // 此时，heapUsed 为 45M 左右
> > process.memoryUsage(); 
> 
> { rss: 62652416,
>   heapTotal: 51437568,
>   heapUsed: 45911664,
>   external: 8951 }
> 
> // 解除对象 b 的引用  
> > b = null;
> null
> 
> // 再次执行垃圾回收
> > global.gc();
> undefined
> 
> // 解除 b 的引用以后，heapUsed 变回 4M 左右
> // 说明 WeakMap 中的那个长度为 5*1024*1024 的数组被销毁了
> 
> > process.memoryUsage(); 
> 
> { rss: 20639744,
>   heapTotal: 8425472,
>   heapUsed: 3979792,
>   external: 8956 }
> ```

上面代码中，只要外部的引用消失，WeakMap 内部的引用，就会自动被垃圾回收清除。由此可见，有了它的帮助，解决内存泄漏就会简单很多。

参考：https://blog.csdn.net/qq_17550381/article/details/81126809

