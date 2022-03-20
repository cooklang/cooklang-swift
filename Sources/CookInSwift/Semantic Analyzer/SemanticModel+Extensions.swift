//
//  Symbol+Extensions.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation
import i18n


extension Recipe: Equatable {
    public static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.steps == rhs.steps && lhs.metadata == rhs.metadata
    }
}



extension Step: CustomStringConvertible {
    public var description: String {
        return """
        Directions:
        > \(directions.description)
        Ingredients:
        > \(ingredientsTable.description)
        """
    }
}

extension Step: Equatable {
    public static func ==(lhs: Step, rhs: Step) -> Bool {
        // TODO too expensive
        return lhs.directions.map { $0.description }.joined() == rhs.directions.map { $0.description }.joined()
    }
}



extension TextItem: CustomStringConvertible {
    public var description: String {
        return value
    }
}

extension TextItem: Equatable {
    public static func == (lhs: TextItem, rhs: TextItem) -> Bool {
        return lhs.value == rhs.value
    }
}



extension Equipment: Equatable {
    public static func == (lhs: Equipment, rhs: Equipment) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Equipment: CustomStringConvertible {
    public var description: String {
        return name
    }
}




extension Timer: Equatable {
    public static func == (lhs: Timer, rhs: Timer) -> Bool {
        switch lhs.quantity.self {
        case let lhsValue as Int:
            if type(of: rhs.quantity) == Int.self {
                return lhsValue == (rhs.quantity as! Int)
            } else {
                return false
            }
        case let lhsValue as Decimal:
            if type(of: rhs.quantity) == Decimal.self {
                return lhsValue == (rhs.quantity as! Decimal)
            } else {
                return false
            }
        case let lhsValue as String:
            if type(of: rhs.quantity) == String.self {
                return lhsValue == (rhs.quantity as! String)
            } else {
                return false
            }
        default:
            fatalError("Unrecognised value type")
        }
    }
}

extension Timer: CustomStringConvertible {
    public var description: String {
        return displayAmount(quantity: quantity, units: units)
    }
}



extension Ingredient: Equatable {
    public static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.name == rhs.name
    }
}


extension Ingredient: CustomStringConvertible {
    public var description: String {
        return name
    }
}


extension Recipe {
    public static func from(text: String) throws -> Recipe {
        RuntimeSupport.setLemmatizer(EnLemmatizerFactory.create())
        RuntimeSupport.setPluralizer(EnPluralizerFactory.create())

        let analyzer = SemanticAnalyzer()

        let node = try Parser.parse(text) as! RecipeNode

        return analyzer.analyze(node: node)
    }
}
