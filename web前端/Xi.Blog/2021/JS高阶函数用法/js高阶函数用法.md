# js高阶函数用法 

## filter(): 

语法： 
var filteredArray = array.filter(callback[, thisObject]); 
参数说明： 
callback： 要对每个数组元素执行的回调函数。 
thisObject ： 在执行回调函数时定义的this对象。 

``` 
//过滤掉小于 10 的数组元素： 
//代码： 
function isBigEnough(element, index, array) { 
return (element >= 10); 
} 
var filtered = [12, 5, 8, 130, 44].filter(isBigEnough); 
// 12, 130, 44 
//结果：[12, 5, 8, 130, 44].filter(isBigEnough) ： 12, 130, 44 
```

功能说明： 
对数组中的每个元素都执行一次指定的函数（callback），并且创建一个新的数组，该数组元素是所有回调函数执行时返回值为 true 的原数组元素。它只对数组中的非空元素执行指定的函数，没有赋值或者已经删除的元素将被忽略，同时，新创建的数组也不会包含这些元素。 
回调函数可以有三个参数：当前元素，当前元素的索引和当前的数组对象。 
如参数 thisObject 被传递进来，它将被当做回调函数（callback）内部的 this 对象，如果没有传递或者为null，那么将会使用全局对象。 
filter 不会改变原有数组，记住：只有在回调函数执行前传入的数组元素才有效，在回调函数开始执行后才添加的元素将被忽略，而在回调函数开始执行到最后一个元素这一期间，数组元素被删除或者被更改的，将以回调函数访问到该元素的时间为准，被删除的元素将被忽略。 

## map(): 
``` 
//将所有的数组元素转换为大写： 
var strings = ["hello", "Array", "WORLD"]; 
function makeUpperCase(v) 
{ 
return v.toUpperCase(); 
} 
var uppers = strings.map(makeUpperCase); 
// uppers is now ["HELLO", "ARRAY", "WORLD"] 
// strings is unchanged 
//结果：["hello", "Array", "WORLD"].map(makeUpperCase) ： HELLO, ARRAY, WORLD 
```
或 
``` 
var users = [ 
{name: "张含韵", "email": "zhang@email.com"}, 
{name: "江一燕", "email": "jiang@email.com"}, 
{name: "李小璐", "email": "li@email.com"} 
]; 
var emails = users.map(function (user) { 
return user.email; 
}); 
console.log(emails.join(", ")); 
// zhang@email.com, jiang@email.com, li@email.com 
```
功能说明： 
[].map(function(value, index, array) { 
// ... 
}); 
基本用法跟forEach方法,function需要有return值. 
## some(): 
对数组中的每个元素都执行一次指定的函数（callback），直到此函数返回 true，如果发现这个元素，some 将返回 true，如果回调函数对每个元素执行后都返回 false ，some 将返回 false。它只对数组中的非空元素执行指定的函数，没有赋值或者已经删除的元素将被忽略。 
``` 
//检查是否有数组元素大于等于10： 
function isBigEnough(element, index, array) { 
return (element >= 10); 
} 
var passed = [2, 5, 8, 1, 4].some(isBigEnough); 
// passed is false 
passed = [12, 5, 8, 1, 4].some(isBigEnough); 
// passed is true 
//结果： 
//[2, 5, 8, 1, 4].some(isBigEnough) ： false 
//[12, 5, 8, 1, 4].some(isBigEnough) ： true 
```
## find(): 
ES6开始支持，find()方法返回数组中符合测试函数条件的第一个元素,否则返回undefined; 
*注意:* find() 对于空数组，函数是不会执行的。 
*注意:* find() 并没有改变数组的原始值。 
``` 
const array1 = [5, 12, 8, 130, 44]; 
const found = array1.find(element => element > 10); 
console.log(found); 
// expected output: 12 
```
##every(): 
对数组中的每个元素都执行一次指定的函数（callback），直到此函数返回 false，如果发现这个元素，every 将返回 false，如果回调函数对每个元素执行后都返回 true ，every 将返回 true。它只对数组中的非空元素执行指定的函数，没有赋值或者已经删除的元素将被忽略 
``` 
//测试是否所有数组元素都大于等于10： 
function isBigEnough(element, index, array) { 
return (element >= 10); 
} 
var passed = [12, 5, 8, 130, 44].every(isBigEnough); 
// passed is false 
passed = [12, 54, 18, 130, 44].every(isBigEnough); 
// passed is true 
//结果： 
//[12, 5, 8, 130, 44].every(isBigEnough) 返回 ： false 
//[12, 54, 18, 130, 44].every(isBigEnough) 返回 ： true 
```
## sort() 
用于对数组的元素进行排序,并返回数组。默认排序顺序是根据字符串Unicode码点。 
参数fun：参数可选。规定排序顺序。必须是函数。 
不传参数，将不会按照数值大小排序，按照字符编码的顺序进行排序 
``` 
var arr = ['General','Tom','Bob','John','Army']; 
var resArr = arr.sort(); 
console.log(resArr);//输出 ["Army", "Bob", "General", "John", "Tom"] 
var arr2 = [30,10,111,35,1899,50,45]; 
var resArr2 = arr2.sort(); 
console.log(resArr2);//输出 [10, 111, 1899, 30, 35, 45, 50] 
```
传入参数，实现升序，降序 
``` 
var arr3 = [30,10,111,35,1899,50,45]; 
arr3.sort(function(a,b){ 
return a - b; 
}) 
console.log(arr3);//输出 [10, 30, 35, 45, 50, 111, 1899] 
var arr4 = [30,10,111,35,1899,50,45]; 
arr4.sort(function(a,b){ 
return b - a; 
}) 
console.log(arr4);//输出 [1899, 111, 50, 45, 35, 30, 10] 
```
根据数组中的对象的某个属性值排序 
``` 
var arr5 = [{id:10},{id:5},{id:6},{id:9},{id:2},{id:3}]; 
arr5.sort(function(a,b){ 
return a.id - b.id 
}) 
console.log(arr5); 
//输出新的排序 
// {id: 2},{id: 3},{id: 5},{id: 6}, {id: 9},{id: 10} 
```
根据数组中的对象的多个属性值排序，多条件排序 
``` 
var arr6 = [{id:10,age:2},{id:5,age:4},{id:6,age:10},{id:9,age:6},{id:2,age:8},{id:10,age:9}]; 
arr6.sort(function(a,b){ 
if(a.id === b.id) 
{//如果id相同，按照age的降序 
return b.age - a.age } 
else{ 
return a.id - b.id 
} 
}) 
console.log(arr6); 
//输出新的排序:{id: 2, age: 8}, {id: 5, age: 4}, {id: 6, age: 10}, {id: 9, age: 6},{id: 10, age: 9}, {id: 10, age: 2} 
```
## 合并数组： 
将数组合并到第一个数组中，不会有新数组创建 
``` 
let arr1=[1,2,3]; 
let arr2=[4,5,6]; 
Array.prototype.push.apply(arr1,arr2); //将arr2合并到了arr1中 
```
或 
``` 
let arr1=[1,2,3]; 
let arr2=[4,5,6]; 
arr1.push.apply(arr1,arr2); //arr1:[1,2,3,4,5,6] 
```
## concat（） 
将两个数组连接在一起，并返回一个新数组 
``` 
例子：arr1=[1,2,3,4] 
arr2=[5,6,7,8] 
alert(arr1.concat(arr2)) //结果为[1,2,3,4,5,6,7,8] 
```
## 求数组最大值: 
``` 
Math.max.apply(null,arr) 
```
## forEach(): 
``` 
//打印数组内容： 
function printElt(element, index, array) { 
console.log("[" + index + "] is " + element); 
} 
[2, 5, 9].forEach(printElt); 
//结果： 
//[0] is 2 
//[1] is 5 
//[2] is 9 
```
## lastIndexOf(): 
### 语法 
``` 
var index = array.lastIndexOf(searchElement[, fromIndex]); 
```
参数说明 
searchElement： 要搜索的元素 
fromIndex ： 开始搜索的位置，默认为数组的长度（length），在这样的情况下，将搜索所有的数组元素。搜索是反方向进行的。 
功能说明 
比较 searchElement 和数组的每个元素是否绝对一致（===），当有元素符合条件时，返回当前元素的索引。如果没有发现，就直接返回 -1 。 
``` 
//查找符合条件的元素： 
var array = [2, 5, 9, 2]; 
var index = array.lastIndexOf(2); 
// index is 3 
index = array.lastIndexOf(7); 
// index is -1 
index = array.lastIndexOf(2, 3); 
// index is 3 
index = array.lastIndexOf(2, 2); 
// index is 0 
index = array.lastIndexOf(2, -2); 
// index is 0 
index = array.lastIndexOf(2, -1); 
// index is 3 
//结果： 
//[2, 5, 9, 2].lastIndexOf(2) ： 3 
//[2, 5, 9, 2].lastIndexOf(7) ： -1 
//[2, 5, 9, 2].lastIndexOf(2, 3) ： 3 
//[2, 5, 9, 2].lastIndexOf(2, 2) ： 0 
//[2, 5, 9, 2].lastIndexOf(2, -2) ： 0 
//[2, 5, 9, 2].lastIndexOf(2, -1) ： 3 
```
## indexOf(): 
功能与lastIndexOf()一样，搜索是正向进行的 
``` 
//查找符合条件的元素： 
var array = [2, 5, 9]; 
var index = array.indexOf(2); 
// index is 0 
index = array.indexOf(7); 
// index is -1 
//结果： 
//[2, 5, 9].indexOf(2) ： 0 
//[2, 5, 9].indexOf(7) ： -1 
```
## reverse() 
将数组反序 
``` 
var a = [1,2,3,4,5]; 
var b = a.reverse(); //a：[5,4,3,2,1] b：[5,4,3,2,1] 
```
## splice() 
splice() 方法向/从数组中添加/删除项目，然后返回被删除的元素 
注意：该方法会改变原始数组 
arrayObject.splice(index,howmany,item1,.....,itemX) 
index:必需。整数，规定添加/删除项目的位置，使用负数可从数组结尾处规定位置 
howmany:必需。要删除的元素数量。如果设置为 0，则不会删除元素。 
item1...itemX:可选。向数组添加的新元素。 
``` 
var arr = [1,2,3,4] 
console.log(arr.splice(1,1));//[2] 
console.log(arr);//[1,3,4] 
```
删除并添加新元素，从索引值为2处删除两个元素并添加元素7，8，9 
``` 
var a = [1,2,3,4,5]; 
var b = a.splice(2,2,7,8,9); //a：[1,2,7,8,9,5] b：[3,4] 
```
## slice() 
方法可从已有的数组中返回选定的元素 
arr.slice(start,end); //start为初始位置,end为结尾位置,返回的结果是从start到end(不取)的新数组 
arr.slice(start); //选取从start开始直至最后一个元素 
``` 
var arr1 = [1,2,3,4]; 
console.log(arr1.slice(1)); //[2, 3, 4] 
console.log(arr1.slice(1,2));//[2] 
console.log(arr1);//[1,2,3,4] 
```
## shift() 
删除原数组第一项，并返回删除元素的值；如果数组为空则返回undefined 
``` 
var a = [1,2,3,4,5]; 
var b = a.shift(); //a：[2,3,4,5] b：1 
```
## unshift() 
将参数添加到原数组开头，并返回数组的长度 
``` 
var a = [1,2,3,4,5]; 
var b = a.unshift(-2,-1); //a：[-2,-1,1,2,3,4,5] b：7 
```
注：在IE6.0下测试返回值总为undefined，FF2.0下测试返回值为7，所以这个方法的返回值不可靠，需要用返回值时可用splice代替本方法来使用。 
## flat() 
``` 
var newArray = arr.flat([depth]); 
//展开范例 
var arr1 = [1, 2, [3, 4]]; 
arr1.flat(); 
// [1, 2, 3, 4] 
var arr2 = [1, 2, [3, 4, [5, 6]]]; 
arr2.flat(); 
// [1, 2, 3, 4, [5, 6]] 
var arr3 = [1, 2, [3, 4, [5, 6]]]; 
arr3.flat(2); 
// [1, 2, 3, 4, 5, 6] 
```
當遭遇空元素時 
flat()函數會自動清除陣列中空的元素 
``` 
var arr4 = [1, 2, , 4, 5]; 
arr4.flat(); 
// [1, 2, 4, 5] 
```
## reduce() 
reduce() 方法接收一个函数作为累加器,reduce 为数组中的每一个元素依次执行回调函数，不包括数组中被删除或从未被赋值的元素，接受四个参数：初始值（上一次回调的返回值），当前元素值，当前索引，原数组 
语法：arr.reduce(callback,[initialValue]) 
``` 
callback:函数中包含四个参数 
- previousValue （上一次调用回调返回的值，或者是提供的初始值（initialValue）） 
- currentValue （数组中当前被处理的元素） 
- index （当前元素在数组中的索引) 
- array （调用的数组） 
initialValue （作为第一次调用 callback 的第一个参数。） 
```
#### 应用 
``` 
const arr = [1, 2, 3, 4, 5] 
const sum = arr.reduce((pre, item) => { 
return pre + item 
}, 0) 
console.log(sum) // 15 
```
以上回调被调用5次，每次的参数详见下表 
| callback                                                     | previousValue | currentValue | index |      array      | return value |
| ------------------------------------------------------------ | :-----------: | :----------: | :---: | :-------------: | -----------: |
| 第1次                                                        |       0       |      1       |   0   | [1, 2, 3, 4, 5] |            1 |
| 第2次                                                        |       1       |      2       |   1   | [1, 2, 3, 4, 5] |            3 |
| 第3次                                                        |       3       |      3       |   2   | [1, 2, 3, 4, 5] |            6 |
| 第4次                                                        |       6       |      4       |   3   | [1, 2, 3, 4, 5] |           10 |
| 第5次                                                        |      10       |      5       |   5   | [1, 2, 3, 4, 5] |           15 |
| ## pop()                                                     |               |              |       |                 |              |
| 删除原数组最后一项，并返回删除元素的值；如果数组为空则返回undefined |               |              |       |                 |              |
``` 
var a = [1,2,3,4,5]; 
var b = a.pop(); //a：[1,2,3,4] b：5 //不用返回的话直接调用就可以了 
```
##push() 
将参数添加到原数组末尾，并返回数组的长度 
``` 
var a = [1,2,3,4,5]; 
var b = a.push(6,7); //a：[1,2,3,4,5,6,7] b：7 
```
##数组中对象某属性的最大最小值 
查找对象数组中某属性的最大最小值的快捷方法 
例如要查找array数组中对象的value属性的最大值 
``` 
var array=[ 
{ 
"index_id": 119, 
"area_id": "18335623", 
"name": "满意度", 
"value": "100" 
}, 
{ 
"index_id": 119, 
"area_id": "18335624", 
"name": "满意度", 
"value": "20" 
}, 
{ 
"index_id": 119, 
"area_id": "18335625", 
"name": "满意度", 
"value": "80" 
}]; 
```
一行代码搞定 
``` 
Math.max.apply(Math, array.map(function(o) {return o.value})) 
```
执行以上一行代码可返回所要查询的array数组中对象value属性的最大值100。 
同理，要查找最小值如下即可： 
``` 
Math.min.apply(Math, array.map(function(o) {return o.value})) 
```
## 合并对象assign 
``` 
var o1 = { a: 1 }; 
var o2 = { b: 2 }; 
var o3 = { c: 3 }; 
var obj = Object.assign(o1, o2, o3); 
console.log(obj); // { a: 1, b: 2, c: 3 } 
console.log(o1); // { a: 1, b: 2, c: 3 }, 注意目标对象自身也会改变。 
```
##split() 
使用一个指定的分隔符把一个字符串分割存储到数组 
``` 
例子： str=”jpg|bmp|gif|ico|png”; 
arr=str.split(”|”); 
//arr=[jpg”,”bmp”,”gif”,”ico”,”png”] 
```
##join() 
使用您选择的分隔符将一个数组合并为一个字符串 
``` 
var myList=new Array(”jpg”,”bmp”,”gif”,”ico”,”png”); 
var portableList=myList.join(”|”); 
//结果是jpg|bmp|gif|ico|png 
```
##slice() 
功能：arrayObject.slice(start,end) 
start:必需。规定从何处开始选取。如果是负数，那么它规定从数组尾部开始算起的位置。也就是说，-1 指最后一个元素，-2 指倒数第二个元素，以此类推。 
end:可选。规定从何处结束选取。该参数是数组片断结束处的数组下标。如果没有指定该参数，那么切分的数组包含从 start 到数组结束的所有元素。如果这个参数是负数，那么它规定的是从数组尾部开始算起的元素。 
返回一个新的数组，包含从start到end（不包括该元素）的arrayobject中的元素。 
``` 
例子：var str='ahji3o3s4e6p8a0sdewqdasj' 
alert(str.slice(2,5)) //结果ji3 
```
##substring() 
定义和用法 substring 方法用于提取字符串中介于两个指定下标之间的字符。 
语法 stringObject.substring(start,stop) 
start 必需。一个非负的整数，规定要提取的子串的第一个字符在 stringObject 中的位置。 
stop 可选。一个非负的整数，比要提取的子串的最后一个字符在 stringObject 中的位置多 1。 
如果省略该参数，那么返回的子串会一直到字符串的结尾。 
返回 一个新的字符串，该字符串值包含 stringObject 的一个子字符串，其内容是从 start 处到 stop-1 处的所有字符，其长度为 stop 减 start。 说明 substring 方法返回的子串包括 start 处的字符，但不包括 end 处的字符。 如果 start 与 end 相等，那么该方法返回的就是一个空串（即长度为 0 的字符串）。 如果 start 比 end 大，那么该方法在提取子串之前会先交换这两个参数。 如果 start 或 end 为负数，那么它将被替换为 0。 
``` 
例子:var str='ahji3o3s4e6p8a0sdewqdasj' 
alert(str.substring(2,6)) //结果为ji3o3 
```
##substr 
定义和用法 substr 方法用于返回一个从指定位置开始的指定长度的子字符串。 
语法 stringObject.substr(start, length) 
参数 start 必需。所需的子字符串的起始位置。字符串中的第一个字符的索引为 0。 
length 可选。在返回的子字符串中应包括的字符个数。 说明 如果 length 为 0 或负数，将返回一个空字符串。 如果没有指定该参数，则子字符串将延续到stringObject的最后。 
``` 
举例： var str = "0123456789"; 
alert(str.substring(0));------------"0123456789" 
alert(str.substring(5));------------"56789" 
alert(str.substring(10));-----------"" 
alert(str.substring(12));-----------"" 
alert(str.substring(-5));-----------"0123456789" 
alert(str.substring(-10));----------"0123456789" 
alert(str.substring(-12));----------"0123456789" 
alert(str.substring(0,5));----------"01234" 
alert(str.substring(0,10));---------"0123456789" 
alert(str.substring(0,12));---------"0123456789" 
alert(str.substring(2,0));----------"01" 
alert(str.substring(2,2));----------"" 
alert(str.substring(2,5));----------"234" 
alert(str.substring(2,12));---------"23456789" 
alert(str.substring(2,-2));---------"01" 
alert(str.substring(-1,5));---------"01234" 
alert(str.substring(-1,-5));--------"" 
```
##charAt() 
功能：返回指定位置的字符。字符串中第一个字符的下标是 0。如果参数 index 不在 0 与 string.length 之间，该方法将返回一个空字符串。 
``` 
例子:var str='a,g,i,d,o,v,w,d,k,p' 
alert(str.charAt(2)) //结果为g 
```
##charCodeAt() 
charCodeAt() 方法可返回指定位置的字符的 Unicode 编码。这个返回值是 0 - 65535 之间的整数。 
方法 charCodeAt() 与 charAt() 方法执行的操作相似，只不过前者返回的是位于指定位置的字符的编码，而后者返回的是字符子串。 
``` 
例子：var str='a,g,i,d,o,v,w,d,k,p' 
alert(str.charCodeAt(2)) //结果为103。即g的Unicode编码为103 
```
