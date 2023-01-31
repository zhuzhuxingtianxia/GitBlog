# js内存空间及this关键词详解

理解js内存空间，对于我们理解很多题目大有帮助，特别是一些面试题目。例如下面这个题目：

```javascript
var a = 20;
var b = a;
b = 30;
// 这时a的值是多少？

var m = { a: 10, b: 20 }
var n = m;
n.a = 15;
// 这时m.a的值是多少
```

很多朋友搞不清楚。

还有一个this方面的面试题目。大体如下：

```javascript
   var a = 20;
    var haoroomsobj = {
        a: 10,
        c: this.a + 20,
        fn: function () {
            return this.a;
        }
    }
console.log(haoroomsobj.c);
console.log(haoroomsobj.fn());
var haoobj=haoroomsobj.fn;
console.log(haoobj())
```

大家看看上面会输出什么？下面我就和大家一起来剖析一下这两个问题。这两个问题涉及到js内存空间及this关键词的相关知识，通过普及这些知识，来顺便解释一下这两个题目。

## js内存空间

### 栈与堆

其实js中没有严格意义区分栈内存和堆内存。但是我在理解的时候还是把他们分开了！我个人是如下理解的：

> 变量对象与基础数据类型（例如：Undefined、Null、Boolean、Number、String）都放在栈（stack）里
>
> 引用数据类型，比如：对象，数组等一般都放在堆（heap）里

例如如下代码：

```javascript
var a1 = 0;   // 变量对象
var a2 = 'this is string'; // 变量对象
var a3 = null; // 变量对象

var b = { m: 20 }; // 变量b存在于变量对象中也可以理解为栈，{m: 20} 作为对象存在于堆内存中
var c = [1, 2, 3]; // 变量c存在于变量对象中也可以理解为栈，[1, 2, 3] 作为对象存在于堆内存中
```

基础数据类型也可以理解为栈里的数据都是按值访问，我们可以直接操作保存在变量中的实际的值。但是在堆内存中，我们不能直接操作对象的堆内存空间。在操作堆里的对象时，**实际上是在操作对象的引用而不是实际的对象**。因此，引用类型的值都是按引用访问的。我们可以地把引用理解为保存在变量对象中的一个地址，这个地址是和堆内存的值是相关联的。

那么上面的面试题目我们可以用如下图来解释：

![enter image description here](http://www.haorooms.com/uploads/images/zhanexample.png)

因此a还是20

第二个题目：

![enter image description here](http://www.haorooms.com/uploads/images/duiexp.png)

复制之后是引用的复制。 和m对应的是同一个对象，因此输出m.a会变成15

## 关于this

函数中的this是难点和重点，我今天主要讲讲函数中的this

我对函数调用总结了如下三点：

```javascript
1、this的指向，是在函数被调用的时候确定的

2、函数调用时，看其是否被某个对象所拥有，假如被某个对象拥有，那么函数中的this，指向的是其拥有的对象。

例如：

    haoroomsobj.fn()

fn()函数被haoroomsobj所拥有，那么fn里面的this，指向的是haoroomsobj

3、如果函数独立调用，那么该函数内部的this，则指向undefined。在非严格模式中，当this指向undefined时，它会被自动指向全局对象。

例如haoobj() 是独立调用，那么haoobj函数里面的this会指向undefined，在非严格模式下面指向的是全局对象。
```

通过上面的三条结论，我们对于函数的调用应该很清楚了，我们再来看下：

```
haoroomsobj.c
```

这个不是我们上面所说的函数情况，因此，还有一个结论：

> 当haoroomsobj 在全局声明时，无论haoroomsobj.c在什么地方调用，这里的this都指向全局对象，
>
> 而当haoroomsobj在函数环境中声明时，这个this指向undefined，在非严格模式下，会自动转向全局对象。

我们再来看下上面的题目吧：

```javascript
console.log(haoroomsobj.c);
console.log(haoroomsobj.fn());
var haoobj=haoroomsobj.fn;
console.log(haoobj())
```

通过上面的结论，我们可以解释：

### console.log(haoroomsobj.c)

haoroomsob是全局声明haoroomsobj.c在非严格模式下面指向的是window全局对象，因此：

```
this.a + 20
```

输出40

### console.log(haoroomsobj.fn());

fn()是haoroomsobj对象下面的函数，这里this指向的是haoroomsobj，因此输出的是10

### console.log(haoobj())

haoobj()函数是独立调用，指向的是全局，因此输出20

## 小结

js内存空间，关键理清堆里面的数据，在操作堆里的对象时，**实际上是在操作对象的引用而不是实际的对象**。

this关键词要理清函数调用，是独立调用还是被某个对象所调用。独立调用在非严格模式下面指向的是全局，被某个对象所调用，this指向的是某个对象！



参考：[js内存空间及this关键词详解 ](https://www.cnblogs.com/itliulei/articles/7079329.html)
