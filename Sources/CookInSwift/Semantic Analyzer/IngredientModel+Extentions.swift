//
//  IngredientModel+Extentions.swift
//
//
//  Created by Alexey Dubovskoy on 18/04/2021.
//

import Foundation



extension IngredientTable: CustomStringConvertible {
    public var description: String {
        if ingredients.count == 0 {
            return "–"
        } else {
            return ingredients.sorted{ $0.key < $1.key }.map{ "\($0): \($1)" }.joined(separator: "; ")
        }

    }
}

extension IngredientAmount: CustomStringConvertible {
    public var description: String {
        return displayAmount(quantity: quantity, units: units)
    }
}



extension IngredientAmountCollection: CustomStringConvertible {
    public var description: String {
        return enumerated().sorted{ $0.1.units < $1.1.units }.map{ "\($1)" }.joined(separator: ", ")
    }
}

extension IngredientAmountCollection {
    public struct Iterator {

        private var _i1: Array<IngredientAmount>.Iterator , _i2: Array<IngredientAmount>.Iterator

        fileprivate init(_ amountsCountable: [String: Decimal], _ amountsUncountable: [String: String]) {
            _i1 = amountsCountable.map{ IngredientAmount($1, $0) }.makeIterator()
            _i2 = amountsUncountable.map{ IngredientAmount(String($1), $0) }.makeIterator()
        }
    }
}

extension IngredientAmountCollection.Iterator: IteratorProtocol {
    public typealias Element = Array<IngredientAmount>.Element

    public mutating func next() -> Element? {
        return _i1.next() ?? _i2.next()
    }
}

extension IngredientAmountCollection: Sequence {
    public func makeIterator() -> Iterator {
        return Iterator(amountsCountable, amountsUncountable)
    }
}
