//
//  Token.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 06/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation


public enum Braces {
    case left
    case right
}

public enum Constant {
    case integer(Int)
    case decimal(Float)
    case fractional((Int, Int))
    case string(String)
}

public enum Token {
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
