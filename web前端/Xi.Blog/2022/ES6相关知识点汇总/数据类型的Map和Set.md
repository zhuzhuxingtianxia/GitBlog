## ES6新增的数据类型Map和Set

Javascript的默认对象表示方式 {} ，即一组键值对。

但是Javascript的对象有个小问题，就是键必须是字符串。但实际上Number或者其他数据类型作为键也是非常合理的。

为了解决这个问题，最新的ES6规范引入了新的数据类型Map。

 

1.Map

ES6新增了Map数据结构，Map对象保存键值对，任何值(原始值或对象)都可以作为一个键或一个值。

Map是一组键值对，有key 也有value。

初始化Map需要一个二维数组，或者直接初始化一个空Map。 Map具有以下方法：

set ，添加key-value

has，判断是否存在key

get，获取对应key的值

delete， 删除对应的key以及value



```javascript
var m = new Map();  //空Map
m.set('one', 10);   //添加新的key-value
m.set('two', 20);

var a = m.has('one');  //是否存在key 'one'
a;        //true

var b = m.get('two');
b;        //20

m.delete('one');       //删除key 'one'

m.get('one');   //undefined
```



由于一个key只能对应一个value，所以，多次对一个key放入value，后面的值会把前面的值冲掉：

```javascript
var m = new Map();
m.set('one', 10);
m.set('one', 20);
m.get('one');     //20
```

如果key是一个对象。

```javascript
let m = new Map();
let obj = {
    name: 'one',
    sex: '男'
};
let a = m.set(obj, 'myObj');

console.log(a);      //Map { {name: 'one', sex: '男'} => 'myObj' }
```



------

 

2.Set

Set 和 Map类似，也是一组key的集合，但不存储value。由于key不能重复，所以，在Set中，没有重复的key。

要创建一个Set，需要提供一个Array作为输入，或者直接创建一个空Set：

```javascript
var s1 = new Set();  //空Set
var s2 = new Set([1,2,3]);  //含1,2,3
```

重复元素在Set中自动被过滤：

```javascript
var s = new Set([1,2,3,3,'3']);
s;  // Set {1,2,3, "3"}
```

注意数字3和字符串'3'是不同的元素。

通过add() 方法可以添加元素到 Set中，乐意重复添加，但不会有效果：

```javascript
s.add(4);
s;  // Set {1,2,3, '3', 4}
s.add(4);
s;  // 仍然是 Set {1,2,3, '3', 4}
```

通过delete() 方法可以删除元素：

```javascript
s.delete(3);
console.log(s);  // Set {1,2, '3'}
```

 

------

 

3.总结

Map和Set是ES6标准新增的数据类型。

兼容性：

IE8及以下版本不支持Map对象。