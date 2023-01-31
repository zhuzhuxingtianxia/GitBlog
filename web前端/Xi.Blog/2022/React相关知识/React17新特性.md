# React 17 新特性

### 写在前面

React 最近发布了[v17.0.0-rc.0](https://link.segmentfault.com/?enc=xx5dzC2Lp5E%2FjtIVB4gvtQ%3D%3D.NXpUnkKvaCywH%2FmP5b8SrgNGhPIuHEhLaMTvxDsAEbPU145Ty3N4e9uSjCeXHaID6FQyH89ClKV6GpxYq4jeRA%3D%3D)，距上一个大版本[v16.0（发布于 2017/9/27）](https://link.segmentfault.com/?enc=0W8f5sr40XXN1BWl9le8yw%3D%3D.fik71YQUsa8gFTXDU2KwEaTkXPFhw1aI%2FCyVXnaRbnitTlTUBy5%2FJhfQQYZMGhpE)已经过去近 3 年了

与[新特性云集的 React 16](https://link.segmentfault.com/?enc=Qdp3lyz%2F67dA1GtsGJ4UEQ%3D%3D.pdgMqlvtvNSQGdan2qamFkf96WZ65U%2F3WOP0GDZHLfpeFsDKgJs7t7eGI34%2BO%2FIR)及先前的大版本相比，React 17 显得格外特殊——**没有新特性**：

> React v17.0 Release Candidate: No New Features

不仅如此，**还带上来了 7 个 breaking change**……

## 一.真没有新特性？

React 官方对 v17 的定位是**一版技术改造，主要目标是降低后续版本的升级成本**：

> This release is primarily focused on **making it easier to upgrade React itself**.

因此 v17 只是一个铺垫，并不想发布重大的新特性，而是为了 v18、v19……等后续版本能够更平滑、更快速地升上来：

> When React 18 and the next future versions come out, you will now have more options.

但其中有些改造不得不打破向后兼容，于是提出了 v17 这个大版本变更，顺便搭车卸掉两年多积攒的一些历史包袱

## 二.渐进式升级成为了可能

**在 v17 之前，不同版本的 React 无法混用**（事件系统会出问题），所以，开发者要么沿用旧版本，要么花大力气整个升级到新版本，甚至一些常年没有需求的长尾模块也要整体适配、回归测试。考虑到开发者的升级适配成本，React 维护团队同样束手束脚，废弃 API 不敢轻易下掉，要么长时间、甚至无休止地维护下去，要么选择放弃那些老旧的应用

而 React 17 提供了一个新的选项——**渐进式升级，允许 React 多版本并存**，对大型前端应用十分友好，比如弹窗组件、部分路由下的长尾页面可以先不升级，一块一块地平滑过渡到新版本（参考[官方 Demo](https://link.segmentfault.com/?enc=tZ6RbIp3Tan6cfCIuYdOsQ%3D%3D.rHw0d6zKTnImjOEbjcrGJFniv3cqW%2BgWJRO5CXOw%2FmG93vp8g0poUcBh0WvWF5U7F9IniuraBv4kPbnfMflvZA%3D%3D)）

P.S.注意，（按需）加载多个版本的 React 存在着不小的性能开销，同样应该慎重考虑

### 多版本并存与微前端架构

多版本并存、新旧混用的支持让[微前端架构](https://link.segmentfault.com/?enc=5kVnr4NoDmfWF6qESCqpKg%3D%3D.yu%2FNiuKO0%2B5rpgePnjYd78HXarA0pWNXV22pdQi0vDi7i7RZIN9dRiSCR0MeqVDA)所期望的渐进式重构成为了可能：

> 渐进地升级、更新甚至重写部分前端功能成为了可能

与 React 支持多版本并存、渐进地完成版本升级相比，**微前端更在意的是允许不同技术栈并存，平滑地过渡到升级后的架构，解决的是一个更宽的问题**

另一方面，当 React 技术栈下多版本混用难题不复存在时，也有必要对微前端进行反思：

- 一些问题是不是由技术栈自身来解决更为合适？
- 多技术栈并存是常态还是短期过渡？
- 对于短期过渡，是否存在更轻量的解决方案？

关于微前端在解决什么问题的更多思考，见[Why micro-frontends?](https://link.segmentfault.com/?enc=s%2BVaiTtnwN8y2Mk%2Fe60xPQ%3D%3D.bJ0yRvq%2FiJSDdKPAje04dypmQktwWSRh9nLgRO4uxz0ORvrNBXsdeSWWYuixFINl)

## 三.7 个 Breaking change

### 事件委托不再挂到 document 上

之前多版本并存的主要问题在于**React 事件系统默认的[委托机制](https://link.segmentfault.com/?enc=yJIle9JZ%2Fxw02jIZmB7TDw%3D%3D.GMb6Nr%2FoIh8oNjhkXs45HO2Fg7HgJEV76RQ6PqQv5OLnGjC57p4M19w0z0lIclMg1VZsyX60mM%2FK%2BZz0r%2BxhadB3Bs7S6r%2BPYC%2Fh2CqciuhzUZ5G5EgO3BDs5ricon49hslSTYxG%2B7CVK5zCR1rAeg%3D%3D)**，出于性能考虑，React 只会给`document`挂上事件监听，DOM 事件触发后冒泡到`document`，React 找到对应的组件，造一个 React 事件（[SyntheticEvent](https://link.segmentfault.com/?enc=hDlY825cb1aV%2Bh1sCgvgmQ%3D%3D.hD5aJ8Y1KXQOUrb7kQWDoN6oV55o0ulg7QGBkT2Wxi0FmjJBLLtgzqJiJb4LviedzWJ7V1u3lK%2BeH4%2FJW194OqqxShVjM09O0Bs7e97wIwwsEvfoZGx7RgCJ%2BXeVQqwZ)）出来，并按组件树模拟一遍事件冒泡（此时原生 DOM 事件早已冒出`document`了）：

![img](https://segmentfault.com/img/remote/1460000023680285)

因此，不同版本的 React 组件嵌套使用时，`e.stopPropagation()`无法正常工作（两个不同版本的事件系统是独立的，都到`document`已经太晚了）：

> If a nested tree has stopped propagation of an event, the outer tree would still receive it.

P.S.实际上，[Atom 在早些年就遇到了这个问题](https://link.segmentfault.com/?enc=GUPQFPiOovZ0p%2BWclSum8A%3D%3D.sZHIQvqHn5udvUQMrEKBJiMnjeOlYcU8xpWSgAZoiW6dPpTcp1niF%2BFWsQTPXEfm)

为了解决这个问题，**React 17 不再往`document`上挂事件委托，而是挂到 DOM 容器上**：

![img](https://segmentfault.com/img/remote/1460000023680286)

例如：

```awk
const rootNode = document.getElementById('root');
// 以为 render 为例
ReactDOM.render(<App />, rootNode);
// Portals 也一样
// ReactDOM.createPortal(<App />, rootNode)
// React 16 事件委托（挂到 document 上）
document.addEventListener()
// React 17 事件委托（挂到 DOM container 上）
rootNode.addEventListener()
```

另一方面，将事件系统从`document`缩回来，也让 React 更容易与其它技术栈共存（至少在事件机制上少了一些差异）

### 向浏览器原生事件靠拢

此外，React 事件系统还做了一些小的改动，使之更加贴近浏览器原生事件：

- `onScroll`不再冒泡
- `onFocus/onBlur`直接采用原生`focusin/focusout`事件
- [捕获阶段](https://link.segmentfault.com/?enc=%2FRE0asw1Xhrpo78d3P1TGA%3D%3D.EdCOqrvqZOxUBoJoNZsxr96U7S1ED%2B%2BNJZpm5tAYSL2zfu1qrcrOarDpC37kwGt8lDJHKt2Btdf8MlzZJGjZX6nGQgRK4J8rKp9rCDZ1Q9RRwGqlDeF8nRpVr8g45qMxGcFBHf50P%2Ff75ltgxTu9LQ%3D%3D)的事件监听直接采用原生 DOM 事件监听机制

注意，`onFocus/onBlur`的下层实现方案切换并不影响冒泡，也就是说，React 里的`onFocus`仍然会冒泡（并且不打算改，认为这个特性很有用）

### DOM 事件复用池被废弃

之前出于性能考虑，为了复用 SyntheticEvent，维护了一个**事件池，导致 React 事件只在传播过程中可用，之后会立即被回收释放**，例如：

```arcade
<button onClick={(e) => {
    console.log(e.target.nodeName);
    // 输出 BUTTON
    // e.persist();
    setTimeout(() => {
      // 报错 Uncaught TypeError: Cannot read property 'nodeName' of null
      console.log(e.target.nodeName);
    });
  }}>
  Click Me!
</button>
```

传播过程之外的事件对象上的所有状态会被置为`null`，除非手动`e.persist()`（或者直接做值缓存）

**React 17 去掉了事件复用机制**，因为在现代浏览器下这种性能优化没有意义，反而给开发者带来了困扰

### Effect Hook 清理操作改为异步执行

[useEffect](https://link.segmentfault.com/?enc=vBrdQiV9L29%2BpkqnKDh27A%3D%3D.8MbDyik46ePOlOdszpxsueY%2FQiKQZhDRNZT9re%2Fy8LQ9cwG0numvurAryccv9VtGtqG%2BR%2F3KXydtwf9rY%2FCPLOWtGfM1hphFhcO%2Bq4wCHPc%3D)本身是异步执行的，但**其清理工作却是同步执行的**（就像 Class 组件的`componentWillUnmount`同步执行一样），可能会拖慢切 Tab 之类的场景，因此 React 17 改为异步执行清理工作：

```arcade
useEffect(() => {
  // This is the effect itself.
  return () => {
    // 以前同步执行，React 17之后改为异步执行
    // This is its cleanup.
  };
});
```

同时还纠正了清理函数的执行顺序，按组件树上的顺序来执行（之前并不严格保证顺序）

P.S.对于某些需要同步清理的特殊场景，可换用[LayoutEffect Hook](https://link.segmentfault.com/?enc=4KW5qko4797Vj%2B%2FYZWBq6A%3D%3D.k2%2FbEbUbx7d%2BcsHfipHpYRg014nbJq6ZVX49kRUCsIeJ5lAZg8W2eSqknnk8GfKImIIsYGUkClDT2ISE2Dw0nA%3D%3D)

### render 返回 undefined 报错

React 里 render 返回`undefined`会报错：

```actionscript
function Button() {
  return; // Error: Nothing was returned from render
}
```

**初衷是为了把忘写`return`的常见错误提示出来**：

```javascript
function Button() {
  // We forgot to write return, so this component returns undefined.
  // React surfaces this as an error instead of ignoring it.
  <button />;
}
```

在后来的迭代中却没对`forwardRef`、`memo`加以检查，在 React 17 补上了。之后无论类组件、函数式组件，还是`forwardRef`、`memo`等期望返回 React 组件的地方都会检查`undefined`

P.S.空组件可返回`null`，不会引发报错

### 报错信息透出组件“调用栈”

React 16 起，遇到 Error 能够透出组件的“调用栈”，辅助定位问题，但比起 JavaScript 的错误栈还有不小的差距，体现在：

- 缺少源码位置（文件名、行列号等），Console 里无法点击跳转到到出错的地方
- 无法在生产环境中使用（`displayName`被压坏了）

React 17 采用了一种新的组件栈生成机制，**能够达到媲美 JavaScript 原生错误栈的效果（跳转到源码），并且同样适用于生产环境**，大致思路是在 Error 发生时重建组件栈，在每个组件内部引发一个临时错误（对每个组件类型做一次），再从`error.stack`提取出关键信息构造组件栈：

```javascript
var prefix;
// 构造div等内置组件的“调用栈”
function describeBuiltInComponentFrame(name, source, ownerFn) {
  if (prefix === undefined) {
    // Extract the VM specific prefix used by each line.
    try {
      throw Error();
    } catch (x) {
      var match = x.stack.trim().match(/\n( *(at )?)/);
      prefix = match && match[1] || '';
    }
  } // We use the prefix to ensure our stacks line up with native stack frames.

  return '\n' + prefix + name;
}
// 以及 describeNativeComponentFrame 用来构造 Class、函数式组件的“调用栈”
// ...太长，不贴了，有兴趣看源码
```

因为**组件栈是直接从 JavaScript 原生错误栈生成的**，所以能够点击跳回源码、在生产环境也能按 sourcemap 还原回来

P.S.重建组件栈的过程中会重新执行 render，以及 Class 组件的构造函数，这部分属于 Breaking change

P.S.关于重建组件栈的更多信息，见[Build Component Stacks from Native Stack Frames](https://link.segmentfault.com/?enc=OXpUSg5sgeechF5uaz2HZg%3D%3D.fYUMwlzMdsRgZVK5KBNB1ytwyTOXbB%2F6GGeV3kEKvXbbDEW6qG8miEEWrxcJ7new)、以及[react/packages/shared/ReactComponentStackFrame.js](https://link.segmentfault.com/?enc=Mrzt1%2F8hynKxfI4HZs%2BKLA%3D%3D.xJfFPzlQRv6sKjCNfo22t%2F1nm%2BvQKK1%2FWf%2BRRlAEyKPCLcP39aMhg2X6xgjhamwIrsPqby9jgLvnJ7Zvh2XOTc7x1o6KJM3d%2BWSWeeBjJpxJG75h9ZLyFWEL854KKUJkh7KjHaKyLMb7QHkLljfTt3oD6NZsNMtrlki7PwBh9n4%3D)

### 部分暴露出来的私有 API 被删除

React 17 删除了一些私有 API，大多是当初暴露给[React Native for Web](https://link.segmentfault.com/?enc=uoL%2Fa2f9bkwmvNLcYdBqSg%3D%3D.LWHQEgrZpCrL2fewhKTZ4Z%2Bx4fOqa0krdnbo4kitKV6mnufk5kTOfT4s7fmKwoAj)使用的，目前 React Native for Web 新版本已经不再依赖这些 API

另外，修改事件系统时还顺手删除了`ReactTestUtils.SimulateNative`工具方法，因为其行为与语义不符，建议换用[React Testing Library](https://link.segmentfault.com/?enc=eSvrJTBElp8iPN3nWK1Ivg%3D%3D.csPzz7qUewsWbt7Vd6rcYT7x9%2FVNnmsN8flhrtyBy2LjZ%2FDvzwBuOUimFrka6%2FxKCW2NkypQsUONFVRiJygZQQ%3D%3D)

## 四.总结

总之，React 17 是一个铺垫，这个版本的核心目标是让 React 能够渐进地升级，因此最大的变化是**允许多版本混用，为将来新特性的平稳落地做好准备**

> We’ve postponed other changes until after React 17. The goal of this release is to enable gradual upgrades.