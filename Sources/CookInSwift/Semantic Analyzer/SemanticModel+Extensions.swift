//
//  Symbol+Extensions.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation



extension SemanticRecipe: Equatable {
    public static func == (lhs: SemanticRecipe, rhs: SemanticRecipe) -> Bool {
        return lhs.steps == rhs.steps && lhs.metadata == rhs.metadata
    }
}



extension SemanticStep: CustomStringConvertible {
    public var description: String {
        return """
        Directions:
        > \(directions.description)
        Ingredients:
        > \(ingredientsTable.description)
        """
    }
}

extension SemanticStep: Equatable {
    public static func ==(lhs: SemanticStep, rhs: SemanticStep) -> Bool {
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



extension ParsedEquipment: Equatable {
    public static func == (lhs: ParsedEquipment, rhs: ParsedEquipment) -> Bool {
        return lhs.name == rhs.name
    }
}

extension ParsedEquipment: CustomStringConvertible {
    public var description: String {
        return name
    }
}




extension ParsedTimer: Equatable {
    public static func == (lhs: ParsedTimer, rhs: ParsedTimer) -> Bool {
        return lhs.quantity == rhs.quantity
    }
}

extension ParsedTimer: CustomStringConvertible {
    public var description: String {
        if let v = Int(quantity.value) {
            return "\(quantity.value) \(units.pluralize(v))"
        } else {
            return "\(quantity.value) \(units.pluralize(2))"
        }
    }
}



extension ParsedIngredient: Equatable {
    public static func == (lhs: ParsedIngredient, rhs: ParsedIngredient) -> Bool {
        return lhs.name == rhs.name
    }
}


extension ParsedIngredient: CustomStringConvertible {
    public var description: String {
        return name
    }
}


