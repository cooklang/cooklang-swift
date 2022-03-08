//
//  SymbolTableBuilder.swift
//  SwiftCookInSwift
//
//  Created by Alexey Dubovskoy on 10/12/2020.
//  Copyright © 2020 Alexey Dubovskoy. All rights reserved.
//

import Foundation

public class SemanticAnalyzer: Visitor {
    private var currentStep: Step = Step()
    private var currentRecipe: Recipe = Recipe()

    public init() {}

    public func analyze(node: AST) -> Recipe {
        visit(node: node)
        
        return currentRecipe
    }
    
    func visit(direction: DirectionNode) {
        currentStep.addText(direction)
    }
    
    func visit(ingredient: IngredientNode) {
        currentStep.addIngredient(ingredient)
    }
    
    func visit(equipment: EquipmentNode) {
        currentRecipe.addEquipment(equipment)
        currentStep.addEquipment(equipment)
    }
    
    func visit(timer: TimerNode) {
        currentStep.addTimer(timer)
    }

    func visit(recipe: RecipeNode) {
        currentRecipe.addMetadata(recipe.metadata)

        for step in recipe.steps {
            visit(step: step)

            currentRecipe.addStep(currentStep)
            currentStep = Step()
        }
    }
    
}
