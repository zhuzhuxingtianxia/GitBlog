# Metal基础

## Metal Shader Language

MSL基于C++的语法,与OpenGL的GLSL语法作用一样，都是用于编写顶点着色器和片元着色器。与OpenGL着色器不同，Metal是在编译项目时编译的，这比动态编译更有效,提升了运行效率。

### 函数修饰符

* `vertex`: 标识为顶点着色器函数，每个顶点数据执⾏一次该函数，然后为每个顶点生成数据(position)输出到绘制管线中去
* `fragment`: 标识为片元着色器函数,每个片元和其关联的数据执行一次然后为每个⽚元生成数据输出(color)到绘制管线中去
* `kernel`: 标识为内核并行计算函数，它将被分配在一个线程组网格中执行

**注意：** 
1. 使用`kernel`修饰的函数返回值必须是`void`类型
2. 一个被函数修饰符修饰过的函数,不允许被其他函数调用

### 地址空间修饰符
Metal着色器语言使用*地址空间修饰符*来表示一个函数变量或者参数被分配到哪块内存区域，所有的着色函数(`vertex`,`fragment`,`kernel`)的参数,如果是指针或者是引用,都必须带有地址空间修饰符号。

* `device`: 设备地址空间
* `threadgroup`: 线程组地址空间
* `constant`: 常量地址空间
* `thread`: thread 地址空间

对于图形着色器函数，其指针或者引用类型的参数必须定义为`device` 或者 `constant`地址空间；对于并行计算着色函数,其指针或者引用类型的参数必须为`device` 或者 `threadgroup` 或者 `constant` 地址空间；

`texture`纹理对象总是在设备地址空间(`device`)分配内存，地址空间修饰符不必出现在纹理类型定义中，一个纹理对象的内容无法直接访问,Metal提供了读写纹理的内建函数；

### 函数参数限定符

无论是并行计算着色函数，还是顶点着色器函数，或片元着色器函数他们的参数都有一个限定符。

*  `[[buffer(x)]]`: 限定符表明该参数需要使用`device/constant`空间修饰符修饰，是数据交互commandEncoder中调用`setVertexBuffer`写入的数据。而这里x就是在调用`setVertexBuffer`方法时的index值（不是offset）；

*  `[[texture(x)]]`: 限定符表明该参数需要使用`texture`空间修饰符修饰，是一个纹理数据, x是`setVertexTexture`方法中的index值

*  `[[sampler(x)]]`: 限定符表明该参数需要使用`sampler`空间修饰符修饰，x是`setVertexSamplerState`方法中的index值。
   在Metal程序中sampler作为变量时，初始化必须使用`constexpr`关键字修饰;
 ```
 constexpr sampler quadSampler;
 // 或设置配置
 constexpr sampler quadSampler(coord::pixel, filter::linear, mip_filter::nearest)
 ```

*  `[[threadgroup(x)]]`: 限定符表明该参数需要使用`threadgroup`空间修饰符修饰

*  `[[vertext_id]]`: 顶点着色器是在渲染每个顶点的时候都会执行该函数。因此这个vertex_id是当前的顶点下标（因为我们所有的顶点是一个数组）
*  `[[stage_in]]`: 在片元着色器中的表示该参数是由顶点着色器传入进来的。即顶点着色器会return一个数据，而这个数据会根据stage_in限定符传入到片元着色器中；在顶点函数中，系统则会根据stage_in限定符自动获取当前索引，并解包为当前索引处的顶点缓存的(即传入的参数结构)数据结构，而不再需要vertext_id限定符修饰的参数
*  `[[instance_id]]`: 这个限定符用于多次绘制时的不同实例，对应`renderCommandEncoder.drawIndexedPrimitives`方法的`instanceCount`参数

### 采样器Sampler配置参数

用于一些纹理的属性配置

| 枚举名称                                | 有效值                                      | 描述                                 |
| ----------------------------------- | ---------------------------------------- | ---------------------------------- |
| `coord`                             | `normalized`,`pixel`                     | 从纹理中采样,纹理坐标是否需要归一化                 |
| `address`                           | `clamp_to_edge`,`clamp_to_zero`, `mirrored_repeat`,`repeat` | 设置所有纹理的寻址模式                        |
| `s_address` `t_address` `r_address` | `clamp_to_edge`,`clamp_to_zero`, `mirrored_repeat`,`repeat` | 设置某一个纹理坐标的寻址模式                     |
| `filter`                            | `nearest`,`linear`                       | 设置纹理的采样缩放过滤方式                      |
| `mag_filter`                        | `nearest`,`linear`                       | 设置纹理的采样放大过滤方式                      |
| `min_filter`                        | `nearest`,`linear`                       | 设置纹理的采样缩小过滤方式                      |
| `mip_filter`                        | `none`,`nearest`,`linear`                | 设置纹理的采样minmap过滤方式                  |
| `compare_func`                      | `none`,`less`,`less_qual`,`greater`,`greate_qual`,`equal`,`not_equal` | 设置比较测试逻辑,这个状态值的设置只能在Metal着色语言程序中完成 |

### 内置数学函数

* sin：正弦函数;
* cos：余弦函数;
* atan/atan2: 反正切函数,求的角度值，`atan((y2-y1)/(x2-x1))`取值范围是[-PI/2, PI/2],`atan2(y2-y1, x2-x1)`取值范围是[-PI, PI];
* fract: 函数返回一个值的小数部分;
* dot: 点乘函数返回两个向量乘积的标量结果即`(x1,y1)*(x2,y2) = x1*x2 + y1*y2`;
* cross: 叉乘函数,其功能是计算向量积,得到垂直与该面的向量。表达式为: `A x B = [(x1 * y2) - (y1 * x2), (x2 * y0) - (y2 * x0), (x0 * y1) - (y0 * x1)]`;
* pow：幂函数,例如： pow(2,3) = 2 * 2 * 2 = 8;
* sqrt: 开平方函数，例如：sqrt(16) = 4;
* abs: 函数只返回绝对值,任何值都会丢失其符号并始终返回非负值;
* fmod: 函数返回`float`的余数小数部分（相当于整数的模运算符％）;
* length: 计算向量或矩阵的长度；
* distance: 计算两个向量之间的距离；
* normalize: 将数据归一化至同一个值域区间(单位圆内)；
* floor: 向下取整;
* exp: 指数曲线函数,是以自然常数e为底的指数函数；
* reflect: [反射函数](https://zhuanlan.zhihu.com/p/152561125)，通过给定的入射光线与法向量求取反射向量;
* refract: 折射函数，折射与材质有关;
* clamp: 函数将点移动到最接近的可用值。 如果小于它，则输入采用`min`的值，如果大于它，则输入`max`的值，并且如果介于两者之间则保持其值;
* mix: 混入函数，使用它们之间的权重来执行`x`和`y`之间的线性插值,返回值计算表达式为:`x *（1-t）+ y * t`,t为0结果为x, t为1结果为y; 展开表达式为:`(x1,y1)*(1-t) + (x2,y2) * t = (x1*(1-t)+x2*t, y1*(1-t)+y2*t)`;
* step: 函数x小于edge为0，否则为1;
* smoothstep: 函数将实数x作为输入，如果x小于`edge0`边缘则输出0,如果x大于`edge1`边缘则输出1，否则实现区间[edge0，edge1]中0和1之间的三次插值，计算表达式为：

```
//[edge0 < x < edge1]
float smoothstep(float edge0, float edge1, float x){
	 float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0); 
　　return t * t * (3.0 - 2.0 * t);
}

```


使用方式：

```
import simd

///SIMD 创建写法如下
// SIMD2(1,4)或 .init(1,4) 或 SIMD2(x: 1, y: 4) 或 [1,4]

///fract
let f: SIMD2<Float> = fract(.init(3.10,3.40))
print(f) //SIMD2<Float>(0.1, 0.4)
/// dot
let dot: Float = dot(.init(x: 0.5, y: 0.5), .init(x: 0.5, y: 1))
print(dot) // 0.75
/// pow
let pow: SIMD2<Float> = pow(.init(2,2), .init(3,3))
print(pow)
/// fmod
let fmod: Float = fmodf(2.5, 0.2)
print(fmod.formatted()) // 0.1

/// length
 let length: Float = length(SIMD2<Float>([1,1]))
 print(length) // 1.414214
 /// distance
 let d = distance(SIMD2<Float>(0,1), SIMD2<Float>(0,3.3))
 print(d) // 2.3
 
 ///normalize
 let norm = normalize(SIMD2<Float>(1,1))
 print(norm) // SIMD2<Float>(0.7071067, 0.7071067)
 
 /// floor
 let f = floor(SIMD2<Float>.init(x: 4.3, y: 5.8))
 print(f) // SIMD2<Float>(4.0, 5.0)

/// clamp
let clamp: SIMD2<Float> = clamp(.init(x: 1.0, y: 4.0), min: 2.0, max: 5.0)
print(clamp) // SIMD2<Float>(2.0, 4.0)

/// mix
let mix: SIMD2<Float> = mix(.init(x: 1, y: 2), .init(x: 0, y: 1), t: 0.5)
//((1*(1-0.5) + 0 * 0.5),(2*(1-0.5) + 1*0.5))
print(mix) //SIMD2<Float>(0.5, 1.5) 

/// step
let step: SIMD2<Float> = step(.init(x: 1, y: 4), edge: .init(x: 2, y: 3))
 print(step) // SIMD2<Float>(0.0, 1.0)
 
 /// smoothstep
 let smooth: SIMD2<Float> = smoothstep([5,3], edge0: [1,2], edge1: [8,8])
 print(smooth) // SIMD2<Float>(0.606414, 0.07407408)
 
```

