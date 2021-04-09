//
//  main.swift
//  json
//
//  Created by mac on 2021/4/9.
//

import Foundation

public enum JSON {
  case object([String: JSON])
  case array([JSON])
  case string(String)
  case number(NSNumber)
  case bool(Bool)
  case null
}

extension JSON: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .string(v): return "String(\(v))"
    case let .number(v): return "Number(\(v))"
    case let .bool(v): return "Bool(\(v))"
    case let .array(a): return "Array(\(a.description))"
    case let .object(o): return "Object(\(o.description))"
    case .null: return "Null"
    }
  }
}

extension JSON: Equatable {
    public static func == (lhs: JSON, rhs: JSON) -> Bool {
      switch (lhs, rhs) {
      case let (.string(l), .string(r)): return l == r
      case let (.number(l), .number(r)): return l == r
      case let (.bool(l), .bool(r)): return l == r
      case let (.array(l), .array(r)): return l == r
      case let (.object(l), .object(r)): return l == r
      case (.null, .null): return true
      default: return false
      }
    }
}





