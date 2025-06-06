# Vue相关

## Vue的生命周期
1. beforeCreate（创建前）

2. created（创建后）

3. beforeMount（载入前）

4. mounted（载入后）

5. beforeUpdate（更新前）

6. updated（更新后）

7. beforeDestroy（销毁前）

8. destroyed（销毁后）

9. activated：被keep-alive缓存的组件激活时调用（只有被包裹在 keep-alive 中的组件，才有activated生命周期

10. deactivated：被 keep-alive 缓存的组件停用时调用（只有被包裹在 keep-alive 中的组件，才有deactivated生命周期）

计算属性：computed
监听属性：wacher

## Vue的双向绑定
1. 使用 Object.definePropety()方法(Vue 2.x)或Proxy构造函数(Vue 3.x），来劫持data 各个属性的 setter、getter，在数据变动时发布消息给订阅者，触发相应的监听回调
2. 在组件渲染时，若用到 data 里的某个数据，这个数据就会被依赖收集进 watcher 里。当数据更新，如果这个数据在 watcher 里，就会收到通知并更新，否则不会更新
3. vue 采用“数据劫持”+“观察者模式（发布者-订阅者模式）”相结合的方式实现了双向绑定



## Vue2的响应式：
Vue2是通过`Object.defineProperty()`来拦截数据，将数据转换成getter/setter的形
式，在访问数据时调用getter函数，在修改数据时调用setter函数。然后利用发布
-订阅模式，在数据变动时触发依赖，也即发布更新给订阅者，订阅者收到消息后进
行相应的处理

Object.defineProperty() 方法会直接在一个对象上定义一个新属性，或者修改
一个对象的现有属性，并返回此对象

```
const data = {
  message: 'Hello, World!'
};

// Vue 2 内部会类似这样为 data 对象的每个属性添加 getter 和 setter
function defineReactive(obj, key, val) {
  if(arguments.length === 2) {
    // 不传属性值自动获取
    val = obj[key];
  }
  if(val instanceof Object) {
    new Observer(val);
  }

  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get() {
      // 在实际 Vue 中，这里会触发依赖收集
      return val;
    },
    set(newVal) {
      if(newVal !== val) {
        val = newVal;
        // 在实际 Vue 中，这里会触发依赖更新
      }
    }
  });
}

class Observer {
  constructor(obj) {
    this.value  = obj;
    if (!obj || (typeof obj !== 'object' && typeof obj !== 'Array')) {
        return;
    }
    if(typeof obj === 'Array') {
      // 数组处理
    }else {
      const keys = Object.keys(obj);
      for(let i = 0; i < keys.length; i++) {
        defineReactive(obj, keys[i]);
      }
    }
  }
}

// 使用
const ob_data = new Observer(data);
ob_data.message = 'xxxx';
```

## Vue3中ref和reactive的区别

* ref和reactive在vue3中都可以实现数据响应式API
* ref用来定义一个基本类型的响应式数据，reactive用来定义一个对象类型的响应式数据返回代理对象`Proxy`的实例对象
* reactive底层是通过es6的`Proxy`来实现数据响应式的，vue2中是通过`Object.defineProperty()`来实现数据响应式的
* reactive通过`Proxy`的`get`和`set`来实现数据响应式(数据劫持), 并通过Reflect操作源对象内部的数据
* ref通过`Object.defineProperty()`的`get`和`set`来实现数据响应式
* ref定义的数据，在修改时需要`.value`，reactive定义数据时不能直接赋值，否则会失去响应性。

## Vue3的响应式原理

* 利用Proxy实现数据响应式
* 利用Reflect实现数据操作

```
const obj = {};

const proxy = new Proxy(obj, {
  get(target, key) {
    console.log('get', key);
    return Reflect.get(target, key);
  },
  set(target, key, value) {
    console.log('set', key, value);
    return Reflect.set(target, key, value);
  },
  deleteProperty(target, key) {
    console.log('delete', key);
    return Reflect.deleteProperty(target, key);
  }
});

proxy.name = '张三';
console.log(proxy.name);

```

## Vue数据传递

* 父组件传子组件采用`props`,子组件通过props来接受数据, 例如：props: [“属性名”] 或 props:{属性名:数据类型}
* 子传父: 子组件通过this.$emit(“事件”)来触发父组件定义的事件，数据是以参数的形式进行传递
* 通过ref获取实例直接调用组件的方法或访问数据，也是一种数据传递的方式
* 通过parent可以获父组件实例，然后通过这个实例就可以访问父组件的属性和方法它还有一个兄弟root，可以获取根组件实例
* 祖孙跨组件传递数据，通过`props`传递，还可以通过`$attrs`
* 孙祖利用`$listeners`传值
* 兄弟组件通信（bus总线），新建一个Bus.js的文件，然后通过`Bus.$emit('事件名','参数')`来派发事件，数据是以$emit()的参数形式来传递
* sessionStorage传值
* 路由传值
* Vuex通信

## Vue插槽
插槽: `<slot></slot>`
具名插槽: `<slot name="title"></slot>`
使用具名插槽: `<template #title> 等价于 <template v-slot:title>`
插槽传参: `<template #default="scope"></template>` scope即为传递的参数对象

## 自定义指令
可以扩展模板语法，实现特定的功能。
通过 `Vue.directive`全局注册自定义指令,也可以在单个组件中通过 `directives`注册局部指令。
```
// 全局注册自定义指令
Vue.directive('focus', {
  inserted: function (el) {
    el.focus();
  }
});

// 局部注册
<template>
  <input v-focus />
</template>

<script>
export default {
  directives: {
    focus: {
      inserted: function (el) {
        el.focus();
      }
    }
  }
}
</script>

```
Vue2自定义指令生命周期钩子函数:

* bind：只调用一次，指令第一次绑定到元素时调用。在这里可以进行一次性初始化设置
* inserted：被绑定元素插入父节点时调用（仅保证父节点存在，但不一定已被插入文档中）
* update：所在组件的 VNode 更新时调用，但可能发生在其子 VNode 更新之前
* componentUpdated：指令所在组件的 VNode 及其子 VNode 全部更新后调用
* unbind：只调用一次，指令与元素解绑时调用

Vue3自定义指令生命周期钩子函数:

* created：指令绑定到元素时调用，不接受任何参数
* beforeMount：在绑定元素的父组件实例挂载之前调用
* mounted：在绑定元素的父组件实例挂载之后调用，此时元素已经插入到 DOM 中
* beforeUpdate：在更新包含组件的 VNode 之前调用
* updated：在包含组件的 VNode 及其子组件的 VNode 更新后调用
* beforeUnmount：在卸载绑定元素的父组件实例之前调用
* unmounted：在卸载绑定元素的父组件实例之后调用

指令传递参数
```
// binding.arg 访问
<template>
  <div v-my-directive:name="foo"></div>
</template>

<script>
export default {
  directives: {
    'my-directive': {
      bind: function (el, binding) {
        console.log(binding.arg); // 输出 "name"
        console.log(binding.value); // 输出 "foo"
      }
    }
  }
}
</script>

//修饰符通过 binding.modifiers 访问
<template>
  <div v-my-directive.foo.bar></div>
</template>

<script>
export default {
  directives: {
    'my-directive': {
      bind: function (el, binding) {
        console.log(binding.modifiers); // 输出 { foo: true, bar: true }
      }
    }
  }
}
</script>

//动态参数
<template>
  <div v-my-directive:[dynamicArg]="color"></div>
</template>

<script>
export default {
  data() {
    return {
      dynamicArg: 'background'
    };
  },
  directives: {
    'my-directive': {
      bind: function (el, binding) {
      	const { value, arg, modifiers } = binding;
         console.log(arg); // 输出 "background"
         if (arg === 'background') {
         	// 应用背景颜色
		      el.style.backgroundColor = value; 
		    } else {
		    // 默认应用文字颜色
		      el.style.color = value; 
		    }

      }
    }
  }
}
</script>
```

## 角色权限控制

权限控制：
```hasPermi.js
export default {
  mounted(el, binding, vnode) {
    const { value } = binding
    const all_permission = "*:*:*";
    const permissions = allPermissions;

    if (value && value instanceof Array && value.length > 0) {
      const permissionFlag = value

      const hasPermissions = permissions.some(permission => {
        return all_permission === permission || permissionFlag.includes(permission)
      })

      if (!hasPermissions) {
        el.parentNode && el.parentNode.removeChild(el);
        // 或如果用户没有所需权限，隐藏元素
        // el.style.display = 'none'; 
      }
    } else {
      throw new Error(`请设置操作权限标签值`)
    }
  }
}

```
在全局注册`app.directive('hasPermi', hasPermi)`,
元素上使用`v-hasPermi="['monitor:job:remove']"`

## vue中的nextTick
在 DOM 更新循环结束之后执行延迟回调。在修改数据之后立即使用这个方法，获取更新后的 DOM。

## mixin(混入)

app.mixin()，全局的 mixin 会作用于应用中的每个组件实例。

mixins是包含组件对象的数组，这些对象都将被混入到当前组件的实例中。

mixin钩子调用顺序：child mixin混入 -> mixin混入->组件自身。
组件内部 data 的优先级是高于 mixin 内部 data 的优先级的，
事件名称相同时，组件中同名事件优先级比mixin混入优先级高，将覆盖mixin混入中的事件。
属性混入也是组件内部属性覆盖混入的属性，可以通过修改自定义合并策略，来定义自定义属性的优先级。

**优点**: mixin可以将部分组件抽成可重用块.
**缺点**
1. mixin很容易发生冲突，你会不清晰某个值到底是从 mixin 还是 app 来的
2. 可重用性有限，不能通过传递参数修改 mixin 的逻辑，降低了抽象逻辑的灵活性

## Vuex
vuex是一个专为 Vue.js 应用程序开发的状态管理工具，采用单一数据源存储管理应用的所有组件状态，更改状态的唯一方法就是在mutaions里修改state，actions不能直接修改state。

1. state数据存储
2. getter state的计算属性
3. mutation 更改state中状态的逻辑 同步操作
4. action 提交mutation 异步操作
5. model 模块化

* 创建store对象存储state数据

```
const store = new Vuex.Store({
	state: {
	    a: 'true',
	    b: 2,
	    c: false,
	    d: null
	  },
});

```

## Vue中v-if和v-show的区别

1. 都可以控制元素的显示和隐藏
2. v-show控制元素的display值来让元素显示和隐藏；v-if显示隐藏是添加或删除整个DOM元素；
3. v-if有一个局部编译/卸载的过程，切换时会适当的销毁和重建内部的事件监听和子组件；v-show只是简单的css切换；
4. v-if是真正的条件渲染；v-show不会触发组件的生命周期，v-if会触发生命周期；
5. v-if的切换效率比较低，v-show的效率高
6. v-if触发重排

