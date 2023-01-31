# ReactJS forceUpdate()用法及代码示例

仅当组件的状态或传递给它的道具发生变化时，React中的组件才会re-render，但是如果某些数据发生变化，如果我们需要更改组件的re-render，则我们将使用React的forceUpdate()方法。调用forceUpdate()将强制组件re-render，从而跳过该shouldComponentUpdate()方法而调用该组件的render()方法。

提示：通常，避免使用forceUpdate()，而只能从render()中的this.props和this.state中读取。

**用法:**

```
component.forceUpdate(callback)
```

虽然确实有一些使用forceUpdate()方法的用例，但最好在需要时使用挂钩，道具，状态和上下文来对组件进行re-render处理。

```
import React from 'react'; 
  
class App extends React.Component { 
  reRender = () => { 
    // calling the forceUpdate() method 
    this.forceUpdate(); 
  }; 
  render() { 
  
    console.log('Component is re-rendered'); 
    return ( 
      <div> 
        <h2>GeeksForGeeks</h2> 
        <button onClick={this.reRender}>Click To Re-Render</button> 
      </div> 
    ); 
  } 
} 
export default App;
```

**注意：**您可以将自己的样式应用于应用程序。

运行应用程序的步骤：从项目的根目录中使用以下命令运行应用程序：

```
npm start
```

**输出：**

![img](https://vimsky.com/wp-content/uploads/2021/03/139f864bc5e246b13f5984dbd61a5a39.gif)