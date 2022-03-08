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
        switch quantity {
        case let value as Decimal:
            // when summing up quantities converted to Decimal in IngredientsTable
            // here we want to check if value can be converted back to integer before representation
            if let v = Int("\(value)") {
                if units == "" {
                    return "\(value)"
                } else {
                    return "\(value) \(units.pluralize(v))"
                }
            } else {
                if units == "" {
                    return "\(value.cleanValue)"
                } else {
                    return "\(value.cleanValue) \(units.pluralize(2))"
                }
            }
        case is String:
            if units == "" {
                return "\(quantity)"
            } else {
                return "\(quantity) \(units.pluralize(2))"
            }

        case let value as Int:
            if units == "" {
                return "\(value)"
            } else {
                return "\(value) \(units.pluralize(value))"
            }

        default:
            return ""
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


