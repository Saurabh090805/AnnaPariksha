import Foundation

struct GlobalNutrientRef {
    let rda: Double
    let unit: String
    let upperLimit: Double?
}

let NUTRIENT_LIMITS: [String: GlobalNutrientRef] = [

    // Energy & macros
    "energy": .init(rda: 2000, unit: "kcal", upperLimit: nil),
    "protein": .init(rda: 50, unit: "g", upperLimit: nil),

    "total fat": .init(rda: 70, unit: "g", upperLimit: 70),
    "saturated fat": .init(rda: 20, unit: "g", upperLimit: 20),
    "trans fat": .init(rda: 2, unit: "g", upperLimit: 2),

    // Sugar (strict rule)
    "added sugar": .init(rda: 50, unit: "g", upperLimit: 50),

    "dietary fibre": .init(rda: 30, unit: "g", upperLimit: nil),

    // Minerals
    "sodium": .init(rda: 2000, unit: "mg", upperLimit: 2000),
    "cholesterol": .init(rda: 300, unit: "mg", upperLimit: 300),

    "calcium": .init(rda: 1000, unit: "mg", upperLimit: 2500),
    "iron": .init(rda: 18, unit: "mg", upperLimit: 45),
    "potassium": .init(rda: 3500, unit: "mg", upperLimit: nil),
    "magnesium": .init(rda: 400, unit: "mg", upperLimit: 350),
    "zinc": .init(rda: 11, unit: "mg", upperLimit: 40),

    // Vitamins
    "vitamin a": .init(rda: 900, unit: "mcg", upperLimit: 3000),
    "vitamin c": .init(rda: 75, unit: "mg", upperLimit: 2000),
    "vitamin d": .init(rda: 15, unit: "mcg", upperLimit: 100),
    "vitamin b12": .init(rda: 2.4, unit: "mcg", upperLimit: nil)
]
