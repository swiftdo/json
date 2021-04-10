//
//  main.swift
//  json
//
//  Created by mac on 2021/4/9.
//

let json = JSON([
    "a": JSON([JSON(8), JSON(9), JSON(10)]),
    "b": JSON(10.2),
    "c": JSON([
        "name": JSON("world"),
        "say": JSON("hello"),
        "temp": JSON(true)
    ])
])

let result = prettyJson(level: 0, json: json)
print(result)








