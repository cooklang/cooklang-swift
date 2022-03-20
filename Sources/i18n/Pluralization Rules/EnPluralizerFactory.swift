//
//  File.swift
//
//
//  Created by Alexey Dubovskoy on 10/03/2022.
//

import Foundation

public class EnPluralizerFactory {
    static let uncountables = ["alcohol", "bacon", "beef", "beer", "bread", "butter", "cheese", "coffee", "cream", "fish", "flour", "flu", "food", "garlic", "ground", "honey", "ice", "iron", "jelly", "mayonnaise", "meat", "milk", "oil", "pasta", "rice", "rum", "salad", "sheep", "soup", "steam", "toast", "veal", "vengeance", "g", "kg", "tbsp", "tsp", "ml", "l", "small", "medium", "large"]

    static let singularToPlural = [
        ("$", "s"),
        ("s$", "s"),
        ("^(ax|test)is$", "$1es"),
        ("(octop|vir)us$", "$1i"),
        ("(octop|vir)i$", "$1i"),
        ("(alias|status)$", "$1es"),
        ("(bu)s$", "$1ses"),
        ("(buffal|tomat)o$", "$1oes"),
        ("([ti])um$", "$1a"),
        ("([ti])a$", "$1a"),
        ("sis$", "ses"),
        ("(?:([^f])fe|([lr])f)$", "$1$2ves"),
        ("(hive)$", "$1s"),
        ("([^aeiouy]|qu)y$", "$1ies"),
        ("(x|ch|ss|sh)$", "$1es"),
        ("(matr|vert|ind)(?:ix|ex)$", "$1ices"),
        ("^(m|l)ouse$", "$1ice"),
        ("^(m|l)ice$", "$1ice"),
        ("^(ox)$", "$1en"),
        ("^(oxen)$", "$1"),
        ("(quiz)$", "$1zes")]

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

    public static func create() -> Pluralizer {
        let pluralizer = Pluralizer()

        irregulars.forEach { (key, value) in
            pluralizer.addIrregularRule(singular: key, andPlural: value)
        }

        singularToPlural.reversed().forEach { (key, value) in
            pluralizer.addPluralRule(rule: key, forReplacement: value)
        }

        unchangings.forEach { pluralizer.unchanging(word: $0) }
        uncountables.forEach { pluralizer.uncountableWord(word: $0) }

        return pluralizer
    }

}
