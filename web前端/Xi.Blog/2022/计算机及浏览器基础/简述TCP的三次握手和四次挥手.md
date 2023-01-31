# 简述TCP的三次握手和四次挥手

![img](https://img-blog.csdnimg.cn/20210323204703875.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)

TCP（Transmission Control Protocol，传输控制协议）是面向连接的协议，也就是说，在收发数据前，必须和对方建立可靠的连接。一个TCP连接必须要经过三次“对话”才能建立起来，其中的过程非常复杂，只简单的描述下这三次对话的简单过程。

#### 简述三次握手过程：

在开始讲解之前，先来讲几个重要字段的全称，方便记忆：

seq：（sequence number）序号
ack：（acknowledgement number）确认号

标志位：
SYN ：(SYNchronization）同步
ACK ：(ACKnowlegment）确认
FIN   :（FINish）终止
先来看个总括图：

![img](https://img-blog.csdnimg.cn/2021032320474182.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)                                    

第一次握手：Client将同步标志位SYN置为1（SYN为1就表示要建立连接，连接成功之后该位置会再次被置为0），请求序号seq=x（在所有的字节排列中，申请从哪一个字节开始发送，这个序号就一般表示当前已经发送到哪个序号，服务器同意后将会从下一个序号开始发送，第一次握手只有请求序号没有确认号），并将该数据包发送给Server，Client进入SYN_SENT状态，等待Server确认。

![img](https://img-blog.csdnimg.cn/20210323205005356.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)

第二次握手：Server收到数据包后由同步标志位SYN=1知道Client请求建立连接，确认标志位ACK置为1（这会才有确认标志位，第一次握手并没有确认标志位。当确认标志位为0时，确认号不起作用），ack=x+1（确认序号等于请求序号+1，表示x+1之前的Server都收到了，从Server发送的请求已经收到）。TCP是全双工协议，因此Server有可能也会给Client发送数据，因此Server也会向Client建立连接，Server将同步标志位SYN置为1（Server也要向Client发送请求，因此SYN也要被置为1），seq=y就表示Server给Client发送的数据开始序号。并将该数据包发送给Client以确认连接请求，Server进入SYN_RCVD状态。

![img](https://img-blog.csdnimg.cn/20210323205012213.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)

第三次握手：因为连接要是双向的，Server确认后只是Client到Server连通了，因此Client也要确认一下，才能让Server向Client的连接也连通。Client和Server进入ESTABLISHED状态，完成三次握手，随后Client与Server之间可以开始传输数据了。

![img](https://img-blog.csdnimg.cn/20210323205019467.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)


设计这样一个相似的情景：

1、客户端主机C说：“我可以给你发送数据吗？”

2、服务器S说：“可以的，不过我可能也会给你发送数据。”

3、C：“好，那我开始互相发送数据吧。”

#### 简述四次挥手过程：

所谓四次挥手（Four-Way Wavehand）即终止TCP连接，就是指断开一个TCP连接时，需要客户端和服务端相互总共发送4个包以确认连接的断开。在socket编程中，这一过程由客户端或服务端任一方执行close来触发。

![img](https://img-blog.csdnimg.cn/20210323204828555.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)

由于TCP连接是全双工的，因此，每个方向都必须要单独进行关闭。这一原则是当一方完成数据发送任务后，发送一个FIN来终止这一方向的连接，收到一个FIN只是意味着这一方向上没有数据流动了，即不会再收到数据了。但是在这个TCP连接上仍然能够发送数据，直到另一方向也发送了FIN。首先进行关闭的一方将执行主动关闭，而另一方则执行被动关闭，上图描述的即是如此。


第一次挥手：Client发送一个FIN，以及选择号seq=u（表示：u之前的数据已经全部发送，并且数据发到u就可以截止了，就不再有数据了），用来关闭Client到Server的数据传送。Client进入FIN_WAIT_1状态。

![img](https://img-blog.csdnimg.cn/20210323205428149.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)

第二次挥手：Server收到FIN后，发送一个请求号seq=v和确认序号ack=u+1给Client。Server进入CLOSE_WAIT状态。

第三次挥手：Server发送一个FIN，请求号为最新的seq=w和确认序号ack=u+1，用来关闭Server到Client的数据传送。Server进入LAST_ACK状态。

![img](https://img-blog.csdnimg.cn/20210323205441529.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)




第四次挥手：Client收到FIN后，Client进入TIME_WAIT状态，接着发送一个ACK给Server，确认序号为w+1。Server进入CLOSED状态，完成四次挥手。

![img](https://img-blog.csdnimg.cn/20210323205455797.PNG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ0NjQ3ODA5,size_16,color_FFFFFF,t_70)

四次挥手的情景大致是这样的：

1、客户端主机C说：“我没有数据了，断开连接吧。 ”

2、服务器S说：“好，但是我还有数据（不断给C发送数据，此时C已经不能给S发送数据了，但是必须要就收S发来的数据）。”

3、（当S给C发完数据后）S说：“我发完了，断开连接吧。”

4、C说：“好，断开连接吧。”

参考：[https://blog.csdn.net/qq_44647809/article/details/115143100](https://blog.csdn.net/qq_44647809/article/details/115143100)