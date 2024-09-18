## 修改npm镜像

* 查看npm镜像源的地址
 ```
 npm config get registry
 ```
* 设置npm镜像源
```
npm config set registry https://registry.npmmirror.com
```

* yarn
```
npm install -g yarn
```
修改源
```
yarn config set registry https://registry.npmmirror.com -g
```
卸载
```
npm uninstall yarn -g
```
版本查看
```
yarn -v
```
yarn命令：
1. yarn init //安装package.json里所有包，并将包及它的所有依赖项保存进yarn.lock
2. yarn run  //用来执行在 package.json 中 scripts 属性下定义的脚本
3. yarn add [package] //添加一个包
4. yarn add --dev [package] //添加一个开发依赖包
5. yarn remove 包名 // 删除包
6. yarn info //可以用来查看某个模块的最新版本信息
7. yarn config list // 显示所有配置项
8. yarn config set //设置配置
9. yarn config get registry //显示某配置项,这里是显示镜像源配置
10. yarn config delete //删除某配置项

## node
node管理工具
```
npm install -g n
```
安装并切换版本:
```
sudo n v14.5.0
```
安装某个版本：
```
sudo n install 16.20.0
```
查看所有可以安装的版本: `n ls`
设置n镜像环境变量并下载稳定版本：
```
// 替代https://nodejs.org/dist/
N_NODE_MIRROR=https://npmmirror.com/mirrors/node n lts

```
删除指定版本: 
```
sudo n rm v14.5.0
// 或
n uninstall 16.19.1
```
win可以使用[nvm](./windows操作.md)来管理node版本

## 创建react项目

#### npx方式:
```
npx create-react-app react-demo
```
ts：
```
npx create-react-app ts-demo --template typescript
```
查看信息：`create-react-app --info`

#### NextJs:
自动初始化：
```
npx create-next-app@latest
# 指定版本号
npx create-next-app@^13.5.6 --use-pnpm
# or
yarn create next-app
# or
pnpm create next-app

# ts支持
npx create-next-app@latest --typescript
# or
yarn create next-app --typescript
# or
pnpm create next-app --typescript

```
手动初始化：
```
npm install next react react-dom
# or
yarn add next react react-dom
# or
pnpm add next react react-dom

# 修改package.json文件
"scripts": {
  "dev": "next dev",
  "build": "next build",
  "start": "next start",
  "lint": "next lint"
}


```

在配置选项选择时，Would you like to use App Router? (recommended): 是否使用App Router，选择yes则使用app目录的路由系统，选择no则使用pages目录的路由系统


#### Vite搭建vue3.x项目
```
npm create vite@latest
# 或
yarn create vite
# 或
pnpm create vite --template react-ts

```


## git或sourcetree 一直提示输入密码
```
git config --global credential.helper osxkeychain
```

## RN安卓运行报错
```
No toolchains found in the NDK toolchains folder for ABI with prefix: arm-linux-androideabi
```
原因：新版Ndk目录下缺失platforms文件夹及内容，可以再下载一个21.4的版本
解决参考：https://www.jianshu.com/p/09b32f480e49

## RN安装react-devtools报错
**安装electron失败 postinstall: `node install.js`**
解决方法：将electron下载地址指向taobao镜像
```
npm config set electron_mirror "https://npm.taobao.org/mirrors/electron/"
```

## RN iOS运行指定模拟器
`yarn ios --simulator="iPhone 14"`

## [devServer](http://t.zoukankan.com/jkr666666-p-11067270.html)
* port:配置属性指定了开启服务的端口号
* host:设置的是服务器的主机号,可设置为`0.0.0.0`
* proxy: 设置代理接口api

```
devServer: {
   port:7000,
   host:'0.0.0.0',
   proxy: {
    '/api': {
        target: 'http://your_api_server.com',
        changeOrigin: true,
        pathRewrite: {
            '^/api': ''
        }
   }

}

```
类似的代理还有`setupProxy.js`

## RN报错：[_classCallCheck](https://juejin.cn/post/7063401589901361166)
之前运行没问题，突然报了这个错**Unhandled JS Exception: Unexpected identifier ‘_classCallCheck’. import call expects exactly one argument. no stack**, 搜索是babel相关插件的问题，
排查发现是`metro-react-native-babel-preset`版本低导致的，
原来版本：`"metro-react-native-babel-preset": "0.51.1",`；
修改后：`"metro-react-native-babel-preset": "0.59.0",`

## Nginx配置
安装：	`brew install nginx`
检查配置文件是否有语法错误: `nginx -t`
启动：nginx
停止：nginx -s stop
刷新：nginx -s reload
查看配置：`brew info nginx`
打开安装目录：`open /usr/local/etc/nginx/`
配置文件路径: /usr/local/etc/nginx/nginx.conf

```
## http配置反向代理的参数
server {
    listen    8080;
    server_name localhost;
 
    ## 1. 用户访问 http://localhost，则反向代理到 https://github.com
    location / {
        proxy_pass  https://github.com;
        proxy_set_header X-Nginx-Proxy true;
        proxy_redirect     off;
        proxy_set_header   Host             $host;        # 传递域名
        proxy_set_header   X-Real-IP        $remote_addr; # 传递ip
        proxy_set_header   X-Scheme         $scheme;      # 传递协议
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    }
}

```
代理前端服务配置[参考](https://blog.csdn.net/shuxiaohua/article/details/124560311)：
```
server {
        listen       10080;
        server_name  localhost, 127.0.0.1;
        
        location / {
            proxy_set_header X-Nginx-Proxy true;
            proxy_pass   http://localhost:10086/;
            proxy_redirect off;

            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_set_header Upgrade-Insecure-Requests 1;
            proxy_set_header X-Forwarded-Proto https;

        }

        
        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        location /mbff {
           proxy_pass   https://test.wang.com/mbff;
        }
        location /test {
           proxy_pass   https://www.baidu.com/;
        }
			# 代理 //host/xxxxxxx.png时需要注意路径问题
        location /shop-image/ {
           proxy_pass  https://test.images.cn.myhuaweicloud.com/;   
        }
        
    }


```

## Yarn 报错
如下：
```
..../sbc-boss/node_modules/gifsicle: Command failed.
Exit code: 1
Command: node lib/install.js
Arguments: 
Directory: ...../sbc-boss/node_modules/gifsicle
Output:
⚠ getaddrinfo ENOTFOUND raw.githubusercontent.com
  ⚠ gifsicle pre-build test failed
  ℹ compiling from source
  ✖ Error: Command failed: /bin/sh -c autoreconf -ivf
/bin/sh: autoreconf: command not found
```

分析[参考](https://segmentfault.com/a/1190000040764846),其实是我们无法访问raw.githubusercontent.com这个网址导致的
解决方案1：
sudo vim /etc/hosts 增加如下内容
```
# GitHub Start
192.30.255.112  gist.github.com
192.30.255.112  github.com
192.30.255.112  www.github.com
151.101.56.133  avatars0.githubusercontent.com
151.101.56.133  avatars1.githubusercontent.com
151.101.56.133  avatars2.githubusercontent.com
151.101.56.133  avatars3.githubusercontent.com
151.101.56.133  avatars4.githubusercontent.com
151.101.56.133  avatars5.githubusercontent.com
151.101.56.133  avatars6.githubusercontent.com
151.101.56.133  avatars7.githubusercontent.com
151.101.56.133  avatars8.githubusercontent.com
151.101.56.133  camo.githubusercontent.com
151.101.56.133  cloud.githubusercontent.com
151.101.56.133  gist.githubusercontent.com
151.101.56.133  marketplace-screenshots.githubusercontent.com
151.101.56.133  raw.githubusercontent.com
151.101.56.133  repository-images.githubusercontent.com
151.101.56.133  user-images.githubusercontent.com
# GitHub End

```
解决方案2:
在 package.json 文件中 配置忽略该错误：
```
{
  
  "scripts": {
    ....
  },
  "dependencies": {
    ......
  },
    
 // 问题解决配置
  "resolutions": {
    "//": "Used to install imagemin dependencies, because imagemin may not be installed in China. If it is abroad, you can delete it",
    "bin-wrapper": "npm:bin-wrapper-china",
    "rollup": "^2.72.0"
  }
}

```

## Charles下载安装
[下载地址](https://www.charlesproxy.com/latest-release/download.do)
文章：[https://www.jianshu.com/p/113fc82f603e](https://www.jianshu.com/p/113fc82f603e)

### 配置
1. 安装证书：Help->SSL Proxxying->Install Charles Root Certificate
2. 设置信任证书：打开 钥匙串访问找到charles证书，设置选择始终信任
3. 端口配置：Proxy->Proxying Settings 勾选Enable SOCKS proxy
4. 端口配置：Proxy->SSL Proxying Settings 点击add 添加 `*:*`和`*:443`端口监听
5. iOS模拟器抓包：Help->SSL Proxxying->Install Charles in iOS Simulators
6. 真机：Help->SSL Proxxying->Install Charles in device
7. 打开模拟器设置证书信任
8. 真机需在同一局域网下，移动设备需手动设置http代理，即设置服务器IP地址和端口8888

## tree-node-cli
用于生成项目文件目录结构

1. 全局安装：`npm i tree-node-cli -g`
2. 定位到项目根目录，生成目录结构文件

```
tree -L 4 -I "node_modules|themes|public" > tree.md

```
* `tree -L n` 显示项目的层数。n 代表你要生成文件夹树的层级;
* `tree -I "node_modules|themes|public"` 表示要过滤的文件或目录, 过滤多个文件或目录用 | 分割;
* `tree > tree.md` 表示将树结构输出到 tree.md 这个文件;

## 项目代码行数统计
```
git log --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }'

```

## ESLint 检测配置
package.json文件修改
```
"eslintConfig": {
    "rules": {
       "indent": [1, 4], //设置缩进
       "no-unused-vars":"off"  //关闭警告
     },
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },

```

## start 报出问题
```
[DEP_WEBPACK_DEV_SERVER_ON_AFTER_SETUP_MIDDLEWARE] DeprecationWarning: 'onAfterSetupMiddleware' option is deprecated. Please use the 'setupMiddlewares' option.
(Use `node --trace-deprecation ...` to show where the warning was created)
(node:14644) [DEP_WEBPACK_DEV_SERVER_ON_BEFORE_SETUP_MIDDLEWARE] DeprecationWarning: 'onBeforeSetupMiddleware' option is deprecated. Please use the 'setupMiddlewares' option.
```

## 插件跨域
https://www.crx4chrome.com/crx/53489/

## depcheck
用于检查项目中未使用的依赖项

## 安全漏洞修复策略

例如lodash@4.17.4具有安全漏洞，已修复的版本4.17.12
```
npm audit fix
```
执行的逻辑相当于：
```
npm update lodash@4.17.12
```

#### 间接依赖漏洞

假设我们现在的依赖路径非常深,例如`@commitlint/load`依赖`lodash` 直接的修复不在这个范围，所以我们不能直接通过升级`Lodash`来修复漏洞,那么修复策略为:
```
npm update @commitlint/load@1.0.2 --depth=2
```
npm update 只会检查更新顶层的依赖，更新更深层次的依赖版本需要使用 --depth 指定更新的深度

#### 强制修复漏洞
不能找到一个可修复的版本`npm audit fix`命令就无能为力了,可以尝试
```
npm audit fix --force
```
这回强制将依赖更新到最新版本，一定要谨慎使用！

npm 还提供了一些其他的修复命令命令：
```
npm audit fix --package-lock-only
```

在不修改`ode_modules`的情况下执行`audit fix`，仍然会更改 `pkglock`。

`npm audit fix --only=prod`跳过更新 `devDependencies`

**不可修复漏洞**:以上的修复策略都不能解决这个安全漏洞，那说明此漏洞是无法自动修复的，需要人工判定处理

## 关闭安全检查

* 安装单个包关闭安全审查: `npm install example-package-name --no-audit`
* 安装所有包关闭安全审查 - 运行: `npm set audit false`
* 手动将`~/.npmrc`配置文件中的`audit`修改为`false`

## 解读依赖漏洞报告

执行`npm audit --json`将会打印出一个详细的`json`格式的安全报告，在这个报告里可以看到这些漏洞的详情，以及具体的漏洞修复策略。

## 前端相关配置文件

#### .babelrc
配置 Babel 预设和插件，Babel 还支持其他几种配置方式：

* `babel.config.js`: 使用 JavaScript 导出配置，适用于 monorepos 或全局配置
* `babel.config.json`: JSON 格式的全局配置文件
* `package.json`: 在项目的 package.json 文件中使用 babel 字段来定义 Babel 配置

#### .eslintrc.js
ESLint的配置文件，可以配置代码检查规则、集成插件和扩展、环境设置。ESLint 还支持其他几种配置文件格式：

* `.eslintrc.json`: JSON 格式的配置文件。
* `.eslintrc.yml` 或 `.eslintrc.yaml`: YAML 格式的配置文件
* `package.json`: 在项目的 package.json 文件中使用`eslintConfig` 字段来定义ESLint配置

#### .node-version
该文件用于指定项目的node版本，配合`nvm`工具并自动切换到指定的 Node.js 版本。
```
# 指定具体版本
16.14.0

# 使用稳定版本
18.x

```

#### .prettierrc
是 Prettier 的配置文件，用于定义代码格式化的规则。还支持其他的配置文件：

* `prettier.config.js`: 使用 JavaScript 导出配置
* `.prettierrc.json`: JSON 格式的配置文件
* `.prettierrc.yaml`或`.prettierrc.yml`: YAML 格式的配置文件
* `.prettierrc.toml`: TOML 格式的配置文件

#### .stylelintrc
Stylelint的配置文件，它是一个强大的 CSS 和预处理器的代码风格检查工具。通过这个配置文件可以定义代码样式规则，确保样式代码的一致性和质量。也支持上面的几种配置文件格式。

#### .npmrc
是npm用来存储配置信息的文件，被用来控制依赖包的安装来源、认证信息、缓存位置、日志级别等。`.npmrc`优先级规则: 项目级别最高->用户级别次之->全局配置文件最低

```
# 指定仓库源
registry=https://registry.npmmirror.com

# 特定包的私有源，即所有 @parern 范围内的包从该私有注册表获取
@parern:registry=https://e.coding.net

# 特定包的私有注册表
react-native-umeng:registry=http://192.168.30.12

# 指定的环境变量
sass_binary_site=https://cdn.npmmirror.com/binaries/node-sass

# 进行身份验证，即对registry地址的所有请求都需要身份验证保护私有包不被未授权访问
always-auth=true
registry=http://192.168.13.97:8081/repository/local-npm/

# 私有库认证信息，需登录私有npm库生成访问令牌
registry=https://private-registry.example.com
//private-registry.example.com/:_authToken=<your-token>
# 确保总是进行身份验证
always-auth=true

# 作用域语法令牌,只对@parern下的库做认证
@parern:registry=https://private-registry.example.com/
//private-registry.example.com/:_authToken=<YOUR_AUTH_TOKEN>

# 忽略 SSL 错误
strict-ssl=false

# 设置缓存目录
cache=/path/to/cache

# 日志配置
loglevel=verbose

# 代理设置
https-proxy=http://myproxy:8080
http-proxy=http://myproxy:8080

```

根据库指定的环境变量，设置对应的下载地址，例如`node-sass`库的变量`sass_binary_site`。例如遇到如下报错：

`Cannot download "https://github.com/sass/node-sass/releases/download/v4.14.1/darwin-x64-83_binding.node": ` 下载报错。

有可能node版本与node-sass版本不对应。

查看一下：node: 14.18.0 node-sass: 4.14.1, 查看对比版本是可以对应上的。
第一种解决方案就是把`node-sass`库使用`sass`替换。如果其他库中有依赖的，可以添加`.npmrc`文件修改如下：
```
# 这个没成功
# sass_binary_site=https://registry.npmmirror.com/mirrors/node-sass
# 这个成功了
sass_binary_site=https://cdn.npmmirror.com/binaries/node-sass

```

## 前端掌握技术

* ts
* less、sass
* UI框架：antd、element-ui、mui
* webpack、rollup
* echarts、G2、G3、D3、D6
* three.js
* vite: 类似webpack的打包编辑器
* react-app-rewired、@craco/craco、babel : 路径别名配置
* dotenv/dotenv-cli: 多环境变量配置
* React-router
* redux、vuex
* Vue3.0、nuxtjs、nextjs
* tailwindcss: css框架


