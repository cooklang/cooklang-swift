//
//  File.swift
//  
//
//  Created by Alexey Dubovskoy on 07/03/2022.
//

import Foundation

public func mergeIngredientTables(_ left: IngredientTable, _ right: IngredientTable) -> IngredientTable {
    var result = IngredientTable()

    for (name, amounts) in left.ingredients {
        result.add(name: name, amounts: amounts)
    }

    for (name, amounts) in right.ingredients {
        result.add(name: name, amounts: amounts)
    }

    return result
}
