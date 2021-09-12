//
//  Lexer.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

enum NumberParseStrategy {
    case integer
    case preSlashFractional
    case postSlashFractional
    case fractional
    case decimal
    case string
}

/**
 Basic lexical analyzer converting program text into tokens
 */
public class Lexer {

    // MARK: - Fields
    private let onlyLetters = CharacterSet.letters.subtracting(CharacterSet.nonBaseCharacters)
    private let text: [Unicode.Scalar]
    private let count: Int
    private var currentPosition: Int
    private var currentCharacter: Unicode.Scalar?

    // MARK: - Constants

    public init(_ text: String) {
        self.text = Array(text.unicodeScalars)
        self.count = text.count
        currentPosition = 0
        currentCharacter = text.isEmpty ? nil : self.text[0]
    }

    // MARK: - Stream helpers

    /**
     Skips all the whitespace
     */
    private func skipWhitestace() {
        while let character = currentCharacter, CharacterSet.whitespaces.contains(character) {
            advance()
        }
    }
    
    /**
     Skips all the newlines and whitespaces
     */
    private func skipNewlines() {
        while let character = currentCharacter, CharacterSet.newlines.contains(character) {
            advance()
        }
    }

    
    /**
     Skips comments
     */
    private func skipComment() {
        while let character = currentCharacter, !CharacterSet.newlines.contains(character) {
            advance()
        }
    }

    /**
     Advances by one character forward, sets the current character (if still any available)
     */
    private func advance() {
        currentPosition += 1

        guard currentPosition < count else {
            currentCharacter = nil
            return
        }

        currentCharacter = text[currentPosition]
    }

    /**
     Returns the next character without advancing

     Returns: Character if not at the end of the text, nil otherwise
     */
    private func peek() -> Unicode.Scalar? {
        let peekPosition = currentPosition + 1

        guard peekPosition < count else {
            return nil
        }

        return text[peekPosition]
    }

    // MARK: - Parsing helpers

    /**
     Reads a possible multidigit integer starting at the current position
     */
    private func number() -> Token {
        var lexem = ""

        var strategy: NumberParseStrategy = .integer

        var i = currentPosition + 1

        // need to look ahead to define if we can use numbers
        strategyLookAhead: while i < count {
            let character = text[i]

            switch strategy {
            case .integer:
                if CharacterSet.decimalDigits.contains(character) {
                    break
                } else if character == "." {
                    strategy = .decimal
                    break
                } else if character == "/" {
                    strategy = .postSlashFractional
                    break
                } else if CharacterSet.whitespaces.contains(character) {
                    strategy = .preSlashFractional
                    break
                } else if CharacterSet.newlines.contains(character) || CharacterSet.punctuationCharacters.contains(character) || CharacterSet.symbols.contains(character) {
                    break strategyLookAhead
                } else {
                    strategy = .string
                    break strategyLookAhead
                }
            case .decimal:
                if CharacterSet.decimalDigits.contains(character) {
                    break
                } else if CharacterSet.newlines.contains(character) || CharacterSet.whitespaces.contains(character) || CharacterSet.punctuationCharacters.contains(character) || CharacterSet.symbols.contains(character) {
                    break strategyLookAhead
                } else {
                    strategy = .string
                    break strategyLookAhead
                }
            case .preSlashFractional:
                if CharacterSet.whitespaces.contains(character) {
                    break
                } else if character == "/" {
                    strategy = .postSlashFractional
                    break
                } else {
                    strategy = .integer
                    break strategyLookAhead
                }

            case .postSlashFractional:
                if CharacterSet.decimalDigits.contains(character) {
                    strategy = .fractional
                    break
                } else if CharacterSet.whitespaces.contains(character) {
                    break
                } else {
                    strategy = .string
                    break strategyLookAhead
                }

            case .fractional:
                if CharacterSet.decimalDigits.contains(character) {
                    break
                } else if CharacterSet.newlines.contains(character) || CharacterSet.whitespaces.contains(character) || CharacterSet.punctuationCharacters.contains(character) || CharacterSet.symbols.contains(character) {
                    break strategyLookAhead
                } else {
                    strategy = .string
                    break strategyLookAhead
                }
            default:
                fatalError("Lexer bug, unspecified case for number parsing")
            }

            i += 1
        }

        switch strategy {
        case .decimal:
            let nextCharacter = peek()

            if let character = currentCharacter, character == "0" && nextCharacter! !=  "." {
                return word()
            }

            while let character = currentCharacter, CharacterSet.decimalDigits.contains(character) {
                lexem += String(character)
                advance()
            }

            if let character = currentCharacter, character == "." {
                lexem += "."
                advance()
            }

            while let character = currentCharacter, CharacterSet.decimalDigits.contains(character) {
                lexem += String(character)
                advance()
            }

            return .constant(.decimal(Float(lexem)!))
        case .integer:
            if let character = currentCharacter, character == "0" {
                return word()
            }

            while let character = currentCharacter, CharacterSet.decimalDigits.contains(character) {
                lexem += String(character)
                advance()
            }

            return .constant(.integer(Int(lexem)!))
        case .fractional:
            if let character = currentCharacter, character == "0" {
                return word()
            }

            var nominator = ""
            var denominator = ""
            while let character = currentCharacter, CharacterSet.decimalDigits.contains(character) {
                nominator += String(character)
                advance()
            }

            while  let character = currentCharacter, CharacterSet.whitespaces.contains(character) {
                advance()
            }

            if let character = currentCharacter, character == "/" {
                advance()
            }

            while  let character = currentCharacter, CharacterSet.whitespaces.contains(character) {
                advance()
            }

            while let character = currentCharacter, CharacterSet.decimalDigits.contains(character) {
                denominator += String(character)
                advance()
            }

            return .constant(.fractional((Int(nominator)!, Int(denominator)!)))
        case .string:
            return word()
        default:
            fatalError("Oops, something went wrong")
        }
    }

    private func word() -> Token {
        var lexem = ""
        while let character = currentCharacter, CharacterSet.alphanumerics.contains(character) {
            lexem += String(character)
            advance()
        }
        return .constant(.string(lexem))
    }
    
    private func punctuation() -> Token {
        var lexem = ""
        while let character = currentCharacter, !["{", "}", "@", "%", "/", ":", ">", "|"].contains(character) && (CharacterSet.punctuationCharacters.contains(character) || CharacterSet.symbols.contains(character)) {
            lexem += String(character)
            advance()
        }
        return .constant(.string(lexem))
    }
    
    private func whitespace() -> Token {
        while let character = currentCharacter, CharacterSet.whitespaces.contains(character) {
            advance()
        }
        return .constant(.space)
    }

    // MARK: - Public methods

    /**
     Reads the text at current position and returns next token

     - Returns: Next token in text
     */
    public func getNextToken() -> Token {
        while let currentCharacter = currentCharacter {            
            if CharacterSet.newlines.contains(currentCharacter) {
                skipNewlines()
                return .eol
            }

            if CharacterSet.whitespaces.contains(currentCharacter) {
                return whitespace()
            }

            // if the character is a digit, convert it to int, create an integer token and move position
            if CharacterSet.decimalDigits.contains(currentCharacter) {
                return number()
            }

            if currentCharacter == "@" {
                advance()
                return .at
            }
            
            if currentCharacter == "%" {
                advance()
                return .percent
            }
            
            if currentCharacter == "{" {
                advance()
                return .braces(.left)
            }

            if currentCharacter == "}" {
                advance()
                return .braces(.right)
            }
            
            if currentCharacter == ":" {
                advance()
                return .colon
            }
            
            if currentCharacter == ">" {
                advance()
                return .chevron
            }
            
            if currentCharacter == "|" {
                advance()
                return .pipe
            }
            
            if currentCharacter == "#" {
                advance()
                return .hash
            }
            
            if currentCharacter == "~" {
                advance()
                return .tilde
            }
            
            if currentCharacter == "/" {
                let nextCharacter = peek()
                
                advance()
                
                if let unwrapped = nextCharacter {
                    if unwrapped == "/" {
                        advance()
                        skipComment()
                        return .eol
                    } else {
                        return .constant(.string("/"))
                    }
                } else {
                    return .constant(.string("/"))
                }
            }

            if CharacterSet.punctuationCharacters.contains(currentCharacter) || CharacterSet.symbols.contains(currentCharacter) {
                return punctuation()
            }
            
            if CharacterSet.alphanumerics.contains(currentCharacter) {
                return word()
            }            
        }

        return .eof
    }
}
