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
        switch quantity {
        case let value as Decimal:
            // when summing up quantities converted to Decimal in IngredientsTable
            // here we want to check if value can be converted back to integer before representation
            if let v = Int("\(value)") {
                if units == "" {
                    return "\(value)"
                } else {
                    return "\(value) \(units.pluralize(v))"
                }
            } else {
                if units == "" {
                    return "\(value.cleanValue)"
                } else {
                    return "\(value.cleanValue) \(units.pluralize(2))"
                }
            }
        case is String:
            if units == "" {
                return "\(quantity)"
            } else {
                return "\(quantity) \(units.pluralize(2))"
            }

        case let value as Int:
            if units == "" {
                return "\(value)"
            } else {
                return "\(value) \(units.pluralize(value))"
            }

        default:
            return ""
        }
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
