//
//  Pretty.swift
//  json
//
//  Created by mac on 2021/4/9.
//

import Foundation

/// JSON 的格式化

func prettyJson(level: Int, json: JSON) -> String {
    switch json {
    case let .string(s): return s
    case let .double(n): return "\(n)"
    case let .int(n): return "\(n)"
    case let .bool(b): return b ? "true":"false"
    case .null: return "null"
    case let .array(arr):
        if arr.isEmpty { return "[]"}
        return "[" + prettyList(level: level, pretty: prettyJson, list: arr) + "]"
    case let .object(obj):
        if obj.isEmpty {return "{}"}
        return ""
    }
}


func replicate<T>(count: Int, elem: T) -> [T] {
    return [T](repeating: elem, count: count)
}


func intersperse<T>(a: T, b:[T]) -> [T] {
    if b.isEmpty {return []}
    return [b.x] + prependToAll(a: a, b: b.xs)
}

func prependToAll<T>(a: T, b: [T]) -> [T] {
    if b.isEmpty {return []}
    return [a] + [b.x] + prependToAll(a: a, b: b.xs)
}

func intercalate<T>(a: [T], b: [[T]]) -> [T] {
    return intersperse(a: a, b: b).flatMap { $0 }
}


func prettyList(level: Int, pretty: (Int, JSON) -> String, list: [JSON]) -> String {
    
    
}



func prettyObject(level: Int, pretty: (Int, JSON) -> String, object: [String: JSON]) -> String {
    
}

extension Array {
    
    var x: Element {
        return self.first!
    }
    
    var xs: [Element] {
        return self.dropFirst().map {$0}
    }
}
