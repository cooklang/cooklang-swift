//
//  Token+Extensions.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 09/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

protocol Literal {
    var literal: String { get }
}

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.eof, .eof):
            return true
        case (.eol, .eol):
            return true
        case (.at, .at):
            return true
        case (.percent, .percent):
            return true
        case (.chevron, .chevron):
            return true
        case (.colon, .colon):
            return true
        case (.pipe, .pipe):
            return true
        case (.tilde, .tilde):
            return true
        case (.hash, .hash):
            return true
        case let (.constant(left), .constant(right)):
            return left == right
        case let (.braces(left), .braces(right)):
            return left == right
        default:
            return false
        }
    }
}

extension Constant: Equatable {
    static func == (lhs: Constant, rhs: Constant) -> Bool {
        switch (lhs, rhs) {
        case let (.integer(left), .integer(right)):
            return left == right
        case let (.decimal(left), .decimal(right)):
            return left == right
        case let (.fractional((leftN, leftD)), .fractional((rightN, rightD))):
            return leftN == rightN && leftD == rightD
        case let (.string(left), .string(right)):
            return left == right
        case (.space, .space):
            return true
        default:
            return false
        }
    }
}

extension Token: Literal {
    var literal: String {
        get {
            switch self {
            case .at:
                return "@"
            case .eof:
                return ""
            case .eol:
                return ""
            case .percent:
                return "%"
            case .hash:
                return "#"
            case .tilde:
                return "~"
            case .chevron:
                return ">"
            case .colon:
                return ":"
            case .pipe:
                return "|"
            case let .braces(braces):
                return braces.literal
            case let .constant(constant):
                return constant.literal
            }
        }
    }
}

extension Braces: Literal {
    var literal: String {
        get {
            switch self {
            case .left:
                return "{"
            case .right:
                return "}"
            }
        }
    }
}

extension Constant: Literal {
    var literal: String {
        get {
            switch self {
            case let .integer(value):
                return String(value)
            case let .decimal(value):
                return "\(value)"
            case let .fractional((nominator, denominator)):
                return "\(nominator)/\(denominator)"
            case let .string(value):
                return value
            case .space:
                return " "
            }
        }
    }
}

extension Braces: CustomStringConvertible {
    var description: String {
        switch self {
        case .left:
            return "LBRACE"
        case .right:
            return "RBRACE"
        }
    }
}

extension Constant: CustomStringConvertible {
    var description: String {
        switch self {
        case let .integer(value):
            return "INTEGER_CONST(\(value))"
        case let .decimal(value):
            return "DECIMAL_CONST(\(value))"
        case let .fractional((nominator, denominator)):
            return "FRACTIONAL_CONST(\(nominator)/\(denominator)"
        case let .string(value):
            return "STRING_CONST(\(value))"
        case .space:
            return "SPACE_CONST"
        }
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        switch self {
        case .eof:
            return "EOF"
        case .eol:
            return "EOL"
        case .at:
            return "@"
        case .percent:
            return "%"
        case .hash:
            return "#"
        case .tilde:
            return "~"
        case .chevron:
            return ">"
        case .colon:
            return ":"
        case .pipe:
            return "|"
        case let .constant(constant):
            return constant.description        
        case let .braces(braces):
            return braces.description        
        }
    }
}
