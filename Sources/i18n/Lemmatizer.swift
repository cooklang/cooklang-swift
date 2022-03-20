//
//  File.swift
//
//
//  Created by Alexey Dubovskoy on 10/03/2022.
//

import Foundation

public class Lemmatizer {
    public init() {}

    private var singularRules: [InflectorRule] = []

    private var words: Set<String> = Set<String>()
    private var regexCache: [String: NSRegularExpression] = [:]

    public func lemma(_ string: String) -> String {
        return singularize(string: string)
    }

    func singularize(string: String) -> String {
        return apply(rules: singularRules, forString: string)
    }

    func addIrregularRule(singular: String, andPlural plural: String) {
        let singularRule: String = "\(plural)$"
        addSingularRule(rule: singularRule, forReplacement: singular)
    }

    func addSingularRule(rule: String, forReplacement replacement: String) {
        singularRules.append(InflectorRule(rule: rule, replacement: replacement))
        regexCache[rule] = try! NSRegularExpression(pattern: rule, options: .caseInsensitive)
    }

    func uncountableWord(word: String) {
        words.insert(word)
    }

    func unchanging(word: String) {
        words.insert(word)
    }

    private func apply(rules: [InflectorRule], forString string: String) -> String {
        if string == "" {
            return ""
        }

        if words.contains(string) {
            return string
        } else {
            for rule in rules {
                let range = NSMakeRange(0, string.count)
                let regex: NSRegularExpression = regexCache[rule.rule]!
                if let _ = regex.firstMatch(in: string, options: [], range: range) {
                    return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: rule.replacement)
                }
            }
        }
        return string
    }
}
