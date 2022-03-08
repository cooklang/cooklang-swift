//
//  IngredientModelTests.swift
//  CookInSwiftTests
//
//  Created by Alexey Dubovskoy on 16/02/2021.
//  Copyright © 2021 Alexey Dubovskoy. All rights reserved.
//


import Foundation
@testable import CookInSwift
import XCTest

class IngredientModelTests: XCTestCase {

    func testIngredientTableAddition() {
        var table1 = IngredientTable()

        table1.add(name: "chilli", amount: IngredientAmount(3, "items"))
        table1.add(name: "chilli", amount: IngredientAmount(1, "medium"))

        var table2 = IngredientTable()

        table2.add(name: "chilli", amount: IngredientAmount(5, "items"))
        table1.add(name: "chilli", amount: IngredientAmount(3, "small"))

        XCTAssertEqual(mergeIngredientTables(table1, table2).description, "chilli: 8 items, 1 medium, 3 small")
    }

    func testSameUnitsAndType() {
        var collection = IngredientAmountCollection()
        
        collection.add(IngredientAmount(1, "g"))
        collection.add(IngredientAmount(3, "g"))
            
        
        XCTAssertEqual(collection.description, "4 g")
    }
    
    func testDifferentUnits() {
        var collection = IngredientAmountCollection()
        
        collection.add(IngredientAmount(50, "g"))
        collection.add(IngredientAmount(50, "g"))
        collection.add(IngredientAmount(1, "kg"))
            
        
        XCTAssertEqual(collection.description, "100 g, 1 kg")
    }
    
    func testDifferenQuantityTypes() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(500, "g"))
        collection.add(IngredientAmount(1.5, "kg"))
        collection.add(IngredientAmount(Decimal(1), "kg"))
            
        
        XCTAssertEqual(collection.description, "500 g, 2.5 kg")
    }
    
    func testFractionsQuantityTypes() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(0.5, "cup"))
        collection.add(IngredientAmount(1, "cup"))
            
        
        XCTAssertEqual(collection.description, "1.5 cups")
    }

    func testFractionsQuantityDecimalTypes() {
        var collection = IngredientAmountCollection()

        collection.add(IngredientAmount(Decimal(1) / Decimal(3), "cup"))
        collection.add(IngredientAmount(1, "cup"))


        XCTAssertEqual(collection.description, "1.3 cups")
    }
    
    func testWithPluralUnits() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(1, "cup"))
        collection.add(IngredientAmount(2, "cups"))
            
        
        XCTAssertEqual(collection.description, "3 cups")
    }
    
    func testWithPluralAndSingularIngredient() {
        var collection = IngredientAmountCollection()

        collection.add(IngredientAmount(1, "onion"))
        collection.add(IngredientAmount(2, "onions"))

        XCTAssertEqual(collection.description, "3 onions")
    }
    
    func testWithTextQuantity() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount("few", "springs"))
        
        XCTAssertEqual(collection.description, "few springs")
    }

    
//    test valid ingridient: when only units, but no name of in

    
}
