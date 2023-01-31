## 替换this: 3种情况

### 1.call()

一次调用函数时， 临时替换一次this,**要调用的函数.call(替换this的对象, 实参值1,...) 调用**

call做3件事儿: 

1). 立刻调用一次点前的函数

2). 自动将.前的函数中的this替换为指定的新对象 

3). 还能向要调用的函数中传实参值

**错误做法：**

```javascript
//有一个公共的计算器函数，计算每个人的总工资
// 底薪 奖金1 奖金2
function jisuan(base, bonus1, bonus2){
console.log(`${this.ename}的总工资是:${base+bonus1+bonus2}`)
}
//两个员工:
var lilei={ename:"Li Lei"};
var hmm={ename:"Han Meimei"};
//lilei想用jisuan()计算自己这个月的薪资
//错误:
 lilei.jisuan(10000,1000,2000);
// this->window
//lilei自己没有计算，lilei的爹Object也没有计算函数，
//所以报错:不是一个function
```

**正确做法：**

```javascript
//有一个公共的计算器函数，计算每个人的总工资
// 底薪 奖金1 奖金2
function jisuan(base, bonus1, bonus2){
console.log(`${this.ename}的总工资是:${base+bonus1+bonus2}`)
}
//两个员工:
var lilei={ename:"Li Lei"};
var hmm={ename:"Han Meimei"};
//要调用 替换this 还能
//的函数 调用 的对象 传实参
jisuan.call( hmm,5000, 6000, 3000)
// | ↓ ↓ ↓
//相当于jisuan( ↓ base,bonus1,bonus2 )
// this.ename
// hmm.ename
// "Han Meimei"
```

### 2.apply()

使用场景：1.如果多个实参值是放在一个数组中给的。 2.需要既替换this，又要拆散数组再传参

做三件事：

1). 调用.前的函数

2). 替换.前的函数中的this为指定对象 

3). 先拆散数组为多个元素值， 再分别传给函数的形参变量

如下：

```javascript
//有一个公共的计算器函数，计算每个人的总工资
// 底薪 奖金1 奖金2
function jisuan(base, bonus1, bonus2){
console.log(`${this.ename}的总工资是:${base+bonus1+bonus2}`)
}
//两个员工:
var lilei={ename:"Li Lei"};
var hmm={ename:"Han Meimei"};
//lilei想用jisuan()计算自己这个月的薪资
var arr=[10000, 1000, 2000];
jisuan.apply(lilei, arr );
// | 拆散数组——apply的特异功能
// | 10000, 1000, 2000 ——多个值
//相当于jisuan( ↓ base,bonus1,bonus2)
// this.ename
// lilei.ename
// "Li Lei"
```

call和apply只能临时替换一次this

 • 如果反复调用函数，每次都要用call和apply临时替换this，太麻烦！ 

• 比如: - jisuan.call(lilei, 10000,1000,2000) 

   		 - jisuan.call(lilei, 10000,2000,2000)

​			- jisuan.call(lilei, 10000,1000,1000)

### 3.bind()

**创建函数副本 并永久绑定this**

a. var 新函数=原函数.bind(替换this的对象)

b. 2件事: 

​	1). 创建一个和原函数一模一样的新函数副本 

​	2). 永久替换新函数中的this为指定对象

c.如何使用新函数：

**新函数(实参值,...) **

- 因为bind()已提前将指定对象替换新函数中this， 
- 所以后续每次调用新函数副本时

- 不需要再替换this了！

示例：

```javascript
//有一个公共的计算器函数，计算每个人的总工资
// 底薪 奖金1 奖金2
function jisuan(base, bonus1, bonus2){
console.log(`${this.ename}的总工资是:${base+bonus1+bonus2}`)
}
var lilei={ename:"Li Lei"};
var hmm={ename:"Han Meimei"};
//lilei每个月都要call，很麻烦
//于是买一个一模一样的自己专属的jisuan()函数。
var jisuan2=jisuan.bind(lilei);
//jisuan2=function(basic, bonus1, bonus2){
// …`${lilei.ename}的总工资是:${base+bonus1+bonus2}`…
//}
jisuan2(10000, 1000,2000);
```

• bind()不但可以提前永久绑定this,而且还能提前永久绑定部分实参值

• **var 新函数=原函数.bind(替换this的对象, 不变的实参值)**

• 也做3件事儿: 

• 1). 创建一模一样的新函数副本 

• 2). 永久替换this为指定对象 

• 3). 永久替换部分形参变量为固定的实参值！

```javascript
//有一个公共的计算器函数，计算每个人的总工资
// 底薪 奖金1 奖金2
function jisuan(base, bonus1, bonus2){
console.log(`${this.ename}的总工资是:${base+bonus1+bonus2}`)
}
var lilei={ename:"Li Lei"};
var hmm={ename:"Han Meimei"};
//lilei每个月都要call，很麻烦
//于是lilei决定买一个一模一样的自己专属的jisuan()函数。
var jisuan2=jisuan.bind(lilei,10000);
//jisuan2=function(10000, bonus1, bonus2){
// console.log(
`${lilei.ename}的总工资是:${10000+bonus1+bonus2}`)
//}
```

如果已绑定了部分参数，剩下的参数该如何调用呢？

• 只需要传剩余的实参值即可

• **新函数(剩余实参值,...,...)**

```javascript
//有一个公共的计算器函数，计算每个人的总工资
// 底薪 奖金1 奖金2
function jisuan(base, bonus1, bonus2){
console.log(`${this.ename}的总工资是:${base+bonus1+bonus2}`)
}
var lilei={ename:"Li Lei"};
var hmm={ename:"Han Meimei"};
//lilei每个月都要call，很麻烦
//于是lilei决定买一个一模一样的自己专属的jisuan()函数。
var jisuan2=jisuan.bind(lilei,10000);
//jisuan2=function(10000, bonus1, bonus2){
// …`${lilei.ename}的总工资是:${10000+bonus1+bonus2}`…
//}
jisuan2(1000,2000);
```

**！！！被bind()永久绑定的this，即使用call，也无法再替换为其它对象了。  ——箭头函数的底层原理**



### 总结

• a. 只在一次调用函数时，临时替换一次this: call 

• b. 既要替换一次this，又要拆散数组再传参: apply 

• c. 创建新函数副本，并永久绑定this: bind

