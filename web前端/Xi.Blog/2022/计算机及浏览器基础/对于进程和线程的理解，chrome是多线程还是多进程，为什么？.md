# 对于进程和线程的理解，chrome是多线程还是多进程，为什么？

多进程。

## 为什么要给浏览器使用多进程架构？

传统的浏览器被设计为显示网页，而Chrome的设计目标是支撑“Web App”（当时的js和相关技术已经相当发达了，Gmail等服务也很成功）。这就要求Chrome提供一个类似于“[操作系统](https://www.zhihu.com/search?q=操作系统&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A999401453})”感觉的架构，支持App的运行。而App会变得相当的复杂，这就难以避免出现bug，然后crash。同时浏览器也要面临可能运行“[恶意代码](https://www.zhihu.com/search?q=恶意代码&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A999401453})”。流览器不能决定上面的js怎么写，会不会以某种形式有意无意的攻击浏览器的渲染引擎。如果将所有这些App和[浏览器](https://www.zhihu.com/search?q=浏览器&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A999401453})实现在一个进程里，一旦挂，就全挂。

因此Chrome一开始就设计为把**隔离性**作为基本的设计原则，用进程的隔离性来实现对App的隔离。这样用户就不用担心：

- 一个Web App挂掉造成其他所有的Web App全部挂掉（稳定性）
- 一个Web App可以以某种形式访问其他App的数据（安全性）

以及Web App之间是并发的，可以提供更好的响应，一个App的渲染卡顿不会影响其他App的渲染（性能）（当然这点线程也能做到）

因此，这样看起来用进程实现非常自然。



## 每个进程里都有什么在跑？

Chromium里有三种进程——浏览器、渲染器和插件。

浏览器进程只有一个，管理窗口和tab，也处理所有的与磁盘，网络，用户输入和显示的工作。这就是我们看到的“Chrome界面”。

渲染器开多个。每个渲染器负责处理HTML、CSS、js、图片等，将其转换成用户可见的数据。当时Chrome使用开源的webkit实现这个功能。

> 顺便说一句，webkit是由Apple开发的，当时有很多坑，也被长期吐槽；现在Chrome已经转成使用自家的Blink引擎了。

插件会开很多。每个类型的插件在第一次使用时会启动一个相应的进程。

总结下，渲染器进程和[插件进程](https://www.zhihu.com/search?q=插件进程&search_source=Entity&hybrid_search_source=Entity&hybrid_search_extra={"sourceType"%3A"answer"%2C"sourceId"%3A999401453})就是平时被杀的最多的进程了。

## 

## 进程和线程的区别

做个简单的比喻：进程=火车，线程=车厢

- 线程在进程下行进（单纯的车厢无法运行）
- 一个进程可以包含多个线程（一辆火车可以有多个车厢）
- 不同进程间数据很难共享（一辆火车上的乘客很难换到另外一辆火车，比如站点换乘）
- 同一进程下不同线程间数据很易共享（A车厢换到B车厢很容易）
- 进程要比线程消耗更多的计算机资源（采用多列火车相比多个车厢更耗资源）
- 进程间不会相互影响，一个线程挂掉将导致整个进程挂掉（一列火车不会影响到另外一列火车，但是如果一列火车上中间的一节车厢着火了，将影响到所有车厢）
- 进程可以拓展到多机，进程最多适合多核（不同火车可以开在多个轨道上，同一火车的车厢不能在行进的不同的轨道上）
- 进程使用的内存地址可以上锁，即一个线程使用某些共享内存时，其他线程必须等它结束，才能使用这一块内存。（比如火车上的洗手间）－"互斥锁"
- 进程使用的内存地址可以限定使用量（比如火车上的餐厅，最多只允许多少人进入，如果满了需要在门口等，等有人出来了才能进去）－“信号量”

