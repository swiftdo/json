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

/// 分词
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
            return try JsonToken.string(scanString())
        case _ where isNumber(c: ch):
            return try JsonToken.number(scanNumbers())
        default:
              throw JsonParserError(msg: "无法解析的字符:\(ch)")
        }
    }
    
    mutating func peekNext() -> Character? {
        advance()
        return current
    }
    
    mutating func scanString() throws -> String {
        var ret:[Character] = []
        
        repeat {
            guard let ch = peekNext() else {
                throw JsonParserError(msg: "scanString 报错，\(currentIndex) 报错")
            }
            switch ch {
            case "\\": // 处理转义字符
                
                guard let cn = peekNext(), !isEscape(c: cn) else {
                    throw JsonParserError(msg: "无效的特殊类型的字符")
                }
                
                ret.append("\\")
                ret.append(cn)
                
                /// 处理 unicode 编码
                if cn == "u" {
                    try ret.append(contentsOf: scanUnicode())
                }
                return String(ret)
            case "\"": // 碰到另一个引号，则认为字符串解析结束
                return String(ret)
            case "\r", "\n": // 传入JSON 字符串不允许换行
                throw JsonParserError(msg: "无效的字符\(ch)")
            default:
                ret.append(ch)
            }
        } while (true)
    }
    
    mutating func scanUnicode() throws -> [Character] {
        var ret:[Character] = []
        for _ in 0..<4 {
            if let ch = peekNext(), isHex(c: ch) {
                ret.append(ch)
            } else {
                throw JsonParserError(msg: "unicode 字符不规范\(currentIndex)")
            }
        }
        return ret
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
    
    mutating func scanSpaces() {
        while current != " " {
            advance()
        }
    }
    
    mutating func scanMatch(string: String) throws -> String {
        return try scanMatch(characters: string.map { $0 })
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
    
    func isEscape(c: Character) -> Bool {
        // \" \\ \u \r \n \b \t \f
        return ["\"", "\\", "u", "r", "n", "b", "t", "f"].contains(c)
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


struct JsonParser {
    private var tokenizer: JsonTokenizer
    
    private init(text: String) {
        tokenizer = JsonTokenizer(string: text)
    }
    
    static func parse(text: String) throws -> JSON? {
        var parser = JsonParser(text: text)
        return try parser.parse()
    }
    
    
    private mutating func parseElement() throws -> JSON {
        
        
        
    }
    
    private mutating func parserArr() throws -> [JSON] {
        
        
        
    }
    
    private mutating func parserObj() throws -> [String: JSON] {
        
        
        
    }
    
    private mutating func parse() throws  -> JSON? {
        guard let token = try tokenizer.nextToken() else {
            return nil
        }
        switch token {
        case .arrBegin:
            return try JSON(parserArr())
        case .objBegin:
            return try JSON(parserObj())
        default:
            return nil
    }
    
        
}





