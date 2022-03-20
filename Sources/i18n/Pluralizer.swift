//
// Pluralize.swift
// link:
//     https://github.com/joshualat/Pluralize.swift
//
// usage:
//     "Tooth".pluralize
//     "Nutrtion".pluralize
//     "House".pluralize(count: 1)
//     "Person".pluralize(count: 2, with: "Persons")
//
// Copyright (c) 2014 Joshua Arvin Lat
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
import Foundation

struct InflectorRule {
    var rule: String
    var replacement: String
}

public class Pluralizer {

    private var pluralRules: [InflectorRule] = []
    private var words: Set<String> = Set<String>()
    private var regexCache: [String: NSRegularExpression] = [:]


    public func pluralize(string: String) -> String {
        return apply(rules: pluralRules, forString: string)
    }

    public func pluralize(string: String, count: Int) -> String {
        if count == 1 { return string }
        return pluralize(string: string)
    }

    func addIrregularRule(singular: String, andPlural plural: String) {
        let pluralRule: String = "\(singular)$"
        addPluralRule(rule: pluralRule, forReplacement: plural)
    }

    func addPluralRule(rule: String, forReplacement replacement: String) {
        pluralRules.append(InflectorRule(rule: rule, replacement: replacement))
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

