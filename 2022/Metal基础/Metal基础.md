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

* `[[sampler(x)]]`: 限定符表明该参数需要使用`sampler`空间修饰符修饰，x是`setVertexSamplerState`方法中的index值。
 	在Metal程序中sampler作为变量时，初始化必须使用`constexpr`关键字修饰;
 ```
 constexpr sampler quadSampler;
 // 或设置配置
 constexpr sampler quadSampler(coord::pixel, filter::linear, mip_filter::nearest)
 ```

*  `[[threadgroup(x)]]`: 限定符表明该参数需要使用`threadgroup`空间修饰符修饰

* `[[vertext_id]]`: 顶点着色器是在渲染每个顶点的时候都会执行该函数。因此这个vertex_id是当前的顶点下标（因为我们所有的顶点是一个数组）
* `[[stage_in]]`: 在片元着色器中的表示该参数是由顶点着色器传入进来的。即顶点着色器会return一个数据，而这个数据会根据stage_in限定符传入到片元着色器中；在顶点函数中，系统则会根据stage_in限定符自动获取当前索引，并解包为当前索引处的顶点缓存的(即传入的参数结构)数据结构，而不再需要vertext_id限定符修饰的参数
* `[[instance_id]]`: 这个限定符用于多次绘制时的不同实例，对应`renderCommandEncoder.drawIndexedPrimitives`方法的`instanceCount`参数

### 采样器Sampler配置参数

用于一些纹理的属性配置

枚举名称 | 有效值 | 描述
--------- | --------- | -------------
`coord` | `normalized`,`pixel` | 从纹理中采样,纹理坐标是否需要归一化
`address` | `clamp_to_edge`,`clamp_to_zero`, `mirrored_repeat`,`repeat` | 设置所有纹理的寻址模式
`s_address` `t_address` `r_address` | `clamp_to_edge`,`clamp_to_zero`, `mirrored_repeat`,`repeat` | 设置某一个纹理坐标的寻址模式
`filter` | `nearest`,`linear` | 设置纹理的采样缩放过滤方式
`mag_filter` | `nearest`,`linear` | 设置纹理的采样放大过滤方式
`min_filter` | `nearest`,`linear` | 设置纹理的采样缩小过滤方式
`mip_filter` | `none`,`nearest`,`linear` | 设置纹理的采样minmap过滤方式
`compare_func` | `none`,`less`,`less_qual`,`greater`,`greate_qual`,`equal`,`not_equal` | 设置比较测试逻辑,这个状态值的设置只能在Metal着色语言程序中完成




