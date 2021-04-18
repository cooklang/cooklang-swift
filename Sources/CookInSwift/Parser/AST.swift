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
    case decimal(Float)
    case fractional((Int, Int))
    case string(String)
}

public class ValuesNode: AST {
    var values: [ConstantNode]

    init()  {
        values = []
    }

    init(_ value: ConstantNode)  {
        values = [value]
    }

    init(_ value: String) {
        values = [ConstantNode(value)]
    }

    init(_ value: Int) {
        values = [ConstantNode(value)]
    }

    init(_ value: Float) {
        values = [ConstantNode(value)]
    }

    init(_ value: (Int, Int)) {
        values = [ConstantNode(value)]
    }

    func add(_ value: ConstantNode) {
        values.append(value)
    }

    func isEmpty() -> Bool {
        return values.isEmpty
    }
}

class DirectionNode: AST {
    let value: String

    init(_ value: String) {
        self.value = value
    }
}




class MetadataNode: AST {
    let key: String
    let value: ValuesNode

    init(_ key: String, _ value: ValuesNode) {
        self.key = key
        self.value = value
    }

    init(_ key: String, _ value: ConstantNode) {
        self.key = key
        self.value = ValuesNode(value)
    }

    init(_ key: String, _ value: String) {
        self.value = ValuesNode(ConstantNode.string(value))
        self.key = key
    }

    init(_ key: String, _ value: Int) {
        self.value = ValuesNode(ConstantNode.integer(value))
        self.key = key
    }

    init(_ key: String, _ value: Float) {
        self.value = ValuesNode(ConstantNode.decimal(value))
        self.key = key
    }

    init(_ key: String, value: (Int, Int)) {
        self.value = ValuesNode(ConstantNode.fractional(value))
        self.key = key
    }

}


class AmountNode: AST {
    let quantity: ValuesNode
    let units: String

    init(quantity: ValuesNode, units: String) {
        self.quantity = quantity
        self.units = units
    }

    init(quantity: ConstantNode, units: String) {
        self.quantity = ValuesNode(quantity)
        self.units = units
    }

    init(quantity: String, units: String) {
        self.quantity = ValuesNode(ConstantNode.string(quantity))
        self.units = units
    }

    init(quantity: Int, units: String) {
        self.quantity = ValuesNode(ConstantNode.integer(quantity))
        self.units = units
    }

    init(quantity: Float, units: String) {
        self.quantity = ValuesNode(ConstantNode.decimal(quantity))
        self.units = units
    }

    init(quantity: (Int, Int), units: String) {
        self.quantity = ValuesNode(ConstantNode.fractional(quantity))
        self.units = units
    }
}

class IngredientNode: AST {
    let name: String
    let amount: AmountNode

    init(name: String, amount: AmountNode) {
        self.name = name
        self.amount = amount
    }
}

class EquipmentNode: AST {
    let name: String

    init(name: String) {
        self.name = name
    }
}

class TimerNode: AST {
    let quantity: ValuesNode
    let units: String

    init(quantity: ValuesNode, units: String) {
        self.quantity = quantity
        self.units = units
    }

    init(quantity: ConstantNode, units: String) {
        self.quantity = ValuesNode(quantity)
        self.units = units
    }

    init(quantity: String, units: String) {
        self.quantity = ValuesNode(ConstantNode.string(quantity))
        self.units = units
    }

    init(quantity: Int, units: String) {
        self.quantity = ValuesNode(ConstantNode.integer(quantity))
        self.units = units
    }

    init(quantity: Float, units: String) {
        self.quantity = ValuesNode(ConstantNode.decimal(quantity))
        self.units = units
    }

    init(quantity: (Int, Int), units: String) {
        self.quantity = ValuesNode(ConstantNode.fractional(quantity))
        self.units = units
    }
}

class StepNode: AST {
    let instructions: [AST]

    init(instructions: [AST]) {
        self.instructions = instructions
    }
}

class RecipeNode: AST {
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




