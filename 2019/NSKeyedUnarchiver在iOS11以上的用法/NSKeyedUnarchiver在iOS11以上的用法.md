# NSKeyedUnarchiver在iOS11以上的用法

## 基本用法
所存储的对象必须服从**NSSecureCoding协议**
对于已经服从的类型，如NSString、NSInteger可以直接使用
```
//1.对需要保存的数据进行编码归档 ->NSdata 
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@"string" requiringSecureCoding:NO error:nil];

//2.解归档,将二进制数据转化为对应的对象类型
NSString *str = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSString class] fromData:data error:nil];

```
## 自定义对象
1. 实现NSSecureCoding协议
 
```
@interface TCMCacheItem: NSObject<NSCoding, NSSecureCoding>
@property (nonatomic,copy)NSString *key;
@property (nonatomic,strong)id data;
@property (nonatomic,assign)NSTimeInterval time;
@property (nonatomic,assign)NSTimeInterval limtTime;
@end
@implementation TCMCacheItem
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.data = [aDecoder decodeObjectForKey:@"data"];
        self.time = [aDecoder decodeDoubleForKey:@"time"];
        self.limtTime = [aDecoder decodeDoubleForKey:@"limtTime"];
    }
    return self;
}
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeDouble:self.time forKey:@"time"];
    [aCoder encodeDouble:self.limtTime forKey:@"limtTime"];
}

//归档时使用iOS11以上方法，需实现该协议
+ (BOOL)supportsSecureCoding{
    return YES;
}
```

2.归档操作
```
TCMCacheItem *cacheItem = [TCMCacheItem new];
 cacheItem.key = [key copy];
 cacheItem.data = caches;
 cacheItem.time = [[NSDate date] timeIntervalSince1970];
 cacheItem.limtTime = limtTime * 60;
if (@available(iOS 11.0, *)) {
NSData *secureCoding = [NSKeyedArchiver archivedDataWithRootObject:cacheItem requiringSecureCoding:NO error:nil];           
     }
```
3.解归档操作
```
if (@available(iOS 11.0, *)) {
        NSError *err = nil;
       id  item = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[TCMCacheItem.class,NSDictionary.class]] fromData:secureCoding error:&err];
        NSLog(@"%@",err);
    }
```
**说明:**
1.如果TCMCacheItem类的属性为基本数据类型，则可使用unarchivedObjectOfClass；
2.如果属性包含其他数据类型或自定义类型，则使用unarchivedObjectOfClasses把所有类型写入集合中，且自定义类型也需实现NSSecureCoding协议！
3.对于归档返回的安全码secureCoding需独立保存，否则解档就会失败。

## 总结

从以上可以看出，新方法使用起来比较繁琐，不支持写入指定路径，对于复杂多变的数据类型并不是很友好。
老方法自定义对象需实现NSCoding协议：

```
//归档
[NSKeyedArchiver archiveRootObject:cacheItem toFile:path]；
//解档
id item = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
```


