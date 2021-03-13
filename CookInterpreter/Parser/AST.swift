//
//  AST.swift
//  SwiftCookInterpreter
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

class DirectionNode: AST {
    let value: String
    
    init(_ value: String) {
        self.value = value
    }
}

class MetadataNode: AST {
    let key: String
    let value: ConstantNode
    
    init(_ key: String, _ value: ConstantNode) {
        self.key = key
        self.value = value
    }
    
    init(_ key: String, _ value: String) {
        self.value = ConstantNode.string(value)
        self.key = key
    }
    
    init(_ key: String, _ value: Int) {
        self.value = ConstantNode.integer(value)
        self.key = key
    }
    
    init(_ key: String, _ value: Float) {
        self.value = ConstantNode.decimal(value)
        self.key = key
    }
    
    init(_ key: String, value: (Int, Int)) {
        self.value = ConstantNode.fractional(value)
        self.key = key
    }
        
}

class AmountNode: AST {
    let quantity: ConstantNode
    let units: String
    
    init(quantity: String, units: String) {
        self.quantity = ConstantNode.string(quantity)
        self.units = units
    }
    
    init(quantity: Int, units: String) {
        self.quantity = ConstantNode.integer(quantity)
        self.units = units
    }
    
    init(quantity: Float, units: String) {
        self.quantity = ConstantNode.decimal(quantity)
        self.units = units
    }
    
    init(quantity: (Int, Int), units: String) {
        self.quantity = ConstantNode.fractional(quantity)
        self.units = units
    }
    
    init(quantity: ConstantNode, units: String) {
        self.quantity = quantity
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
    let quantity: ConstantNode
    let units: String
    
    init(quantity: String, units: String) {
        self.quantity = ConstantNode.string(quantity)
        self.units = units
    }
    
    init(quantity: Int, units: String) {
        self.quantity = ConstantNode.integer(quantity)
        self.units = units
    }
    
    init(quantity: Float, units: String) {
        self.quantity = ConstantNode.decimal(quantity)
        self.units = units
    }
    
    init(quantity: (Int, Int), units: String) {
        self.quantity = ConstantNode.fractional(quantity)
        self.units = units
    }
    
    init(quantity: ConstantNode, units: String) {
        self.quantity = quantity
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


