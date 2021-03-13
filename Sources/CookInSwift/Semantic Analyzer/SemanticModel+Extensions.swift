//
//  Symbol+Extensions.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation


extension SemanticStep: CustomStringConvertible {
    public var description: String {
        return """
        Directions:
        > \(directions.description)
        Ingredients:
        > \(ingredientsTable.description)
        """
    }
}

extension IngredientTable: CustomStringConvertible {
    public var description: String {
        if ingredients.count == 0 {
            return "–"
        } else {
            return ingredients.description
        }
        
    }
}

public extension IngredientTable {
    static func + (left: IngredientTable, right: IngredientTable) -> IngredientTable {
        let result = IngredientTable()
        
        for (name, amounts) in left.ingredients {
            result.add(name: name, amounts: amounts)
        }
        
        for (name, amounts) in right.ingredients {
            result.add(name: name, amounts: amounts)
        }
        
        return result
    }
}

extension IngredientAmount: CustomStringConvertible {
    public var description: String {
        if let v = Int(quantity.value) {
            return "\(quantity.value) \(units.pluralize(v))"
        } else {
            return "\(quantity.value) \(units.pluralize(2))"
        }
    }
}

extension ParsedTimer: CustomStringConvertible {
    public var description: String {
        if let v = Int(quantity.value) {
            return "\(quantity.value) \(units.pluralize(v))"
        } else {
            return "\(quantity.value) \(units.pluralize(2))"
        }
    }
}

extension ParsedEquipment: CustomStringConvertible {
    public var description: String {
        return name
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
    
        fileprivate init(_ amountsCountable: [String: Float], _ amountsUncountable: [String: String]) {
            _i1 = amountsCountable.map{ IngredientAmount(ConstantNode.decimal($1), $0) }.makeIterator()
            _i2 = amountsUncountable.map{ IngredientAmount(ConstantNode.string($1), $0) }.makeIterator()
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
