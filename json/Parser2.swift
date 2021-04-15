//
//  Parser2.swift
//  json
//
//  Created by mac on 2021/4/14.
//

import Foundation

struct JsonParserError: Error {
    var msg: String
    init(msg: String) {
        self.msg = msg
    }
}

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
    
    mutating func nextToken() throws -> JsonToken? {
        guard let _ = current else {
            return nil
        }
        scanSpaces()
        
        guard let ch = current else {
            return nil
        }
        
        switch ch {
        case "{":
            return JsonToken.objBegin
        case "}":
            return JsonToken.objEnd
        case "[":
            return JsonToken.arrBegin
        case "]":
            return JsonToken.arrEnd
        case ",":
            return JsonToken.sepComma
        case ":":
            return JsonToken.sepColon
        case "n":
            return try JsonToken.null(scanMatch(string: "null"))
        case "t":
            return try JsonToken.bool(scanMatch(string: "true"))
        case "f":
            return try JsonToken.bool(scanMatch(string: "false"))
        case "\"":
            return nil
        case _ where isNumber(c: ch):
            return try JsonToken.number(scanNumbers())
        default:
              throw JsonParserError(msg: "无法解析的字符:\(ch)")
        }
    }
    
    mutating func scanNumbers() throws -> String {
        let ind = currentIndex
        while let c = current, isNumber(c: c) {
            advance()
        }
        if currentIndex != ind {
            return String(input[ind..<currentIndex])
        }
        throw JsonParserError(msg: "scanNumbers 出错:\(ind)")
    }
    
    mutating func scanMatch(string: String) throws -> String {
        return try scanMatch(characters: string.map { $0 })
    }
    
    mutating func scanSpaces() {
        while current != " " {
            advance()
        }
    }
    
    mutating func scanMatch(characters: [Character]) throws -> String {
        let ind = currentIndex
        var isMatch = true
        for index in (0..<characters.count) {
            if characters[index] != current {
                isMatch = false
                break
            }
            advance()
        }
        if (isMatch) {
            return String(input[ind..<currentIndex])
        }
        throw JsonParserError(msg: "scanUntil 不满足 \(characters)")
    }
    
   
    /// 判断是否是数字字符
    func isNumber(c: Character) -> Bool {
        
        let chars:[Character: Bool] = ["-": true, "+": true, "e": true, "E": true, ".": true]
        
        if let b = chars[c], b {
            return true
        }
        
        if(c >= "0" && c <= "9") {
            return true
        }
        
        return false;
    }

    /// 判断是否为 16 进制字符
    func isHex(c: Character) -> Bool {
        return c >= "0" && c <= "9" || c >= "a" && c <= "f" || c >= "A" && c <= "F"
    }

}



