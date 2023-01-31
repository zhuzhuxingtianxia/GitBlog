# useCallback 和 useMemo

在hooks诞生之前，如果组件包含内部 `state`，我们都是基于 `class` 的形式来创建组件。

在react中，性能优化主要是针对以下两个场景：

1. 调用 `setState`，就会触发组件的重新渲染，无论前后 `state` 是否相同
2. 父组件更新，子组件也会自动更新

在类组件的开发模式下，我们通常的解决方案是：使用 `immutable` 进行比较，在不相等的时候调用 `setState`， 在 `shouldComponentUpdate` 中判断前后的 `props` 和 `state`，如果没有变化，则返回 `false` 来阻止更新。

在 `hooks` 出来之后，函数组件中没有 `shouldComponentUpdate` 生命周期，我们无法通过判断前后状态来决定是否更新。`useEffect` 不再区分 `mount` `update` 两个状态，这意味着函数组件的每一次调用都会执行其内部的所有逻辑，那么会带来较大的性能损耗。

但是hooks提供了 `useCallback` 和 `useMemo`两个hook方便进行上述场景的优化。

## useCallback

先看看`useCallback`，其实就是返回一个函数，只有在依赖项发生变化的时候才会更新（返回一个新的函数）。

```jsx
const memoizedCallback = useCallback(
  () => {
    doSomething(a, b);
  },
  [a, b],
);
```

把内联回调函数及依赖项数组作为参数传入 `useCallback`，它将返回该回调函数的 memoized 版本，该回调函数仅在某个依赖项改变时才会更新。当你把回调函数传递给经过优化的并使用引用相等性去避免非必要渲染（例如 `shouldComponentUpdate`）的子组件时，它将非常有用。

## useMemo

把“创建”函数和依赖项数组作为参数传入 `useMemo`，它仅会在某个依赖项改变时才重新计算 memoized 值。这种优化有助于避免在每次渲染时都进行高开销的计算。

```jsx
const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);
```

记住，传入 `useMemo` 的函数会在渲染期间执行。请不要在这个函数内部执行与渲染无关的操作，诸如副作用这类的操作属于 `useEffect` 的适用范畴，而不是 `useMemo`。

如果没有提供依赖项数组，`useMemo` 在每次渲染时都会计算新的值。

**你可以把 `useMemo` 作为性能优化的手段，但不要把它当成语义上的保证。**将来，React 可能会选择“遗忘”以前的一些 memoized 值，并在下次渲染时重新计算它们，比如为离屏组件释放内存。先编写在没有 `useMemo` 的情况下也可以执行的代码 —— 之后再在你的代码中添加 `useMemo`，以达到优化性能的目的。

## useCallback 和 useMemo 对比

先看看两个方法的定义对比：

```php
function useMemo<T>(factory: () => T, deps: DependencyList | undefined): T; 
function useCallback<T extends (...args: any[]) => <any>(callback: T, deps: DependencyList): T;
```

`useCallback` 和 `useMemo` 的参数跟 `useEffect` 一致，他们之间最大的区别有是 `useEffect` 会用于处理副作用，而前两个hooks不能。

`useCallback` 和 `useMemo` 都会在组件第一次渲染的时候执行，之后会在其依赖的变量发生改变时再次执行；并且这两个hooks都返回缓存的值，`useMemo` 返回缓存的 **变量**，`useCallback` 返回缓存的 **函数**。

只有在发现页面卡顿时，或者性能不好时，才需要考虑使用这两个Hook来进行性能优化。

React 重新渲染对性能影响一般情况可以忽略不计，而且 memoized 还是需要消耗一定内存的，如果你不正确地大量使用这些优化，可能会适得其反。

参考：https://www.jianshu.com/p/a645bc3259f4