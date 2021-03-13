//
//  Naming+Extensions.swift
//  SwiftPascalInterpreter
//
//  Created by Alexey Dubovskoy on 09/12/2020.
//  Copyright © 2017 Alexey Dubovskoy. All rights reserved.
//

import Foundation

extension Lexer: CustomStringConvertible {
    public var description: String {
        return "Lexer"
    }
}

extension Parser: CustomStringConvertible {
    public var description: String {
        return "Parser"
    }
}

extension SemanticAnalyzer: CustomStringConvertible {
    public var description: String {
        return "SemanticAnalyzer"
    }
}
