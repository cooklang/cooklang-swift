//
//  Symbol.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

public protocol DirectionItem {
    var description: String { get }
}

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
    public var directions: [DirectionItem] = []
    public var timers: [ParsedTimer] = []
    public var equipments: [ParsedEquipment] = []

    func addIngredient(_ ingredient: IngredientNode) {
        let name = ingredient.name
        let amount = IngredientAmount(ingredient.amount.quantity, ingredient.amount.units)
        let ingredient = ParsedIngredient(name, amount)

        ingredientsTable.add(name: name, amount: amount)
        directions.append(ingredient)
    }

    func addTimer(_ timer: TimerNode) {
        let timer = ParsedTimer(timer.quantity, timer.units)

        timers.append(timer)
        directions.append(timer)
    }

    func addText(_ direction: DirectionNode) {
        let text = TextItem(direction.value.description)

        directions.append(text)
    }

    func addEquipment(_ equipment: EquipmentNode) {
        let equipment = ParsedEquipment(equipment.name)

        equipments.append(equipment)
        directions.append(equipment)
    }
}

public class TextItem: DirectionItem {
    public var value: String

    init(_ value: String) {
        self.value = value
    }
}

public class IngredientAmount {
//    TODO remove refs to internal ValuesNode
    public var quantity: ValuesNode
    public var units: String

    init(_ quantity: ValuesNode, _ units: String) {
        self.quantity = quantity
        self.units = units
    }

    init(_ quantity: ConstantNode, _ units: String) {
        self.quantity = ValuesNode(quantity)
        self.units = units
    }
}

public class ParsedIngredient: DirectionItem {
    public var name: String
    public var amount: IngredientAmount

    init(_ name: String, _ amount: IngredientAmount) {
        self.name = name
        self.amount = amount
    }
}


public class ParsedEquipment: DirectionItem {
    public var name: String

    init(_ name: String) {
        self.name = name
    }
}

public class ParsedTimer: DirectionItem {
//    TODO remove refs to internal ValuesNode
    public var quantity: ValuesNode
    public var units: String

    init(_ quantity: ValuesNode, _ units: String) {
        self.quantity = quantity
        self.units = units
    }
}

public class IngredientAmountCollection {
    var amountsCountable: [String: Float] = [:]
    var amountsUncountable: [String: String] = [:]

    func add(_ amount: IngredientAmount) {
        let units = amount.units.singularize

//        TODO
        switch amount.quantity.values.first {
        case let .integer(value):
            amountsCountable[units] = amountsCountable[units, default: 0] + Float(value)
        case let .decimal(value):
            amountsCountable[units] = Float(amountsCountable[units, default: 0]) + value
        case let .fractional(value):
            amountsCountable[units] = amountsCountable[units, default: 0] + Float(value.0)/Float(value.1)
        case let .string(value):
            amountsUncountable[amount.units] = value
        case .none:
            fatalError("Shite!")
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
}

