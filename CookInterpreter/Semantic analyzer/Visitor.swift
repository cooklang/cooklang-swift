//
//  Visitor.swift
//  CookInterpreter
//
//  Created by Alexey Dubovskoy on 14/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

protocol Visitor: class {
    func visit(node: AST)
    func visit(recipe: RecipeNode)
    func visit(step: StepNode)
    func visit(ingredient: IngredientNode)
    func visit(direction: DirectionNode)
    func visit(timer: TimerNode)
    func visit(equipment: EquipmentNode)
}

extension Visitor {
    func visit(node: AST) {
        switch node {
        case let direction as DirectionNode:
            visit(direction: direction)
        case let ingredient as IngredientNode:
            visit(ingredient: ingredient)
        case let timer as TimerNode:
            visit(timer: timer)
        case let equipment as EquipmentNode:
            visit(equipment: equipment)
        case let step as StepNode:
            visit(step: step)
        case let recipe as RecipeNode:
            visit(recipe: recipe)
        default:
            fatalError("Unsupported node type \(node)")
        }
    }
    
    func visit(direction: DirectionNode) {
    }
    
    func visit(ingredient: IngredientNode) {
    }
    
    func visit(timer: TimerNode) {
    }
    
    func visit(equipment: EquipmentNode) {
    }
    
    func visit(step: StepNode) {
        for item in step.children {
            visit(node: item)
        }
    }
    
    func visit(recipe: RecipeNode) {
    }
    
}
