# NSArray的enumerate

在for循环中可以使用break、continue等关键字控制循环。
当使用`enumerateObjectsUsingBlock`遍历复杂的数据结构的时候，我们该怎么控制和跳出循环呢？

那么我们看一下运行效果：

## 使用：*stop = YES;
```
NSArray *rawArray = [NSArray arrayWithObjects:@1,@2,@3,@4,@5, nil];
    [rawArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"start obj = %@", obj);
        if ([obj isEqual:@3]) {
            *stop = YES;
        }
        NSLog(@"stop obj = %@", obj);
    }];
```
打印结果：

 start obj = 1 <br/>  stop obj = 1 <br/>  start obj = 2 <br/>  stop obj = 2 <br/>  start obj = 3 <br/>  stop obj = 3 <br/>

## 使用：return;
```
NSArray *rawArray = [NSArray arrayWithObjects:@1,@2,@3,@4,@5, nil];
[rawArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {         NSLog(@"start obj = %@", obj);         if ([obj isEqual:@3]) {             return;         }         NSLog(@"stop obj = %@", obj);     }];
```
打印结果：
 start obj = 1	<br/>  stop obj = 1<br/>  start obj = 2<br/>  stop obj = 2<br/>  start obj = 3<br/>  start obj = 4<br/>  stop obj = 4<br/>  start obj = 5<br/>  stop obj = 5<br/>

## 使用：*stop = YES; 和 return;同时使用
```
NSArray *rawArray = [NSArray arrayWithObjects:@1,@2,@3,@4,@5, nil];
[rawArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {         NSLog(@"start obj = %@", obj);         if ([obj isEqual:@3]) {             *stop = YES;             return;         }         NSLog(@"stop obj = %@", obj);     }];
```
打印结果：
 start obj = 1<br/>  stop obj = 1<br/>  start obj = 2<br/>  stop obj = 2<br/>  start obj = 3<br/>

## 结果总结：

1. 只用 `*stop = YES;` 跳出循环Block，但是本次循环需要执行完
2. 只用 `return;` 跳出本次循环Block，相当于for循环中`continue`的用法
3. `*stop = YES;` 和 `return;` 连用，跳出循环Block，不执行本次循环剩余的代码，相当于for循环中`break`的用法。
    


