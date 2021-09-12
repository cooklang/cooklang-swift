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
        let table1 = IngredientTable()

        table1.add(name: "chilli", amount: IngredientAmount(ConstantNode.integer(3), "items"))
        table1.add(name: "chilli", amount: IngredientAmount(ConstantNode.integer(1), "medium"))

        let table2 = IngredientTable()

        table2.add(name: "chilli", amount: IngredientAmount(ConstantNode.integer(5), "items"))
        table1.add(name: "chilli", amount: IngredientAmount(ConstantNode.integer(3), "small"))

        XCTAssertEqual((table1 + table2).description, "chilli: 8 items, 1 medium, 3 small")
    }

    func testSameUnitsAndType() {
        let collection = IngredientAmountCollection()
        
        collection.add(IngredientAmount(ConstantNode.integer(1), "g"))
        collection.add(IngredientAmount(ConstantNode.integer(3), "g"))
            
        
        XCTAssertEqual(collection.description, "4 g")
    }
    
    func testDifferentUnits() {
        let collection = IngredientAmountCollection()
        
        collection.add(IngredientAmount(ConstantNode.integer(50), "g"))
        collection.add(IngredientAmount(ConstantNode.integer(50), "g"))
        collection.add(IngredientAmount(ConstantNode.integer(1), "kg"))
            
        
        XCTAssertEqual(collection.description, "100 g, 1 kg")
    }
    
    func testDifferenQuantityTypes() {
        let collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.integer(500), "g"))
        collection.add(IngredientAmount(ConstantNode.decimal(1.5), "kg"))
        collection.add(IngredientAmount(ConstantNode.decimal(1), "kg"))
            
        
        XCTAssertEqual(collection.description, "500 g, 2.5 kg")
    }
    
    func testFractionsQuantityTypes() {
        let collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.fractional((1, 2)), "cup"))
        collection.add(IngredientAmount(ConstantNode.integer(1), "cup"))
            
        
        XCTAssertEqual(collection.description, "1.5 cups")
    }

    func testFractionsQuantityDecimalTypes() {
        let collection = IngredientAmountCollection()

        collection.add(IngredientAmount(ConstantNode.fractional((1, 3)), "cup"))
        collection.add(IngredientAmount(ConstantNode.integer(1), "cup"))


        XCTAssertEqual(collection.description, "1.3 cups")
    }
    
    func testWithPluralUnits() {
        let collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.integer(1), "cup"))
        collection.add(IngredientAmount(ConstantNode.integer(2), "cups"))
            
        
        XCTAssertEqual(collection.description, "3 cups")
    }
    
    func testWithPluralAndSingularIngredient() {
        let collection = IngredientAmountCollection()

        collection.add(IngredientAmount(ConstantNode.integer(1), "onion"))
        collection.add(IngredientAmount(ConstantNode.integer(2), "onions"))

        XCTAssertEqual(collection.description, "3 onions")
    }
    
    func testWithTextQuantity() {
        let collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.string("few"), "springs"))
        
        XCTAssertEqual(collection.description, "few springs")
    }

    
//    test valid ingridient: when only units, but no name of in

    
}
