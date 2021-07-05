//
//  ConfigParser.swift
//
//
//  Created by Alexey Dubovskoy on 07/04/2021.
//


import Foundation

public class CookConfig {

    public var sections: [String: [String]] = [:]
    public var items: [String: String] = [:]

    public func add(item: String, section: String) {
        items[item] = section

        if sections[section] == nil {
            sections[section] = []
        } else {
            sections[section]?.append(item)
        }
    }
}

extension CookConfig: CustomStringConvertible {
    public var description: String {
        return sections.description
    }
}

extension CookConfig: Equatable {
    public static func == (lhs: CookConfig, rhs: CookConfig) -> Bool {
        return lhs.sections == rhs.sections
    }
}

func trim(_ s: String) -> String {
    let whitespaces = CharacterSet(charactersIn: " \n\r\t")
    return s.trimmingCharacters(in: whitespaces)
}


func parseSectionHeader(_ line: String) -> String {
    let from = line.index(after: line.startIndex)
    let to = line.index(before: line.endIndex)
    return line.substring(with: from..<to)
}


func parseLine(_ line: String) -> String {
    return trim(String(line))
}


public class ConfigParser {
    var text: String
    // MARK: - Fields

    public init(_ text: String) {
        self.text = text
    }

    public func parse() -> CookConfig {
        let config = CookConfig()
        var currentSectionName = "main"
        for line in text.components(separatedBy: "\n") {
            let line = trim(line)
            if (line == "") { continue }

            if line.hasPrefix("[") && line.hasSuffix("]") {
                currentSectionName = parseSectionHeader(line)
            } else {
                config.add(item: parseLine(line), section: currentSectionName)
            }
        }

        return config
    }
}
