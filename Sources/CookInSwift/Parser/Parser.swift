//
//  Parser.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

// GRAMMAR
// recipe: metadata step;
// metadata: key value;
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

enum ParserError: Error {
    case terminatorNotFound
}

class Parser {

    // MARK: - Fields

    private var tokenIndex = 0
    private let tokens: [Token]

    private var currentToken: Token {
        return tokens[tokenIndex]
    }

    private var nextToken: Token {
        return tokens[tokenIndex + 1]
    }

    init(_ tokens: [Token]) {
        self.tokens = tokens
    }

    static func parse(_ text: String) throws -> AST {
        let lexer = Lexer(text)
        let tokens = lexer.lex()
        let parser = Parser(tokens)
        return parser.parse()
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
    private func stringUntilTerminator(terminators: [Token]) throws -> String {
        var parts: [String] = []

        while true {
            if terminators.contains(currentToken) {
                break
//                TODO should really be configurable, because in some cases we consider next @ to be a stopper
            } else if currentToken == .eol || currentToken == .eof {
                throw ParserError.terminatorNotFound
            } else {
                parts.append(currentToken.literal)
                eat(currentToken)
            }
        }

        return parts.joined().trimmingCharacters(in: CharacterSet.whitespaces)
    }

    /**

     */
    private func direction() -> DirectionNode {
        var items: [String] = []

        while true {
            switch currentToken {
            case .eof, .eol:
                return DirectionNode(items.joined())
            case let .constant(.string(value)):
                eat(.constant(.string(value)))
                items.append(value)
            case let .constant(.integer(value)):
                eat(.constant(.integer(value)))
                items.append(String(value))
            case let .constant(.decimal(value)):
                eat(.constant(.decimal(value)))
                items.append("\(value)")
            case let .constant(.fractional((nom, denom))):
                eat(.constant(.fractional((nom, denom))))
                items.append("\(nom)/\(denom)")
            case .tilde:
                if case .constant(.string) = nextToken {
                    return DirectionNode(items.joined())
                } else if nextToken == .braces(.left) {
                    return DirectionNode(items.joined())
                } else {
                    items.append(currentToken.literal)
                    eat(currentToken)
                }
            case .at, .hash:
                if case .constant(.string) = nextToken {
                    return DirectionNode(items.joined())
                } else if case .constant(.integer) = nextToken {
                    return DirectionNode(items.joined())
                } else {
                    items.append(currentToken.literal)
                    eat(currentToken)
                }
            default:
                items.append(currentToken.literal)
                eat(currentToken)
            }
        }
    }

    private func ignoreWhitespace() {
        while currentToken == .constant(.space) {
            eat(.constant(.space))
        }
    }

    /**

     */
    private func values(defaultValue: ValueNode) -> ValueNode {
        var v = defaultValue

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
            case .constant(.space):
                break
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
                v = ValueNode.decimal(value)
                eat(.constant(.decimal(value)))

            case let .constant(.integer(value)):
                eat(.constant(.integer(value)))
                v = ValueNode.integer(value)

            case let .constant(.fractional((n, d))):
                eat(.constant(.fractional((n, d))))
                v = ValueNode.decimal(Decimal(n) / Decimal(d))

            default:
                if !(currentToken == .braces(.right) || currentToken == .percent) {
                    fatalError("Number or word is expected, got \(currentToken)")
                }
            }

        } else {
            var value = ""

            do {
                value = try stringUntilTerminator(terminators: [.percent, .braces(.right)])
            } catch ParserError.terminatorNotFound {
                print("woops")
            } catch {
                fatalError("Unexpected exception")
            }

            if value != "" {
                v = ValueNode.string(value)
            }
        }

        ignoreWhitespace()

        return v
    }

    /**

     */
    private func amount() throws -> AmountNode {
        eat(.braces(.left))

        var q = values(defaultValue: ValueNode.string(""))

        var units = ""

        if currentToken == .percent {
            eat(.percent)

            units = try stringUntilTerminator(terminators: [.braces(.right)])
        }

        eat(.braces(.right))

        if q.value == "" {
            if units.isEmpty {
                q = ValueNode.string("some")
            }
        }

        return AmountNode(quantity: q, units: units)
    }



    /**

     */
    private func taggedName() -> String {
        var i = tokenIndex
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
            var value = ""

            do {
                value = try stringUntilTerminator(terminators: [.braces(.left)])
            } catch ParserError.terminatorNotFound {
                print("woops")
            } catch {
                fatalError("Unexpected exception")
            }

            return value
        case .noBraces:
//            TODO not stable place
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
        var ingridientAmount = AmountNode(quantity: "some", units: "")

        if currentToken == .braces(.left) {
            do {
                ingridientAmount = try amount()
            } catch ParserError.terminatorNotFound {
                print("Warning: expected '}' but got end of line")
            } catch {
                fatalError("Unexpected exception")
            }
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

            if currentToken == .braces(.right) {
                eat(.braces(.right))
            } else {
                print("Warning: expected '}' but got \(currentToken.literal)")
            }
        }

        return EquipmentNode(name: name)
    }

    /**

     */
    private func timer() -> TimerNode {
        eat(.tilde)
        let name = taggedName()
        eat(.braces(.left))
        let quantity = values(defaultValue: ValueNode.integer(0))
        var units = ""
        if currentToken == .percent {
            eat(.percent)

            do {
                units = try stringUntilTerminator(terminators: [.braces(.right)])
            } catch ParserError.terminatorNotFound {
                print("Warning: expected '}' but got end of line")
                return TimerNode(quantity: "", units: "", name: "Invalid timer syntax")
            } catch {
                fatalError("Unexpected exception")
            }
        }

        eat(.braces(.right))

        return TimerNode(quantity: quantity, units: units, name: name)
    }

    /**
        >> key: value

     */
    private func metadata() -> MetadataNode {
        eat(.chevron)
        eat(.chevron)

        var key = ""

        do {
            key = try stringUntilTerminator(terminators: [.colon])
        } catch ParserError.terminatorNotFound {
            return MetadataNode("Invalid key syntax", "Invalid value syntax")
        } catch {
            fatalError("Unexpected exception")
        }

        eat(.colon)

        var value = ""

        do {
            value = try stringUntilTerminator(terminators: [.eol, .eof])
        } catch ParserError.terminatorNotFound {
//            TODO this is redundant
        } catch {
            fatalError("Unexpected exception")
        }

        if currentToken == .eol {
            eat(.eol)
        }

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
                switch nextToken {
                case .constant(.string), .constant(.integer):
                    instructions.append(ingredient())
                default:
                    instructions.append(direction())
                }
            case .hash:
                switch nextToken {
                case .constant(.string), .constant(.integer):
                    instructions.append(equipment())
                default:
                    instructions.append(direction())
                }
            case .tilde:
                switch nextToken {
                case .constant(.string), .braces(.left):
                    instructions.append(timer())
                default:
                    instructions.append(direction())
                }
            default:
                instructions.append(direction())
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


