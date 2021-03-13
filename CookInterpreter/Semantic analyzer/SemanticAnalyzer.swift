//
//  SymbolTableBuilder.swift
//  SwiftCookInterpreter
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

public class SemanticAnalyzer: Visitor {
    private var currentDescription: [String] = []
    private var currentStep: SemanticStep = SemanticStep()
    private var recipe: SemanticRecipe = SemanticRecipe()

    public init() {
    }

    public func analyze(node: AST) -> SemanticRecipe {
        visit(node: node)
        
        return recipe
    }
    
    func visit(direction: DirectionNode) {
        currentDescription.append(direction.value.description)
    }
    
    func visit(ingredient: IngredientNode) {
        currentDescription.append("\(ingredient.name)")
        currentStep.addIngredient(ingredient)
    }
    
    func visit(equipment: EquipmentNode) {
        currentDescription.append("\(equipment.name)")
        recipe.addEquipment(equipment)
    }
    
    func visit(timer: TimerNode) {
        currentDescription.append("\(timer.quantity) \(timer.units)")
        currentStep.addTimer(timer)
    }

    func visit(recipe: RecipeNode) {
        for step in recipe.steps {
            visit(step: step)
            
            currentStep.addDirections(currentDescription.joined())
            self.recipe.addStep(currentStep)
            
            currentDescription = []
            currentStep = SemanticStep()
        }
    }
    
}
