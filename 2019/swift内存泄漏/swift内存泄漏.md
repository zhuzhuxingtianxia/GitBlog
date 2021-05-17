# swift内存泄漏

## 类实例之间相互引用
两个类实例都有一个强引用指向对方，这样的情况就是强引用循环，从而导致内存泄露。
```
class A {
    var b : B?
     
    init(){
        print("a实例初始化完成")
    }
     
    deinit{
        print("a实例例释完成")
    }
}
 
class B {
    var a : A?
     
    init(){
        print("b实例初始化完成")
    }
     
    deinit{
        print("b实例释放完成")
    }
}
//测试开始
var a:A?
var b:B?
a = A()
b = B()
a!.b = b
b!.a = a        
a = nil
b = nil
 
//测试结果（deinit未调用，则内存泄露）
a实例初始化完成
b实例初始化完成

```
解决办法：使用弱引用
只需要将上述例子A类的b变量加上关键字`weak`，或者将B类的a变量加上关键字`weak`。
当A类中包含有B类的弱引用的实例，同时，B类中存在A的强引用实例时，如果A释放，也不会影响B的释放。但A的内存回收要等到B的实例释放后才可以回收。
```
class A {
   weak var b : B?
     
    init(){
        print("a实例初始化完成")
    }
     
    deinit{
        print("a实例例释完成")
    }
}
 
class B {
    var a : A?
     
    init(){
        print("b实例初始化完成")
    }
     
    deinit{
        print("b实例释放完成")
    }
}

```
## 闭包引起的循环引用 
将一个闭包赋值给类实例的某个属性，并且这个闭包体中又使用了实例，也会发生循环引用。 
```
class PP {
    let name:String
    let content:String?
    
    lazy var block:() -> String = {
        if let text = self.content {
            return "\(self.name):\(text)"
        }else{
            return "text is nil"
        }
    }
    
    init(name:String, text:String) {
        self.name = name
        self.content = text
        print("初始化闭包")
    }
    
    deinit {
        print("闭包释放")
    }
}

//测试
var pp:PP? = PP(name: "名字", text: "内容")
 print(pp!.block())
 pp = nil

//结果：
//初始化闭包
//名字:内容

```
deinit未调用，则内存泄露。

解决办法：使用闭包捕获列表
当闭包和实例之间总是引用对方并且同时释放时，定义闭包捕获列表为**unowned**无主引用。但捕获引用可能为nil时，定义捕获列表为弱引用。弱引用通常是可选类型，并且在实例释放后被设置为nil。

```
class PP {
    let name:String
    let content:String?
    
    lazy var block:() -> String = {
    [unowned self] in
        if let text = self.content {
            return "\(self.name):\(text)"
        }else{
            return "text is nil"
        }
    }
    
    init(name:String, text:String) {
        self.name = name
        self.content = text
        print("初始化闭包")
    }
    
    deinit {
        print("闭包释放")
    }
}

```

## [weak self] 与 [unowned self] 介绍
我们只需将闭包捕获列表定义为弱引用（**`weak`**）、或者无主引用（**`unowned`**）即可解决问题，这二者的使用场景分别如下：

* 如果捕获（比如 `self`）可以被设置为 nil，也就是说它可能在闭包前被销毁，那么就要将捕获定义为 weak。
* 如果它们一直是相互引用，即同时销毁的，那么就可以将捕获定义为 unowned

**测试案例:**

1.新建一个DetailController，自定义一个View
2.从首页push到DetailController
3.返回查看DetailController和View是否释放

```
class DetailController: UIViewController {
     @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var viewPage: View!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPage.block = {str in
            
            print("当前输入内容：\(str)")
            self.label.text = str
            
        }
        
    }
    
    deinit {
        print(#file, #function)
    }
    
}

```
**自定义view代码:**
```
class View: UIView, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    
    typealias Block = (String)->Void
    var block:Block?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        print(#file, #function)
    }
    
    //MARK: - TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var str = ""
        
        if string.count > 0 {
            str = textField.text! + string
        }else{
            let startIndex = textField.text!.startIndex
            let index = textField.text!.index(textField.text!.startIndex, offsetBy: range.location)
            
            str = String(textField.text![startIndex..<index])
        }
        
        if let block = block {
            block(str)
        }
        
        return true
    }
    

}

```
从DetailController返回，**`deinit`**都没有执行，造成了上面说到的闭包的循环引用。

为了更好的理解**weak**和**unowned**的区别，我们在延迟 3 秒后让输入框的内容显示在文本Label上
```
class DetailController: UIViewController {
     @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var viewPage: View!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPage.block = {str in
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                print("当前输入内容：\(str)")
                self.label.text = str
            }
            
        }
        
    }
    
    deinit {
        print(#file, #function)
    }
    
}

```
测试结果：输入 1 后立刻返回，可以看到控制台 3 秒仍然会输出内容，且 deinit 方法没有被调用，说明页面未被释放。

#### [weak self]

对上面的样例代码稍作修改，增加个 `[weak self]`：

```
class DetailController: UIViewController {
     @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var viewPage: View!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPage.block = {[weak self] str in
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                print("当前输入内容：\(str)")
                self?.label.text = str
            }
            
        }
        
    }
    
    deinit {
        print(#file, #function)
    }
    
}

```
输入 1 后立刻返回，打印结果如下：
xxx/DetailController.swift deinit
xxx/View.swift deinit
当前输入内容：1
看到` deinit `方法成功被调用，说明页面被释放。

#### [unowned self]

如果不用 `[weak self]` 而改用 `[unowned self]`，返回主页面　3　秒钟后由于DetailController已被销毁，这时访问 label 将会抛出异常，引用读取了一个已经释放了的对象。
结果如下：
```
xxxx/DetailController.swift deinit
xxxx/View.swift deinit
当前输入内容：1
Fatal error: Attempted to read an unowned reference but the object was already deallocated2019-04-30 16:08:47.556768+0800 BUG[15481:197906] Fatal error: Attempted to read an unowned reference but the object was already deallocated
```
去掉延时操作，再测试一下：
```
class DetailController: UIViewController {
     @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var viewPage: View!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewPage.block = {[unowned self] str in
            
            print("当前输入内容：\(str)")
            self.label.text = str
            
        }
        
    }
    
    deinit {
        print(#file, #function)
    }
    
}

```

当前输入内容：1
xxxx/DetailController.swift deinit
xxxx/View.swift deinit

看到` deinit `方法成功被调用，说明页面被释放,使用 `[unowned self]`也是没有问题的。

