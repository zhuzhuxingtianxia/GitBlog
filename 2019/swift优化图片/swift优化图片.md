# swift优化图片

他们说最好的相机就是你,如果这一格言持有任何重量,那么毫无疑问,iPhone是最重要的因素。还有就是我们的行业。
[https://www.swiftjectivec.com/optimizing-images/]

## 展示图片尺寸
方式一：直接使用ImageView
```
let filePath = Bundle.main.path(forResource:"baylor", ofType: "jpg")!
let url = NSURL(fileURLWithPath: filePath)
let fileImage = UIImage(contentsOfFile: filePath)

// Image view
let imageView = UIImageView(image: fileImage)
imageView.translatesAutoresizingMaskIntoConstraints = false
imageView.contentMode = .scaleAspectFit
imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
imageView.heightAnchor.constraint(equalToConstant: 400).isActive = true

view.addSubview(imageView)
imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

```

方式二：
设置圆角剪切
```
let circleSize = CGSize(width: 60, height: 60)

UIGraphicsBeginImageContextWithOptions(circleSize, true, 0)

// Draw a circle
let ctx = UIGraphicsGetCurrentContext()!
UIColor.red.setFill()
ctx.setFillColor(UIColor.red.cgColor)
ctx.addEllipse(in: CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height))
ctx.drawPath(using: .fill)

let circleImage = UIGraphicsGetImageFromCurrentImageContext()
UIGraphicsEndImageContext()

```

方式三：
设置圆角剪切,比上一种节省75%的像素资源

```
let circleSize = CGSize(width: 60, height: 60)
let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height))

let circleImage = renderer.image{ ctx in
    UIColor.red.setFill()
    ctx.cgContext.setFillColor(UIColor.red.cgColor)
    ctx.cgContext.addEllipse(in: CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height))
    ctx.cgContext.drawPath(using: .fill)
}

```

## 降尺度vs降采样

```
let imageSource = CGImageSourceCreateWithURL(url, nil)!
let options: [NSString:Any] = [kCGImageSourceThumbnailMaxPixelSize:400,kCGImageSourceCreateThumbnailFromImageAlways:true]

if let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) {
    let imageView = UIImageView(image: UIImage(cgImage: scaledImage))
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 400).isActive = true
    
    view.addSubview(imageView)
    imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
}

```
新型加载图片方法：
```
func downsampleImage(at URL:NSURL, maxSize:Float) -> UIImage
{
    let sourceOptions = [kCGImageSourceShouldCache:false] as CFDictionary
    let source = CGImageSourceCreateWithURL(URL as CFURL, sourceOptions)!
    let downsampleOptions =
    [kCGImageSourceCreateThumbnailFromImageAlways:true,
                             kCGImageSourceThumbnailMaxPixelSize:maxSize
                             kCGImageSourceShouldCacheImmediately:true,
                             kCGImageSourceCreateThumbnailWithTransform:true,
                             ] as CFDictionary
    
    let downsampledImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions)!
    
    return UIImage(cgImage: downsampledImage)
}

```
简单实用：
```
// Use your own queue instead of a global async one to avoid potential thread explosion
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.downsampledImage != nil || 
        self.listItem.mediaAssetData == nil) return;
    
    NSIndexPath *mediaIndexPath = [NSIndexPath indexPathForRow:0
                                                     inSection:SECTION_MEDIA];
    if ([indexPaths containsObject:mediaIndexPath])
    {
        CGFloat scale = tableView.traitCollection.displayScale;
        CGFloat maxPixelSize = (tableView.width - SSSpacingJumboMargin) * scale;
        
        dispatch_async(self.downsampleQueue, ^{
            // Downsample
            self.downsampledImage = [UIImage downsampledImageFromData:self.listItem.mediaAssetData
                               scale:scale
                        maxPixelSize:maxPixelSize];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                self.listItem.downsampledMediaImage = self.downsampledImage;
            });
        });
    }
}

```

# swift 说明
## convenience关键字和required关键字

一.使用convenience修饰的构造函数叫做便利构造函数，便利构造函数通常用在对系统的类进行构造函数的扩充时使用。**convenience**增加init的初始化方法,convenience修饰的初始化方法不能被子类重写或者是从子类中以super的方式被调用。
1、便利构造函数通常都是写在extension里面；
2、便利函数init前面需要加载convenience
3、在便利构造函数中需要明确的调用self.init()

二.希望子类中一定实现的初始化方法，我们可以通过添加**required**关键字进行限制，强制子类对这个方法重写。

## Swift 访问级别
1.open: 公开权限, 最高的权限,可以被其他模块访问, 继承及复写。
2.public: 公有访问权限，类或者类的公有属性或者公有方法可以从文件或者模块的任何地方进行访问。那么什么样才能成为一个模块呢？一个App就是一个模块，一个第三方API或第三方框架等都是一个完整的模块，这些模块如果要对外留有访问的属性或者方法，就应该使用public的访问权限。public的权限在Swift 3.0后无法在其他模块被复写方法/属性或被继承。
3.internal: 在Swift中默认就是internal的访问权限，即有着internal访问权限的属性和方法说明在模块内部可以访问，超出模块内部就不可被访问了。
4.fileprivate: 文件私有访问权限，被fileprivate修饰的类或者类的属性或方法可以在同一个物理文件中访问。
5.private: 私有访问权限，被private修饰的类或者类的属性或方法可以在同一个物理文件中的同一个类型(包含extension)访问。如果超出该物理文件或不属于同一类型，那么有着private访问权限的属性和方法就不能被访问。
**访问控制：**
1.类成员的访问级别不能高于类的访问级别(注意：嵌套类型的访问级别也符合此条规则)。
2.必要构造方法（required修饰）的访问级别必须和类访问级别相同，结构体的默认构造函数的访问级别不高于其成员的访问级别（例如一个成员是private那么这个构造函数就是private，但是可以通过自定义来声明一个public的构造函数）。
3.子类的访问级别不高于父类的访问级别，但是在遵循五种访问级别作用范围的前提下子类可以将父类低访问级别的成员重写成更高的访问级别（例如父类A和子类B在同一个源文件，A的访问级别是public，B的访问级别是internal，其中A有一个private方法，那么B可以覆盖其private方法并重写为internal）。
4.协议中所有必须实现的成员的访问级别和协议本身的访问级别相同，其子协议的访问级别不高于父协议；
5.如果一个类继承于另一个类的同时实现了某个协议那么这个类的访问级别为父类和协议的最低访问级别，并且此类中方法访问级别和所实现的协议中的方法相同；
6.元组的访问级别是元组中各个元素的最低访问级别，注意：元组的访问级别是自动推导的，无法直接使用关键字修饰其访问级别；
7.函数的访问级是函数的参数、返回值的最低级别，并且如果其访问级别和默认访问级别（internal）不符需要明确声明；
8.枚举成员的访问级别等同于枚举的访问级别（无法单独设置），同时枚举的原始值、关联值的访问级别不能低于枚举的访问级别；
9.泛型类型或泛型函数的访问级别是泛型类型、泛型函数、泛型类型参数三者中最低的一个；
10.类型别名的访问级别不能高于原类型的访问级别；


## typealias 定义别名
指定将某个特定的类型通过typealias赋值为新名字。
```
public typealias CompatibleType = DataProxy
```
给DataProxy定义一个别名为CompatibleType

## where 限定元素遵循的协议
```
extension Collection where Iterator.Element: TextRepresentable
```
Collection 定义一个扩展来应用于任意元素遵循上面 TextRepresentable 协议

## 扩展一个泛型类型
当你扩展一个泛型类型时，不需要在扩展的定义中提供类型形式参数列表。
类型约束语法：在一个类型形式参数名称后面放置一个类或者协议作为形式参数列表的一部分，并用冒号隔开，以写出一个类型约束。下面展示了一个泛型函数类型约束的基本语法（和泛型类型的语法相同）
```
func someFunction<T: SomeClass, U: SomeProtocol>(someT: T, someU: U) {
    // function body goes here
}

```

## associatedtype关联类型
定义一个协议时，有时在协议定义里声明一个或多个关联类型是很有用的。关联类型给协议中用到的类型一个占位符名称。直到采纳协议时，才指定用于该关联类型的实际类型。关联类型通过 associatedtype 关键字指定。
```
public protocol TransformType {
	associatedtype Object
	associatedtype JSON

	func transformFromJSON(_ value: Any?) -> Object?
	func transformToJSON(_ value: Object?) -> JSON?
}

```
转变为实际类型
```
open class DataTransform: TransformType {
	public typealias Object = Data
	public typealias JSON = String

	public init() {}

	open func transformFromJSON(_ value: Any?) -> Data? {
		guard let string = value as? String else{
			return nil
		}
		return Data(base64Encoded: string)
	}

	open func transformToJSON(_ value: Data?) -> String? {
		guard let data = value else{
			return nil
		}
		return data.base64EncodedString()
	}
}
```


## 泛型Where分句
泛型 Where 分句让你能够要求一个关联类型必须遵循指定的协议，或者指定的类型形式参数和关联类型必须相同。
泛型 Where 分句以 Where 关键字开头，后接关联类型的约束或类型和关联类型一致的关系。
泛型 Where 分句写在一个类型或函数体的左半个大括号前面。
```
func allItemsMatch <C1: Container, C2: Container> (_ someContainer: C1, _ anotherContainer: C2) -> Bool
   where C1.ItemType == C2.ItemType, C1.ItemType: Equatable {
        if someContainer.count != anotherContainer.count {
            return false
        }
        for i in 0..<someContainer.count {
            if someContainer[i] != anotherContainer[i] {
                return false
            }
        }
        return true
}

```
C1 必须遵循 Container 协议（写作 C1: Container ）；
C2 也必须遵循 Container 协议（写作 C2: Container ）；
C1 的 ItemType 必须和 C2 的 ItemType 相同（写作 C1.ItemType == C2.ItemType ）；
C1 的 ItemType 必须遵循 Equatable 协议（写作 C1.ItemType: Equatable ）

## 带有泛型 Where 分句的扩展
```
extension Stack where Element: Equatable {
    func isTop(_ item: Element) -> Bool {
        guard let topItem = items.last else {
            return false
        }
        return topItem == item
    }
}

```

## 写一个泛型 where 分句来要求 Item 为特定类型
```
extension Container where Item == Double {
    func average() -> Double {
        var sum = 0.0
        for index in 0..<count {
        sum += self[index]
        }
        return sum / Double(count)
    }
}

```

## 关联类型的泛型 Where 分句
```
protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    subscript(i: Int) -> Item { get }
    associatedtype Iterator: IteratorProtocol where Iterator.Element == Item
    func makeIterator() -> Iterator
}

```
## 泛型 where 分句继承的协议添加限定
对于一个继承自其他协议的协议来说，你可以通过在协议的声明中包含泛型 where 分句来给继承的协议中关联类型添加限定。比如说，下面的代码声明了一个 ComparableContainer 协议，它要求 Item 遵循 Comparable ：
```
protocol ComparableContainer: Container where Item: Comparable { }
```

## discardableResult 解决返回值没使用消除警告
函数的返回值没有被使用，可以用注解@discardableResult解决warning的问题

## @escaping @ noescaping 逃逸闭包与非逃逸闭包
闭包只有在函数中做参数时才会区分逃逸闭包和非逃逸闭包。
Swift 3.0之后，传递闭包到函数中的时候，系统会默认为非逃逸闭包类型（NonescapingClosures)@noescaping，逃逸闭包在闭包前要添加@escaping关键字。

非逃逸闭包的生命周期与函数相同：
1，把闭包作为参数传给函数；
2，函数中调用闭包；
3，退出函数。结束


逃逸闭包的生命周期：
1，闭包作为参数传递给函数；
2，退出函数；
3，闭包被调用，闭包生命周期结束

即逃逸闭包的生命周期长于函数，函数退出的时候，逃逸闭包的引用仍被其他对象持有，不会在函数结束时释放

## 带有私有设置方法的属性private(set)
通过在属性前面使用 **private(set)** ，属性就被设置为默认访问等级的 **getter** 方法，但是 **setter** 方法是私有的。

## class的readonly只读属性
```
var options:String {
        return "aa"
    }
```

