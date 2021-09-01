//
//  Parser.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

enum TaggedParseStrategy {
    case noBraces
    case withBraces
}

enum QuantityParseStrategy {
    case number
    case string
}

public class Parser {

    // MARK: - Fields

    private var tokenIndex = 0
    private let tokens: [Token]

    private var currentToken: Token {
        return tokens[tokenIndex]
    }

    private var nextToken: Token {
        return tokens[tokenIndex + 1]
    }

    public init(_ text: String) {
        let lexer = Lexer(text)
        var token = lexer.getNextToken()
        var all = [token]
        while token != .eof {
            token = lexer.getNextToken()
            all.append(token)
        }
        tokens = all
    }

    // MARK: - Helpers

    /**
     Compares the current token with the given token, if they match, the next token is read,
     otherwise an error is thrown

     - Parameter token: Expected token
     */
    private func eat(_ token: Token) {
        if currentToken == token {
            tokenIndex += 1
        } else {
            fatalError("Syntax error, expected \(token), got \(currentToken)")
        }
    }

    // MARK: - Grammar rules

    /**

     */
    private func direction() -> DirectionNode {
        var items: [String] = []

        while true {
            switch currentToken {
            case let .constant(.string(value)):
                eat(.constant(.string(value)))
                items.append(value)
            case let .constant(.integer(value)):
                eat(.constant(.integer(value)))
                items.append(String(value))
            case let .constant(.decimal(value)):
                eat(.constant(.decimal(value)))
                items.append(String(value))
            case .chevron:
                eat(.chevron)
                items.append(">")
            case .colon:
                eat(.colon)
                items.append(":")
            case .pipe:
                eat(.pipe)
                items.append("|")
            case .at, .hash, .tilde, .eof, .eol:
                return DirectionNode(items.joined())
            default:
                fatalError("Can't understand \(currentToken)")
            }
        }
    }

//    TODO support not only space?
    private func ignoreWhitespace() {
        while currentToken == .constant(.string(" ")) {
            eat(.constant(.string(" ")))
        }
    }

    /**

     */
    private func values() -> ValuesNode {
        var v = ValuesNode()

        var strategy: QuantityParseStrategy = .string
        var i = tokenIndex

        // need to look ahead to define if we can use numbers
        strategyLookAhead: while i < tokens.count {
            switch tokens[i] {
            case .percent, .braces(.right):
                break strategyLookAhead
            case .constant(.decimal):
                strategy = .number
            case .constant(.integer):
                strategy = .number
            case .constant(.fractional):
                strategy = .number
            case let .constant(.string(value)):
//                TODO not 100% right as this is valid only for fractional
                if CharacterSet.whitespaces.contains(value.unicodeScalars.first!) {
                    break
                } else {
                    strategy = .string
                    break strategyLookAhead
                }
            default:
                strategy = .string
                break strategyLookAhead
            }

            i += 1
        }

        if strategy == .number {
            ignoreWhitespace()

            switch currentToken {

            case let .constant(.decimal(value)):
                v.add(ConstantNode.decimal(value))
                eat(.constant(.decimal(value)))

            case let .constant(.integer(value)):
                eat(.constant(.integer(value)))
                v.add(ConstantNode.integer(value))

            case let .constant(.fractional((n, d))):
                eat(.constant(.fractional((n, d))))
                v.add(ConstantNode.fractional((n, d)))

            default:
                if !(currentToken == .braces(.right) || currentToken == .percent) {
                    fatalError("Number or word is expected, got \(currentToken)")
                }
            }

        } else {
            let value = stringUntilTerminator(terminators: [.percent, .braces(.right)])

            if value != "" {
                v.add(ConstantNode.string(value))
            }
        }

        if v.isEmpty() {
            v.add(ConstantNode.integer(1))
        }

        ignoreWhitespace()

        return v
    }

    /**

     */
    private func amount() -> AmountNode {
        eat(.braces(.left))

        let q = values()

        var units = ""

        if currentToken == .percent {
            eat(.percent)

            units = stringUntilTerminator(terminators: [.braces(.right)])
        }

        eat(.braces(.right))

        return AmountNode(quantity: q, units: units)
    }

    /**

     */
    private func stringUntilTerminator(terminators: [Token]) -> String {
        var parts: [String] = []

        while true {
            if terminators.contains(currentToken) {
                break
            } else if currentToken == .eol || currentToken == .eof {
                fatalError("Unexpectd end of line or endo of file")
            } else {
                parts.append(currentToken.literal)
                eat(currentToken)
            }
        }

        return parts.joined().trimmingCharacters(in: CharacterSet.whitespaces)
    }

    /**

     */
    private func taggedName() -> String {
        var i = tokenIndex + 1
        var strategy: TaggedParseStrategy?

        // need to look ahead to define if we need to wait for braces or not
        while i < tokens.count {
            if tokens[i] == .braces(.left) {
                strategy = .withBraces
                break
            }

            if tokens[i] == .eof || tokens[i] == .eol || tokens[i] == .at || tokens[i] == .hash || tokens[i] == .tilde {
                strategy = .noBraces
                break
            }

            i += 1
        }

        switch strategy {
        case .withBraces:
            return stringUntilTerminator(terminators: [.braces(.left)])
        case .noBraces:
            guard case let .constant(.string(value)) = currentToken else {
                fatalError("String expected, got \(currentToken)")
            }

            eat(.constant(.string(value)))

            return value
        default:
            fatalError("Can't understand strategy")
        }
    }

    /**

     */
    private func ingredient() -> IngredientNode {
        eat(.at)

        let name = taggedName()
        var ingridientAmount = AmountNode(quantity: 1, units: "")

        if currentToken == .braces(.left) {
            ingridientAmount = amount()
        }

        return IngredientNode(name: name, amount: ingridientAmount)
    }

    /**

     */
    private func equipment() -> EquipmentNode {
        eat(.hash)

        let name = taggedName()

        if currentToken == .braces(.left) {
            eat(.braces(.left))
            ignoreWhitespace()
            eat(.braces(.right))
        }

        return EquipmentNode(name: name)
    }

    /**

     */
    private func timer() -> TimerNode {
        eat(.tilde)
        let name = ""// taggedName()
        eat(.braces(.left))
        let quantity = values()
        eat(.percent)
        let units = stringUntilTerminator(terminators: [.braces(.right)])
        eat(.braces(.right))

        return TimerNode(quantity: quantity, units: units, name: name)
    }

    /**

     */
    private func metadata() -> MetadataNode {
        eat(.chevron)
        eat(.chevron)

        let key = stringUntilTerminator(terminators: [.colon])

        eat(.colon)

        let value = stringUntilTerminator(terminators: [.eol, .eof])

        return MetadataNode(key, value)
    }

    /**

     */
    private func step() -> StepNode {
        var instructions: [AST] = []

        while true {
            switch currentToken {
            case .eol:
                eat(.eol)

                if !instructions.isEmpty {
                    return StepNode(instructions: instructions)
                }
            case .eof:
                return StepNode(instructions: instructions)
            case .at:
                instructions.append(ingredient())
            case .hash:
                instructions.append(equipment())
            case .tilde:
                instructions.append(timer())
            case .constant:
                instructions.append(direction())
            default:
                fatalError("Illigal instruction \(currentToken)")
            }
        }
    }

    /**

     */
    private func recipe() -> RecipeNode {
        var steps: [StepNode] = []
        var meta: [MetadataNode] = []

        while currentToken != .eof {
            if currentToken == .chevron && nextToken == .chevron {
                meta.append(metadata())
            } else {
                steps.append(step())
            }
        }

        let node = RecipeNode(steps: steps, metadata: meta)

        return node
    }

    // MARK: - Public methods.

    /**

     */
    public func parse() -> AST {
        let node = recipe()

        if currentToken != .eof {
            fatalError("Syntax error, end of file expected")
        }

        return node
    }
}


