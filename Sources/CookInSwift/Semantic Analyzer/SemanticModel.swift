//
//  Symbol.swift
//  SwiftCookInSwift
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
    public var metadata: [String: String] = [:]

    func addStep(_ step: SemanticStep) {
        steps.append(step)
        ingredientsTable = ingredientsTable + step.ingredientsTable
    }

    func addEquipment(_ e: EquipmentNode) {
        equipment.append(ParsedEquipment(e.name))
    }

    func addMetadata(_ m: [MetadataNode]) {
        // TODO
        m.forEach{ item in
            metadata[item.key] = item.value.description
        }
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

//    TODO figure out how to make it DRY
    init(_ quantity: Int, _ units: String) {
        self.quantity = ValuesNode(quantity)
        self.units = units
    }

    init(_ quantity: String, _ units: String) {
        self.quantity = ValuesNode(quantity)
        self.units = units
    }

    init(_ quantity: Float, _ units: String) {
        self.quantity = ValuesNode(quantity)
        self.units = units
    }
}

public protocol DirectionItem {
    var description: String { get }
}
