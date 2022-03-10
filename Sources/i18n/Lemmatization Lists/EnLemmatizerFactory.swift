//
//  File.swift
//
//
//  Created by Alexey Dubovskoy on 10/03/2022.
//

import Foundation

public class EnLemmatizerFactory {
    static let uncountables = ["alcohol", "bacon", "beef", "beer", "bread", "butter", "cheese", "coffee", "cream", "fish", "flour", "flu", "food", "garlic", "ground", "honey", "ice", "iron", "jelly", "mayonnaise", "meat", "milk", "oil", "pasta", "rice", "rum", "salad", "sheep", "soup", "steam", "toast", "veal", "vengeance", "g", "kg", "tbsp", "tsp", "ml", "l", "small", "medium", "large"]

    static let pluralToSingular = [
        ("s$", ""),
        ("(ss)$", "$1"),
        ("(n)ews$", "$1ews"),
        ("([ti])a$", "$1um"),
        ("((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$", "$1sis"),
        ("(^analy)(sis|ses)$", "$1sis"),
        ("([^f])ves$", "$1fe"),
        ("(hive)s$", "$1"),
        ("(tive)s$", "$1"),
        ("([lr])ves$", "$1f"),
        ("([^aeiouy]|qu)ies$", "$1y"),
        ("(s)eries$", "$1eries"),
        ("(m)ovies$", "$1ovie"),
        ("(x|ch|ss|sh)es$", "$1"),
        ("^(m|l)ice$", "$1ouse"),
        ("(bus)(es)?$", "$1"),
        ("(o)es$", "$1"),
        ("(shoe)s$", "$1"),
        ("(cris|test)(is|es)$", "$1is"),
        ("^(a)x[ie]s$", "$1xis"),
        ("(octop|vir)(us|i)$", "$1us"),
        ("(alias|status)(es)?$", "$1"),
        ("^(ox)en", "$1"),
        ("(vert|ind)ices$", "$1ex"),
        ("(matr)ices$", "$1ix"),
        ("(quiz)zes$", "$1"),
        ("(database)s$", "$1")]

    static let unchangings = [
        "sheep",
        "deer",
        "moose",
        "swine",
        "bison",
        "corps"]

    static let irregulars = [
        ("person", "people"),
    ]

    public static func create() -> Lemmatizer {
        let lemmatizer = Lemmatizer()

        irregulars.forEach { (key, value) in
            lemmatizer.addIrregularRule(singular: key, andPlural: value)
        }

        pluralToSingular.reversed().forEach { (key, value) in
            lemmatizer.addSingularRule(rule: key, forReplacement: value)
        }

        unchangings.forEach { lemmatizer.unchanging(word: $0) }
        uncountables.forEach { lemmatizer.uncountableWord(word: $0) }

        return lemmatizer
    }

}
