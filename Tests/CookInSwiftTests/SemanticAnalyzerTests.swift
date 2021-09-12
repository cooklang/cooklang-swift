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



        measure {
            let analyzer = SemanticAnalyzer()

            let parser = Parser(recipe)
            let parsed = parser.parse()
            let parsedRecipe = analyzer.analyze(node: parsed)

            XCTAssertEqual(parsedRecipe.ingredientsTable.description, "avocados: 2; black pepper: 2; butter: 30 g; cannellini beans: 2 tins; cheddar cheese: 75 g; cherry tomatoes: 10; coriander: 1 bunch; eggs: 8 large; fresh red chilli: 2; garlic clove: 2; ground cumin: 1 pinch; lime: 2; olive oil: 1 tbsp; red chilli: 1 item; red onion: 1; salt: 1; sea salt: 1; smoked paprika: 1 pinch; sour cream: 200 ml; tinned tomatoes: 2 tins; tortillas: 6 large")
        }

    }

    func testLagman() {
        let recipe =
            """
            >> Prep Time: 15 minutes
            >> Cook Time: 30 minutes
            >> Total Time: 45 minutes
            >> Servings: 6 servings

            Cook the @linguine pasta{230%g} according to the instructions. Drain and rinse with cold water. Keep covered until ready to use so it does not dry out.

            Cube the @lamb{450%g} into small cubes. In a dutch oven, heat @oil. Once hot add meat, cook about ~{5%minutes}.

            Meanwhile, finely chop the @onion{1%medium}. Finely dice @tomatoes{2%large}. Cube @carrots{1%large} and @red peppers{1/2%large} into even sizes. Cube @potatoes{420%g} into small cubes.

            Add onions to the meat in the Dutch oven. Turn heat down to medium heat, cook until onions are tender.

            Add tomatoes and @garlic{1%glove}, cook ~{2%minutes}, stirring as needed.

            Add potatoes, carrots, peppers and mix well.

            Pour in @water{1.4%kg}, @black pepper{1%tsp}, @ground coriander{1%tsp}, @ground cumin{1%tsp} and @bay leaves{2}, @star anise{1%small} and cook about ~{20%minutes}, until all of the vegetables are tender. Remove star anise once the soup is cooked.

            Meanwhile, cook pasta. Drain and return to pot, cover to prevent from drying out.

            Serve hearty soup over pasta.

            """


        let analyzer = SemanticAnalyzer()

        let parser = Parser(recipe)
        let parsed = parser.parse()
        let parsedRecipe = analyzer.analyze(node: parsed)

        XCTAssertEqual(parsedRecipe.ingredientsTable.description, "bay leaves: 2; black pepper: 1 tsp; carrots: 1 large; garlic: 1 glove; ground coriander: 1 tsp; ground cumin: 1 tsp; lamb: 450 g; linguine pasta: 230 g; oil: 1; onion: 1 medium; potatoes: 420 g; red peppers: 0.5 large; star anise: 1 small; tomatoes: 2 large; water: 1.4 kg")

    }

    func testManti() {
        let recipe =
            """
            Attach the dough hook to the Kitchen Aid mixer. Mix the @milk{160%g}, @salt{1%tsp}, @egg{1%large} and @water{180%g}.

            Add the @flour{530%g}, continue mixing until the dough is smooth and flour is well incorporated. (Dough should not stick to your hands.)

            Keep the dough covered until ready to use.

            Place @butter{110%g} into freezer. Cube @chicken thighs{450%g} into small pieces. Chop @onion{1%small} really fine. Peel @potatoes{450%g} and cube into small pieces, place in bowl and cover with cold water, set aside.

            Divide dough into two. Return the one half to the bowl and cover. Lightly flour the working surface. Roll out the dough into about 20" to 22" circle, adding flour as needed, it needs to be really thin. Fold the circle as if it's and accordion going back and forth. With a sharp knife cut about every 2 1/2 inches. Take the strips and stack them. When stacking, the strips will all be different lengths, stack them all starting at one end, not in the middle. Cut again about every 2 2/12 inches.

            Lay out the squares. Some pieces may not be complete squares, edges, just take two pieces and stick them together.

            Finish the filling. Take out the butter from the freezer and either grate or cube. Drain potatoes add to the bowl, add @ground coriander{1/2%tsp}, @ground cumin{1/4%tsp}, @black pepper{1/4%tsp}, minced @garlic{2%cloves} add chopped @parsley{1%bunch}. Mix everything.

            Take spoonfuls of the filling and add to the center of the squares.

            Take a square, place one corner over the other and pinch together. Take the other corner and repeat. Pinch together the four openings. Now take the two edges and pinch them together as well, placing over edge over the other.

            Add water to a tiered steamer. Lay out Manti on tiers. Cover steamer and cook 20-25 minutes. All steamers are different, check a Manti to see if it's ready. If using different meat, it'll need about 40 - 60 minutes.

            Enjoy with butter and sour cream.
            """


        let analyzer = SemanticAnalyzer()

        let parser = Parser(recipe)
        let parsed = parser.parse()
        let parsedRecipe = analyzer.analyze(node: parsed)

        XCTAssertEqual(parsedRecipe.ingredientsTable.description, "black pepper: 0.25 tsp; butter: 110 g; chicken thighs: 450 g; egg: 1 large; flour: 530 g; garlic: 2 cloves; ground coriander: 0.5 tsp; ground cumin: 0.25 tsp; milk: 160 g; onion: 1 small; parsley: 1 bunch; potatoes: 450 g; salt: 1 tsp; water: 180 g")

    }

    func testBrokenManti() {
        let recipe =
            """
            > sdfsf: fff
            >> fsdfd:::
            >>:fdsfd
            >>sfsdfd:
            > > fsdf
            Attach the dough @ hook > to the Kitchen Aid mixer. Mix the @milk{160g}, @ salt{1%tsp}, @egg{%large} and @water{180%}.

            Add the @flour{530%g, continue mixing until the dough is smooth and flour is well incorporated. (Dough should not stick to your hands.)

            Keep the dough //covered until ready to use.

            Place @butter{%} into freezer. Cube @chicken > thighs{450%g} into small pieces. Chop @onion{1 really fine. Peel @potatoes{450%g} and cube into small pieces, place in bowl and cover with cold water, set aside.

            Divide dough into two. Return # the one half | to the bowl : and cover >. Lightly flour the working surface. Roll out the dough into about 20" to 22" circle, adding flour as needed, it needs to be really thin. Fold the circle as if it's and accordion going back and forth. With a sharp knife cut about every 2 1/2 inches. Take the strips and stack them. When stacking, the strips will all be different lengths, stack them all starting at one end, not in the middle. Cut again about every 2 2/12 #inches{.

            Lay out the squares. Some pieces may not be complete squares, edges, }just take{ two pieces and stick them together.

            Finish the filling. Take out the butter from the freezer and either % grate or cube. Drain potatoes add to the bowl, add @ground coriander{1/2%tsp}, @ground cumin{1/4%tsp}, @black pepper{1/4%tsp}, minced @garlic{2%cloves} add chopped @parsley{1%bunch}. Mix everything.

            >> Take spoonfuls of the filling and add to the ~center of the squares.

            Hehe, ~ and # and @ here.

            @

            ~

            #

            Take a square, place one corner over the other ~and{%} pinch together. Take the other corner and repeat. Pinch together the four openings. Now take the two edges and pinch them together as well, placing over edge over the other.

            Add water to a tiered steamer. Lay out Manti on tiers. Cover steamer and cook ~{20-25%minutes}. All steamers are different, check a Manti to see if it's ready. If using different meat, it'll need about 40 - 60 minutes.

            Enjoy with butter and sour cream.
            """


        let analyzer = SemanticAnalyzer()

        let parser = Parser(recipe)
        let parsed = parser.parse()
        let parsedRecipe = analyzer.analyze(node: parsed)

        let text = parsedRecipe.steps.map{ step in
            step.directions.map { $0.description }.joined()
        }

        XCTAssertEqual(parsedRecipe.metadata, ["sfsdfd": "",
                                               "Invalid key syntax": "Invalid value syntax",
                                               "": "fdsfd",
                                               "fsdfd": "::"])

        XCTAssertEqual(text, ["> sdfsf: fff",
                              "> > fsdf",
                              "Attach the dough @ hook > to the Kitchen Aid mixer. Mix the milk, @ salt{1%tsp}, egg and water.",
                              "Add the flour",
                              "Keep the dough ",
                              "Place butter into freezer. Cube chicken > thighs into small pieces. Chop onion and cube into small pieces, place in bowl and cover with cold water, set aside.",
                              "Divide dough into two. Return # the one half | to the bowl : and cover >. Lightly flour the working surface. Roll out the dough into about 20\" to 22\" circle, adding flour as needed, it needs to be really thin. Fold the circle as if it\'s and accordion going back and forth. With a sharp knife cut about every 2 1/2 inches. Take the strips and stack them. When stacking, the strips will all be different lengths, stack them all starting at one end, not in the middle. Cut again about every 2 2/12 inches.",
                              "Lay out the squares. Some pieces may not be complete squares, edges, }just take{ two pieces and stick them together.",
                              "Finish the filling. Take out the butter from the freezer and either % grate or cube. Drain potatoes add to the bowl, add ground coriander, ground cumin, black pepper, minced garlic add chopped parsley. Mix everything.",
                              "Hehe, ~ and # and @ here.",
                              "@",
                              "~",
                              "#",
                              "Take a square, place one corner over the other 1  pinch together. Take the other corner and repeat. Pinch together the four openings. Now take the two edges and pinch them together as well, placing over edge over the other.",
                              "Add water to a tiered steamer. Lay out Manti on tiers. Cover steamer and cook 20-25 minutes. All steamers are different, check a Manti to see if it\'s ready. If using different meat, it\'ll need about 40 - 60 minutes.",
                              "Enjoy with butter and sour cream."]

        )

    }


    
}
