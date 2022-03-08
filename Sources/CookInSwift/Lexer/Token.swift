//
//  Token.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 06/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation


enum Braces {
    case left
    case right
}

enum Constant {
    case integer(Int)
    case decimal(Decimal)
    case fractional((Int, Int))
    case string(String)
    case space
}

enum Token {
    case eof
    case eol
    case at
    case percent
    case hash
    case tilde
    case chevron
    case colon
    case pipe
    case braces(Braces)
    case constant(Constant)    
}
