//
//  ConfigParserTests.swift
//
//
//  Created by Alexey Dubovskoy on 07/04/2021.
//

import Foundation
@testable import CookInSwift
import XCTest

class ConfigParserTests: XCTestCase {

    func testBasicConfig() {
        let textConfig =
        """
        [fruit and veg]
        apples
        bananas
        beetroots

        [milk and dairy]
        butter
        egg
        """

        let parser = ConfigParser(textConfig)
        let result = parser.parse()

        let sections = ["fruit and veg": ["bananas", "beetroots"],
                        "milk and dairy": ["egg"]]

        let items = ["egg": "milk and dairy",
                     "butter": "milk and dairy",
                     "beetroots": "fruit and veg",
                     "apples": "fruit and veg",
                     "bananas": "fruit and veg"]

        XCTAssertEqual(result.sections, sections)
        XCTAssertEqual(result.items, items)
    }

}
