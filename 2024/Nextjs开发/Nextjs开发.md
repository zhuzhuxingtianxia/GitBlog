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


