# KC_Cooci老师的面试题

## 一、选择题
> 1. LGTeacher 继承于 LGPerson, 下面代码输出为什么 (  ) 

```
LGTeacher *t = [[LGTeacher alloc] init];

- (instancetype)init{
    self = [super init];
    if (self) {
        NSLog(@"%@ - %@",[self class],[super class]);
    }
    return self;
}
```

* A: LGTeacher - LGTeacher
* B: LGTeacher - LGPerson
* C: LGTeacher - NSObject
* D: LGTeacher - 它爱输出啥就输出啥,我不清楚

答案：**A**。
分析：初始化时，`self = [super init]`,所以self和super的class都是当前类**LGTeacher**，而`[self superclass]`才指向父类**LGPerson**。


> 2. 下面代码能否正常执行以及输出 (  )

```
@interface LGPerson : NSObject
@property (nonatomic, retain) NSString *kc_name;
- (void)saySomething;
@end

@implementation LGPerson
- (void)saySomething{ 
    NSLog(@"%s - %@",__func__,self.kc_name);
}
@end


- (void)viewDidLoad {
    [super viewDidLoad] ;

    Class cls = [LGPerson class];
    void  *kc = &cls;
    [(__bridge id)kc saySomething];
}
```

* A: 能 - ViewController
* B: 能 - null
* C: 能 - ViewController: 0x7ff8d240ad30
* D: 能不能自己运行一下不就知道,非要问我 - 它爱输出啥就输出啥,我不清楚

答案：**C**
分析：

