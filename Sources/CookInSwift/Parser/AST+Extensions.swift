//
//  AST+Extensions.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 09/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

extension Decimal {
    var cleanValue: String {
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = 2
        return formatter.string(from: self as NSDecimalNumber)!
    }
}


extension ValueNode {
    init(_ value: Int) {
        self = .integer(value)
    }

    init(_ value: Decimal) {
        self = .decimal(value)
    }

    init(_ value: String) {
        self = .string(value)
    }
}


extension ValueNode: CustomStringConvertible {
    var description: String {
        switch self {
        case let .integer(value):
            return "\(value)"
        case let .decimal(value):
            return value.cleanValue
        case let .string(value):
            return "\(value)"
        }
    }
}

extension ValueNode: Equatable {
    static func == (lhs: ValueNode, rhs: ValueNode) -> Bool {
        switch (lhs, rhs) {
        case let (.integer(left), .integer(right)):
            return left == right
        case let (.decimal(left), .decimal(right)):
            return left == right
        case let (.decimal(left), .integer(right)):
            return left == Decimal(right)
        case let (.integer(left), .decimal(right)):
            return Decimal(left) == right
        case let (.string(left), .string(right)):
            return left == right
        case (.string(_), _):
            return false
        case (_, .string(_)):
            return false
        }
    }
}

extension RecipeNode: Equatable {
    static func == (lhs: RecipeNode, rhs: RecipeNode) -> Bool {
        return lhs.steps == rhs.steps && lhs.metadata == rhs.metadata
    }
}

extension StepNode: Equatable {
    static func == (lhs: StepNode, rhs: StepNode) -> Bool {
        return lhs.instructions.map{ ($0.value ) }  == rhs.instructions.map{ ($0.value ) }
    }
}


extension MetadataNode: Equatable {
    static func == (lhs: MetadataNode, rhs: MetadataNode) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

extension EquipmentNode: Equatable {
    static func == (lhs: EquipmentNode, rhs: EquipmentNode) -> Bool {
        return lhs.name == rhs.name
    }
}

extension TimerNode: Equatable {
    static func == (lhs: TimerNode, rhs: TimerNode) -> Bool {
        return lhs.quantity == rhs.quantity && lhs.units == rhs.units
    }
}

extension AST {
    var value: String {
        switch self {
        case let v as ValueNode:

            switch v {
            case let .string(v):
                return "\(v)"
            case let .integer(v):
                return "\(v)"
            case let .decimal(v):
                return "\(v.cleanValue)"
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
            return "TIMER(\(timer.name)): \(timer.quantity) \(timer.units)"        
        case let amount as AmountNode:
//            TODO
            switch amount.quantity {
            case let .integer(value):
                return "\(value) \(amount.units.pluralize(value))"
            case let .decimal(value):
                return "\(value) \(amount.units.pluralize(2))"
            default:
                return "\(amount.quantity) \(amount.units)"
            }

        default:
            fatalError("Missed AST case \(self)")
        }
    }

    var children: [AST] {
        switch self {
        case is ValueNode:
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

    func printTree() -> String { return treeLines().joined(separator: "\n") }
}

