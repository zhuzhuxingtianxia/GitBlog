# 判断JS数据类型的方法

> 个人心得：判断非Object类型用typeof，判断Object可以用constructor(但要注意继承问题，如有继承问题可以用constructor，文中有说明)和instanceof。判断对象中的Array类型可以用instanseof(用它来判断Object会有误差)，通用判断方式用Object.prototype.toString和jquery.type()

```javascript
typeof "Hello" // "string"
typeof 42      // "number"
typeof true    // "boolean"
typeof undefined // "undefined"
typeof null    // "object" （注意：null 的类型在这里表现为 "object"，这是 JavaScript 的历史遗留问题）
typeof {}      // "object"
typeof []      // "object" （数组在 typeof 运算符下也表现为 "object"）
typeof function(){} // "function"

var str = new String("Hello");
str instanceof String; // true
[1, 2, 3] instanceof Array; // true
function MyClass() {}
var obj = new MyClass();
obj instanceof MyClass; // true

Object.prototype.toString.call("Hello"); // "[object String]"
Object.prototype.toString.call(42);       // "[object Number]"
Object.prototype.toString.call(true);    // "[object Boolean]"
Object.prototype.toString.call(undefined); // "[object Undefined]"
Object.prototype.toString.call(null);     // "[object Null]"
Object.prototype.toString.call([]);       // "[object Array]"
Object.prototype.toString.call(function(){}); // "[object Function]"

```

在 ECMAScript 规范中，共定义了 7 种数据类型，分为 基本类型 和 引用类型 两大类，如下所示：

> **基本类型**：String、Number、Boolean、Symbol、Undefined、Null 
>
> **引用类型**：Object

基本类型也称为简单类型，由于其占据空间固定，是简单的数据段，为了便于提升变量查询速度，将其存储在栈中，即按值访问。

引用类型也称为复杂类型，由于其值的大小会改变，所以不能将其存放在栈中，否则会降低变量查询速度，因此，其值存储在堆(heap)中，而存储在变量处的值，是一个指针，指向存储对象的内存处，即按址访问。引用类型除 Object 外，还包括 Function 、Array、RegExp、Date 等等。

鉴于 ECMAScript 是松散类型的，因此需要有一种手段来检测给定变量的数据类型。对于这个问题，JavaScript 也提供了多种方法，但遗憾的是，不同的方法得到的结果参差不齐。

下面介绍常用的5种方法，并对各个方法存在的问题进行简单的分析。

### **1、**最常见的判断方法：typeof

typeof用的比较多的时候，是判断某个全局变量在不在，假如某个页面定义了一个全局变量。假如你做如下判断：

```javascript
//haorooms是全局变量
if(haorooms!=undefined){
}//js会报错，说"Uncaught ReferenceError: haorooms is not defined"
```

解决的方法是我们如下写：

var a = {key a value :1}





```javascript
if(typeof haorooms!=undefined){
}
```

用了typeof之后，就不会报错了！这是typeof的应用之一!

typeof 是一个操作符，其右侧跟一个一元表达式，并返回这个表达式的数据类型。返回的结果用该类型的字符串(全小写字母)形式表示，包括以下 7 种：number、boolean、symbol、string、object、undefined、function 等。

```javascript
typeof ''; // string 有效
typeof 1; // number 有效
typeof Symbol(); // symbol 有效
typeof true; //boolean 有效
typeof undefined; //undefined 有效
typeof null; //object 无效
typeof [] ; //object 无效
typeof new Function(); // function 有效
typeof new Date(); //object 无效
typeof new RegExp(); //object 无效
```

有些时候，typeof 操作符会返回一些令人迷惑但技术上却正确的值：

- 对于基本类型，除 null 以外，均可以返回正确的结果。
- 对于引用类型，除 function 以外，一律返回 object 类型。
- 对于 null ，返回 object 类型。
- 对于 function 返回  function 类型。

其中，null 有属于自己的数据类型 Null ， 引用类型中的 数组、日期、正则 也都有属于自己的具体类型，而 typeof 对于这些类型的处理，只返回了处于其原型链最顶端的 Object 类型，没有错，但不是我们想要的结果。

**对于null->"object"的问题，仅仅typeof无解，记住有这么个坑即可。**

**而关于array->"object"的问题，建议使用：`Array.isArray([]) // true`来判断即可。**





### **2、**判断已知对象类型的方法： instanceof

可以用其判断是否是数组。

```javascript
var haorooms=[];
console.log(haorooms instanceof Array) //返回true 
```

instanceof 是用来判断 A 是否为 B 的实例，表达式为：A instanceof B，如果 A 是 B 的实例，则返回 true,否则返回 false。 在这里需要特别注意的是：**instanceof 检测的是原型**，我们用一段伪代码来模拟其内部执行过程：

```javascript
instanceof (A,B) = {
    var L = A.__proto__;
    var R = B.prototype;
    if(L === R) {
        // A的内部属性 __proto__ 指向 B 的原型对象
        return true;
    }
    return false;
}
```

从上述过程可以看出，当 A 的 __proto__ 指向 B 的 prototype 时，就认为 A 就是 B 的实例，我们再来看几个例子：

```javascript
[] instanceof Array; // true
{} instanceof Object;// true
new Date() instanceof Date;// true
 
function Person(){};
new Person() instanceof Person;
 
[] instanceof Object; // true
new Date() instanceof Object;// true
new Person instanceof Object;// true
```

我们发现，虽然 instanceof 能够判断出 [ ] 是Array的实例，但它认为 [ ] 也是Object的实例，为什么呢？

我们来分析一下 [ ]、Array、Object 三者之间的关系：

从 instanceof 能够判断出 [ ].__proto__  指向 Array.prototype，而 Array.prototype.__proto__ 又指向了Object.prototype，最终 Object.prototype.__proto__ 指向了null，标志着原型链的结束。因此，[]、Array、Object 就在内部形成了一条原型链：

![img](https://images2015.cnblogs.com/blog/849589/201601/849589-20160112232510850-2003340583.png)

从原型链可以看出，[] 的 __proto__  直接指向Array.prototype，间接指向 Object.prototype，所以按照 instanceof 的判断规则，[] 就是Object的实例。依次类推，类似的 new Date()、new Person() 也会形成一条对应的原型链 。因此，**instanceof 只能用来判断两个对象是否属于实例关系**， 而不能判断一个对象实例具体属于哪种类型。

instanceof 操作符的问题在于，它假定只有一个全局执行环境。如果网页中包含多个框架，那实际上就存在两个以上不同的全局执行环境，从而存在两个以上不同版本的构造函数。如果你从一个框架向另一个框架传入一个数组，那么传入的数组与在第二个框架中原生创建的数组分别具有各自不同的构造函数。

```javascript
var iframe = document.createElement('iframe');
document.body.appendChild(iframe);
xArray = window.frames[0].Array;
var arr = new xArray(1,2,3); // [1,2,3]
arr instanceof Array; // false
```

针对数组的这个问题，ES5 提供了 Array.isArray() 方法 。该方法用以确认某个对象本身是否为 Array 类型，而不区分该对象在哪个环境中创建。

```javascript
if (Array.isArray(value)){
   //对数组执行某些操作
}
```

Array.isArray() 本质上检测的是对象的 [[Class]] 值，[[Class]] 是对象的一个内部属性，里面包含了对象的类型信息，其格式为 [object Xxx] ，Xxx 就是对应的具体类型 。对于数组而言，[[Class]] 的值就是 [object Array] 。

```javascript
alert(c instanceof Array) ---------------> true
alert(d instanceof Date)
alert(f instanceof Function) ------------> true
alert(f instanceof function) ------------> false
```

**注意：instanceof 后面一定要是对象类型，并且大小写不能错，该方法适合一些条件选择或分支。**　

### **3、**根据对象的constructor判断： constructor

alert(c.constructor === Array) ----------> true
alert(d.constructor === Date) -----------> true
alert(e.constructor === Function) -------> true

注意： constructor 在类继承时会出错

eg：

```javascript
function A(){};
function B(){};
A.prototype = new B(); //A继承自B
var aObj = new A();
alert(aobj.constructor === B) -----------> true;
alert(aobj.constructor === A) -----------> false;
```

而instanceof方法不会出现该问题，对象直接继承和间接继承的都会报true：

```javascript
alert(aobj instanceof B) ----------------> true;
alert(aobj instanceof A) ----------------> true;
```

言归正传，解决construtor的问题通常是让对象的constructor手动指向自己：

```javascript
aobj.constructor = A; //将自己的类赋值给对象的constructor属性
alert(aobj.constructor === A) -----------> true;
alert(aobj.constructor === B) -----------> false; //基类不会报true了;
```

### **4、繁琐且通用：toString**

toString() 是 Object 的原型方法，调用该方法，默认返回当前对象的 [[Class]] 。这是一个内部属性，其格式为 [object Xxx] ，其中 Xxx 就是对象的类型。

对于 Object 对象，直接调用 toString() 就能返回 [object Object] 。而对于其他对象，则需要通过 call / apply 来调用才能返回正确的类型信息。

```javascript
Object.prototype.toString.call('') ;   // [object String]
Object.prototype.toString.call(1) ;    // [object Number]
Object.prototype.toString.call(true) ; // [object Boolean]
Object.prototype.toString.call(Symbol()); //[object Symbol]
Object.prototype.toString.call(undefined) ; // [object Undefined]
Object.prototype.toString.call(null) ; // [object Null]
Object.prototype.toString.call(new Function()) ; // [object Function]
Object.prototype.toString.call(new Date()) ; // [object Date]
Object.prototype.toString.call([]) ; // [object Array]
Object.prototype.toString.call(new RegExp()) ; // [object RegExp]
Object.prototype.toString.call(new Error()) ; // [object Error]
Object.prototype.toString.call(document) ; // [object HTMLDocument]
Object.prototype.toString.call(window) ; //[object global] window 是全局对象 global 的引用
```



### **5、无敌万能的方法jquery.type()**

如果对象是undefined或null，则返回相应的“undefined”或“null”。

```javascript
jQuery.type( undefined ) === "undefined"
jQuery.type() === "undefined"
jQuery.type( window.notDefined ) === "undefined"
jQuery.type( null ) === "null"
```

如果对象有一个内部的[[Class]]和一个浏览器的内置对象的 [[Class]] 相同，我们返回相应的 [[Class]] 名字。 (有关此技术的更多细节。 )

```javascript
jQuery.type( true ) === "boolean"
jQuery.type( 3 ) === "number"
jQuery.type( "test" ) === "string"
jQuery.type( function(){} ) === "function"
jQuery.type( [] ) === "array"
jQuery.type( new Date() ) === "date"
jQuery.type( new Error() ) === "error" // as of jQuery 1.9
jQuery.type( /test/ ) === "regexp"
```

其他一切都将返回它的类型“object”。

**总结：通常情况下用typeof 判断就可以了，遇到预知Object类型的情况可以选用instanceof或constructor方法,实在没辙就使用$.type()方法。**

参考：https://www.jb51.net/article/102972.htm

​		   https://www.cnblogs.com/onepixel/p/5126046.html
