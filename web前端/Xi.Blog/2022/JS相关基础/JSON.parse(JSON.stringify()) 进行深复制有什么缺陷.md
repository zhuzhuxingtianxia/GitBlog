# JSON.parse(JSON.stringify()) 进行深复制有什么缺陷

```javascript
    let syz = {
      name: '孙艺珍',
      age: 20,
      //
      birthday: new Date('1996/01/01'), // Date日期自动用 toJSON() 或 toISOString() 转成了字符串
      // NaN和Infinity格式的数值会被当做是null
      inf: Infinity,
      NaN: NaN,
      // undefined、Symbol类型、函数会被忽略
      love: undefined,
      sym: Symbol('小明同学'),
      say() {
        console.log('说话')
      },
      obj: { a: 1, b: 2 },
      reg: /(0-9)/ // 正则会转成空对象 {}
    }
    // syz.z = syz 此时用JSON转会报错

    let syz1 = JSON.parse(JSON.stringify(syz))
    let syz2 = _.cloneDeep(syz)
    
```



![img](https://img2020.cnblogs.com/blog/1742906/202012/1742906-20201217175347664-1576812970.png)

 

参考：[JSON.parse(JSON.stringify()) 进行深复制有什么缺陷](https://www.cnblogs.com/wuqilang/p/14151005.html)