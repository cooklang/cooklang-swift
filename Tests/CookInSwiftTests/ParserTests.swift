//
//  ParserTests.swift
//  SwiftCookInSwiftTests
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation
@testable import CookInSwift
import XCTest
import Yams

enum QuantityType: Decodable {
  case int(Int)
  case string(String)

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    do {
      self = try .int(container.decode(Int.self))
    } catch DecodingError.typeMismatch {
      do {
        self = try .string(container.decode(String.self))
      } catch DecodingError.typeMismatch {
        throw DecodingError.typeMismatch(QuantityType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
      }
    }
  }
}

struct CookTestDirectionItem: Decodable {
    var type: String
    var name: String?
    var quantity: QuantityType?
    var units: String?
    var value: String?

    init(type: String, name: String? = nil, quantity: QuantityType? = nil, units: String? = nil, value: String? = nil) {
        self.type = type
        self.name = name
        self.quantity = quantity
        self.units = units
        self.value = value
    }
}

struct CookTestStepDefinition {
    var directions: [CookTestDirectionItem]
}

struct CookTestResultDefinition {
    var steps: [CookTestStepDefinition]
}

extension CookTestResultDefinition: Decodable {
    enum CodingKeys: String, CodingKey {
        case steps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var stepsContainer = try container.nestedUnkeyedContainer(forKey: .steps)

        steps = []

        while !stepsContainer.isAtEnd {
            var stepContainer = try stepsContainer.nestedUnkeyedContainer()
            var directions: [CookTestDirectionItem] = []
            while !stepContainer.isAtEnd {
                let direction = try stepContainer.decode(CookTestDirectionItem.self)
                directions.append(direction)
            }
            steps.append(CookTestStepDefinition(directions: directions))
        }
    }
}

struct CookTestDefinition: Decodable {
    var name: String?
    var source: String
    var result: CookTestResultDefinition
}

struct CookTestSuiteDefinition {
    var tests: [CookTestDefinition]
}

extension CookTestSuiteDefinition: Decodable {

    struct DirectoryKeys: CodingKey {
        var intValue: Int?

        init?(intValue: Int) {
            return nil
        }

        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DirectoryKeys.self)

        tests = []

        try container.allKeys.forEach { key in
            var testCase = try container.decode(CookTestDefinition.self, forKey: key)
            testCase.name = key.stringValue
            tests.append(testCase)
        }
    }
}


class ParserTests: XCTestCase {

    var recipe: String!
    var node: RecipeNode!

    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: self)
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let resourceURL = thisDirectory.appendingPathComponent("ParserTestCases.yaml")
        let yaml = try! String(contentsOfFile: resourceURL.path, encoding: String.Encoding.utf8)
        let definitions = try! YAMLDecoder().decode(CookTestSuiteDefinition.self, from: yaml)

        definitions.tests.forEach { test in
            // Generate a test for our specific selector
            let t = ParserTests(selector: #selector(yamlTests))
//            test.name = "testBasicDirection"
            t.recipe = test.source
            var steps: [StepNode] = []
            test.result.steps.forEach { step in
                var directions: [AST] = []
                step.directions.forEach { direction in
                    switch direction.type {
                    case "text":
                        directions.append(DirectionNode(direction.value!))
                    case "ingredient":
                        directions.append(IngredientNode(name: direction.name!, amount: AmountNode(quantity: direction.quantity!, units: direction.units!)))
                    case "cookware":
                        directions.append(EquipmentNode(name: direction.name!, amount: AmountNode(quantity: direction.quantity!, units: direction.units!)))
                    case "timer":
                        directions.append(TimerNode(name: direction.name!, amount: AmountNode(quantity: direction.quantity!, units: direction.units!)))
                    default:
                        print("Unknown type \(direction.type)")
                    }
                }

                steps.append(StepNode(instructions: directions))
            }
//            TODO support metadata
            t.node = RecipeNode(steps: steps)

            // Add it to the suite, and the defaults handle the rest
            suite.addTest(t)
        }
        return suite
    }

    @objc func yamlTests() {
        let result = try! Parser.parse(recipe) as! RecipeNode

        XCTAssertEqual(result, node)
    }
 
    func testBasicDirection() {
        let recipe =
            """
            Add a bit of chilli
            """
                
        let result = try! Parser.parse(recipe) as! RecipeNode
        
        let direction = DirectionNode("Add a bit of chilli")
        let steps = [StepNode(instructions: [direction])]
        let node = RecipeNode(steps: steps)
                
        XCTAssertEqual(result, node)
    }
    
    func testMultiLineDirections() {
        let recipe =
            """
            Add a bit of chilli

            Add a bit of hummus
            """
        
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [DirectionNode("Add a bit of chilli")]),
            StepNode(instructions: [DirectionNode("Add a bit of hummus")]),
        ]
        let node = RecipeNode(steps: steps)
                
        XCTAssertEqual(result, node)
    }
    
    func testDirectionWithIngrident() {
        let recipe =
            """
            Add @chilli{3%items}, @ginger{10%g} and @milk{1%l}.
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Add "),
                    IngredientNode(name: "chilli", amount: AmountNode(quantity: 3, units: "items")),
                    DirectionNode(", "),
                    IngredientNode(name: "ginger", amount: AmountNode(quantity: 10, units: "g")),
                    DirectionNode(" and "),
                    IngredientNode(name: "milk", amount: AmountNode(quantity: 1, units: "l")),
                    DirectionNode(".")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testIngridentExplicitUnits() {
        let recipe =
            """
            @chilli{3%items}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [IngredientNode(name: "chilli", amount: AmountNode(quantity: ConstantNode.integer(3), units: "items"))])
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testIngridentExplicitUnitsWithSpaces() {
        let recipe =
            """
            @chilli{ 3 % items }
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [IngredientNode(name: "chilli", amount: AmountNode(quantity: ConstantNode.integer(3), units: "items"))])
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testIngridentImplicitQuantity() {
        let recipe =
            """
            @chilli{%items}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [IngredientNode(name: "chilli", amount: AmountNode(quantity: ConstantNode.integer(1), units: "items"))])
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    

    
    func testIngridentImplicitUnits() {
        let recipe =
            """
            @chilli{3}
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "chilli", amount: AmountNode(quantity: ConstantNode.integer(3)))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testIngridentNoUnits() {
        let recipe =
            """
            @chilli
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "chilli", amount: AmountNode(quantity: ConstantNode.integer(1)))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }

    func testIngridentNoUnitsNotOnlyString() {
        let recipe =
            """
            @5peppers
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [IngredientNode(name: "5peppers", amount: AmountNode(quantity: ConstantNode.integer(1)))])
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testIngridentWithNumbers() {
        let recipe =
            """
            @tipo 00 flour{250%g}
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "tipo 00 flour", amount: AmountNode(quantity: ConstantNode.integer(250), units: "g"))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testMultiWordIngrident() {
        let recipe =
            """
            @hot chilli{3}
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "hot chilli", amount: AmountNode(quantity: ConstantNode.integer(3)))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }

    func testQuantityDigitalString() {
        let recipe =
            """
            @water{7 k }
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [IngredientNode(name: "water", amount: AmountNode(quantity: ConstantNode.string("7 k")))])
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testMultiWordIngridentNoAmount() {
        let recipe =
            """
            @hot chilli{}
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "hot chilli", amount: AmountNode(quantity: ConstantNode.integer(1)))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }

    func testIngredientMultipleWordsWithLeadingNumber() {
        let recipe =
            """
            Top with @1000 island dressing{ }
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Top with "),
                    IngredientNode(name: "1000 island dressing", amount: AmountNode(quantity: ConstantNode.integer(1)))]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }

    func testIngredientWithEmoji() {
        let recipe =
            """
            Add some @🧂
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Add some "),
                    IngredientNode(name: "🧂", amount: AmountNode(quantity: ConstantNode.integer(1)))]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testIngridentWithoutStopper() {
        let recipe =
            """
            @chilli cut into pieces
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "chilli", amount: AmountNode(quantity: ConstantNode.integer(1))),
                                    DirectionNode(" cut into pieces"),
            ])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testFractions() {
        let recipe =
            """
            @milk{1/2%cup}
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "milk", amount: AmountNode(quantity: ConstantNode.fractional((1, 2)), units: "cup"))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }

    func testFractionsLike() {
        let recipe =
            """
            @milk{01/2%cup}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [IngredientNode(name: "milk", amount: AmountNode(quantity: ConstantNode.string("01/2"), units: "cup"))])
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testFractionsWithSpaces() {
        let recipe =
            """
            @milk{1 / 2 %cup}
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "milk", amount: AmountNode(quantity: ConstantNode.fractional((1, 2)), units: "cup"))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }

    func testFractionsInDirections() {
        let recipe =
            """
            knife cut about every 1/2 inches
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [DirectionNode("knife cut about every 1/2 inches")])
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    
    func testMutipleIngridentsWithoutStopper() {
        let recipe =
            """
            @chilli cut into pieces and @garlic
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "chilli", amount: AmountNode(quantity: ConstantNode.integer(1))),
                                    DirectionNode(" cut into pieces and "),
                                    IngredientNode(name: "garlic", amount: AmountNode(quantity: ConstantNode.integer(1))),
            ])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testEquipmentOneWord() {
        let recipe =
            """
            Simmer in #pan for some time
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Simmer in "),
                    EquipmentNode(name: "pan"),
                    DirectionNode(" for some time"),]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testEquipmentMultipleWords() {
        let recipe =
            """
            Fry in #frying pan{}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Fry in "),
                    EquipmentNode(name: "frying pan")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }

    func testEquipmentMultipleWordsWithSpaces() {
        let recipe =
            """
            Fry in #frying pan{ }
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Fry in "),
                    EquipmentNode(name: "frying pan")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }

    func testEquipmentMultipleWordsWithLeadingNumber() {
        let recipe =
            """
            Fry in #7-inch nonstick frying pan{ }
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Fry in "),
                    EquipmentNode(name: "7-inch nonstick frying pan")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testTimerInteger() {
        let recipe =
            """
            Fry for ~{10%minutes}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Fry for "),
                    TimerNode(quantity: 10, units: "minutes")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }

    func testTimerWithName() {
        let recipe =
            """
            Fry for ~potato{42%minutes}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Fry for "),
                        TimerNode(quantity: 42, units: "minutes", name: "potato")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testTimerDecimal() {
        let recipe =
            """
            Fry for ~{1.5%minutes}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Fry for "),
                        TimerNode(quantity: 1.5, units: "minutes")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    func testTimerFractional() {
        let recipe =
            """
            Fry for ~{1/2%hour}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps = [
            StepNode(instructions: [
                    DirectionNode("Fry for "),
                        TimerNode(quantity: (1,2), units: "hour")]),
        ]
        let node = RecipeNode(steps: steps)

        XCTAssertEqual(result, node)
    }
    
    
    func testDirectionsWithNumbers() {
        let recipe =
            """
            Heat 5L of water
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [DirectionNode("Heat 5L of water"),
            ])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testDirectionsWithDegrees() {
        let recipe =
            """
            Heat oven up to 200°C
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [DirectionNode("Heat oven up to 200°C"),
            ])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testQuantityAsText() {
        let recipe =
            """
            @thyme{few%springs}
            """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "thyme", amount: AmountNode(quantity: ConstantNode.string("few"), units: "springs"))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testComments() {
        let recipe = "-- testing comments"
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testCommentsWithIngredients() {
        let recipe =
        """
        -- testing comments
        @thyme{2%springs}
        """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "thyme", amount: AmountNode(quantity: ConstantNode.integer(2), units: "springs"))])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    
    func testCommentsAfterIngredients() {
        let recipe =
        """
        @thyme{2%springs} -- testing comments
        """
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [IngredientNode(name: "thyme", amount: AmountNode(quantity: ConstantNode.integer(2), units: "springs")), DirectionNode(" ")])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testSlashInText() {
        let recipe = "Preheat the oven to 200℃/Fan 180°C."
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                
        let steps = [
            StepNode(instructions: [DirectionNode("Preheat the oven to 200℃/Fan 180°C.")])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }
    
    func testMetadata() {
        let recipe = ">> sourced: babooshka"
        
        let result = try! Parser.parse(recipe) as! RecipeNode
                        
        let node = RecipeNode(steps: [], metadata: [MetadataNode("sourced", "babooshka")])
        
        XCTAssertEqual(result, node)
    }
    
    func testMetadataBreak() {
        let recipe = "hello >> sourced: babooshka"
        
        let result = try! Parser.parse(recipe) as! RecipeNode
        
        let steps = [
            StepNode(instructions: [DirectionNode("hello >> sourced: babooshka")])
        ]
        let node = RecipeNode(steps: steps)
        
        XCTAssertEqual(result, node)
    }

    func testMetadataMultiwordKey() {
        let recipe = ">> cooking time: 30 mins"

        let result = try! Parser.parse(recipe) as! RecipeNode

        let node = RecipeNode(steps: [], metadata: [MetadataNode("cooking time", "30 mins")])

        XCTAssertEqual(result, node)
    }

    func testMetadataMultiwordKeyWithSpaces() {
        let recipe = ">>cooking time    :30 mins"

        let result = try! Parser.parse(recipe) as! RecipeNode

        let node = RecipeNode(steps: [], metadata: [MetadataNode("cooking time", "30 mins")])

        XCTAssertEqual(result, node)
    }
    
    func testServings() {
        let recipe = ">> servings: 1|2|3"
        
        let result = try! Parser.parse(recipe) as! RecipeNode
        let node = RecipeNode(steps: [], metadata: [MetadataNode("servings", "1|2|3")])
        
        XCTAssertEqual(result, node)
    }

    func testMultipleLines() {
        let recipe = """
            >> Prep Time: 15 minutes
            >> Cook Time: 30 minutes
            """

        let result = try! Parser.parse(recipe) as! RecipeNode
        let node = RecipeNode(steps: [], metadata: [MetadataNode("Prep Time", "15 minutes"), MetadataNode("Cook Time", "30 minutes")])

        XCTAssertEqual(result, node)
    }

    
//    TODO add tests for errors and edge-cases
    // TODO spaces in all possible random places
//    special symbols, quotes
}
