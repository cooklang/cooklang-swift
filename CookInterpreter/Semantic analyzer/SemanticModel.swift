//
//  Symbol.swift
//  SwiftCookInterpreter
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation


public class SemanticRecipe: Identifiable {
    public let id = UUID()
    public var ingredientsTable: IngredientTable = IngredientTable()
    public var steps: [SemanticStep] = []
    public var equipment: [ParsedEquipment] = []

    func addStep(_ step: SemanticStep) {
        steps.append(step)
        ingredientsTable = ingredientsTable + step.ingredientsTable
    }
    
    func addEquipment(_ e: EquipmentNode) {
        equipment.append(ParsedEquipment(e.name))
    }
    
}

public class SemanticStep: Identifiable {
    public let id = UUID()
    public var ingredientsTable: IngredientTable = IngredientTable()
    public var directions: String = ""
    public var timers: [ParsedTimer] = []
    
    func addDirections(_ text: String) {
        directions = text
    }
    
    func addIngredient(_ ingredient: IngredientNode) {
        ingredientsTable.add(ingredient)
    }
    
    func addTimer(_ timer: TimerNode) {
        timers.append(ParsedTimer(timer.quantity, timer.units))
    }
    
}

public class IngredientAmount {
    public var quantity: ConstantNode
    public var units: String
    
    init(_ quantity: ConstantNode, _ units: String) {
        self.quantity = quantity
        self.units = units
    }
}

public class ParsedEquipment {
    public var name: String
    
    init(_ name: String) {
        self.name = name
    }
}

public class ParsedTimer {
    public var quantity: ConstantNode
    public var units: String
    
    init(_ quantity: ConstantNode, _ units: String) {
        self.quantity = quantity
        self.units = units
    }
}

public class IngredientAmountCollection {
    var amountsCountable: [String: Float] = [:]
    var amountsUncountable: [String: String] = [:]
        
    func add(_ amount: IngredientAmount) {
        let units = amount.units.singularize
        
        switch amount.quantity {
        case let .integer(value):
            amountsCountable[units] = amountsCountable[units, default: 0] + Float(value)
        case let .decimal(value):
            amountsCountable[units] = Float(amountsCountable[units, default: 0]) + value
        case let .fractional(value):
            amountsCountable[units] = amountsCountable[units, default: 0] + Float(value.0)/Float(value.1)
        case let .string(value):
            amountsUncountable[amount.units] = value
        }

    }
}

public class IngredientTable {
    public var ingredients: [String: IngredientAmountCollection] = [:]
    
    public init() {
    }
    
    func add(name: String, amount: IngredientAmount) {
        if ingredients[name] == nil {
            ingredients[name] = IngredientAmountCollection()
        }
                
        ingredients[name]?.add(amount)
    }
    
    func add(name: String, amounts: IngredientAmountCollection) {
        amounts.forEach {
            add(name: name, amount: $0)
        }
    }
        
    func add(_ ingredient: IngredientNode) {
        let amount = IngredientAmount(ingredient.amount.quantity, ingredient.amount.units)
        
        add(name: ingredient.name, amount: amount)
    }
    
}
