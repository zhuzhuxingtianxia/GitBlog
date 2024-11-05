# Web相关

## js中闭包、异步编程、事件循环的概念，并给出实际应用的例子

* 闭包：允许函数捕获其作用域外的变量
	* 数据封装：闭包可以用来创建私有变量，使外部无法直接访问
	* 记忆化：可以存储计算结果，提高性能
* 异步编程是一种允许程序在等待某些操作完成时继续执行其他任务的方法。js中可以通过回调、promise、async/await实现
	* 网络请求，不阻塞UI渲染
	* 事件处理，响应用户触摸、输入时，避免卡顿
* 事件循环是js处理异步操作的机制，能使其在单线程中执行异步代码。它通过调用栈和事件队列协作，管理任务的执行顺序。
	* 用户交互：保证在用户操作界面时不会出现阻塞
	* 定时任务：如定时器和动画

## 如何利用浏览器缓存提升性能

* 设置缓存策略
  * 利用http头信息来控制资源的缓存行为，请求size是memory cache 和 disk cache就表示，浏览器并没有向服务器发送请求，而是直接读取了本地的缓存资源文件。

  * 缓存过程分为[强缓存和协商缓存](./Xi.Blog/2022/计算机及浏览器基础/浏览器的缓存机制.md)
  * 强缓存不会向服务器发送请求，直接从缓存中读取资源，请求头需设置`Cache-Control`并设置缓存时长，在这个时间内都读取缓存即使服务器资源文件发生变化。
	* 协商缓存就是强缓存失效后，浏览器携带缓存标识向服务器发起请求，由服务器根据缓存标识决定是否使用缓存的过程。请求头通过设置`Last-Modified`或者`ETag`实现
* 资源版本化
	* 对静态资源版本化，当资源发生变化后，通过改变文件名来通知浏览器，忽略旧缓存获取新版本。
* 使用service worker
	* 使用Service Workers拦截请求实现离线缓存和更灵活的缓存策略，可以精细控制如何处理网络请求和缓存响应。
* 利用浏览器的本地缓存
	* 利用localStorage、index DB来存储一些需要快速访问的数据，减少服务器请求次数。
* 资源压缩与合并
	* 压缩静态资源（如使用Gzip）减小文件大小，加快加载速
	* 合并多个CSS或JavaScript文件，减少HTTP请求次数


## 创建react项目
```
npx create-react-app prejectName
```
ts：
```
npx create-react-app prejectName --template typescript
```

## React生命周期

**Class:**

1. constructor创建构造函数并做state数据初始化
2. componentWillMount()-组件将要加载，但还没有加载出来，js逻辑已经可以执行, 异步方法可以放在这里执行
3. render()- 组件渲染
4. componentDidMount()-组件加载完成
5. componentWillUpdate()-组件将要更新
6. componentDidUpdate()-组件更新完成
7. componentWillReceiveProps()-接收父组件传递过来的参数props时触发
8. shouldComponentUpdate()-判断组件是否需要更新, 它需要一个返回值，默认为true，若为false则组件不更新
9. componentWillUnmount()-组件将要被销毁

**Hooks**

```
useEffect(()=>{
  // 加载处理
  return ()=> {
    //销毁操作
  }
},[
  // 监听参数变化
])
```
### 父子组件周期调用顺序

**class:**

1. 父constructor
2. 父componentWillMount
3. 父render
4. 子constructor
5. 子componentWillMount
6. 子render
7. 子componentDidMount
8. 父componentDidMount

**Hooks:**

1. 子effect
2. 父effect

## Hooks与Class的区别

1. hooks的写法比class简洁，class组件中生命周期较为复杂；
2. hooks的业务代码比class更加聚合,useEffect聚合了多个生命周期函数；
3. hooks逻辑复用方便

## useMemo与useCallback的区别

1. `useMemo`和`useCallback`都会在组件第一次渲染的时候执行；
2. 用法基本相同，都会在其依赖的变量发生改变时再次执行，主要用于减少组件的更新次数、优化组件性能
3. `useMemo` 返回缓存的 **变量**值，
4. `useCallback` 返回缓存的 **函数**, state的变化整个组件都会被重新刷新,对于没必要刷新的函数则使用缓存来提高性能

他们是提升性能的一种手段，但不可乱用。

## React.memo

* `React.memo`与 PureComponent 很相似，每次对 props 进行一次浅比较。
* 相比于PureComponent，React.memo()可以支持指定一个参数，可以相当于 shouldComponentUpdate 的作用，相对于 PureComponent 来说用法更加方便

```
export default React.memo(MyComponent,(prevProps, nextProps) => {
	return true;
});
```

* React.memo()在最外层包装整个组件，需要手动写一个方法比较props不相同才进行re-render，可使用 useMemo()进行细粒度性能优化


```js
import React, { useMemo } from 'react';

export default (props = {}) => {
    console.log(`--- component re-render ---`);
    return useMemo(() => {
        console.log(`--- useMemo re-render ---`);
        return <div>
            {/* <p>step is : {props.step}</p> */}
            {/* <p>count is : {props.count}</p> */}
            <p>number is : {props.number}</p>
        </div>
    }, [props.number]);
}
```
只有当依赖的 props.number 发生变化的时候，才会重新触发useMemo()包装的函数的重新执行或渲染

##	如何自定义hook方法

自定义hook可以理解为一个使用Hooks构建的自定义函数,use开头：
```
const useInput = (initialValue) => {
  const [value, setValue] = useState(initialValue)

  return {
    value,
    onChange: e => setValue(e.target.value)
  }
}

//使用
const FormComponent = () => {

  const username = useInput('admin')

  const password = useInput('')

  const onSubmit = (e) => {
    e.preventDefault()
    // 获取表单值
    console.log(username.value, password.value);
  }

  return (
    <form onSubmit={onSubmit} >
      <input type="text" {...username} />
      <input type="password" {...password} />
      <button type="submit">提交</button>
    </form>
  );
}

```

## Hooks中useState的用法
初始化useState:
**方式一:**
```
const [value, setValue] = useState(设置初始值)
```
**方式二：**回调函数
```
const [value, setValue] = useState(()=>{ 
  // 编写计算逻辑    
  return '计算之后的初始值'
})

```
回调函数中的逻辑只会在组件初始化的时候执行一次,return出去的值将作为`value`的初始值.

**set方法使用回调函数:**
```
  setValue(oldValue => ({
      ...oldValue,
      newKey:'newValue',
  }))
```
回调函数中oldValue为value原值，返回新的value值

## React数据传递
1. 通过props,父子组件数据传递
2. 子传父通过回调函数的方式
3. Context是React官方提供的一个管理数据的方法，他可以让我们避免一级一级地把数据沿着组件树传下来
4. 使用postMessage, EventEmitter，或Publish/Subscribe 的广播形式
5. 通过Redux或Mobx插件
6. Provider，Redux也提供了相同的组件

## 数据共享方案，redux和mobx的区别，如何使用context

1. 通过context共享，子组件使用`useContext`可以更加方便的获取上层组件提供的数据，这种方式容易增加组件的耦合性
2. redux和mobx都可以实现数据共享的目的

### redux和mobx的区别：

**共同点:**

* 都是状态管理应用的工具
* 一个状态只有一个可靠的数据来源
* 操作更新的方式是统一的，并且是可控的
* 都支持store与react组件，如react-redux,mobx-react;

**对比总结:**

1. redux将数据保存在单一的store中，而mobx将数据保存在分散的多个store中
2. redux使用plain object保存数据，需要手动处理变化后的操作，mobx使用observable保存数据，数据变化后自动处理响应的操作。
3. redux使用的是不可变状态，意味着状态是只读的，不能直接去修改它，而是应该返回一个新的状态，同时使用纯函数；mobx中的状态是可变的，可以直接对其进行修改。
4. mobx相对来说比较简单，在其中有很多的抽象，mobx使用的更多的是面向对象的思维，redux会比较复杂，采用的是函数式编程思想，同时需要借助一系列的中间件来处理异步和副作用。
5. mobx中有更多的抽象和封装，所以调试起来会更加复杂，同时结果也更难以预测，而redux提供可以进行时间回溯的开发工具，同时其纯函数以及更少的抽象，让调试变得更加容易。

**Redux:**
是一个JavaScript库，通过action（一个对象，包含type，和payload属性）中的type判断需要处理的数据是什么，通过payload进行数据负载，Reducer是一个纯函数，用来通过对应每一个action中的type去进行对应的store中的数据进行操作，有两个参数，第一个是store的初始值，第二个是action。
store提供三个功能：

1. getstate()获取数据
2. dispatch(action)监听action的分发进行数据更新
3. 支持订阅store的变更
    当组件中使用store，可以通过getstate()获取到数据，通过dispatch(action)进行数据的更新，通过subscribe监听到数据，当对应的store中的数据也被修改时，组件中的数据也会相应改变。

在redux中存在异步流，由于Redux对所有的store数据的变更，都应该通过action触发，异步任务（通常是业务或者是获取数据任务）也不例外，而为了不将业务或数据相关的任务混入react组件中，就需要使用其它框架配合管理异步流程，如redux-thunk，redux-presist,redux-logger。

**Mobx:**
Mobx是一个函数响应式编程的状态管理库,它使得状态管理简单可压缩.

- Mobx在action中定义改变状态的动作函数，包括如何变更状态
- Mobx在store中集中管理状态(state)和动作(action)

**mobx:**
面向对象思维、多个store、observable自动响应变化操作、mobx状态可变，直接修改、更多的抽象和封装，调试复杂，结果难以预测。
**redux:**
函数式编程思想、单一store，plan object保存数据，手动处理变化后的操作、使用不可变状态，意味着状态只读，使用纯函数修改，返回的是一个新的状态、提供时间回溯的开发工具

redux伪代码
```
import React from 'react'
import { render } from 'react-dom'
import { createStore, 
		applyMiddleware, 
		combineReducers
 } from 'redux'
import { Provider } from 'react-redux'
import { createLogger } from 'redux-logger'
import thunk from 'redux-thunk'

const middleware = [ thunk ];
if (process.env.NODE_ENV !== 'production') {
  middleware.push(createLogger());
}
// 1.创建store
const store = createStore(
  reducer,
 {
 /*state初始化数据*/
 	data:'',
 },
 // 设置中间件
  applyMiddleware(...middleware)
)
// 2. 构建reducer方法
const reducer = combineReducers({
  changeState,
})
// 3. reducer对应的实际操作
const changeState = (state, action) => {
  switch (action.type) {
    case "xxx":
      return {
      	...state,
      	...action.payload
      }
    default:
      return state
  }
}
// 4. action
const action = () => {
	return {
		type: 'xxx',
		payload: {
			data:'redux'
		}
	}
}

const onClick = ()=> {
	//5. 触发数据变化
	store.dispatch(action)
}

// 2. store挂载到根元素
render(
  <Provider store={store}>
    <App onClick=()=>onClick/>
  </Provider>,
  document.getElementById('root')
)

// 6. 获取
store.getState()
// data:'redux'
```

## setState异步还是同步？

* 在react的生命周期函数或者作用域下为异步
* 在原生事件或setTimeout/setIntaval中是同步

## 防抖和节流

**防抖：**
是指在事件被触发n秒后再执行回调，如果在这n秒内事件又被触发，则重新计时。这可以使用在一些点击请求的事件上，避免因为用户的多次点击向后端发送多次请求。

**节流：**
是指规定一个单位时间，在这个单位时间内，只能触发一次事件回调函数的执行，如果在同一个单位时间内某事件被触发多次，只有一次能生效。节流可以使用在 scroll 函数的事件监听上，通过事件节流来降低事件调用的频率。

函数防抖的实现
```
function debounce(fn, wait) {            
	var timer = null;            
	return function () {                
		var context = this;
		// arguments是function里特定的对象之一，指的是function的参数对象                    
		args = [...arguments];                 
		 
		//如果此时存在定时器的话，则取消之前的定时器重新计时                               
		if (timer) {                    
			clearTimeout(timer)                    
			timer = null                
		}                
		//设计定时器，使事件间隔指定时间后执行                
		timer = setTimeout(() => {                    
			fn.apply(context, args);                
		}, wait)            
	}        
}        
	
	function sayHi() {            
		console.log("防抖成功");        
	}        
	var inp = document.getElementById("inp"); 
	//防抖       
	inp.addEventListener("input", debounce(sayHi, 2000)); 

```

函数节流的实现
```
 //时间戳版        
 function throttle(fn, delay) { 
 	// 毫秒级时间戳           
 	var preTime = Date.now();            
 	return function () {                
 		var context = this, 
 		args = [...arguments], 
 		nowTime = Date.now();                
 		//如果两次时间间隔超过了指定时间，则执行函数。                
 		if (nowTime - preTime >= delay) {                    
 			preTime = Date.now();                    
 			return fn.apply(context,args);                
 		 }            
 	 }        
 }        
 
 //定时器版        
 function throttle2(fun, awit) {            
 	let timeOut = null;            
 	return function () {                
 		let context = this, 
 		args = [...arguments];                
 		if (!timeOut) {                    
 			timeOut = setTimeout(() => {                        
 				fun.apply(context, args);                        
 				timeOut = null                    
 			}, awit)                
 		}            
 	}        
 }        
 
 function sayHi(){            
 	console.log(e.target.innerWidth,e.target.innerHeight);        
 }        
 window.addEventListener('resize',throttle2(sayHi,1000))

```
## async/await的设计和实现

## 深拷贝需要注意的问题

## 跨域问题

## 数据类型的判断

* typeof：判断基本数据类型、值类型；
* instanceof：判断对象类型、引用类型,例如`[] instanceof Array`返回true


[面试题](https://www.php.cn/toutiao-493353.html) 用于学习

## call()和apply()的区别

1. call，apply都属于Function.prototype的一个方法，是JS引擎内实现的
2. call和apply方法的作用相同：都可以调用函数,改变this指向
3. 传的参数类型不同,第一个都是this, call后面的参数是传入的Function的参数，apply参数是传入Funtion的参数组成的数组
```
fn.call(this, ...arguments)
fn.apply(this, [...arguments])
```


## require与import的区别和使用

1. import是ES6中的语法标准也是用来加载模块文件的，import函数可以读取并执行一个JS文件，然后返回该模块的export命令指定输出的代码。export与export default均可用于导出常量、函数、文件、模块，export可以有多个，export default只能有一个。
2. require 定义模块：module变量代表当前模块，它的exports属性是对外的接口。通过exports可以将对象从模块中导出，其他文件加载该模块实际上就是读取module.exports变量，他们可以是变量、函数、对象等。在node中如果用exports进行导出的话系统会帮您转成module.exports的，只是导出需要定义导出名。

**require与import的区别**

1. require是CommonJS规范的模块化语法，import是ES6规范的模块化语法；
2. require是运行时加载，import是编译时加载；
3. require可以写在代码的任意位置，import只能写在文件的最顶端且不可在条件语句或函数作用域中使用；
4. require通过module.exports导出的值就不能再变化，import通过export导出的值可以改变；
5. require通过module.exports导出的是exports对象，import通过export导出是指定输出的代码；
6. require运行时才引入模块的属性所以性能相对较低，import编译时引入模块的属性所以性能稍高。

## 箭头函数
js在调⽤函数的时候经常会遇到this作⽤域的问题，ES6则提供了箭头函数来解决这个问题

1. 箭头函数是匿名函数不能作为构造函数，不能使用new
2. 箭头函数不绑定arguments,取而代之用rest参数…解决，
3. this指向不同,箭头函数的this在定义的时候继承自外层第一个普通函数的this
4. 箭头函数通过call()或apply()调用一个函数,只传入了一个参数,对this并没有影响.
5. 箭头函数没有prototype(原型)，所以箭头函数本身没有this
6. 箭头函数不能当做Generator函数,不能使用yield关键字、
7. 写法不同，箭头函数把function省略掉了 ()=> 也可以把return 省略调 写法更简洁
8. 箭头函数不能通过call()、apply()、bind()方法直接修改它的this指向。

## prototype(原型)和proto

* prototype是每个函数都会具备的一个属性，它是一个指针，指向一个对象，只有函数才有;
* proto是主流浏览器上在除null以外的每个对象上都支持的一个属性，它能够指向该对象的原型，用来将对象与该对象的原型相连的属性

## 并发任务请求数量控制

代码封装如下：
```
// 全局控制的话，可将变量定义为全局变量，方法使用static静态方法 
class GCDTask {
  constructor(count = 2) {
    this.count = count; // 并发任务数量
    this.tasks = []; // 任务列表
    this.runningCount = 0; // 正在运行的任务数量
  }

  addTask(task) {
    return new Promise((resolve, reject) => {
      this.tasks.push({ task, resolve, reject });
      this.run();
    })
  }
  // 执行任务
  run() {
    while (this.runningCount < this.count && this.tasks.length > 0) {
      const { task, resolve, reject } = this.tasks.shift();
      this.runningCount++;
      task().then(resolve, reject).finally(() => {
        this.runningCount--;
        this.run();
      })
    }
  }
}
```

## typescript
* type: 为一个类型取一个新的名字。它可用于定义对象、联合类型、元组等复杂类型

```
type Name = string;

type User = {
  name: Name;
  age: number;
};

type Result = User | null;

```

* interface: 用于定义对象类型，但与 type 不同的是，它还可以定义函数类型、可索引类型、类等类型。另外，interface 可以与类一起使用，从而实现接口继承和类实现

```
interface IProps {
  visible: boolean,
  name: string,
  age: number|undefined,
  map:Map<string, any>;
  objc: [string, any],
  record: Record<string, User>, //类似map
  list: Array<any>; //数组
  rows?: string[]; //数组
  option: 'row'|'colum'; 
  onOkFun(...args): void;// 函数类型
  onCancelFun: Function;// 函数类型
  [key: string]: any; // 可索引类型

}

```

* declare: 用于声明全局变量、全局函数、命名空间等。当你需要引入第三方库时，如果该库没有提供类型定义文件，你可以使用 declare 来告诉编译器该库中包含的变量、函数和类型

```
declare var jQuery: (selector: string) => any;

declare function Ajax(url: string, settings?: any): void;

declare namespace MyLib {
  interface Options {
    color?: string;
    size?: number;
  }
  function createButton(options: Options): void;
}

```

* infer:用于推断类型，只能在条件类型中使用，它还可以结合`extends`关键字和`keyof`操作符进行高级类型推断 

```
type ElementType<T> = T extends (infer E)[] ? E : never;
// 使用示例
type NumberArray = number[];
type Element = ElementType<NumberArray>; // Element 结果是 number

type PropertyType<T, K extends keyof T> = T extends { [key in K]: infer V } ? V : never;

// 使用示例
type Person = {
    name: string;
    age: number;
    isStudent: boolean;
};

type NameType = PropertyType<Person, 'name'>; // NameType 结果是 string
type AgeType = PropertyType<Person, 'age'>;   // AgeType 结果是 number
```

* record: 用来定义泛型类型，可以方便地创建一个简单或复杂的对象
* enum: 枚举类型用来定义一组带有名字的常量值，存在命名空间污染、可读性差、容易被错误使用等风险，可用`const`、`type`来替换
* 泛型: 是指一种通用的类型，它可以用来支持多种不同类型的数据，从而提高代码的复用性和可读性

## Promise.all

多个promise执行的解决方案，promise.all中任何一个promise出现错误都会执行reject，导致其他正常返回的数据无法使用

```
Promise.all(
	[
		Promise.reject({code: 500, msg: '服务异常'}),
		Promise.resolve({code: 200, list: []}),
	]
	.map(p => p.catch(e => e))
)
.then(res => {
	console.log(res)
})
.catch(error => {
	console.log(error)
})
```

可将`.map(p => p.catch(e => e))`中catch得到的err置空，`.map(p => p.catch(e => ''))`来解决

## generator 有了解过吗？

* Generator 生成器 也是 ES6 提供的一种异步编程解决方案，语法行为与传统函数完全不同 function *（）{}
* Generator 函数是一个状态机，封装了多个内部状态，除了状态机，还是一个遍历器对象生成函数
* Generator 是分段执行的, yield （又得）可暂停，next方法可启动。每次返回的是yield后的表达式结果，这使得`Generator`函数非常适合将异步任务同步化
* Generator并不是为异步而设计出来的，他还有其他功能（对象迭代、控制输出、部署Interator）
* Generator函数返回Interator对象，因此我们还可以通过for...of进行遍历,原生对象没有遍历接口，通过Generator函数为它加上这个接口，就能使用for...of进行遍历了

## promise、Generator、async/await进行比较：

* promise和async/await是专门用于处理异步操作的，是异步编程的解决方案
* Generator并不是为异步而设计出来的，它还有其他功能（对象迭代、控制输出、部署Interator接口…）
* promise编写代码相比Generator、async更为复杂化，且可读性也稍差
* Generator、async需要与promise对象搭配处理异步情况
* async实质是Generator的语法糖，相当于会自动执行Generator函数
* async使用上更为简洁，将异步代码以同步的形式进行编写，是处理异步编程的最终方案


## 微前端
微前端与技术无关

#### iframe方案
**特点：**
1. 接入比较简单
2. 隔离性稳定
**缺点：**
1. dom割裂感严重，弹框只能在iframe，而且有滚动条
2. 通讯非常麻烦，而且刷新iframe url状态丢失
3. 前进后退按钮无效

#### qiankun方案
[qiankun](https://qiankun.umijs.org/zh/guide)方案是基于single-spa的微前端方案
**特点：**
1. html entry的方式引入子应用，相比js entry极大的降低了应用改造成本
2. 完备的沙盒方案，js沙箱、css沙箱隔离
3. 做了静态资源预加载能力
**缺点：**
1. 适配成本高，工程化、生命周期、静态资源路径、路由等都要做一系列的适配工作
2. css沙箱采用严格隔离会有各种问题，js沙箱在某些场景下执行性能下降严重
3. 无法同时激活多个子应用，也不支持子应用保活；
4. 无法支持vite等esmodule脚本运行；

#### [micro-app](http://cangdu.org/micro-app/docs.html#/zh-cn/start)方案
micro-app是基于webcomponent+qiankun sandbox的微前端方案。
**特点：**
1. 使用webcomponent加载子应用相比single-spa这种注册监听方案更加优雅；
2. 复用经过大量项目验证过qiankun的沙盒机制也使得框架更加可靠；
3. 组合式的api更加符合使用习惯，支持子应用保活；
4. 降低子应用改造的成本，提供静态资源预加载能力
**缺点：**
1. css沙箱依然无法绝对隔离，js沙箱做全局变量查找缓存，性能有所优化；
2. 支持vite，但必须使用plugin改造子应用，且js代码无法做沙箱隔离；
3. 对于不支持webcompnent的浏览器没有做降级处理；

#### [无界](https://wujie-micro.github.io/doc/)微前端方案
**特点：**
1. 接入简单只需要四五行代码
2. 不需要针对vite额外处理
3. 预加载
4. 应用保活机制
**缺点：**
1. 隔离js使用一个空的iframe进行隔离；
2. 子应用axios需要自行适配
3. iframe沙箱的src设置了主应用的host，初始化iframe的时候需要等待iframe的location.orign,采用的计时器等待不是很优雅；


## 浏览器兼容性问题

重置浏览器标签的样式表,因为浏览器的品种很多，每个浏览器的默认样式也是不同的，然后再将它统一定义，就可以产生相同的显示效果。


## Webpack打包优化
具体可查看node-dev项目下的webpack目录
#### Babel
[Babel](https://www.babeljs.cn/docs/) 是一个 JavaScript 编译器


#### 打包过程

1. 读取入口文件，如项目中的main.js；
2. 由入口文件，解析模块所依赖的文件或包，生成ATS树；
3. 对模块代码进行处理：根据@babel工具转换ATS树（es6转es5、polyfill等）；
4. 递归所有模块
5. 生成浏览器可运行的代码

#### treeShaking

在官网中有提到treeShaking,就是利用esModule的特性，删除上下文未引用的代码。因为webpack可以根据esModule做静态分析，本身来说它是打包编译前输出，所以webpack在编译esModule的代码时就可以做上下文未引用的删除操作
前提条件，使用 tree shaking 必须：
	1	使用 ES6 module
	2	使用 production
需要配合 package.json 里面 sideEffects: ["*.css"] 一同使用，否则可能会干掉打包好的 css 文件。


#### 减少打包时间

```
module.exports = {
    module: {
        rules: [
            test: /\.js$/, // 对js文件使用babel
            loader: 'babel-loader',
            include: [resolve('src')],// 只在src文件夹下查找
            // 不去查找的文件夹路径，node_modules下的代码是编译过得，没必要再去处理一遍
            exclude: /node_modules/ 
        ]
    }
}

```

* 优化Loader: 

  * 对于Loader来说，首先优化的当然是babel了，babel会将代码转成字符串并生成AST，然后继续转化成新的代码，转换的代码越多，效率就越低。
  * 缓存已编译过的文件: 可以将babel编译过文件缓存起来，以此加快打包时间，主要在于设置cacheDirectory。`loader: 'babel-loader?cacheDirectory=true'`

* HappyPack
  因为受限于Node的单线程运行，所以webpack的打包也是单线程的，使用HappyPack可以将Loader的同步执行转为并行，从而提高Loader的编译等待时间。

* DllPlugin
  该插件可以将特定的类库提前打包然后引入，这种方式可以极大的减少类库的打包次数，只有当类库有更新版本时才会重新打包，并且也实现了将公共代码抽离成单独文件的优化方案。

#### 代码压缩相关

* 启用gzip压缩

```
const CompressionPlugin = require('compression-webpack-plugin')
// gzip压缩处理
chainWebpack: (config) => {
    if(isProd) {
        config.plugin('compression-webpack-plugin')
            .use(new CompressionPlugin({
                test: /\.js$|\.html$|\.css$/, // 匹配文件名
                threshold: 10240, // 对超过10k的数据压缩
                deleteOriginalAssets: false // 不删除源文件
            }))
    }
}

```

* 可以使用UglifyJS压缩代码，但是它是单线程的，因此可以使用webpack-parallel-uglify-plugin来运行UglifyJS，但在webpack4中只要启动了mode为production就默认开启了该配置
* 压缩html和css代码，通过配置删除console.log和debugger等

```
new UglifyJsPlugin({
    UglifyOptions: {
        compress: {
            warnings: false,
            drop_console: true,
            pure_funcs: ['console.log']
        }
    },
    sourceMap: config.build.productionSourceMap,
    parallel: true
})
//或使用以下配置
new webpack.optimize.UglifyJsPlugin({
    compress: {
        warnings: false,
        drop_debugger: true,
        drop_console: true
    }
})

```

#### 减少包大小

* 按需加载
  首页加载文件越小越好，将每个页面单独打包为一个文件，（同样对于loadsh类库也可以使用按需加载），原理即是使用的时候再去下载对应的文件，返回一个promise，当promise成功后再去执行回调。

* 配置optimization属性，使用splitChunks（分割代码块）字段对一个体积大的chunk进行分割，从而达到减少boundle体积的目的。主要对splitChunks进行配置（配置字段较多），并且也可以配置第三方库的缓存设置

#### 拆分配置文件

**原因：**
开发环境和生产环境的对于`webpack.config.js`的配置是不一样的，比如在开发环境中不需要配置代码压缩，在生产环境中不需要配置代码调试，所以需要针对不同的环境配置不同的webpack配置文件。

1. 根据开发环境和生产环境的不同，可以新建一个config文件夹，同时拆分两个webpack.config.js文件，分别是`webpack.config.dev.js`和`webpack.config.prod.js`。分别对这两个文件进行不同的配置。
2. 更改mode,生产环境的`mode:production`,开发环境的`mode:development`
3. 将output中的path路径改下 `path: path.resolve(__dirname, "../dist")`,
4. 可以将外部的package.json,package-lock.json及node_modules文件复制到当前的项目下，并在package.json中配置启动的服务:

  ```
  "scripts": {
  	"start": "webpack serve -c ./config/webpack.config.dev.js",
  	"build": "webpack serve -c ./config/webpack.config.prod.js"
  },
  ```

#### 提取公共配置，合并配置文件
由于生产和开发环境中的webpack.config.js有大量的代码重复，我们可以提取公共的配置。

1. 新建一个`webpack.config.common.js`文件，用于存放公共代码。在建一个`webpack.config.js`文件，用于merge代码。
2. 下载webpack-merge插件，并配置`webpack.config.js`文件。

```
const {merge} = require('webpack-merge')
const productionConfig = require('./webpack.config.prod')
const developmentConfig = require('./webpack.config.dev')
const commonConfig = require('./webpcak.config.common')
module.exports = (env)=>{
    switch(true){
        case env.production:
            return merge(productionConfig,commonConfig)
        
        case env.development:
            return merge(developmentConfig,commonConfig)
        
        default:
            return new Error('no found');
    }
}

```

3. 更改，package.json中的配置。

```
"scripts": {
    "start": "webpack serve -c ./config/webpack.config.js --env development",
    "build":"webpack serve -c ./config/webpack.config.js --env production"
  },

```

#### sideEffects
Webpack4 中还新增了一个叫 sideEffects 的新特性，它允许我们去标识我们的代码是否有副作用，从而为 Tree shaking 提供更大的压缩空间。副作用就是模块去执行时除了导出成员之外所做的事情，sideEffects 一般只有我们在去开发一个 npm 模块的时候才会去使用，那是因为官网将 sideEffects 和 Tree shaking 混到了一起，所以很多人误认为它们两个是因果关系，其实它们两个的关系不大。
当我们去封装组件的时候，我们一般会将所有的组件都导入在一个文件中，然后通过这个文件集体导出，但是其他文件引入这个文件的时候，就会将这个导出文件的所有组件都引入

```
// components/index.js
export { default as Button } from './button'
export { default as Heading } from './heading'

```
```
// main.js
import { Button } from './components'
document.body.appendChild(Button())

```

这样 Webpack 在打包的时候，也会将 Heading 组件打包到文件中，这时 sideEffects 就能解决这个问题:

```
module.exports = {
  mode: 'none',
  entry: './src/index.js',
  output: {
    filename: 'bundle.js'
  },
  optimization: {
    sideEffects: true,
  }
}

```

同时我们在 packag.json 中导入将没有副作用的文件关闭，这样就不会将无用的文件打包到项目中了:
```
{
  "name": "side-effects",
  "version": "0.1.0",
  "main": "index.js",
  "author": "maoxiaoxing",
  "license": "MIT",
  "scripts": {
    "build": "webpack"
  },
  "devDependencies": {
    "webpack": "^4.41.2",
    "webpack-cli": "^3.3.9"
  },
  "sideEffects": false
}

```

使用 sideEffects 的需要注意的是，我们的代码中真的没有副作用，如果有副作用的代码，我们就不能去这样配置了:
```
// exten.js
// 为 Number 的原型添加一个扩展方法
Number.prototype.pad = function (size) {
  // 将数字转为字符串 => '8'
  let result = this + ''
  // 在数字前补指定个数的 0 => '008'
  while (result.length < size) {
    result = '0' + result
  }
  return result
}

```

例如我们在 extend.js 文件中为 Number 的原型添加一个方法，我们并没有向外导出成员，只是基于原型扩展了一个方法，我们在其他文件导入这个 extend.js

```
// main.js
// 副作用模块
import './extend'
console.log((8).pad(3))

```
如果我们还标识项目中所有模块没有副作用的话，这个添加在原型的方法就不会被打包进去，在运行中肯定会报错，还有就是我们在代码中导入的 css 模块，也都是副作用模块，我们就可以在 package.json 中去标识我们的副作用模块:
```
{
  "name": "side-effects",
  "version": "0.1.0",
  "main": "index.js",
  "author": "maoxiaoxing",
  "license": "MIT",
  "scripts": {
    "build": "webpack"
  },
  "devDependencies": {
    "webpack": "^4.41.2",
    "webpack-cli": "^3.3.9"
  },
  "sideEffects": [
    "./src/extend.js",
    "*.css"
  ]
}

```

这样标识的有副作用的模块也会被打包进来。

#### css 的模块化打包

* MiniCssExtractPlugin 是一个能够将 css 文件从打包文件中单独提取出来的插件，通过这个插件我们就可以实现 css 模块的按需加载
* optimize-css-assets-webpack-plugin 是一个能够压缩 css 文件的插件，因为使用了 MiniCssExtractPlugin 之后，就不需要使用 style 标签的形式去加载 css 了，所以我们就不需要 style-loader 了
* terser-webpack-plugin 因为 optimize-css-assets-webpack-plugin 是需要使用在 optimization 的 minimizer 中的，而开启了 optimization，Webpack 就会认为我们的压缩代码需要自己配置，所以 js 文件就不会压缩了，所以我们需要安装 terser-webpack-plugin 再去压缩 js 代码

```
// 安装 mini-css-extract-plugin
yarn add mini-css-extract-plugin --dev
// 安装 optimize-css-assets-webpack-plugin
yarn add optimize-css-assets-webpack-plugin --dev
// 安装 terser-webpack-plugin
yarn add terser-webpack-plugin --dev

```

接下来我们就可以配置它们:

```
const { CleanWebpackPlugin } = require('clean-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const OptimizeCssAssetsWebpackPlugin = require('optimize-css-assets-webpack-plugin')
const TerserWebpackPlugin = require('terser-webpack-plugin')

module.exports = {
  mode: 'none',
  entry: {
    main: './src/index.js'
  },
  output: {
    filename: '[name].bundle.js'
  },
  optimization: {
    minimizer: [
      new TerserWebpackPlugin(), // 压缩 js 代码
      new OptimizeCssAssetsWebpackPlugin() // 压缩模块化的 css 代码
    ]
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          // 'style-loader', // 将样式通过 style 标签注入
          MiniCssExtractPlugin.loader, // 使用 MiniCssExtractPlugin 的 loader 就不需要 style-loader 了
          'css-loader'
        ]
      }
    ]
  },
  plugins: [
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({
      title: 'Dynamic import',
      template: './src/index.html',
      filename: 'index.html'
    }),
    new MiniCssExtractPlugin()
  ]
}

```


#### 图片资源压缩
主要是有选择的压缩图片资源，webpack对图片的处理常用的有`url-loader`、`file-loader`、`image-webpack-loader`，各个加载器都在打包过程中有着自己的功能职责。

*	file-loader: 将项目中定义加载的图片通过webpack编译打包，并返回一个编码后的公共的url路径。
  *url-loader: url-loader作用和file-loader的作用基本是一致的，不同点是url-loader可以通过配置一个limit值来决定图片是要像file-loader一样返回一个公共的url路径，或者直接把图片进行base64编码，写入到对应的路径中去。
  *image-webpack-loader: 用来对编译过后的文件进行压缩处理，在不损失图片质量的情况下减小图片的体积大小

安装：
```
npm i image-webpack-loader --save-dev
```
在webpack.config.js中配置：

```
{
	test: /\.(png|jpe?g|gif|svg)(\?.*)?$/,
	use: [
		{
			loader: 'url-loader',
			options:{
				limit: 10000,
				name: utils.assetsPath('img/[name].[hash:7].[ext]')
			}
		},
		{
			loader: 'image-webpack-loader', // 压缩图片
			options: {
				bypassOnDebug:true
			}
		}
	]
}
```
这样超出1M的图片就会交给image-webpack-loader 去处理，打包时就会发现vendor.js文件大小减少了很多


## 文章参考

* [可视化拖拽组件库一些技术要点原理分析](https://juejin.cn/post/6908502083075325959)

