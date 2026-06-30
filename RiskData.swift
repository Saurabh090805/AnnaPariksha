import Foundation

func getRisks(for foodName: String) -> [Risk] {
    switch foodName {

    case "Milk":
        return [
            Risk(
                title: "Water Dilution",
                description: "Common practice to increase volume, reducing nutritional density."
            ),
            Risk(
                title: "Detergent Addition",
                description: "Gastrointestinal irritation, nausea and health risks."
            ),
            Risk(
                title: "Urea Contamination",
                description: "Long-term kidney stress and toxicity."
            )
        ]

    case "Paneer":
        return [
            Risk(
                title: "Starch Addition",
                description: "Reduces protein quality and adds unnecessary carbohydrates."
            ),
            Risk(
                title: "Synthetic Milk",
                description: "Chemical exposure risk from artificial paneer production."
            )
        ]

    case "Ghee":
        return [
            Risk(
                title: "Vanaspati Adulteration",
                description: "High trans-fat content increases heart disease risk."
            ),
            Risk(
                title: "Palm Oil Mixing",
                description: "Reduces nutritional value and authenticity."
            )
        ]

    case "Butter":
        return [
            Risk(
                title: "Margarine Mixing",
                description: "Artificial fats concerning to health and cardiovascular system."
            ),
            Risk(
                title: "Vegetable Fat Substitution",
                description: "Cheaper oils replace milk fat, reducing quality."
            )
        ]

    case "Curd":
        return [
            Risk(
                title: "Synthetic Curd",
                description: "Chemical-based curd with no nutritional value."
            ),
            Risk(
                title: "Starch Thickening",
                description: "Artificial thickening agents used to fake consistency."
            )
        ]

    case "Red Chilli Powder":
        return [
            Risk(
                title: "Brick Powder",
                description: "Digestive tract irritation and internal damage."
            ),
            Risk(
                title: "Synthetic Dyes",
                description: "Toxicity with long-term exposure, carcinogenic risks."
            ),
            Risk(
                title: "Sudan Dye",
                description: "Banned carcinogenic coloring agent."
            )
        ]

    case "Turmeric Powder":
        return [
            Risk(
                title: "Metanil Yellow",
                description: "Toxic dye causing liver damage and cancer risk."
            ),
            Risk(
                title: "Chalk Powder",
                description: "Mineral imbalance and digestive issues."
            ),
            Risk(
                title: "Lead Chromate",
                description: "Heavy metal poisoning, neurological damage."
            )
        ]

    case "Coriander Powder":
        return [
            Risk(
                title: "Husk Addition",
                description: "Fiber filler reducing spice potency."
            ),
            Risk(
                title: "Sawdust Mixing",
                description: "Non-food material contamination."
            )
        ]

    case "Black Pepper":
        return [
            Risk(
                title: "Papaya Seeds",
                description: "Cheap filler with different taste and health properties."
            ),
            Risk(
                title: "Light Berries",
                description: "Immature or dried berries lacking flavor."
            )
        ]

    case "Garam Masala":
        return [
            Risk(
                title: "Artificial Fillers",
                description: "Non-spice materials reducing authenticity."
            ),
            Risk(
                title: "Aflatoxin Contamination",
                description: "Mold toxins from improper storage."
            )
        ]

    case "Asafoetida":
        return [
            Risk(
                title: "Soapstone Mixing",
                description: "Mineral filler with no food value."
            ),
            Risk(
                title: "Synthetic Resin",
                description: "Artificial binding agents."
            )
        ]

    case "Tea Powder":
        return [
            Risk(
                title: "Artificial Coloring",
                description: "Synthetic dyes for enhanced appearance."
            ),
            Risk(
                title: "Iron Filings",
                description: "Metal contamination to increase weight."
            ),
            Risk(
                title: "Used Tea Leaves",
                description: "Reprocessed waste leaves with no nutrients."
            )
        ]

    case "Tomato":
        return [
            Risk(
                title: "Artificial Ripening",
                description: "Calcium carbide use causing chemical residue."
            ),
            Risk(
                title: "Pesticide Residue",
                description: "Concerning chemical accumulation on skin."
            )
        ]

    case "Potato":
        return [
            Risk(
                title: "Sprout Toxins",
                description: "Solanine formation in stored potatoes."
            ),
            Risk(
                title: "Greening",
                description: "Chlorophyll and toxin buildup from light exposure."
            ),
            Risk(
                title: "Pesticide Residue",
                description: "Chemical retention in potato eyes."
            )
        ]

    case "Green Peas":
        return [
            Risk(
                title: "Malachite Green",
                description: "Toxic dye for enhanced green color."
            ),
            Risk(
                title: "Sulfite Treatment",
                description: "Preservative causing allergic reactions."
            )
        ]

    case "Spinach":
        return [
            Risk(
                title: "Formaldehyde",
                description: "Preservative for extending shelf life, carcinogenic."
            ),
            Risk(
                title: "Nitrate Accumulation",
                description: "Excessive fertilizers causing health risks."
            )
        ]

    case "Cauliflower":
        return [
            Risk(
                title: "Whitening Agents",
                description: "Concerning bleaches for visual appeal."
            ),
            Risk(
                title: "Sulfur Dioxide",
                description: "Toxic gas treatment for preservation."
            )
        ]

    case "Brinjal":
        return [
            Risk(
                title: "Dye Injection",
                description: "Artificial color injection for darkening."
            ),
            Risk(
                title: "Pesticide Residue",
                description: "High absorption in porous skin."
            )
        ]

    case "Apple":
        return [
            Risk(
                title: "Wax Coating",
                description: "Petroleum-based wax for artificial shine."
            ),
            Risk(
                title: "Pesticide Residue",
                description: "Chemical retention in skin."
            )
        ]

    case "Banana":
        return [
            Risk(
                title: "Calcium Carbide",
                description: "Ripening agent leaving toxic residue."
            ),
            Risk(
                title: "Artificial Ripening",
                description: "Forced ripening with chemical exposure."
            )
        ]

    case "Mango":
        return [
            Risk(
                title: "Calcium Carbide",
                description: "Toxic ripening agent causing health issues."
            ),
            Risk(
                title: "Arsenic Traces",
                description: "Byproduct of carbide ripening."
            )
        ]

    case "Orange":
        return [
            Risk(
                title: "Synthetic Coloring",
                description: "Artificial dyes for uniform orange color."
            ),
            Risk(
                title: "Wax Coating",
                description: "Concerning waxes masking natural texture."
            )
        ]

    case "Grapes":
        return [
            Risk(
                title: "Sulfur Dioxide",
                description: "High levels of preservative gas."
            ),
            Risk(
                title: "Oiled Coating",
                description: "Mineral oil for artificial shine."
            )
        ]

    case "Rice":
        return [
            Risk(
                title: "Plastic Rice",
                description: "Synthetic polymer imitation."
            ),
            Risk(
                title: "Polishing Agents",
                description: "Concerning chemicals for artificial shine."
            ),
            Risk(
                title: "Insecticide Residue",
                description: "Toxic storage treatment chemicals."
            )
        ]

    case "Wheat Flour":
        return [
            Risk(
                title: "Chalk Powder",
                description: "Mineral filler increasing weight."
            ),
            Risk(
                title: "Talc Powder",
                description: "Concerning mineral dust contamination."
            ),
            Risk(
                title: "Bleaching Agents",
                description: "Chemical whiteners for appearance."
            )
        ]

    case "Sugar":
        return [
            Risk(
                title: "Chalk Powder",
                description: "White filler to increase bulk."
            ),
            Risk(
                title: "Coloring Agents",
                description: "Artificial whitening chemicals."
            )
        ]

    case "Honey":
        return [
            Risk(
                title: "Sugar Syrup",
                description: "Cheap sweetener causing blood sugar spikes."
            ),
            Risk(
                title: "Corn Syrup",
                description: "High fructose syrup reducing nutritional value."
            ),
            Risk(
                title: "Antibiotic Residue",
                description: "Beekeeping antibiotic contamination."
            )
        ]

    case "Mustard Oil":
        return [
            Risk(
                title: "Argemone Oil",
                description: "Adulterant associated with serious health concerns and requiring official verification."
            ),
            Risk(
                title: "Mineral Oil",
                description: "Industrial oil unfit for consumption."
            )
        ]

    default:
        return [
            Risk(
                title: "Possible Adulteration",
                description: "This food may have unverified quality concerns. Further verification is recommended."
            )
        ]
    }
}
