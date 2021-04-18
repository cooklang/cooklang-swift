//
//  SymbolTableTests.swift
//  SwiftCookInSwiftTests
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation
@testable import CookInSwift
import XCTest

class SemanticAnalyzerTests: XCTestCase {
    func testSemanticAnalyzer() {
        // TODO properly support "30 mins" as cooking time metadata
        let program =
            """
            >> cooking time: hour
            Add @chilli{3}, @ginger{10%g} and @milk{1%litre} place in #oven and cook for ~{10%minutes}
            """

        let parser = Parser(program)
        let node = parser.parse()

        let analyzer = SemanticAnalyzer()
        let parsedRecipe = analyzer.analyze(node: node)

        let recipe = SemanticRecipe()
        recipe.metadata["cooking time"] = "hour"

        let step = SemanticStep()
        step.directions = [
            TextItem("Add "),
            ParsedIngredient("chilli", IngredientAmount(3, "items")),
            TextItem(", "),
            ParsedIngredient("ginger", IngredientAmount(10, "g")),
            TextItem(" and "),
            ParsedIngredient("milk", IngredientAmount(1, "litre")),
            TextItem(" place in "),
            ParsedEquipment("oven"),
            TextItem(" and cook for "),
            ParsedTimer(10, "minutes")
        ]
        recipe.steps = [step]

        XCTAssertEqual(parsedRecipe, recipe)

        let text = parsedRecipe.steps.map{ step in
            step.directions.map { $0.description }.joined()
        }
        XCTAssertEqual(text, ["Add chilli, ginger and milk place in oven and cook for 10 minutes"])
    }


    func testShoppingListCombination() {
        let recipe1 =
            """
            Add @chilli{3}, @ginger{10%g} and @milk{1%litre} place in #oven and cook for ~{10%minutes}
            """

        let recipe2 =
            """
            Simmer @milk{250%ml} with @honey{2%tbsp} for ~{20%minutes}
            """

        let analyzer = SemanticAnalyzer()
        let parsedRecipe1 = analyzer.analyze(node: Parser(recipe1).parse())
        let parsedRecipe2 = analyzer.analyze(node: Parser(recipe2).parse())

        var table = IngredientTable()

        table = table + parsedRecipe1.ingredientsTable + parsedRecipe2.ingredientsTable

        XCTAssertEqual(table.description, "chilli: 6 items; ginger: 20 g; honey: 4 tbsp; milk: 2 litres, 500 ml")
    }
    
//    test valid ingridient: when only units, but no name of in

    
}
