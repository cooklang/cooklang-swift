//
//  Symbol+Extensions.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation



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
        return lhs.quantity == rhs.quantity
    }
}

extension Timer: CustomStringConvertible {
    public var description: String {
        if let v = Int(quantity.value) {
            return "\(quantity.value) \(units.pluralize(v))"
        } else {
            return "\(quantity.value) \(units.pluralize(2))"
        }
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


