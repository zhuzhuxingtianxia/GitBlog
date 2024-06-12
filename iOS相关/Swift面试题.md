# Swift

* [x]
* [ ]

## throws 和 rethrows
Swift中 throws 和 rethrows 关键字用于异常处理（Error handling)，都是用在函数中

* throws表示当前函数可能会抛出异常，需要处理, 调用方法时使用try关键字，或者使用do-catch
* rethrows表示以闭包或函数作为参数可能出现异常，但当前函数调用者不需处理异常 rethrows只是传递参数中的异常。

```
public func asURL() throws -> URL {
    guard let url = URL(string: self) else { throw AFError.invalidURL(url: self) }

    return url
}

func around(_ closure: () throws -> Void) rethrows {
    lock(); defer { unlock() }
    try closure()
}

```

## defer
`defer` 关键字提供了一种机制，用于在代码块结束之前执行一段代码.无论是正常执行结束，还是由于错误、异常、return语句或是break/continue控制流语句退出之前都会在最后执行`defer`包裹的代码块。

例如上面的代码👆:
先执行`lock()`加锁，再执行`closure()`闭包函数，最后执行defer中的代码块`unlock()`解锁

## try、 try?、 try!

* try: 标明方法有异常抛出，需使用do-catch处理异常或使用`guard`拆包处理
* try?: 不想处理异常，返回一个可选值类型，如果有异常则返回nil,否则返回一个可选类型的值
* try!: 不处理异常，若抛出了异常则程序crash,类似NSAssert()

```
do {
    // 执行操作 let store = CNContactStore()
    try store.execute(request)
    completion(true, error)
} catch {
    completion(false, error)
    //或抛出异常
    // throw error
}
```

## associatedtype 和 typealias

* associatedtype: 定义关联类型，相当于类型的占位符，在协议中达到泛型效果,让实现协议的类型来指定具体的类型
* typealias: 定义类型别名

```
/// Define Property protocol
internal protocol JKSwiftPropertyCompatible {
  
    /// Extended type
    associatedtype T
    
    ///Alias for callback function
    typealias SwiftCallBack = ((T?) -> ())
    
    ///Define the calculated properties of the closure type
    var swiftCallBack: SwiftCallBack?  { get set }
}

private var buttonCallBackKey: Void?
extension UIButton: JKSwiftPropertyCompatible {
    internal typealias T = UIButton
    internal var swiftCallBack: SwiftCallBack? {
        get { return jk_getAssociatedObject(self, &buttonCallBackKey) }
        set { jk_setRetainedAssociatedObject(self, &buttonCallBackKey, newValue) }
    }
    
    @objc internal func swiftButtonAction(_ button: UIButton) {
        self.swiftCallBack?(button)
    }
}

public func jk_getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

public func jk_setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T, _ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
    objc_setAssociatedObject(object, key, value, policy)
}
```

## final

final关键字可以用在 class ，func和var前面进行修饰，表示不允许对类或方法进行继承或者重写操作。

## @discardableResult

使用关键字取消不使用方法返回值引起的警告

## mutating 和 inout

* mutating: 用在值类型的方法中，结构体实例化后，属性值不可修改。可在方法前添加关键字来修改属性值
* inout: 修改的是参数类型,从值类型变成引用类型

```
 /// 交换两个值
@discardableResult
public static func swapMe<T>(value1: inout T, value2: inout T) -> (T,T) {
    (value1,value2) = (value2,value1)
    return (value1, value2)
}
```

## convenience 便利构造器

重新增加一个init方法，需要`convenience`修饰
```
public extension DateFormatter {

    // MARK: 1.1、格式化快捷方式
    /// 格式化快捷方式
    /// - Parameter format: 格式
    convenience init(format: String) {
        self.init()
        dateFormat = format
    }
}
```

## 访问权限

* private: 修饰的属性或方法只能在当前类中访问
* fileprivate: 修饰的属性或方法在当前文件里可以访问
* internal: 默认访问级别，修饰的属性或方法在当前模块中都可以访问，如果是库或框架在其内部都是可访问的，外部代码不可访问，在App代码中，app内部可以访问
* public: 可以被任何人访问，模块(module)中可以被override和继承，但在其他模块(module)中不可以被override和继承
* open: 可以被任何人使用，包括override和继承

## @autoclosure 和 @escaping

* @autoclosure: 自动闭包，通过将参数标记为 @autoclosure，参数将自动转化为一个闭包
* @escaping: 逃逸闭包生命周期长于相关函数，当函数退出时，逃逸闭包的引用仍然被其他对象持有，不会再相关函数结束后释放。
* 非逃逸闭包: 非逃逸闭包被限制在函数内，当函数退出时，该闭包的引用计数不会增加

```
func rxFatalErrorInDebug(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
    #if DEBUG
        fatalError(lastMessage(), file: file, line: line)
    #else
        print("\(file):\(line): \(lastMessage())")
    #endif
}

/// 回到主线程
/// - Parameters:
///   - parameter: 返回的参数
///   - eventsClosure: 闭包
private static func resultMain<T>(parameter: T, eventsClosure: @escaping ((T) -> Void)) {
    DispatchQueue.main.async {
        eventsClosure(parameter)
    }
}

```

## @inline

添加`@inline`关键字的函数告诉编译器可以使用直接派发

```
extension RecursiveLock : Lock {
    @inline(__always)
    final func performLocked(_ action: () -> Void) {
        self.lock(); defer { self.unlock() }
        action()
    }
}
```

## lazy
lazy关键词的作用：指定延迟加载（懒加载），懒加载存储属性只会在首次使用时才会计算初始值属性。 lazy修饰的属性非线程安全的

## Swift和OC的区别

1. swift是静态语言，有类型推断，OC是动态语言
2. swift面向协议编程，OC面向对象编程
3. swift注重值类型，OC注重引用类型
4. swift支持泛型，OC只支持轻量泛型
5. swift支持静态派发（效率高）、动态派发（函数表派发、消息派发）方式，OC支持动态派发（消息派发）方式
6. swift支持函数式编程
7. swift的协议不仅可以被类实现，也可以被struct和enum实现
8. swift有元组类型、支持运算符重载
9. swift支持命名空间
10. swift支持默认参数
11. swift比oc代码更加简洁

## 沙盒数据

* 应用重启沙盒目录**tmp**下的文件被会丢弃
* 沙盒**Documents**目录下的所有文件，都可以通过iTunes进行备份和恢复
* 离线数据，图片视频文件缓存文件放在沙盒**Library/Caches**目录下
* **Library**目录下除了**Caches**目录外，都可以通过iTunes进行备份
* **keychain**是独立于每个App的沙盒之外的，即使App被删掉后，**keychain**里面的信息依然存在









