# Nextjs开发
[nextjs官网地址](https://nextjs.org/docs/getting-started/installation)

版本说明：
next@12.x 使用 pages 目录进行路由
next@13.x 使用 app 目录的路由系统, 并兼容pages目录， 优先app目录，app目录没有时，再使用pages目录

[引导学习地址](https://nextjs.org/learn/dashboard-app/getting-started)

## 初始化项目

```
npx create-next-app@^13.5.6 --typescript
```
* What is your project named? : 设置项目的名称，例如next02
* Would you like to use ESLint?: 是否使用ESLint，选择no
* Would you like to use Tailwind CSS? : 是否使用Tailwind CSS，选择yes
* Would you like to use `src/` directory?: 是否想要使用src目录，默认会把所有文件放在根目录，为了源代码好管理，这里选择yes
* Would you like to use App Router? (recommended): 是否使用App Router，选择yes则使用app目录的路由系统，选择no则使用pages目录的路由系统
* Would you like to customize the default import alias (@/*)? : 是否要自定义别名，默认是@/*，选择no

## 结构
* `./pages/_app.tsx`: 自定义app组件, 可以在此文件导入全局样式表
* `./pages/_document.tsx`: 自定义document,

## 路由
nest.js是基于文件系统的路由器，文件夹用于定义路由，路由是嵌套文件夹的单一路径，遵循文件系统层次结构，从根文件一直到包含 page.tsx。app或pages目录下的结构生成。
例如pages目录下的生成: 目录`pages/about/index.tsx` 对应的路由就是 `/about`
动态参数，目录`pages/user/[userId].tsx` 对应路由 `/user/xxx`
例如app目录生成: `pages/about/page.tsx` 对应路由`/about`

## 预渲染静态页面

根据参数获取外部数据: `getStaticProps` 该函数在构建时被调用，并允许你在预渲染时将获取的数据作为 `props` 参数传递给页面.
```
// 此函数在构建时被调用
export async function getStaticProps() {
  // 调用外部 API 获取博文列表
  const res = await fetch('https://.../posts')
  const posts = await res.json()

  // 通过返回 { props: { posts } } 对象，Blog 组件
  // 在构建时将接收到 `posts` 参数
  return {
    props: {
      posts,
    },
  }
}

```

动态路由渲染静态页面: `getStaticPaths`,该函数在构建时被调用，并允许你指定要预渲染的路径。同时也要调用`getStaticProps`函数。
```
// 此函数在构建时被调用
export async function getStaticPaths() {
  // 调用外部 API 获取博文列表
  const res = await fetch('https://.../posts')
  const posts = await res.json()

  // 据博文列表生成所有需要预渲染的路径
  const paths = posts.map((post) => ({
    params: { id: post.id },
  }))

  // We'll pre-render only these paths at build time.
  // { fallback: false } means other routes should 404.
  return { paths, fallback: false }
}

```

## 动态渲染SSR
服务器端渲染，则会在 每次页面请求时 重新生成页面的 HTML.
`getServerSideProps`服务器将在每次页面请求时调用此函数.
```
function Page({ data }) {
  // Render data...
}

// This gets called on every request
export async function getServerSideProps() {
  // Fetch data from external API
  const res = await fetch(`https://.../data`)
  const data = await res.json()

  // Pass data to the page via props
  return { props: { data } }
}

export default Page

```
getServerSideProps 类似于 getStaticProps，但两者的区别在于 `getServerSideProps` 在每次页面请求时都会运行，而在构建时不运行。

由于服务器端渲染会导致性能比“静态生成”慢，因此仅在绝对必要时才使用此功能。

## pm2部署

pm2部署，使用pm2启动项目，需要安装pm2
```
npm install pm2 -g
```
启动项目
```
pm2 start npm --name "next02" -- start
```
查看项目列表
```
pm2 list
```
重启项目
```
pm2 restart next02
```
停止项目
```
pm2 stop next02
```

pm2.json为pm2配置文件:
* apps: 要启动的应用的内容，这里是一个数组，支持一次性配置多个
* name: 应用的名称，会显示在pm2的列表中
* script，启动脚本的位置。这里默认使用nodejs启动
* args: 启动参数，这里一般不需要
* env: 环境变量, 这里设置了一个端口

使用配置文件启动在根目录执行： `pm2 start pm2.json`

## Docker部署

