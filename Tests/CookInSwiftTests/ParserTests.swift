//
//  ParserTests.swift
//  SwiftCookInSwiftTests
//
//  Created by Alexey Dubovskoy on 07/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation
import XCTest
@testable import CookInSwift

class ParserTests: XCTestCase {
    
//    TODO add tests for errors and edge-cases
//    TODO spaces in all possible random places
//    special symbols, quotes

    func testTimerInteger() {
        let recipe =
            """
            Fry for ~{10 minutes}
            """

        let result = try! Parser.parse(recipe) as! RecipeNode

        let steps: [StepNode] = [
            StepNode(instructions: [
                DirectionNode("Fry for "),
                TimerNode(quantity: "10 minutes", units: "", name: ""),
            ]),
        ]

        let metadata: [MetadataNode] = []

        let node = RecipeNode(steps: steps, metadata: metadata)

        XCTAssertEqual(result, node)
    }
}
