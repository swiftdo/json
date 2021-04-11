//
//  main.swift
//  json
//
//  Created by mac on 2021/4/9.
//

let json = JSON([
    "a": JSON([JSON(8), JSON(9), JSON(10)]),
    "b": JSON(10.2),
    "c": JSON(1),
    "d": JSON([
        "name": JSON("world"),
        "say": JSON("hello"),
        "temp": JSON(true),
        "old": JSON.null
    ])
])

print("正常打印:\n\(json)")
//
let result = prettyJson(level: 0, json: json)
print("\n格式化输出:\n\(result)")

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








