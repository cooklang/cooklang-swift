//
//  IngredientModel.swift
//
//
//  Created by Alexey Dubovskoy on 17/04/2021.
//

import Foundation
import i18n

public protocol ValueProtocol {}

extension String:ValueProtocol {}
extension Int:ValueProtocol {}
extension Decimal:ValueProtocol {}

public struct IngredientAmount {
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

    init(_ quantity: Decimal, _ units: String) {
        self.quantity = quantity
        self.units = units
    }

    init(_ quantity: String, _ units: String) {
        self.quantity = quantity
        self.units = units
    }
}


public struct IngredientAmountCollection {
    var amountsCountable: [String: Decimal] = [:]
    var amountsUncountable: [String: String] = [:]

    mutating func add(_ amount: IngredientAmount) {
        // TODO locale
        let units = RuntimeSupport.lemmatizer.lemma(amount.units)

        switch amount.quantity.self {
        case let value as Int:
            amountsCountable[units] = amountsCountable[units, default: 0] + Decimal(value)
        case let value as Decimal:
            amountsCountable[units] = amountsCountable[units, default: 0] + value
        case let value as String:
            amountsUncountable[amount.units] = value
        default:
            fatalError("Unrecognised value type")
        }
    }
}

public struct IngredientTable {
    public var ingredients: [String: IngredientAmountCollection] = [:]

    public init() {
    }

    mutating public func add(name: String, amount: IngredientAmount) {
        if ingredients[name] == nil {
            ingredients[name] = IngredientAmountCollection()
        }

        ingredients[name]?.add(amount)
    }

    mutating public func add(name: String, amounts: IngredientAmountCollection) {
        amounts.forEach {
            add(name: name, amount: $0)
        }
    }
}
