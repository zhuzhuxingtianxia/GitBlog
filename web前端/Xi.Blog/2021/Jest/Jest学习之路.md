

![前端测试框架 Jest](https://pic2.zhimg.com/v2-bb374b825806745695da301112f50b20_1440w.jpg?source=172ae18b)

### 初识Jest



##### 使用Jest的好处

> 可解决一些常见问题：1.保证当前组件质量，即当前业务的正常使用。2.除该组件Owner之外第二人，在修改组件的过程中，避免因为对代码的不熟悉，该出BUG。3.一个组件多个页面复用，修改后的测试回归任务重。
>
> Jest 是 Facebook 出品的一个测试框架，相对其他测试框架，其一大特点就是就是内置了常用的测试工具，比如自带断言、测试覆盖率工具，实现了开箱即用。
>
> 而作为一个面向前端的测试框架， Jest 可以利用其特有的[快照测试](https://link.zhihu.com/?target=http%3A//facebook.github.io/jest/docs/zh-Hans/snapshot-testing.html%23content)功能，通过比对 UI 代码生成的快照文件，实 现对 React 等常见框架的自动测试。
>
> 此外， Jest 的测试用例是并行执行的，而且只执行发生改变的文件所对应的测试，提升了测试速度。目前在 Github 上其 star 数已经破万；而除了 Facebook 外，业内其他公司也开始从其它测试框架转向 Jest ，比如 [Airbnb 的尝试](https://link.zhihu.com/?target=https%3A//medium.com/airbnb-engineering/unlocking-test-performance-migrating-from-mocha-to-jest-2796c508ec50) ，相信未来 Jest 的发展趋势仍会比较迅猛。

#### 安装

使用 [`yarn`](https://yarnpkg.com/en/package/jest) 安装 Jest：

```yarn add --dev jest
yarn add --dev jest
```

或使用 [`npm`](https://www.npmjs.com/package/jest) 安装：(create-react-app的项目会自带babel-jest)

```
npm install --save-dev jest
```



将如下代码添加到 `package.json` 中：

```
{
  "scripts": {
	   "test": "jest"
  }
}
```



#### hello jest!

运行第一个测试用例

下面我们开始给一个假定的函数写测试，这个函数的功能是两数相加。首先创建 `sum.js` 文件：

```
function sum(a, b) {
  return a + b;
}
module.exports = sum;
```

接下来，创建名为 `detail.test.js` 的文件。这个文件包含了实际测试内容：

```
const sum = require('./sum');
test('adds 1 + 2 to equal 3', () => {
  expect(sum(1, 2)).toBe(3);
});
```

最后，运行或者 `npm test` ，Jest 将输出如下信息：

![image-20210926111037717](/Users/xizijian567/Library/Application Support/typora-user-images/image-20210926111037717.png)





#### Jest支持Es6的解决方案

对于用惯了ES6语法的我来说，不能用是一大痛苦，在写用例时突然发觉import导入Jest会报错，不支持，报错代码及信息如下：

```
// const sum = require('./sum')
import sum from './sum'

test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
});
```

![image-20210926113326444](/Users/xizijian567/Library/Application Support/typora-user-images/image-20210926113326444.png)

解决方法如下：

```
npm add --dev babel-jest @babel/core @babel/preset-env
```

可以在工程的根目录下创建一个`babel.config.js`文件用于配置与你当前Node版本兼容的Babel：`  

```
module.exports = {
  presets: [['@babel/preset-env', {targets: {node: 'current'}}]],
};
```

搞定！

###### 工作中碰到的小问题

由于公司内网开发，npm源是公司的地址，在npm install时无法同步最近的except版本，需手动更换淘宝源下载

```
npm config set registry https://registry.npm.taobao.org/
```

查看是否更新成功

```
npm config get registry
```



#### Package.json配置

添加"test": "jest --coverage"

运行`npm test` 可测试所有单元测试脚本，如需测试单个文件，可运行 `npm 文件名 --coverage` 

当文件执行一个单元测试时会生成覆盖率报告如图所示：

![image-20211005164121815](/Users/xizijian567/Library/Application Support/typora-user-images/image-20211005164121815.png)

- %stmts是语句覆盖率（statement coverage）：是不是每个语句都执行了？
- %Branch分支覆盖率（branch coverage）：是不是每个if代码块都执行了？
- %Funcs函数覆盖率（function coverage）：是不是每个函数都调用了？
- %Lines行覆盖率（line coverage）：是不是每一行都执行了？

