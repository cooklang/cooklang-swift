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
        let program =
            """
            >> cooking time: 30 min
            Add @chilli{3}, @ginger{10%g} and @milk{1%litre} place in #oven and cook for ~{10%minutes}
            """

        let parser = Parser(program)
        let node = parser.parse()

        let analyzer = SemanticAnalyzer()
        let parsedRecipe = analyzer.analyze(node: node)

        let recipe = SemanticRecipe()
        recipe.metadata["cooking time"] = "30 min"

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

        XCTAssertEqual(table.description, "chilli: 6; ginger: 20 g; honey: 4 tbsp; milk: 2 litres, 500 ml")
    }
    
//    test valid ingridient: when only units, but no name of in

    func testBurrito() {

        let recipe =
            """
            Preheat your oven to the lowest setting. Drain the @cannellini beans{2%tins} in a sieve. Place a saucepan on a medium heat.

            Peel and dinely slice the @garlic clove{2}. add the @olive oil{1%tbsp} and sliced garlic to the hot pan.

            Crubmle the @red chilli{1%item} into the pan, then stir and fry until the grlic turns golden.

            Add the @tinned tomatoes{2%tins} and drained cannellini beans to the pan, reduce to a low heat and simmer gently for around 20 minutes, or until reduced and nice and thick. Meanwhile...

            Peel, halve and finely chop the @red onion{}. Roughly chop the @cherry tomatoes{10}. Finely chop the @coriander{1%bunch} stalks and roughly chop the leaves.

            Coarsely grate the @cheddar cheese{75%g}. Cut @lime{} in half and the other @lime{} into six wedges.

            Cut the @avocados{2} in half lengthways, use a spppon to sccoop out and dicard the stone, then scoop the fles into a bowl to make your guacamole.

            Roughly mash the avocado with the back of a fork, then add the onion, cherry tomatoes, coriander stalks and @ground cumin{1%pinch}. Season with @sea salt{} and @black pepper{} and squeeze in the juice from one of the lime halves.

            Mix well then have a taste of your guacoamole and tweak with more salt, pepper and lime jouice until you've got a good balance of flovours and its tasing delicious. Set aside.

            Loosely wrap the @tortillas{6%large} in tin foil then pop in the hot oven to warm through, along with two plates. Finely chop the @fresh red chilli{2} and put it aside for later.

            Make your table look respectable - get the cutlery, salt and pepper and drinks laid out nicely.

            By now your beans should be done, so have a taste and season with salt and pepper. Turn the heat off and pop a lid on th pan sothey stay nice and warm.

            Put a small non-stick saucepan on a low heat. Add the @butter{30%g} and leave to melt. Meanwhile...

            Crack the @eggs{8%large} into a bowl, add a pinch of @salt{} and @black pepper{} and beat with a fork. When the buter has melted, add the eggs to the pan. Stir the eggs slowly with a spatula, getting right into the sides of the pan. Cook gently for 5 to 10 minutes until they just start to scramble then turn the heat off - they'll continute to cook on their own.

            Get two plates and pop a warm tortilla on each one. Divide the scrambled eggs between them then top with a good spoonful of you home-made beans.

            Scatter each portion with grated cheese and as much chilli as youdare, then roll each tortilla up.

            Spoon guacamole and @sour cream{200%ml} on top of each one, scatter with coriander leaves and dust with a little @smoked paprika{1%pinch}. Serve each portion with wedge of lime for squeezing over, and tuck in.

            """

        let analyzer = SemanticAnalyzer()
        var parser: Parser?
        var parsed: AST?
        var parsedRecipe: SemanticRecipe?

        parser = Parser(recipe)
        parsed = parser!.parse()
        parsedRecipe = analyzer.analyze(node: parsed!)

        XCTAssertEqual(parsedRecipe!.ingredientsTable.description, "avocados: 2; black pepper: 2; butter: 30 g; cannellini beans: 2 tins; cheddar cheese: 75 g; cherry tomatoes: 10; coriander: 1 bunch; eggs: 8 larges; fresh red chilli: 2; garlic clove: 2; ground cumin: 1 pinch; lime: 2; olive oil: 1 tbsp; red chilli: 1 item; red onion: 1; salt: 1; sea salt: 1; smoked paprika: 1 pinch; sour cream: 200 ml; tinned tomatoes: 2 tins; tortillas: 6 larges")

    }

    
}
