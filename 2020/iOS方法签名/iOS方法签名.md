# iOS方法签名
## 一.方法签名NSMethodSignature
如何获取NSMethodSignature的实例？

1. NSMethodSignature类的初始化方法：
```
 + (nullable NSMethodSignature *)signatureWithObjCTypes:(const char *)types;
```
2. NSObject中也包含获取NSMethodSignature对象的方法 <br/>
 获取类方法或者实例方法签名, 无论是对象还是类对象都能调用该方法
```
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;
```
 只能获取实例方法签名
```
+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)aSelector
```
3. 方法签名中的CTypes描述

第一个表示返回值类型，例如：@为id类型，v为void类型
第二个表示函数调用者类型self，即为id类型。一般表示为@
第三个表示SEL方法选择器，一般表示为：冒号。
第四个表示参数类型，没有即无参数。例如：i表示int类型

CTypes描述的字符个数是对应的，如果不设置类型描述或类型描述不正确，在运行的时候就会闪退。

获取类型编码字符串
```
NSLog(@"id 类型的编码是：%s",@encode(id));
//id 类型的编码是：@
```
## 二.NSInvocation
NSInvocation 包含的目标target是一个接受消息的对象，包含的选择器selector是被发送的消息，
    包含方法签名methodSignature。
NSInvocation可以获取和设置返回值，也可以获取和设置参数值。

NSInvocation一般用于runtime的消息转发机制；当然也可以作为事件的载体。

## 三.使用案例
创建一个Controller类和Person类。
Person类定义属性和方法如下：
```
@interface Person : NSObject
@property (strong, nonatomic)NSString *methodName;
@property (strong, nonatomic)NSNumber *number;
-(void)eat;
-(void)eat:(NSNumber*)food;
- (NSString*)eatFood:(NSString*)food;

@end

@implementation Person

-(void)eat{
    self.methodName = [NSString stringWithFormat:@"%s",__func__];
    NSLog(@"%s",__func__);
}

-(void)eat:(NSString*)food{
    self.methodName = [NSString stringWithFormat:@"eat: %s",__func__];
    self.number = food;
    NSLog(@"NSNumber* 类型的编码是：%s",@encode(NSNumber*));
    NSLog(@"eat: %s",__func__);
}

-(void)food:(NSNumber*)food {
    self.methodName = [NSString stringWithFormat:@"food: %s",__func__];
    self.number = food;
    NSLog(@"food: %s",__func__);
}

- (NSString*)eatFood:(NSString*)food{
    self.methodName = [NSString stringWithFormat:@"return: %s",__func__];
    NSLog(@"return: %s",__func__);
    return food;
}

@end
```
为方便调用，Controller类定义方法如下：
```
-(void)invocationTest {
    SEL selector = @selector(methodTest);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
//    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
//    创建 NSInvocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //设置接收消息的对象
    [invocation setTarget:self];
   
    //设置发送的方法名
    [invocation setSelector:selector];
   
    //调用NSInvocation
    [invocation invoke];
}


-(void)methodTest {
    NSLog(@"%s",__func__);
}
-(void)eat {
    NSLog(@"-----%s",__func__);
}

-(void)invocationTest1 {
    Person *person = [Person new];
    SEL selector = @selector(eat);
    NSMethodSignature *signature = [person methodSignatureForSelector:selector];
//    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    //    创建 NSInvocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //设置接收消息的对象
    [invocation setTarget:self];
   
    //设置发送的方法名
    [invocation setSelector:selector];
   
    //调用NSInvocation
    [invocation invoke];
   
    //------[ViewController eat]
    //Target决定执行的目标方法
   
}
-(void)invocationTest2 {
    Person *person = [Person new];
    SEL selector = @selector(eat:);
//    NSMethodSignature *signature = [person methodSignatureForSelector:selector];
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    //    创建 NSInvocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //设置接收消息的对象
    [invocation setTarget:person];
   
    //设置发送的方法名
    [invocation setSelector:selector];
   
    NSNumber *number = @2;
    [invocation setArgument:&number atIndex:2];
   
    //调用NSInvocation
    [invocation invoke];
   
    NSLog(@"p.number=%@",person.number);
    //p.number=2
}

-(void)invocationTest3 {
    Person *person = [Person new];
    SEL selector = @selector(eatFood:);
//    NSMethodSignature *signature = [person methodSignatureForSelector:selector];
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"@@:@"];
    //    创建 NSInvocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //设置发送的方法名
    [invocation setSelector:selector];
   
    NSNumber *number = @2;
    [invocation setArgument:&number atIndex:2];
   
    NSString *getArg;
    [invocation getArgument:&getArg atIndex:2];
   
    //调用NSInvocation
    [invocation invokeWithTarget:person];
   
    //设置返回值，替换执行方法的返回值
    NSString *seValue = @"我是返回值";
    [invocation setReturnValue:&seValue];
    //获取返回值
    NSString *reValue;
    [invocation getReturnValue:&reValue];
   
    NSLog(@"reValue:%@",reValue);
    //reValue:我是返回值
}
// 把事件转发给其他对象
-(void)invocationTest4 {
    [self performSelector:@selector(eat)];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sign = [Person instanceMethodSignatureForSelector:aSelector];
    return sign;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    // 执行Person的eat方法
    [anInvocation invokeWithTarget:[Person new]];
  //[Person eat]
}
```
运行打印结果都写在了注释中，前几个例子NSInvocation是作为一个载体在使用，最后一个例子用于消息转发。

