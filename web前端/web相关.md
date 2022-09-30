# Web相关

## Webpack打包优化

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
*	url-loader: url-loader作用和file-loader的作用基本是一致的，不同点是url-loader可以通过配置一个limit值来决定图片是要像file-loader一样返回一个公共的url路径，或者直接把图片进行base64编码，写入到对应的路径中去。
*	image-webpack-loader: 用来对编译过后的文件进行压缩处理，在不损失图片质量的情况下减小图片的体积大小

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


