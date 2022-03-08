//
//  Symbol.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

public struct Recipe {
    public var ingredientsTable: IngredientTable = IngredientTable()
    public var steps: [Step] = []
    public var equipment: [Equipment] = []
    public var metadata: [String: String] = [:]

    mutating func addStep(_ step: Step) {
        steps.append(step)
        ingredientsTable = mergeIngredientTables(ingredientsTable, step.ingredientsTable)
    }

    mutating func addEquipment(_ e: EquipmentNode) {
        equipment.append(Equipment(e.name))
    }

    mutating func addMetadata(_ m: [MetadataNode]) {
        m.forEach{ item in
            metadata[item.key] = item.value.description
        }
    }

    public static func from(text: String) throws -> Recipe {
        let analyzer = SemanticAnalyzer()

        let node = try Parser.parse(text) as! RecipeNode

        return analyzer.analyze(node: node)
    }

}

public struct Step {
    public var ingredientsTable: IngredientTable = IngredientTable()
    public var directions: [DirectionItem] = []
    public var timers: [Timer] = []
    public var equipments: [Equipment] = []

    mutating func addIngredient(_ ingredient: IngredientNode) {
        let name = ingredient.name
        var quantity: ValueProtocol

        switch ingredient.amount.quantity {
        case let .integer(value):
            quantity = value
        case let .decimal(value):
            quantity = value
        case let .string(value):
            quantity = value
        }

        let amount = IngredientAmount(quantity, ingredient.amount.units)
        let ingredient = Ingredient(name, amount)

        ingredientsTable.add(name: name, amount: amount)
        directions.append(ingredient)
    }

    mutating func addTimer(_ timer: TimerNode) {
        var quantity: ValueProtocol

        switch timer.quantity {
        case let .integer(value):
            quantity = value
        case let .decimal(value):
            quantity = value
        case let .string(value):
            quantity = value
        }

        let timer = Timer(quantity, timer.units)

        timers.append(timer)
        directions.append(timer)
    }

    mutating func addText(_ direction: DirectionNode) {
        let text = TextItem(direction.value.description)

        directions.append(text)
    }

    mutating func addEquipment(_ equipment: EquipmentNode) {
        let equipment = Equipment(equipment.name)

        equipments.append(equipment)
        directions.append(equipment)
    }
}

public struct TextItem: DirectionItem {
    public var value: String

    init(_ value: String) {
        self.value = value
    }
}


public struct Ingredient: DirectionItem {
    public var name: String
    public var amount: IngredientAmount

    init(_ name: String, _ amount: IngredientAmount) {
        self.name = name
        self.amount = amount
    }
}

public struct Equipment: DirectionItem {
    public var name: String

    init(_ name: String) {
        self.name = name
    }
}

public struct Timer: DirectionItem {
    public var quantity: ValueProtocol
    public var units: String

    init(_ quantity: ValueProtocol, _ units: String) {
        self.quantity = quantity
        self.units = units
    }

    init(_ quantity: Int, _ units: String) {
        self.quantity = quantity
        self.units = units
    }

    init(_ quantity: String, _ units: String) {
        self.quantity = quantity
        self.units = units
    }

    init(_ quantity: Decimal, _ units: String) {
        self.quantity = quantity
        self.units = units
    }
}

public protocol DirectionItem {
    var description: String { get }
}
