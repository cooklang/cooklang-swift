//
//  SymbolTableBuilder.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

public class SemanticAnalyzer: Visitor {
    private var currentStep: SemanticStep = SemanticStep()
    private var recipe: SemanticRecipe = SemanticRecipe()

    public init() {
    }

    public func analyze(node: AST) -> SemanticRecipe {
        visit(node: node)
        
        return recipe
    }
    
    func visit(direction: DirectionNode) {
        currentStep.addText(direction)
    }
    
    func visit(ingredient: IngredientNode) {
        currentStep.addIngredient(ingredient)
    }
    
    func visit(equipment: EquipmentNode) {
        recipe.addEquipment(equipment)
        currentStep.addEquipment(equipment)
    }
    
    func visit(timer: TimerNode) {
        currentStep.addTimer(timer)
    }

    func visit(recipe: RecipeNode) {
        for step in recipe.steps {
            visit(step: step)

            self.recipe.addStep(currentStep)
            currentStep = SemanticStep()
        }
    }
    
}
