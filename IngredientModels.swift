import Foundation

enum OverallFoodDecision: String {
    case safeToConsume = "LOW CONCERN"
    case consumeOccasionally = "CONSUME IN LIMIT"
    case notAdvised = "REVIEW CAREFULLY"
}

enum ComponentCategory: String {
    case ingredient = "Ingredient"
    case preservative = "Preservative"
    case artificialColour = "Artificial Colour"
    case sweetener = "Sweetener"
    case flavourEnhancer = "Flavour Enhancer"
    case vitamin = "Vitamin"
    case mineral = "Mineral"
    case allergen = "Allergen"
    case nutrient = "Nutrient"
}

enum RiskLevel: String {
    case safe = "Safe"
    case limit = "Limit"
    case avoid = "Avoid"
}

struct FoodComponent: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let aliases: [String]
    let category: ComponentCategory
    let purpose: String
    let riskLevel: RiskLevel
    let explanation: String
    let advice: String
}

struct NutritionMetric: Identifiable {
    let id = UUID()
    let name: String
    let perServe: String?
    let per100g: String?
    let dvPercent: String?
    let rdaPercent: String?
    let status: String
}

struct FoodLabelData {
    let rawText: String
    let cleanedText: String
    let ingredientsText: String?
    let nutritionText: String?
    let allergenText: String?
}

struct MicronutrientReport: Identifiable {
    var id: String { name }
    let name: String
    let status: String
    let role: String
}

struct IngredientSafetyReport {
    let summary: String
    let decision: OverallFoodDecision
    let confidence: Double?
    let riskScore: Int
    let reasons: [String]
    let warnings: [String]
    let labelData: FoodLabelData
    let detectedIngredients: [FoodComponent]
    let detectedAdditives: [FoodComponent]
    let detectedAllergens: [String]
    let nutritionMetrics: [NutritionMetric]
    let micronutrients: [MicronutrientReport]
    let nutrientCount: Int
    let finalAdvice: String
}

struct ServingInfo {
    let value: Double
    let unit: String
}
