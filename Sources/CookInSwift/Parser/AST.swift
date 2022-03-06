//
//  AST.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

public protocol AST {}

public enum ConstantNode: AST {
    case integer(Int)
    case decimal(Decimal)
    case string(String)
}

public struct ValueNode: AST {
    var value: ConstantNode

    init() {
//        TODO ???
        value = ConstantNode("")
    }

    init(_ v: ConstantNode)  {
        value = v
    }

    init(_ v: String) {
        value = ConstantNode(v)
    }

    init(_ v: Int) {
        value = ConstantNode(v)
    }

    init(_ v: Decimal) {
        value = ConstantNode(v)
    }

    mutating func add(_ v: ConstantNode) {
        value = v
    }

    func isEmpty() -> Bool {
        return value.isEmpty
    }
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

    init(_ key: String, _ value: ConstantNode) {
        self.key = key
        self.value = ValueNode(value)
    }

    init(_ key: String, _ value: String) {
        self.value = ValueNode(ConstantNode.string(value))
        self.key = key
    }

    init(_ key: String, _ value: Int) {
        self.value = ValueNode(ConstantNode.integer(value))
        self.key = key
    }

    init(_ key: String, _ value: Decimal) {
        self.value = ValueNode(ConstantNode.decimal(value))
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

    init(quantity: ConstantNode, units: String = "") {
        self.quantity = ValueNode(quantity)
        self.units = units
    }

    init(quantity: String, units: String = "") {
        self.quantity = ValueNode(ConstantNode.string(quantity))
        self.units = units
    }

    init(quantity: Int, units: String = "") {
        self.quantity = ValueNode(ConstantNode.integer(quantity))
        self.units = units
    }

    init(quantity: Decimal, units: String = "") {
        self.quantity = ValueNode(ConstantNode.decimal(quantity))
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

    init(quantity: ConstantNode, units: String, name: String = "") {
        self.quantity = ValueNode(quantity)
        self.units = units
        self.name = name
    }

    init(quantity: String, units: String, name: String = "") {
        self.quantity = ValueNode(ConstantNode.string(quantity))
        self.units = units
        self.name = name
    }

    init(quantity: Int, units: String, name: String = "") {
        self.quantity = ValueNode(ConstantNode.integer(quantity))
        self.units = units
        self.name = name
    }

    init(quantity: Decimal, units: String, name: String = "") {
        self.quantity = ValueNode(ConstantNode.decimal(quantity))
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
