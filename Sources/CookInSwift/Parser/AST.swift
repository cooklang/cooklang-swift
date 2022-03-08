//
//  AST.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

protocol AST {}

enum ValueNode: AST {
    case integer(Int)
    case decimal(Decimal)
    case string(String)
}

struct DirectionNode: AST {
    let value: String

    init(_ value: String) {
        self.value = value
    }
}


struct MetadataNode: AST {
    let key: String
    let value: ValueNode

    init(_ key: String, _ value: ValueNode) {
        self.key = key
        self.value = value
    }

    init(_ key: String, _ value: String) {
        self.value = ValueNode.string(value)
        self.key = key
    }

    init(_ key: String, _ value: Int) {
        self.value = ValueNode.integer(value)
        self.key = key
    }

    init(_ key: String, _ value: Decimal) {
        self.value = ValueNode.decimal(value)
        self.key = key
    }

}


struct AmountNode: AST {
    let quantity: ValueNode
    let units: String

    init(quantity: ValueNode, units: String = "") {
        self.quantity = quantity
        self.units = units
    }

    init(quantity: String, units: String = "") {
        self.quantity = ValueNode.string(quantity)
        self.units = units
    }

    init(quantity: Int, units: String = "") {
        self.quantity = ValueNode.integer(quantity)
        self.units = units
    }

    init(quantity: Decimal, units: String = "") {
        self.quantity = ValueNode.decimal(quantity)
        self.units = units
    }

}

struct IngredientNode: AST {
    let name: String
    let amount: AmountNode

    init(name: String, amount: AmountNode) {
        self.name = name
        self.amount = amount
    }
}

struct EquipmentNode: AST {
    let name: String
    let quantity: ValueNode?

    init(name: String, quantity: ValueNode? = nil) {
        self.name = name
        self.quantity = quantity
    }
}

struct TimerNode: AST {
    let quantity: ValueNode
    let units: String
    let name: String

    init(quantity: ValueNode, units: String, name: String = "") {
        self.quantity = quantity
        self.units = units
        self.name = name
    }

    init(quantity: String, units: String, name: String = "") {
        self.quantity = ValueNode.string(quantity)
        self.units = units
        self.name = name
    }

    init(quantity: Int, units: String, name: String = "") {
        self.quantity = ValueNode.integer(quantity)
        self.units = units
        self.name = name
    }

    init(quantity: Decimal, units: String, name: String = "") {
        self.quantity = ValueNode.decimal(quantity)
        self.units = units
        self.name = name
    }
}

struct StepNode: AST {
    let instructions: [AST]

    init(instructions: [AST]) {
        self.instructions = instructions
    }
}

struct RecipeNode: AST {
    let steps: [StepNode]
    let metadata: [MetadataNode]

    init(steps: [StepNode], metadata: [MetadataNode]) {
        self.steps = steps
        self.metadata = metadata
    }

    init(steps: [StepNode]) {
        self.steps = steps
        self.metadata = []
    }
}
