//
//  Pretty.swift
//  json
//
//  Created by mac on 2021/4/9.
//

import Foundation

/// JSON 的格式化
func prettyJson(level: Int = 0, json: JSON) -> String {
    switch json {
    case let .string(s): return refString(s)
    case let .double(n): return "\(n)"
    case let .int(n): return "\(n)"
    case let .bool(b): return b ? "true":"false"
    case .null: return "null"
    case let .array(arr):
        if arr.isEmpty { return "[]"}
        return "[" + prettyList(level: level, pretty: prettyJson, list: arr) + "]"
    case let .object(obj):
        if obj.isEmpty {return "{}"}
        return "{" + prettyObject(level: level, pretty: prettyJson, object: obj) + "}"
    }
}

/// element 重复 n 遍
func replicate<T>(count: Int, elem: T) -> [T] {
    return [T](repeating: elem, count: count)
}

func refString(_ value: String) -> String {
    return "\"\(value)\""
}

func prettyList(level: Int, pretty: (Int, JSON) -> String, list: [JSON]) -> String {
    let level1 = level + 4
    let indent = "\n" + replicate(count: level1, elem: " ")
    return list.map { (json) -> String in
        let str = pretty(level1, json)
        return indent + str
    }.joined(separator: ",") + "\n" + replicate(count: level, elem: " ")
}

func prettyObject(level: Int, pretty: (Int, JSON) -> String, object: [String: JSON]) -> String {
    let level1 = level + 4
    let indent = "\n" + replicate(count: level1, elem: " ")
    return object.map { (key, value) -> String in
        let str = refString(key) + ":" +  pretty(level1, value)
        return indent + str
    }.joined(separator: ",") + "\n" + replicate(count: level, elem: " ")
}
