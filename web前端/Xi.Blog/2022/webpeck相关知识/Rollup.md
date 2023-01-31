# Rollup使用

> webpack与rollup的区别：
>
> 特性：rollup所有资源放同一个地方，一次性加载，利用tree-shake特性来剔除未使用的代码，减少冗余。webpack拆分代码、按需加载webpack2已经逐渐支持tree-shake
>
> rollup:
>
> 1.打包js文件的时候如果发现无用变量，会将其删除。
>
> 2.可以将你的js中的代码，编译成你想要的格式：IFE.AMD.CJS.UMD,ESM等。
>
> Webpack：
>
> 1.代码拆分
>
> 2.静态资源导入（如js、css、图片、字体等）
>
> 拥有如此强大的功能，所以webpack在进行资源打包的时候，就会产生很多冗余代码。

Rollup同样是一款ES Module打包器，从作用来看，Rollup与Webpack很相似，但Rollup更为小巧，仅仅是一款ESM打包器；比如Rollup中不不支持类似的HMR这种高级特性

Rollup是为了提供一个充分利用ESM各项特性的高效（结构比较扁平，性能比较出众的类库）打包器

##### Rollup快速上手

1. 安装rollup模块yarn add rollup --dev

2. 在node_modules/.bin目录就会有rollup.cmd，通过yarn rollup就可以直接使用

3. `yarn rollup .\src\index.js --format iife --file dist/bundle.js`指定打包格式为iife，并指定打包文件

4. 打包结束，输出打包结果到bundle.js中

   

   ```js
   (function () {
     'use strict';
   
     const log = msg => {
       console.log('---------- INFO ----------');
       console.log(msg);
       console.log('--------------------------');
     };
   
     var messages = {
       hi: 'Hey Guys, I am zce~'
     };
   
     // 导入模块成员
   
     // 使用模块成员
     const msg = messages.hi;
   
     log(msg);
   
   }());
   ```

   可以看出，代码中未使用的代码会被自动清除，因为Rollup默认开启tree-shaking，如果用webpack，虽然可以实现tree-shaking，但需要配置并且打包的代码非常臃肿

##### Rollup配置文件

项目根目录添加rollup.config.js，如下



```js
export default {
  input: 'src/index.js',
  output: {
    file: 'dist/bundle.js', // rollup支持的多种输出格式(有amd,cjs, es, iife 和 umd)
    format: 'iife',
  },
}
```

可以通过`yarn rollup --config`直接运行默认配置文件，也可以指定文件`yarn rollup --config rollup.config.js`，这样可以针对不同的环境使用不同的配置

##### Rollup使用插件

Rollup支持使用插件的方式，并不像webpack中分为loader、plugins和minimize三种扩展方式，插件时Rollip唯一扩展途径

- rollup-plugin-json插件

  1. 安装yarn add rollup-plugin-json --dev

  2. rollup.config.js中通过esm模式引入，import json from 'rollup-plugin-json'，并添加到plugins中

  3. 在index.js中获取json文件中的字段，`import { name, version } from '../package.json'`

  4. 打包结果如下

     

     ```js
     (function () {
         ...
         var name = "01-getting-started";
         var version = "0.1.0";
     
         log(name);
         log(version);
         ...
     }());
     ```

- 加载Npm模块

  Rollup不能像Webpack一样，直接使用模块的名称导入第三方模块，需要使用rollup-plugin-node-resolve

  安装和使用同rollup-plugins-json插件一样，安装成功后导入lodash模块，Rollup默认处理esm模式的打包，所以需要导入import _ from 'lodash-es'，使用console.log(_.camelCase('hello world'))，打包结果如下

  

  ```js
  (function () {
      ...
      console.log(lodash.camelCase('hello world'));
      ...
  }());
  ```

- 加载CommonJS模块

  Rollup设计只处理ESModule的打包，导入CommonJS模块是不支持的；需使用rollup-plugin-commonjs

  1. 创建cjs-module.js文件，以commonJS模式导出一个对象

     

     ```js
     module.exports = {
       foo: 'bar'
     }
     ```

  2. 安装插件，并在plugins中配置

  3. index.js引用模块，并使用

  4. 打包结果如下

     

     ```js
     (function () {
         ...
         var cjsModule = {
             foo: 'bar'
         };
         log(cjsModule);
         ...
     }());
     ```

  ##### Rollup代码拆分

  可以使用import()的方式动态导入文件，返回是一个promise对象

  

  ```js
  import('./logger').then(({ log }) => {
    log('hello')
  })
  ```

  此时通过yarn rollup --config运行打包报错`UMD and IIFE output formats are not supported for code-splitting builds`，因为立即执行函数会将所有模块放入同一个函数，没法实现代码拆分，需使用amd或commonjs标准

  并且code-splitting会输出多个文件，rollup输出需要使用dir的方式，修改rollup.config.js

  

  ```js
  // rollup默认入口
  import json from 'rollup-plugin-json'
  import resolve from 'rollup-plugin-node-resolve'
  import commonjs from 'rollup-plugin-commonjs'
  
  export default {
    input: 'src/index.js',
    output: {
      // file: 'dist/bundle.js',
      // format: 'iife',
      dir: 'dist',
      format: 'amd',
    },
    plugins: [
      json(),
      resolve(),
      commonjs()
    ]
  }
  ```

  再次打包，就会在dist目录下生成入口bundle和动态导入生成的bundle，并且都是使用amd标准输出

  ##### Rollup多入口打包

  多入口打包只需将input改为对象的模式

  

  ```js
  // 多入口打包内部会提取公共模块，内部会使用代码拆分，所以需使用amd
  foo: 'src/home.js',
  bar: 'src/album.js'
  ```

  打包过后，就可在dist目录下生成amd标准的文件，不能直接使用，需要使用require.js，并指定data-main入口

  

  ```html
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Document</title>
    </head>
    <body>
      <script src="https://unpkg.com/requirejs@2.3.6/require.js" data-main="foo.js"></script>
    </body>
  </html>
  ```

##### Rollup与Webpack

- Rollup优势：
  - 输出结果更加扁平，执行效率自然更高
  - 自动移除未引用代码
  - 打包结果依然完全可读
- Rollup缺陷：
  - 加载非ESM的第三方模块比较复杂
  - 模块最终打包到一个函数中，无法实现HMR
  - 浏览器环境中，代码拆分依赖amd

如果正在开发应用程序，需要引用第三方模块、需要使用HMR提升开发效率，应用大时需要使用分包，这些需求Rollup在满足上都会有欠缺；而去过正在开发一个框架或类库，很少依赖第三方模块，像React/Vue都在使用Rollup作为模块打包器

Webpack大而全，Rollup小而美

##### Parcel 零配置的前端应用打包器

- yarn init --yes初始化项目

- 安装parcel模块，yarn add parcel-bundler --dev后，在node-modules/.bin目录就生成了parcel的cli程序，后续使用这个cli执行对整个应用的打包

- 执行yarn parcel src/index.html，不仅会打包应用，同时开启一个开发服务器

  和webpack的dev server一样，支持自动刷新和模块热替换

  

  ```js
  // hot对象是否存在 如果存在就可以使用热替换的api
  if (module.hot) {
    // 仅支持一个参数
    // 当前模块或当前所依赖的模块发生更新会自动执行
    module.hot.accept(() => {
      console.log('hmr')
    })
  }
  ```

  parcel还支持自动安装依赖，比如引用jquery，之前并没有安装，当代码保存成功后，就会自动安装所导入的模块

  

  ```js
  import $ fropm 'jquery'
  $(document.body).append('<h1>hello parcel</h1>')
  ```

  parcel支持加载其他类型的模块，相比其他的模块打包器，在parcel加载任意类型的文件都是零配置

  parcel支持动态导入，如果使用了动态导入，会自动拆分代码

  

  ```js
  import('jquery').then($ => {
    $(document.body).append('<h1>Hello Parcel</h1>')
    $(document.body).append(`<img src="${logo}" />`)
  })
  ```

- 生产模式打包，parcel build src/*.html，parcel打包构建速度会比webpack快很多，因为parcel内部使用多进程同时工作



