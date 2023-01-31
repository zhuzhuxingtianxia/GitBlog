# react18新特性

> 个人心得：React18支持setState所有类型的批量更新（包括异步任务），render写法进行了改变，Suspense过渡使页面等待更加顺滑，提供API **startTransition（过渡更新、提高优先级）**、**useDeferredValue**、**useTransition**（可替代防抖，性能更佳）

- ##### react18之前写法

```javascript
import React from 'react';
import {render} from 'react-dom';

const root = document.querySelector('#root');
const element = <h1>测试</h1>;
render(element, root);

```

此时启动项目`npm run vite`

会看到控制台报错信息，react18不让继续使用此方法。

- ##### react18写法：

```javascript
import React from 'react';
import {createRoot} from 'react-dom/client';

const root = document.querySelector('#root');
const element = <h1>测试</h1>;
createRoot(root).render(element);

```

#### 二、批量更新

- 在react中多次的setState合并到一次进行渲染。
- 在react18中更新是以优先级为依据进行合并。

##### 1、旧版本react以前合并更新：

- 合并更新演示代码：

  ```javascript
  import React, { Component } from "react";

  export default class OldBatchUpdate extends Component {
    state = { age: 0 };

    handleClick = () => {
      this.setState({ age: this.state.age + 1 });
      console.log(this.state.age); // 0
      this.setState({ age: this.state.age + 1 });
      console.log(this.state.age); // 0
      this.setState({ age: this.state.age + 1 });
      console.log(this.state.age); // 0
      setTimeout(() => {
        this.setState({ age: this.state.age + 1 });
        console.log(this.state.age); // 2
        this.setState({ age: this.state.age + 1 });
        console.log(this.state.age); // 3
      });
    };
    render() {
      return (
        <div>
          <span>{this.state.age}</span>
          <button onClick={this.handleClick}>+</button>
        </div>
      );
    }
  }

  ```

  - ##### react18以前版本合并更新原理代码：

```javascript
let state = { age: 0 };
let isBatchUpdate = false; // 批量更新标识
const updaeQueue =[]; // 批量更新队列
function setState(newState){
  if(isBatchUpdate){
    updaeQueue.push(newState);
  }else{
    state = newState;
  }
}
function handleClick() {
  setState({ age: state.age + 1 });
  console.log(state.age);
  setState({ age: state.age + 1 });
  console.log(state.age);
  setState({ age: state.age + 1 });
  console.log(state.age);
  setTimeout(() => {
    setState({ age: state.age + 1 });
    console.log(state.age);
    setState({ age: state.age + 1 });
    console.log(state.age);
  });
}
// 更新函数
function batchUpdate(fn){
  isBatchUpdate= true; // 启用批量更新
  fn();
  isBatchUpdate = false; // 关闭批量更新，此时同步任务执行结束，异步任务还没开始，所以，进入异步任务后，批量更新标识为false，也就是关闭了批量更新。
  console.log(updaeQueue, 'updaeQueue')
  updaeQueue.forEach(item=>{
    state = item;
  });
  updaeQueue.length = 0;
}

batchUpdate(handleClick);

```

##### 2、react18中新的更新机制

- 演示代码：

```javascript
import React, { Component } from "react";

export default class BatchUpdate extends Component {
  state = { age: 0 };

  handleClick = () => {
    this.setState({ age: this.state.age + 1 });
    console.log(this.state.age);  // 0
    this.setState({ age: this.state.age + 1 });
    console.log(this.state.age);// 0
    setTimeout(() => {
      this.setState({ age: this.state.age + 1 });
      console.log(this.state.age); // 1
      this.setState({ age: this.state.age + 1 });
      console.log(this.state.age);  // 1
    });
  };
  render() {
    return (
      <div>
        <span>{this.state.age}</span>
        <button onClick={this.handleClick}>+</button>
      </div>
    );
  }
}

```

**注意：可见，不论是在合成事件中，还是在宏任务中，都是会合并更新**

```javascript
const updaeQueue = [];// 更新队列
let onePriority = 1; // 更新优先级1，数字越小更新优先级越高
let towPriority = 2; // 更新优先级2
let larstPriority; // 上一次更新优先级
let state = { age: 0 }; // 初始化状态

function setState(newState, priority) {
  updaeQueue.push(newState);
  if (priority === larstPriority) {
    return;
  }
  larstPriority = priority;
  setTimeout(() => { // 模拟热更新
    updaeQueue.forEach((item) => {
      state = item;
    });
    updaeQueue.length =0;
  });
}
// 新版更新不再依靠是合成事件或者宏任务微任务作为区分，而是，根据更新优先级来处理。
function handleClick() {
  setState({ age: state.age + 1 }, onePriority);
  console.log(state.age);// 0
  setState({ age: state.age + 1 }, onePriority);
  console.log(state.age); // 0
  setTimeout(() => {
    setState({ age: state.age + 1 }, towPriority);
    console.log(state.age); // 1
    setState({ age: state.age + 1 }, towPriority);
    console.log(state.age); // 1
  });
}
handleClick()

```

##### 三、Suspense

Suspense让你的组件在渲染完成之前进行等待，等待期间显示fallback中的内容。
Suspense内的组件子树比其他组件数优先级更低。
完全同步写法，没有任何异步callback之类东西。

###### 1、Suspense执行流程

在render函数中我们可以使用异步请求数据，而不使用await或者promise。
react会从缓存中读取这个请求数据的promise。
如果没有请求完成就抛出一个promise异常。
当这个promise完成后（数据请求完成），react会重新回到原来的render中，将请求回来数据加载出来

###### 2、Suspense子组件中直接调用promise举例：

```javascript
import React, { Suspense, lazy } from "react";
const Home = lazy(() => import("../Home"));
import ErrorBoundary from "../ErrorBoundary";
export default function SuspensePage() {
  return (
    <Suspense fallback={<div>加载中。。。</div>}>
      <ErrorBoundary>
        <Home />
      </ErrorBoundary>
    </Suspense>
  );
}
```

其中Home组件如下：

```javascript
import React from 'react';
import {login} from '/src/services'
import { wrapPromise } from '../../utils';
const myLogin = login();
const loginRes = wrapPromise(myLogin);
export default function Home(){
  const logins = loginRes.read(); // 此处直接调用promise,没有使用await或者then
  return <div>返回结果：{logins.success?"成功":'失败'}， 请求返回信息: {logins.message}</div>
}

```

##### 3、wrapPromise代码要遵顼Suspense流程

```javascript

export function wrapPromise(promise) {
  let status = "pending";
  let result;
  const subspender = promise
    .then((resolve) => {
      result = resolve;
      status = "success";
      console.log(resolve, "success");
    })
    .catch((error) => {
      console.log(error, "err");
      status = "error";
      result = error;
    });
  return {
    read() {
      if (status === "pending") {
        throw subspender;
      } else if (status === "error") {
        throw result;
      } else if (status === "success") {
        return result;
      }
    },
  };
}

```

##### 4、ErrorBoundary组件

```javascript
mport React, {Component} from 'react';

class ErrorBoundary extends Component{
  state = {hasError: false, error: null};

  static getDerivedStateFromError(err){ // 用于报错时候ui切换
    return {hasError: true, error: err}
  }

  componentDidCatch(error, info){ // 用于上报错误信息
    console.log(error, info);
  }
  render(){
    if(this.state.hasError){
      return <div>报错{this.state.error.toString()}</div>
    }
    return this.props.children;
  }
}
export default ErrorBoundary;

```

##### 5、Suspense原理

```javascript
import React, { Component } from "react";
class Suspense extends Component {
  state = { loading: false };
  componentDidCatch(error) {
    if (typeof error.then === "function") {
      this.setState({ loading: true });
      error.then(() => {
        this.setState({ loading: false });
      });
    }
  }
  render() {
    const { loading = false } = this.state;
    const { fallback, children } = this.props;
    if (loading) {
      return <div>{fallback}</div>;
    }
    return children;
  }
}
export default Suspense;

```

#### 四、 startTransition

##### 1、并发更新

并发更新就是可以中断渲染的架构。
什么时候中断渲染呢？当有更高级别渲染到来时，先放弃当前正在渲染的东西，而是，去立即执行更高级别的渲染，换来视觉上更快的相应速度。
在react18中以是否使用并发特性，作为是否开启并发更新的依据。

##### 2、更新优先级

react18以前没有更新优先级的概念，所有更新都要排队，不管优先级高不高，都要等待上一个更新执行结束才能执行。
react18为什么又要有更新优先级呢？用户对于不同的操作对交互的执行速度有着不同的预期。所以，我们可以根据用户的预期赋予不同的优先级。
高优先级：用户输入，窗口缩放，窗口拖拽。
低优先级：数据请求和文件下载。
高优先级更新会中断低优先级更新，等高优先级执行完以后，低优先级更新会根据高优先级执行结果重新更新。
对于cpu-bound的更新（例如：创建新的DOM节点），并发意味着一个更急迫的渲染可以中断已经开始的更新。

##### 3、开启过渡更新（startTransition）

在输入框搜索东西的使用场景下，输入框优先级要比联想词高，所以，可以对联想词设置开启过渡更新。使用方法就是set值外包裹一层。

```javascript
const [word, setWord]= useState([]);

startTransition(()=>{
    setWord(new Array(10000).fill(1));
})
```

如果不开启过渡更新就会在输入内容时候卡死。开启后，会很流畅。

```javascript
import React, { startTransition, useState, useEffect } from "react";
function AssociativeWord({ word }) {
  const [wordList, setWordList] = useState([]);
  useEffect(() => {
    if (word.length > 0) {
      startTransition(()=>{
        setWordList(new Array(20000).fill(word));
      })
    }
  }, [word]);
  return (
    <ul>
      {wordList.map((item, index) => {
        return <li key={index.toString()}>{item}</li>;
      })}
    </ul>
  );
}
export default function StartTransitionPage() {
  const [word, setWord] = useState("");
  function handleInput(event) {
    const {
      target: { value = "" },
    } = event;
    setWord(value);
  }
  return (
    <div>
      <label htmlFor="world">请输入需要搜素的关键词：</label>
      <input type="text" id="world" onChange={handleInput} />
      <AssociativeWord word={word} />
    </div>
  );
}

```

**注意：低优先级不会被丢弃，只是会在高优先级执行后执行**

##### 4、更新优先级问题

```javascript
import React, {startTransition, useState, useEffect} from 'react';

export default function UpdatePriority(){
  const [result, setResult] = useState('');

  useEffect(()=>{
    console.log(result, 'result');
  }, [result]);
  function handleChangeResult(){
    setResult(item=>item + 'A');
    startTransition(()=>{
      setResult(item=>item + 'B');
    });
    setResult(item=>item + 'C');
    startTransition(()=>{
      setResult(item=>item + 'D');
    });
  }

  return <div>
    <h1>结果：{result}</h1>
    <button onClick={handleChangeResult}>改变结果</button>
  </div>
}

```

结果在控制台输出如下内容：

```
AC result
ABCD result

```

##### 5、结论：

每次渲染时候会有一个渲染优先级，找到优先级最高的作为渲染优先级。

虽然优先级不同，但是，最终的结果顺序和调用顺序是一致的。

因为，优先级高的已经渲染过，会有diff比对更新，所以，相当于缓存。但最终还是都要渲染的。当执行到最低优先级时候，按照代码顺序全部执行一次。官方解释是类似于git，在master分支拉取A分支和B分支，但是，正在开发时候遇到master有bug，拉取一个hotfix分支C进行修改，C改完发布了，此时，发布A时候，C代码也会在里边。

#### 五、 useDeferredValue

##### 1、解决的问题

如果某些渲染比较消耗性能，比如：实时计算和反馈，我们可以使用useDeferredValue来降低计算优先级，从而提升整体的性能。和startTransition作用类似，只是用法不同。

##### 2、和startTransition的区别

startTransition在目的组件中使用，包裹一层setValue来改变计算优先级，从而提升性能。
useDeferredValue在源头改变，通过延时改变传入子组件值，降低优先级，提高性能。
一个在源头解决问题，一个在目的地解决问题。

##### 3、使用方法：

```javascript
import React, { useDeferredValue, useState, useEffect } from "react";
function AssociativeWord({ word }) {
  const [wordList, setWordList] = useState([]);
  useEffect(() => {
    if (word.length > 0) {
      setWordList(new Array(20000).fill(word));
    }
  }, [word]);
  return (
    <ul>
      {wordList.map((item, index) => {
        return <li key={index.toString()}>{item}</li>;
      })}
    </ul>
  );
}
export default function UseDeferredValuePage() {
  const [word, setWord] = useState("");
  const defferedText = useDeferredValue(word);
  function handleInput(event) {
    const {
      target: { value = "" },
    } = event;
    setWord(value);
  }
  return (
    <div>
      <label htmlFor="world">请输入需要搜素的关键词：</label>
      <input type="text" id="world" onChange={handleInput} />
      <AssociativeWord word={defferedText} />
    </div>
  );
}

```

#### 六、useTransition

允许组件在切换到下一个组件之前等待加载内容，从而避免不必要的加载状态。
useTransition返回两个值的数组。一个是isPending，另外一个是startTransition。
适用于加载很快的地方，将会使得Suspense中fallback不再执行，pending结束后直接渲染出来。

##### 1、双缓冲

当数据量很大时候，绘图需要几秒或者更长的时间，而且，有时候会出现闪烁现象。为了解决这些问题，可采用双缓冲技术来绘图。
双缓冲即在内存中创建一个和屏幕绘图区域一致的对象，先将图像绘制到内存中这个对象上，再一次性将图形拷贝到界面上。这时候会加快绘图的速度。

##### 2、useTransition使用

```javascript
import React, { lazy, Suspense, useState, useTransition } from "react";
import ErrorBoundary from "../ErrorBoundary";
const Home = lazy(() => import("../Home"));
const DetailPage = lazy(() => import("../DetailPage"));
export default function UseTransitionPage() {
  const [currentHome, setCurrentHome] = useState(true);
  const [isPending, startTransition] = useTransition();
  function handleChangePage() {
    startTransition(() => { // 使用useTransition结构出来startTransition进行包裹
      setCurrentHome(!currentHome);
    });
  }
  return (
    <Suspense fallback={<div>加载中。。。</div>}>
      <ErrorBoundary>{currentHome ? <Home key="home"/> : <DetailPage key="detail" />}</ErrorBoundary>
      <button onClick={handleChangePage}>切换</button>
      {isPending?'切换中。。。':'已经切换'}
    </Suspense>
  );
}

```

##### useTransition可以用来降低渲染优先级。分别用来包裹计算量大的 function和 value，降低优先级，减少重复渲染次数。

举个例子：搜索引擎的关键词联想。一般来说，对于用户在输入框中输入都希望是实时更新的，如果此时联想词比较多同时也要实时更新的话，这就可能会导致用户的输入会卡顿。这样一来用户的体验会变差，这并不是我们想要的结果。

我们将这个场景的状态更新提取出来：一个是用户输入的更新；一个是联想词的更新。这个两个更新紧急程度显然前者大于后者。

以前我们可以使用防抖的操作来过滤不必要的更新，但防抖有一个弊端，当我们长时间的持续输入（时间间隔小于防抖设置的时间），页面就会长时间都不到响应。而 startTransition 可以指定 UI 的渲染优先级，哪些需要实时更新，哪些需要延迟更新。即使用户长时间输入最迟 5s 也会更新一次，官方还提供了 hook 版本的 useTransition，接受传入一个毫秒的参数用来修改最迟更新时间，返回一个过渡期的pending 状态和startTransition函数。

```javascript

import React, { useState, useTransition } from 'react';
 
export default function Demo() {
  const [value, setValue] = useState('');
  const [searchQuery, setSearchQuery] = useState([]);
  const [loading, startTransition] = useTransition(2000);
 
  const handleChange = (e) => {
    setValue(e.target.value);
    // 延迟更新
    startTransition(() => {
      setSearchQuery(Array(20000).fill(e.target.value));
    });
  };
 
  return (
    <div className="App">
      <input value={value} onChange={handleChange} />
      {loading ? (
        <p>loading...</p>
      ) : (
        searchQuery.map((item, index) => <p key={index}>{item}</p>)
      )}
    </div>
  );
}

```

效果如下：

![img](https://img-blog.csdnimg.cn/aeb8f8c3588e4bf5b6f0c1668d7c1617.gif)

