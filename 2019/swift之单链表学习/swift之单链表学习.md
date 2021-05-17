# swift之单链表学习

单链表:有一个数据节点和一个指向下一个节点的指针；
单链表由数据部分和指向下一个节点的指针构成，包含一个指向头节点的指针，尾节点的下一个节点为 NULL。
使用leetcode中**大数运算**的案例。

## 节点
构建一个节点模型：
```
class LinkNumberNode {
    var val: Int = 0
    var next: LinkNumberNode?
    var mark: Int = 0 //符号标记位
   
    convenience init(value:Int) {
        self.init()
        val = value
    }
   
}
```

## 单链表的翻转

```
func reverseListNode(head: LinkNumberNode?) -> LinkNumberNode {
    var prev: LinkNumberNode?
    var curr = head
    while curr != nil {
        //保存下一个节点，防止断链
       let nextTemp = curr?.next
        // 让当前节点的下一个指向前一个
        curr?.next = prev;
       // 移动前一个位置
        prev = curr;
        // 遍历下一个子串
        curr = nextTemp;
        
    }
    
    return prev!
}
```

## 单链表创建
```
func createLinkedList(inputArray:Array< String >?) -> LinkNumberNode? {
    if  inputArray == nil || inputArray?.count == 0 {
        return nil
    }
    let stringArray:Array< String > = inputArray!
   
    let head = LinkNumberNode.init(value: Int(stringArray[stringArray.startIndex])!)
    var cur = head
    for i in 1.. < stringArray.count
       let value = Int(stringArray[i])
        let node = LinkNumberNode.init(value: value!)
        cur.next = node
        cur = node
    }
   
    return head
}func createLinkedList(inputArray:Array< String >?) -> LinkNumberNode? {
    if  inputArray == nil || inputArray?.count == 0 {
        return nil
    }
    let stringArray:Array< String > = inputArray!
   
    let head = LinkNumberNode.init(value: Int(stringArray[stringArray.startIndex])!)
    var cur = head
    for i in 1.. < stringArray.count
       let value = Int(stringArray[i])
        let node = LinkNumberNode.init(value: value!)
        cur.next = node
        cur = node
    }
   
    return head
}
```

## 链表的输出
```
func outPutLinkedList(head:LinkNumberNode?) -> String{
    if head == nil {
        return ""
    }
    var cur = head
    var result = ""
    while cur != nil {
        result.append(contentsOf: String((cur?.val)!))
        cur = cur?.next
    }
   
    return String(result.reversed())
}
```

## 数字字符串转数组

```
func linkVaules(input: String) -> Array< String >? {
    let scan: Scanner = Scanner(string: input)
    var val:Int = 0
   //验证是否为数字字符串
    if scan.scanInt(&val) && scan.isAtEnd {
        return input.reversed().map({String($0)})
    }
    return nil
}
```

## 链表的比较

```
func compareLinedList(l1: LinkNumberNode?,l2: LinkNumberNode?) -> Int {
    var len1 = 0
    var len2 = 0
   
    var curL1 = l1
    var curL2 = l2
    var iszero1 = true
    var iszero2 = true
   
    while curL1 != nil {
        if curL1?.val != 0 {
            iszero1 = false
        }
        curL1 = curL1?.next
        len1 += 1
    }
   
    while curL2 != nil {
        if curL2?.val != 0 {
            iszero2 = false
        }
        curL2 = curL2?.next
        len2 += 1
    }
   
    if iszero1 && iszero2 {
        return 0
    }else if (iszero1) {
        return -1
    }else if (iszero2) {
        return 1
    }
   
    if len1 > len2 {
        return 1
    }else if len1 < len2 {
        return -1
    }else {
        curL1 = l1
        curL2 = l2
        while curL1 != nil && curL2 != nil {
            if (curL1?.val)! > (curL2?.val)! {
               return 1
            }else if (curL1?.val)! < (curL2?.val)! {
                return -1
            }
           
            curL1 = curL1?.next
            curL2 = curL2?.next
        }
    }
    return 0
}

func isGreaterThan(l1: LinkNumberNode?,l2: LinkNumberNode?) -> Bool {
    let index = compareLinedList(l1: l1, l2: l2)
    return index == 1
}
```
## 大数相加

```
func addTwoNumbers(l1:inout LinkNumberNode?,l2:inout LinkNumberNode?) ->LinkNumberNode? {

    // 创建头节点
    var front: LinkNumberNode?
    //创建尾节点
    var trail: LinkNumberNode?
    //用来标记进位值，大于10则进位为1
    var num = 0;
   
    while l1 != nil || l2 != nil {
        var l1Value = 0
        if l1 != nil {
            l1Value = (l1?.val)!
            l1 = l1?.next
        }
       
        var l2Value = 0
        if l2 != nil {
            l2Value = (l2?.val)!
            l2 = l2?.next
        }
       
        let sum = l1Value + l2Value + num
        var value = sum
        if sum >= 10 {
            num = Int(sum/10)
            value = sum % 10
        }else{
            num = 0
        }
        // 创建一个节点
        let node = LinkNumberNode(value: value)
        if front == nil {
            front = node
        }else {
            trail?.next = node
        }
       
        trail = node
    }
    //如果链表都为空，但进位为1，需要把进位单独创建一个节点
    if num > 0 {
        trail?.next = LinkNumberNode(value: num)
    }
   
    return front
   
}

func add(number1: String,number2: String) -> String {
   
    var link1 = createLinkedList(inputArray: linkVaules(input: number1))
    var link2 = createLinkedList(inputArray: linkVaules(input: number2))
   
    let resultNode = addTwoNumbers(l1: &link1, l2: &link2)
   
    let resultStr = outPutLinkedList(head: resultNode)
   
    return resultStr
}

add(number1: "11", number2: "22")

```

## 大数相减

```
func subTwoNumbers(l1:inout LinkNumberNode?,l2:inout LinkNumberNode?) ->LinkNumberNode?{
   
    let mark = isGreaterThan(l1: l1, l2: l2)
    if !mark {
        let temp = l2
        l2 = l1
        l1 = temp
    }
    // 创建头节点
    var front: LinkNumberNode?
    //创建尾节点
    var trail: LinkNumberNode?
   
   //减数固定不变
    var absL2 = l2
   
    // 用来标记借位的值
    var num = 0
   
    while l1 != nil || absL2 != nil {
        var l1Value = 0
        if l1 != nil {
            l1Value = (l1?.val)!
            l1 = l1?.next
        }
       
        var l2Value = 0
        if absL2 != nil {
            l2Value = (absL2?.val)!
            absL2 = absL2?.next
        }
       
        var sub = 0
        // 需要减去借位的值
        l1Value = l1Value - num
        if l1Value >= l2Value {
            // 直接做减法运算
            sub = l1Value - l2Value
            num = 0
        }else {
           //借 10 再减去 l2Value
            sub = l1Value + 10 - l2Value
            num = 1
        }
        // 创建一个节点
        let node = LinkNumberNode.init(value: sub)
        if front == nil {
            front = node
        }else {
            trail?.next = node
        }
       
        trail = node
    }
    if !mark {
        front?.mark = -1
    }
    return front
}

func sub(number1: String,number2: String) -> String {
   
    var link1 = createLinkedList(inputArray: linkVaules(input: number1))
    var link2 = createLinkedList(inputArray: linkVaules(input: number2))
   
    let resultNode = subTwoNumbers(l1: &link1, l2: &link2)
   
    var mark = ""
    if (resultNode?.mark)! < 0 {
        mark = "-"
    }
    var resultStr = outPutLinkedList(head: resultNode)
   
    while resultStr.hasPrefix("0")&&resultStr.count > 1 {
        resultStr.remove(at: resultStr.startIndex)
    }
    if resultStr == "0" {
        return resultStr
    }
    return mark + resultStr
}

sub(number1: "100", number2: "122")

```

## 大数相乘

```
func multTwoNumbers(l1:inout LinkNumberNode?,l2:inout LinkNumberNode?) ->LinkNumberNode? {
    // 记录中间结果的和
    var temp:LinkNumberNode?
     // 用来标记进位的值，如果大于等于10，则进位
    var num = 0
    // 进行了多少次乘法运算
    var count = 0
   
    while l1 != nil {
        let l1Value = (l1?.val)!
        var curL2 = l2
        var temp_ret_head:LinkNumberNode?
        var temp_ret_cur:LinkNumberNode?
       
       //每次进位需要补 0
       if count > 0 {
            let znode = LinkNumberNode.init(value: 0)
            temp_ret_head = znode
            temp_ret_cur = znode
           
            for _ in 0..<(count-1) {
                temp_ret_cur?.next = LinkNumberNode.init(value: 0)
                temp_ret_cur = temp_ret_cur?.next!
            }
        }
       
        count += 1
        // L2 中的每个数都需要乘以 L1 中的数
        while curL2 != nil {
           let l2Value = (curL2?.val)!
           // 需要加进位的值
            let muti = l1Value * l2Value + num
            var value = 0
           if muti >= 10 {
                value = muti % 10
                num = Int(muti / 10)
            }else {
                value = muti
                num = 0
            }
           
           // 创建一个节点
           let node = LinkNumberNode.init(value: value)
            if temp_ret_head == nil {
                temp_ret_head = node
            }else {
                temp_ret_cur?.next = node
            }
            temp_ret_cur = node
           
            curL2 = curL2?.next
        }
       
        // 如果进位还有值，需要再创建一个节点
        if num > 0 {
            temp_ret_cur?.next = LinkNumberNode.init(value: num)
        }
        num = 0
        // temp 记录了每次乘法相加的结果
       
        if temp != nil{
           let ret = addTwoNumbers(l1: &temp, l2: &temp_ret_head)
            temp = ret
        }else {
            temp = temp_ret_head
        }
        l1 = l1?.next
    }

    return temp
}

func multi(number1: String,number2: String) -> String {
   
    var link1 = createLinkedList(inputArray: linkVaules(input: number1))
    var link2 = createLinkedList(inputArray: linkVaules(input: number2))
   
    let resultNode = multTwoNumbers(l1: &link1, l2: &link2)
   
    let resultStr = outPutLinkedList(head: resultNode)
   
    return resultStr
}

multi(number1: "99", number2: "78")func multTwoNumbers(l1:inout LinkNumberNode?,l2:inout LinkNumberNode?) ->LinkNumberNode? {
    // 记录中间结果的和
    var temp:LinkNumberNode?
     // 用来标记进位的值，如果大于等于10，则进位
    var num = 0
    // 进行了多少次乘法运算
    var count = 0
   
    while l1 != nil {
        let l1Value = (l1?.val)!
        var curL2 = l2
        var temp_ret_head:LinkNumberNode?
        var temp_ret_cur:LinkNumberNode?
       
       //每次进位需要补 0
       if count > 0 {
            let znode = LinkNumberNode.init(value: 0)
            temp_ret_head = znode
            temp_ret_cur = znode
           
            for _ in 0..<(count-1) {
                temp_ret_cur?.next = LinkNumberNode.init(value: 0)
                temp_ret_cur = temp_ret_cur?.next!
            }
        }
       
        count += 1
        // L2 中的每个数都需要乘以 L1 中的数
        while curL2 != nil {
           let l2Value = (curL2?.val)!
           // 需要加进位的值
            let muti = l1Value * l2Value + num
            var value = 0
           if muti >= 10 {
                value = muti % 10
                num = Int(muti / 10)
            }else {
                value = muti
                num = 0
            }
           
           // 创建一个节点
           let node = LinkNumberNode.init(value: value)
            if temp_ret_head == nil {
                temp_ret_head = node
            }else {
                temp_ret_cur?.next = node
            }
            temp_ret_cur = node
           
            curL2 = curL2?.next
        }
       
        // 如果进位还有值，需要再创建一个节点
        if num > 0 {
            temp_ret_cur?.next = LinkNumberNode.init(value: num)
        }
        num = 0
        // temp 记录了每次乘法相加的结果
       
        if temp != nil{
           let ret = addTwoNumbers(l1: &temp, l2: &temp_ret_head)
            temp = ret
        }else {
            temp = temp_ret_head
        }
        l1 = l1?.next
    }

    return temp
}

func multi(number1: String,number2: String) -> String {
   
    var link1 = createLinkedList(inputArray: linkVaules(input: number1))
    var link2 = createLinkedList(inputArray: linkVaules(input: number2))
   
    let resultNode = multTwoNumbers(l1: &link1, l2: &link2)
   
    let resultStr = outPutLinkedList(head: resultNode)
   
    return resultStr
}

multi(number1: "99", number2: "78")
```

## 大数相除
思路是：除法可以转换成减法来处理，不过性能有点差

```
func divTwoNumbers(l1:inout LinkNumberNode?,l2:inout LinkNumberNode?) ->LinkNumberNode? {
    // 创建头结点
    var tempL2 = l2
    var index = compareLinedList(l1: l1, l2: l2)
    if index == 0 {
       //L1 == L2
        let node = LinkNumberNode.init(value: 1)
        return node
    }else if index < 0 {
       //L1 < L2
        let node = LinkNumberNode.init(value: 10)
        return node
    }
   
    // 相减的结果
    var sub = subTwoNumbers(l1: &l1, l2: &l2)
   
    var front:LinkNumberNode?
    var count = 1
    while index == 1 {
        // 到 9 后加到结果链表中
        if count == 9 {
            var node:LinkNumberNode? = LinkNumberNode.init(value: count)
           if front == nil {
                front = node
            }else {
                front = addTwoNumbers(l1: &front, l2: &node)
            }
            count = 0
        }
        var temp_sub = sub
        index = compareLinedList(l1: sub, l2: tempL2)
       
       if index == 1 {
            count += 1
            sub = subTwoNumbers(l1: &temp_sub, l2: &tempL2)
        }else if index == 0 {
            count += 1
           
        }else {
           
        }
       
    }
   
    if count > 0 {
        //结果用链表保存，防止溢出
        var node:LinkNumberNode? = LinkNumberNode.init(value: count)
        front = addTwoNumbers(l1: &front, l2: &node)
    }
    return front
}

func div(number1: String,number2: String) -> String {
   
    var link1 = createLinkedList(inputArray: linkVaules(input: number1))
    var link2 = createLinkedList(inputArray: linkVaules(input: number2))
   
    let resultNode = divTwoNumbers(l1: &link1, l2: &link2)
   
    let resultStr = outPutLinkedList(head: resultNode)
   
    return resultStr
}

div(number1: "100", number2: "2")
```

