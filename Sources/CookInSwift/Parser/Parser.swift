//
//  Parser.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

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
            case .slash:
                eat(.slash)
                items.append("/")
            case .at, .hash, .tilde, .eof, .eol:
                return DirectionNode(items.joined())
            default:
                fatalError("Can't understand \(currentToken)")
            }
        }
    }

    private func ignoreWhitespace() {
        while currentToken == .constant(.string(" ")) {
            eat(.constant(.string(" ")))
        }
    }

    /**

     */
    private func values() -> ValuesNode {
        let v = ValuesNode()

        ignoreWhitespace()

        while true {

            switch currentToken {

            case let .constant(.string(value)):
                v.add(ConstantNode.string(value))
                eat(.constant(.string(value)))

            case let .constant(.decimal(value)):
                v.add(ConstantNode.decimal(value))
                eat(.constant(.decimal(value)))

            case let .constant(.integer(value)):
                eat(.constant(.integer(value)))
                ignoreWhitespace()

                if currentToken == .slash {
                    eat(.slash)
                    ignoreWhitespace()

                    let numerator = value
                    guard case let .constant(.integer(denominator)) = currentToken else {
                        fatalError("Integer expected, got \(currentToken)")
                    }

                    v.add(ConstantNode.fractional((numerator, denominator)))
                    eat(.constant(.integer(denominator)))
                } else {
                    v.add(ConstantNode.integer(value))
                }

            default:
                if !(currentToken == .braces(.right) || currentToken == .percent) {
                    fatalError("Number or word is expected, got \(currentToken)")
                }
            }

            if currentToken == .pipe {
                eat(.pipe)
            } else {
                break
            }
        }

        if v.isEmpty() {
            v.add(ConstantNode.integer(1))
        }

        return v
    }

    /**

     */
    private func units() -> String {
        ignoreWhitespace()

        guard case let .constant(.string(u)) = currentToken else {
            fatalError("Units expected, got \(currentToken)")
        }

        eat(.constant(.string(u)))

        return u.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    /**

     */
    private func amount() -> AmountNode {
        eat(.braces(.left))
        ignoreWhitespace()

        let q = values()
        ignoreWhitespace()

        var u = "item"

        if currentToken == .percent {
            eat(.percent)

            u = units()
        }

        ignoreWhitespace()
        eat(.braces(.right))

        return AmountNode(quantity: q, units: u)
    }

    /**

     */
    private func taggedName() -> String {
        var i = tokenIndex + 1
        var strategy: String = ""

        // need to look ahead to define if we need to wait for braces or not
        while i < tokens.count {
            if tokens[i] == .braces(.left) {
                strategy = "until_braces"
                break
            }

            if tokens[i] == .eof || tokens[i] == .eol || tokens[i] == .at || tokens[i] == .hash || tokens[i] == .tilde {
                strategy = "one_word"
                break
            }

            i += 1
        }

        switch strategy {
        case "until_braces":
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
                case .colon:
                    eat(.colon)
                    items.append(":")
                case .slash:
                    eat(.slash)
                    items.append("/")
                case  .braces(.left):
                    return items.joined()
                default:
                    fatalError("Can't understand \(currentToken)")
                }
            }
        case "one_word":
            guard case let .constant(.string(value)) = currentToken else {
                fatalError("String expected, got \(currentToken)")
            }

            eat(.constant(.string(value)))

            return value
        default:
            fatalError("Unexpected strategy \(strategy)")
        }


    }

    /**

     */
    private func ingredient() -> IngredientNode {
        eat(.at)

        let name = taggedName()
        var ingridientAmount = AmountNode(quantity: 1, units: "item")

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
            eat(.braces(.right))
        }

        return EquipmentNode(name: name)
    }

    /**

     */
    private func timer() -> TimerNode {
        eat(.tilde)

        eat(.braces(.left))
        let q = values()
        eat(.percent)
        let u = units()
        eat(.braces(.right))

        return TimerNode(quantity: q, units: u)
    }

    /**

     */
    private func metadataKey() -> String {
        guard case let .constant(.string(key)) = currentToken else {
            fatalError("String expected")
        }

        eat(.constant(.string(key)))

        return key
    }

    /**

     */
    private func metadata() -> MetadataNode {
        eat(.chevron)
        eat(.chevron)

        ignoreWhitespace()

        let k = metadataKey()

        ignoreWhitespace()

        eat(.colon)

        ignoreWhitespace()

        let v = values()

        return MetadataNode(k, v)
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


