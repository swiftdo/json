//
//  Parser.swift
//  json
//
//  Created by mac on 2021/4/9.
//

import Foundation

// 解析原理：
// * 解析对象 {}
//   对象结构是 `{"Key": [值]}` 的格式，所以先解析到Key字符串，将Key 解析出来，然后再解析值，因为值有可能 [`字符串`、`值类型`、`布尔类型`、`对象`、`数组`、`null`] 所以需要根据前缀得到类型，并调用相应的解析方法，循环解析到 `}` 对象的结尾
// * 解析数组 []
//   对象的结构是 `[[值]、[值]]`，因为值有可能是 [`字符串`、`值类型`、`布尔类型`、`对象`、`数组`、`null`] 所以需要根据前缀得到类型，并调用相应的解析方法，循环解析到 `}` 对象的结尾
// * 解析字符串
//   循环解析，需要判断是否遇到转义符`\`如果遇到，当前字符的下一个字符将是作为普通字符存入结果，如果遇到非转义的 " 字符则退出字符串读取方法，并返回结果
// * 解析值类型
//   循环拉取[0-9]包括.符号，然后调用转换成double类型方法
// * 解析布尔类型
//   转判断是 true 还是 false
// * 解析null
//   转判断是否为 null
//  ![](https://img2020.cnblogs.com/blog/1988850/202007/1988850-20200720134913661-345556756.png)

enum ParserError: Error {
    case notFormatterCharacter(msg: String)
    case unknowEnd(msg: String)
    case unicode(msg: String)
    case line(msg: String)
    case key(msg: String)
    case character(msg: String)
    case bool(msg: String)
    case null(msg: String)
    case element(msg: String)
    case number(msg: String)
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        if offset > count {
            print("offset 越界:\(offset)")
        }
        let c = self[index(startIndex, offsetBy: offset)]
        return c
    }
}

/// 解析 JSON 字符串为 JSON
func parseJson(str: String) throws -> JSON {
    var index = 0

    // 读取非空白字符

    index = readToNonBlankIndex(str: str, index: index)

    let ch = str[index]
    index += 1

    if ch == "[" {
        // 解析数组
        return try parseArray(str: str, index: index).0
    }

    // 解析对象
    return try parseObject(str: str, index: index).0
}

/// "{\"a\":[8,9,10],\"c\":{\"temp\":true,\"say\":\"hello\",\"name\":\"world\"},\"b\":10.2}"
/// 解析JSON字符串为对象结构
func parseObject(str: String, index: Int) throws -> (JSON, Int) {
    var ind = index
    var obj: [String: JSON] = [:]

    repeat {
        ind = readToNonBlankIndex(str: str, index: ind)
        if str[ind] != "\"" {
            throw ParserError.notFormatterCharacter(msg: "不能识别的字符“\(str[ind])”")
        }
        ind += 1

        // 读取字符串
        let (name, ids) = try readString(str: str, index: ind)
        ind = ids

        if obj.keys.contains(name) {
            throw ParserError.key(msg: "已经存在key: \(name)")
        }
        ind = readToNonBlankIndex(str: str, index: ind)

        if str[ind] != ":" {
            throw ParserError.character(msg: "不能识别字符:\(str[ind])")
        }

        ind += 1
        ind = readToNonBlankIndex(str: str, index: ind)

        /// 读取下一个 element
        let next = try readElement(str: str, index: ind)
        ind = next.1
        obj[name] = next.0

        /// 读取到非空白字符
        ind = readToNonBlankIndex(str: str, index: ind)

        let ch = str[ind]
        ind += 1
        if ch == "}" { break }
        if ch != "," {
            throw ParserError.notFormatterCharacter(msg: "不能识别的字符")
        }
    } while true

    return (.object(obj), ind)
}

/// 解析JSON字符串为数组结构
func parseArray(str: String, index: Int) throws -> (JSON, Int) {
    var arr: [JSON] = []
    var ind = index
    repeat {
        ind = readToNonBlankIndex(str: str, index: ind)
        /// 读取下一个element
        let ele = try readElement(str: str, index: ind)
        ind = ele.1
        arr.append(ele.0)
        /// 读取非空白字符
        ind = readToNonBlankIndex(str: str, index: ind)

        let ch = str[ind]
        ind += 1
        if ch == "]" { break }
        if ch != "," {
            throw ParserError.notFormatterCharacter(msg: "不能识别的字符")
        }
    } while true

    return (.array(arr), ind)
}

/// 读取下一个
func readElement(str: String, index: Int) throws -> (JSON, Int) {
    var ind = index
    let c = str[ind]
    ind += 1
    switch c {
    case "[":
        return try parseArray(str: str, index: ind)
    case "{":
        return try parseObject(str: str, index: ind)
    case "\"":
        let (str, ids) = try readString(str: str, index: ind)
        return (.string(str), ids)
    case "t":
        return try readJsonTrue(str: str, index: ind)
    case "f":
        return try readJsonFalse(str: str, index: ind)
    case "n":
        return try readJsonNull(str: str, index: ind)
    case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
        return try readJsonNumber(str: str, index: ind)
    default:
        throw ParserError.element(msg: "未知 element: \(c)")
    }
}

func readJsonNumber(str: String, index: Int) throws -> (JSON, Int) {
    var ind = index - 1
    var value: [Character] = []
    
    while ind < str.count && isNumber(c: str[ind]) || str[ind] == "." {
        value.append(str[ind])
        ind += 1
    }

    if value.contains(".") {
        if let v = Double(String(value)) {
            return (.double(v), ind)
        }
    } else {
        if let v = Int(String(value)) {
            return (.int(v), ind)
        }
    }
    throw ParserError.number(msg: "不能识别的数字类型\(ind)")
}


func readJsonNull(str: String, index: Int) throws -> (JSON, Int) {
    return try readJsonCharacters(str: str,
                                  index: index,
                                  characters: ["u", "l", "l"],
                                  error: .null(msg: "读取null值出错"),
                                  json: .null)
}

func readJsonFalse(str: String, index: Int) throws -> (JSON, Int) {
    return try readJsonCharacters(str: str,
                                  index: index,
                                  characters: ["a", "l", "s", "e"],
                                  error: .bool(msg: "读取false值出错"),
                                  json: .bool(false))
}

func readJsonTrue(str: String, index: Int) throws -> (JSON, Int) {
    return try readJsonCharacters(str: str,
                                  index: index,
                                  characters: ["r", "u", "e"],
                                  error: .bool(msg: "读取true值出错"),
                                  json: .bool(true))
}

/// 读取字符串
func readString(str: String, index: Int) throws -> (String, Int) {
    var ind = index
    var value: [Character] = []

    while ind < str.count {
        
        var c = str[ind]
        ind += 1
        
        if c == "\\" { // 判断是否是转义字符
            value.append("\\")
            if ind >= str.count {
                throw ParserError.unknowEnd(msg: "未知结尾")
            }

            c = str[ind]
            ind += 1
            value.append(c)

            if c == "u" {
                try (0 ..< 4).forEach { _ in
                    c = str[ind]
                    ind += 1

                    if isHex(c: c) {
                        value.append(c)
                    } else {
                        throw ParserError.unicode(msg: "不是有效的unicode 字符")
                    }
                }
            }
        } else if c == "\"" {
            break
        } else if c == "\r" || c == "\n" {
            throw ParserError.line(msg: "传入的JSON字符串内容不允许有换行")
        } else {
            value.append(c)
        }
        
    }

    return (String(value), ind)
}

func isNumber(c: Character) -> Bool {
    return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(c)
}

/// 判断是否为 16 进制字符
func isHex(c: Character) -> Bool {
    return c >= "0" && c <= "9" || c >= "a" && c <= "f" || c >= "A" && c <= "F"
}

/// 读取到非空白字符
func readToNonBlankIndex(str: String, index: Int) -> Int {
    var ind = index
    while ind < str.count && str[ind] == " " {
        ind += 1
    }
    return ind
}


func readJsonCharacters(str: String, index: Int, characters: [Character], error: ParserError, json: JSON) throws -> (JSON, Int) {
    var ind = index
    var result = true
    
    for i in 0 ..< characters.count {
        if str.count <= ind || str[ind] != characters[i] {
            result = false
            break
        }
        ind += 1
    }
    if result {
        return (json, ind)
    }
    throw error
}
