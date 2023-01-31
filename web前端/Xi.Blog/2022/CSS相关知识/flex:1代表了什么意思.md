# flex:1代表了什么意思

flex: 1的组成：

flex-grow（放大比例，默认为0）

flex-shrink（缩小比例，默认为1）

flex-basic（flex 元素的内容盒（content-box）的尺寸，默认auto）的缩写；

flex的第三项指的是flex-basis这个属性，这个属性的“0”和“auto”在大多数情况下都会有所不同：

数值被解释为特定宽度,因此0将与指定“width：0”相同；
0%就相当于容器内所有项目原本的width不起作用,然后平分宽度；
auto就相当于容器内所有项目原本的width起作用，伸缩空间减去这些width，剩余空间再平分。所以有的情况下auto和0%是相同的
2种，flex-basis为0%，覆盖width，实际占用0， flex-basis为auto，width权限更高，占用width的值

所以在下面的情况下


```javascript
  .content {
        display: flex;
      }
     .content1{
        flex:1
      }
<div class="content">
    <div class="content1" style="background-color: blue;">1</div>
    <div class="content1" style="background-color: blueviolet;">2</div>
    <div class="content1" style="background-color: chartreuse;">3</div>
</div>
```
flex: 1 等价于：



```javascript
{
    flex-grow: 1;
    flex-shrink : 1; 
    flex-basis: 0%;
}
```

