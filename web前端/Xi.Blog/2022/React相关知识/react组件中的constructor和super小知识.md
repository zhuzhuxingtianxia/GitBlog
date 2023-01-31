# react组件中的constructor和super小知识

> 个人心得：不管子类写不写constructor，在new实例的过程都会给补上constructor。constructor如果不写，无法声明state。如果写了constructor不实现super，获取不到this。constructor中的props不实现不会影响其他生命周期的使用，只会影响constructor构造函数里的使用。

## 1、react中用class申明的类一些小知识

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180623235555205-1616492599.png)

如上图：类Child是通过class关键字申明，并且继承于类React。

A、Child的类型是？  **typeof Child  === 'function'** ， 其实就相当于ES5用function申明的构造函数  function Child() { //申明构造函数 }

B、Child类调用时候( new Child() )，**会优先执行，并且自动执行Child的constructor函数**。

```
constructor() {
   console.log('执行了constructor')
       return 'hah'
   }

   getName() {
       console.log('执行了方法')
   }
}
var dd = new Person();
console.log(dd)
```

打印如下：

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624000545830-1866124997.png)

3、Child类中的this？  this指向Child的实例，相当于 new Child()  那么它们完全相等吗？ **不是的，react中的this是在new Child()基础上进行了包裹（下图）**。

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624001457100-1991741326.png)

​       上图为new Child（）   下图为 Child中的this

 ![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624001607888-2038033623.png)

**结论：****this是在new Child()基础上进行了包裹，包含了一些react内部方法，**

**同时组件中使用Child类( <div> <Child /> </div> )，可以看成 new Child（） + react包裹。（细节待追究。。。）**

 

## 2、组件中的constructor是否有必要？ 如果没有呢？？作用呢？？？

ES6的知识补充： http://es6.ruanyifeng.com/#docs/class-extends  如下：

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624015759191-1341853377.png)

 

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
class ColorPoint extends Point {
}

// 等同于 
class ColorPoint extends Point {
  constructor(...args) {
    super(...args);
  }
}
// 可见没有写constructor，在执行过程中会自动补上
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

**由ES6的继承规则得知，不管子类写不写constructor，在new实例的过程都会给补上constructor。**

**所以：constructor钩子函数并不是不可缺少的，子组件可以在一些情况略去**。

 

**接下来，继续看下有没有constructor钩子函数有什么区别：**

 

**A、先看有无constructor钩子函数的 this.constructor** 

   有constructor钩子函数的 this.constructor 

 ![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624005200299-97647880.png)

   无constructor钩子函数的 this.constructor 

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624005249326-760117579.png)

如果**能看细节的话，会得知 有constructor钩子函数时候，Child类会多一个constructor方法**。

 

**B、再看有无先看有无constructor钩子函数的 this，也就是组件实例**。

   有constructor钩子函数的 this实例。

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624005802751-1314295343.png)

   无constructor钩子函数的 this实例。

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624005836954-1288481649.png)

会得知 **有constructor钩子函数时候，可以定义state，如果用户不定义state的话，有无constructor钩子函数时候没有区别**。

 

**结论： 如果组件要定义自己的state初始状态的话，需要写在\**constructor钩子函数中，\****

***\*如果用户不使用state的话，纯用props接受参数，有没有\*\*\*\*constructor钩子函数都可以，可以不用\*\*\*\*\*\*\*\*constructor钩子函数。\*\*\*\*\*\*\*\*\*\*\*\*\****

***\**\*\*\*再者如果\*\*\*\*不使用state，那么为什么不使用 无状态组件（建议使用） 呢？？？\*\*\*\*\*\*\*\*\****

 

## 3、super中的props是否必要？ 作用是什么？？

有的小伙伴每次写组件都会习惯性在constructor和super中写上props，那么这个是必要的吗？？

如图：  ![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624002245498-133077391.png)

 

首先要明确很重要的一点就是：

**可以不写constructor，一旦写了constructor，就必须在此函数中写super(),**

**此时组件才有自己的this，在组件的全局中都可以使用this关键字，**

**否则如果只是constructor 而不执行 super() 那么以后的this都是错的！！！**

来源ES6 ： http://es6.ruanyifeng.com/#docs/class-extends  

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624011921369-1337302529.png)

 

 但是super中必须写参数props吗？？  答案是不一定，先看代码：

有props：

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624012646344-1650230433.png)

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624012721420-1438956371.png)

 

无props：

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624012912272-763738012.png)

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624012955198-135846386.png)

 

**可以得出结论：****当想在constructor中使用this.props的时候，super需要加入(props)，**

**此时用props也行，用this.props也行，他俩都是一个东西。（不过props可以是任意参数，this.props是固定写法）**。

如图：

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624013417239-947679704.png)

 

 **如果在custructor生命周期不使用 this.props或者props时候，可以不传入props**。

![img](https://images2018.cnblogs.com/blog/905482/201806/905482-20180624013810215-571587924.png)

 

接上：如果constructor中不通过super来接收props，在其他生命周期，

诸如componentWillMount、componentDidMount、render中能直接使用this.props吗？？

结论：可以的，**react在除了constructor之外的生命周期已经传入了this.props了，完全不受super(props)的影响**。

 

**所以super中的props是否接收，只能影响constructor生命周期能否使用this.props，其他的生命周期已默认存在this.props**

参考：https://www.cnblogs.com/faith3/p/9219446.html