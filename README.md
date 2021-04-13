# swiftdo/json

swift json 解析库

* [x] 完成 json 打印
* [x] 完成 json 解析

## 实现文章
* [Swift 码了个 JSON 解析器(一)](https://oldbird.run/swift/fp/t3-json1.html)

## 使用 

```swift
let str = "{  \"a\":[8,9,10],\"c\":{\"temp\":true,\"say\":\"hello\",\"name\":\"world\"},   \"b\":10.2}"

print("json 字符串::\n\(str) \n")

do {
    // 解析 json 字符串
    let result = try parseJson(str: str)
    print("\n返回结果::")
    // 格式化 json 字符串
    print(prettyJson(json: result))
} catch  {
    print(error)
}
```

结果输出：

```json
json 字符串::
{  "a":[8,9,10],"c":{"temp":true,"say":"hello","name":"world"},   "b":10.2} 


返回结果::
{
    "a":[
        8,
        9,
        10
    ],
    "c":{
        "temp":true,
        "say":"hello",
        "name":"world"
    },
    "b":10.2
}
```


## 参考:

* [150行Haskell代码实现JSON的解析和格式化，诗一样的代码](https://zhuanlan.zhihu.com/p/359406047)
* [半小时实现一个 JSON 解析器](https://zhuanlan.zhihu.com/p/28049617)
* [自己动手实现一个简单的JSON解析器](https://segmentfault.com/a/1190000010998941)
