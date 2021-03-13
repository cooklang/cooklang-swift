//
//  SemanticModelTests.swift
//  CookInterpreterTests
//
//  Created by Alexey Dubovskoy on 16/02/2021.
//  Copyright © 2021 Igor Kulman. All rights reserved.
//


import Foundation
@testable import CookInterpreter
import XCTest

class SemanticModelTests: XCTestCase {
    func testSameUnitsAndType() {
        var collection = IngredientAmountCollection()
        
        collection.add(IngredientAmount(ConstantNode.integer(1), "g"))
        collection.add(IngredientAmount(ConstantNode.integer(3), "g"))
            
        
        XCTAssertEqual(collection.description, "4 g")
    }
    
    func testDifferentUnits() {
        var collection = IngredientAmountCollection()
        
        collection.add(IngredientAmount(ConstantNode.integer(50), "g"))
        collection.add(IngredientAmount(ConstantNode.integer(50), "g"))
        collection.add(IngredientAmount(ConstantNode.integer(1), "kg"))
            
        
        XCTAssertEqual(collection.description, "100 g, 1 kg")
    }
    
    func testDifferenQuantityTypes() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.integer(500), "g"))
        collection.add(IngredientAmount(ConstantNode.decimal(1.5), "kg"))
        collection.add(IngredientAmount(ConstantNode.decimal(1), "kg"))
            
        
        XCTAssertEqual(collection.description, "500 g, 2.5 kg")
    }
    
    func testFractionsQuantityTypes() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.fractional((1, 2)), "cup"))
        collection.add(IngredientAmount(ConstantNode.integer(1), "cup"))
            
        
        XCTAssertEqual(collection.description, "1.5 cups")
    }
    
    func testWithPluralUnits() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.integer(1), "cup"))
        collection.add(IngredientAmount(ConstantNode.integer(2), "cups"))
            
        
        XCTAssertEqual(collection.description, "3 cups")
    }
    
//    func testWithPluralAndSingularIngredient() {
//        var collection = IngredientAmountCollection()
//
//        collection.add(IngredientAmount(ConstantNode.integer(1), "onion"))
//        collection.add(IngredientAmount(ConstantNode.integer(2), "onions"))
//
//        XCTAssertEqual(collection.description, "3 onions")
//    }
    
    func testWithTextQuantity() {
        var collection = IngredientAmountCollection()
                
        collection.add(IngredientAmount(ConstantNode.string("few"), "springs"))
        
        XCTAssertEqual(collection.description, "few springs")
    }
        
    
//    test valid ingridient: when only units, but no name of in

    
}
