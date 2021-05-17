# swift指针和对象的相互转化
## inout关键字实现相互转换
```
var key = String("Substring")
var value = String("xxxxxxx")

func insert(key:inout String, value:inout String) -> String?{
    let _dic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)
    
    //数据对象转指针存入容器
    let rawKey = withUnsafePointer(to: &key, { UnsafeRawPointer($0)})
    let rawValue = withUnsafePointer(to: &value, { UnsafeRawPointer($0)})
    CFDictionarySetValue(_dic, rawKey, rawValue)
    
    //根据key的指针获取值指针
    let rawPointer = CFDictionaryGetValue(_dic, rawKey)
    print("\(String(describing: rawPointer))")
    
    //获取指针的值
    let xx = rawPointer?.load(as: String.self)
    
    return xx
}
insert(key: &key, value: &value)// xxxxxxx
```

## 任意对象的转化
```
var key = String("Substring")
var value = String("xxxxxxx")
func insertObc(key: AnyObject, value: AnyObject) -> AnyObject?{
    let _dic = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, nil, nil)

    //数据对象转指针存入容器
    //使用passUnretained 方法， Unmanaged 保持了一个给定的对象，不增加它的引用计数
    let key = Unmanaged.passUnretained(key).toOpaque()
    let Value = Unmanaged.passUnretained(value).toOpaque()
    CFDictionarySetValue(_dic, key, Value)
    
    //根据key的指针获取值指针
    let rawPointer = CFDictionaryGetValue(_dic, key)
    print("\(String(describing: rawPointer))")
    
    //获取指针的值
    let xx = Unmanaged<AnyObject>.fromOpaque(rawPointer!).takeUnretainedValue()
    
    return xx
}

insertObc(key: key as AnyObject, value: value as AnyObject)//xxxxxxx
```


