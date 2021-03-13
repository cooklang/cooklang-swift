//
//  Lexer.swift
//  SwiftCookInterpreter
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

/**
 Basic lexical analyzer converting program text into tokens
 */
public class Lexer {

    // MARK: - Fields

    private let text: String
    private var currentPosition: Int
    private var currentCharacter: Character?

    // MARK: - Constants

    public init(_ text: String) {
        self.text = text
        currentPosition = 0
        currentCharacter = text.isEmpty ? nil : text[text.startIndex]
    }

    // MARK: - Stream helpers

    /**
     Skips all the whitespace
     */
    private func skipWhitestace() {
        while let character = currentCharacter, CharacterSet.whitespaces.contains(character.unicodeScalars.first!) {
            advance()
        }
    }
    
    /**
     Skips all the newlines and whitespaces
     */
    private func skipNewlines() {
        while let character = currentCharacter, CharacterSet.newlines.contains(character.unicodeScalars.first!) {
            advance()
        }
    }

    
    /**
     Skips comments
     */
    private func skipComment() {
        while let character = currentCharacter, !CharacterSet.newlines.contains(character.unicodeScalars.first!) {
            advance()
        }
    }

    /**
     Advances by one character forward, sets the current character (if still any available)
     */
    private func advance() {
        currentPosition += 1
        guard currentPosition < text.count else {
            currentCharacter = nil
            return
        }

        currentCharacter = text[text.index(text.startIndex, offsetBy: currentPosition)]
    }

    /**
     Returns the next character without advancing

     Returns: Character if not at the end of the text, nil otherwise
     */
    private func peek() -> Character? {
        let peekPosition = currentPosition + 1

        guard peekPosition < text.count else {
            return nil
        }

        return text[text.index(text.startIndex, offsetBy: peekPosition)]
    }

    // MARK: - Parsing helpers

    /**
     Reads a possible multidigit integer starting at the current position
     */
    private func number() -> Token {
        var lexem = ""
        while let character = currentCharacter, CharacterSet.decimalDigits.contains(character.unicodeScalars.first!) {
            lexem += String(character)
            advance()
        }

        if let character = currentCharacter, character == ".", text[text.index(text.startIndex, offsetBy: currentPosition + 1)] != "." {
            lexem += "."
            advance()

            while let character = currentCharacter, CharacterSet.decimalDigits.contains(character.unicodeScalars.first!) {
                lexem += String(character)
                advance()
            }

            return .constant(.decimal(Float(lexem)!))
        }
                
        return .constant(.integer(Int(lexem)!))
    }

    private func word() -> Token {
        var lexem = ""
        while let character = currentCharacter, CharacterSet.alphanumerics.contains(character.unicodeScalars.first!) {
            lexem += String(character)
            advance()
        }
        return .constant(.string(lexem))
    }
    
    private func punctuation() -> Token {
        var lexem = ""
        while let character = currentCharacter, !["{", "}", "@", "%", "/", ":", ">", "|"].contains(character) && (CharacterSet.punctuationCharacters.contains(character.unicodeScalars.first!) || CharacterSet.symbols.contains(character.unicodeScalars.first!)) {
            lexem += String(character)
            advance()
        }
        return .constant(.string(lexem))
    }
    
    private func whitespace() -> Token {
        var lexem = ""
        while let character = currentCharacter, CharacterSet.whitespaces.contains(character.unicodeScalars.first!) {
            lexem += String(character)
            advance()
        }
        return .constant(.string(lexem))
    }

    // MARK: - Public methods

    /**
     Reads the text at current position and returns next token

     - Returns: Next token in text
     */
    public func getNextToken() -> Token {
        while let currentCharacter = currentCharacter {            
            if CharacterSet.newlines.contains(currentCharacter.unicodeScalars.first!) {
                skipNewlines()
                return .eol
            }

            if CharacterSet.whitespaces.contains(currentCharacter.unicodeScalars.first!) {
                return whitespace()
            }

            // if the character is a digit, convert it to int, create an integer token and move position
            if CharacterSet.decimalDigits.contains(currentCharacter.unicodeScalars.first!) {
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
                        return .slash
                    }
                } else {
                    return .slash
                }
                
                
            }
            
            if CharacterSet.punctuationCharacters.contains(currentCharacter.unicodeScalars.first!) || CharacterSet.symbols.contains(currentCharacter.unicodeScalars.first!) {
                return punctuation()
            }
            
            if CharacterSet.alphanumerics.contains(currentCharacter.unicodeScalars.first!) {
                return word()
            }            
        }

        return .eof
    }
}
