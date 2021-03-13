//
//  AST+Extensions.swift
//  SwiftCookInterpreter
//
//  Created by Alexey Dubovskoy on 09/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

extension Float {
    var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension ConstantNode: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .integer(value):
            return "\(value)"
        case let .decimal(value):
            return value.cleanValue
        case let .fractional(value):
            return "\(value.0)/\(value.1)"
        case let .string(value):
            return "\(value)"
        }
    }
}

extension ConstantNode: Equatable {
    public static func == (lhs: ConstantNode, rhs: ConstantNode) -> Bool {
        switch (lhs, rhs) {
        case let (.integer(left), .integer(right)):
            return left == right
        case let (.decimal(left), .decimal(right)):
            return left == right
        case let (.fractional(left), .fractional(right)):
            return left.0 == right.0 && left.1 == right.1
        case let (.decimal(left), .integer(right)):
            return left == Float(right)
        case let (.integer(left), .decimal(right)):
            return Float(left) == right
        case let (.fractional(left), .integer(right)):
            return Float(left.0/left.1) == Float(right)
        case let (.fractional(left), .decimal(right)):
            return Float(left.0/left.1) == Float(right)
        case let (.integer(left), .fractional(right)):
            return Float(left) == Float(right.0/right.1)
        case let (.decimal(left), .fractional(right)):
            return Float(left) == Float(right.0/right.1)
        case (.string(_), _):
            return false
        case (_, .string(_)):
            return false
        }
    }
}

extension RecipeNode: Equatable {
    public static func == (lhs: RecipeNode, rhs: RecipeNode) -> Bool {
        return lhs.steps == rhs.steps
    }
}

extension StepNode: Equatable {
    public static func == (lhs: StepNode, rhs: StepNode) -> Bool {
        return lhs.instructions.map{ ($0.value ) }  == rhs.instructions.map{ ($0.value ) }
    }
}

extension MetadataNode: Equatable {
    public static func == (lhs: MetadataNode, rhs: MetadataNode) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

extension EquipmentNode: Equatable {
    public static func == (lhs: EquipmentNode, rhs: EquipmentNode) -> Bool {
        return lhs.name == rhs.name
    }
}

extension TimerNode: Equatable {
    public static func == (lhs: TimerNode, rhs: TimerNode) -> Bool {
        return lhs.quantity == rhs.quantity && lhs.units == rhs.units
    }
}


extension AST {
    var value: String {
        switch self {
        case let value as ConstantNode:
            
            switch value {
            case let .string(value):
                return "\(value)"
            case let .integer(value):
                return "\(value)"
            case let .decimal(value):
                return "\(value.cleanValue)"
            case let .fractional(value):
                return "\(value)"
            }
            
        case is RecipeNode:
            return "recipe"
        case is StepNode:
            return "step"
        case let m as MetadataNode:
            return "\(m.key) => \(m.value)"
        case let direction as DirectionNode:
            return direction.value
        case let ingredient as IngredientNode:
            return "ING: \(ingredient.name) [\(ingredient.amount.value)]"
        case let equipment as EquipmentNode:
            return "EQ: \(equipment.name)"
        case let timer as TimerNode:
            return "TIMER: \(timer.quantity) \(timer.units)"
        case let amount as AmountNode:
            switch amount.quantity {
            case let .integer(value):
                return "\(value) \(amount.units.pluralize(value))"
            case let .decimal(value):
                return "\(value) \(amount.units.pluralize(2))"
            case let .fractional(value):
                return "\(value) \(amount.units.pluralize(1))"
            default:
                return "\(amount.quantity) \(amount.units)"
            }
            
        default:
            fatalError("Missed AST case \(self)")
        }
    }

    var children: [AST] {
        switch self {
        case is ConstantNode:
            return []
        case is String:
            return []
        case let recipe as RecipeNode:
            return recipe.steps + recipe.metadata
        case let step as StepNode:
            return step.instructions
        case is DirectionNode:
            return []
        case is IngredientNode:
            return []
        case is TimerNode:
            return []
        case is EquipmentNode:
            return []
        case is AmountNode:
            return []
        case is MetadataNode:
            return []
        default:
            fatalError("Missed AST case \(self)")
        }
    }

    func treeLines(_ nodeIndent: String = "", _ childIndent: String = "") -> [String] {
        return [nodeIndent + value]
            + children.enumerated().map { ($0 < children.count - 1, $1) }
            .flatMap { $0 ? $1.treeLines("┣╸", "┃ ") : $1.treeLines("┗╸", "  ") }
            .map { childIndent + $0 }
    }

    public func printTree() -> String { return treeLines().joined(separator: "\n") }
}
