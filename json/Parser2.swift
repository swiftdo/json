//
//  Parser2.swift
//  json
//
//  Created by mac on 2021/4/14.
//

import Foundation

/// 分词 + AST
// [自己动手实现一个简单的JSON解析器](https://segmentfault.com/a/1190000010998941)

// 1. 词法分析：按照构词规则将 JSON 字符串解析成 Token 流
// 2. 语法分析：根据 JSON 文法检查上面 Token 序列所构词的 JSON 结构是否合法

enum JsonToken {
    case objBegin // {
    case objEnd   // }
    case arrBegin // [
    case arrEnd   // ]
    case null(String)    // null
    case number(String)   // 1
    case string(String)   // "a"
    case bool(String)     // true false
    case sepColon // :
    case sepComma // ,
}


struct JsonTokenizer {
    
    private var input: String
    
    private var currentIndex: String.Index
    
    init(string: String) {
        self.input = string
        self.currentIndex = string.startIndex
    }
    
    /// 当前字符
    private var current: Character? {
        guard currentIndex < input.endIndex else {return nil}
        return input[currentIndex]
    }
    
    /// 上一个字符
    private var previous: Character? {
        guard currentIndex > input.startIndex else {return nil}
        let index = input.index(before: currentIndex)
        return input[index]
    }
    
    /// 下一个字符
    private var next: Character? {
        guard currentIndex < input.endIndex else {return nil}
        let index = input.index(after: currentIndex)
        guard index < input.endIndex else {return nil}
        return input[index]
    }
    
    /// 移动下标
    private mutating func advance() {
        currentIndex = input.index(after: currentIndex)
    }
    
    mutating func nextToken() -> JsonToken? {
        guard let c = current else {
            return nil
        }
        
        var token: JsonToken?
        
        // todo
        
        
    }
    
}


