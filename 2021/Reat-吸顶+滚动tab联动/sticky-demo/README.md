# sticky-demo
项目创建：
```
create-react-app sticky-demo
```
添加`antd-mobile`:
```
npm install antd-mobile --save
```
添加`jquery`:
```
npm i jquery --save
```

## 配置
```
npm install react-app-rewired customize-cra --save-dev
```
修改`package.json`文件。
添加`config-overrides.js`用于修改默认配置
按需加载：
```
npm install babel-plugin-import --save-dev
```
修改`config-overrides.js`文件


### `npm start`

```
Don't try to install it manually: your package manager does it automatically.
However, a different version of babel-loader was detected higher up in the tree:

  /Users/jion/node_modules/babel-loader (version: 7.1.5) 

Manually installing incompatible versions is known to cause hard-to-debug issues.

If you would prefer to ignore this check, add SKIP_PREFLIGHT_CHECK=true to an .env file in your project.
That will permanently disable this message but you might encounter other issues.
```

* **方案:**
    项目中创建一个 `.env` 的文件,内容写上 `SKIP_PREFLIGHT_CHECK=true`



## `npm build`
