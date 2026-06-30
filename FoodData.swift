import Foundation

struct AppFoodItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: Category
    let imageName: String
    let homeTest: TestConfiguration?
    let labTest: TestConfiguration?

    static func == (lhs: AppFoodItem, rhs: AppFoodItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

let foodItems: [AppFoodItem] = [
    AppFoodItem(
        name: "Milk",
        category: .dairy,
        imageName: "Milk",
        homeTest: TestConfiguration(
            testName: "Milk Flow Test",
            description: "Visual screening to detect abnormal milk behaviour.",
            steps: [
                ProtocolStepData(number: 1, title: "Prepare Surface", instruction: "Place a single drop of milk on a clean, slightly slanted surface.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Observe Flow", instruction: "Watch the flow speed and examine the residue trail.", icon: "eye.fill")
            ],
            normalIndicators: ["Slow smooth flow", "Clean continuous trail", "No separation"],
            abnormalIndicators: ["Fast watery spread", "Broken chalky trail", "Visible separation"]
        ),
        labTest: TestConfiguration(
            testName: "LC-MS Analysis",
            description: "Liquid Chromatography-Mass Spectrometry for chemical confirmation.",
            steps: [
                ProtocolStepData(number: 1, title: "Sample Collection", instruction: "Collect milk sample in sterile container.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "LC Injection", instruction: "Sample is injected into the LC system.", icon: "arrow.right.circle.fill"),
                ProtocolStepData(number: 3, title: "Component Separation", instruction: "Chemical components are separated.", icon: "line.3.horizontal.decrease"),
                ProtocolStepData(number: 4, title: "Mass Spectrometry", instruction: "MS checks for foreign compounds.", icon: "waveform")
            ],
            normalIndicators: ["Only natural milk constituents", "No detergent peaks", "No urea detected"],
            abnormalIndicators: ["Detergent peaks present", "Urea contamination found", "Foreign compounds detected"]
        )
    ),
    
    AppFoodItem(
        name: "Paneer",
        category: .dairy,
        imageName: "Paneer",
        homeTest: TestConfiguration(
            testName: "Boiling Test",
            description: "Detect starch adulteration through boiling observation.",
            steps: [
                ProtocolStepData(number: 1, title: "Boil Water", instruction: "Boil water in a clean pan.", icon: "flame.fill"),
                ProtocolStepData(number: 2, title: "Add Paneer", instruction: "Add a small piece of paneer to boiling water.", icon: "plus.circle.fill"),
                ProtocolStepData(number: 3, title: "Observe Water", instruction: "Watch the water color after 2 minutes.", icon: "eye.fill")
            ],
            normalIndicators: ["Water remains clear", "No cloudiness", "Paneer retains shape"],
            abnormalIndicators: ["Water turns milky", "Cloudy appearance", "Disintegration observed"]
        ),
        labTest: TestConfiguration(
            testName: "FTIR Spectroscopy",
            description: "Fourier Transform Infrared analysis for molecular confirmation.",
            steps: [
                ProtocolStepData(number: 1, title: "Sample Prep", instruction: "Paneer sample is dried and prepared.", icon: "sun.max.fill"),
                ProtocolStepData(number: 2, title: "IR Exposure", instruction: "Infrared light passed through sample.", icon: "lightbulb.fill"),
                ProtocolStepData(number: 3, title: "Spectrum Analysis", instruction: "Absorption spectrum is analyzed.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["Protein and fat peaks only", "No starch signature", "Standard dairy profile"],
            abnormalIndicators: ["Starch peaks detected", "Synthetic compounds found", "Adulteration confirmed"]
        )
    ),
    
    AppFoodItem(
        name: "Ghee",
        category: .dairy,
        imageName: "Ghee",
        homeTest: TestConfiguration(
            testName: "Heat Test",
            description: "Detect vegetable fat adulteration through melting behavior.",
            steps: [
                ProtocolStepData(number: 1, title: "Take Sample", instruction: "Take one spoon of ghee in a pan.", icon: "spoon.fill"),
                ProtocolStepData(number: 2, title: "Heat Slowly", instruction: "Heat slowly on low flame.", icon: "flame"),
                ProtocolStepData(number: 3, title: "Observe Texture", instruction: "Watch melting behavior and texture.", icon: "eye.fill")
            ],
            normalIndicators: ["Even melting", "Grainy texture", "Rich aroma"],
            abnormalIndicators: ["Completely oily texture", "No grain formation", "Artificial smell"]
        ),
        labTest: TestConfiguration(
            testName: "GC-MS Analysis",
            description: "Gas Chromatography-Mass Spectrometry for fatty acid profiling.",
            steps: [
                ProtocolStepData(number: 1, title: "Vaporization", instruction: "Ghee sample is vaporized.", icon: "wind"),
                ProtocolStepData(number: 2, title: "Fatty Acid Separation", instruction: "Fatty acids are separated by GC.", icon: "arrow.left.and.right"),
                ProtocolStepData(number: 3, title: "Profile Comparison", instruction: "Compared with milk fat standards.", icon: "doc.text.magnifyingglass")
            ],
            normalIndicators: ["Milk fat fingerprint only", "Natural fatty acid profile", "No vegetable oils"],
            abnormalIndicators: ["Vegetable fat detected", "Vanaspati signature", "Palm oil profile found"]
        )
    ),
    
    AppFoodItem(
        name: "Butter",
        category: .dairy,
        imageName: "Butter",
        homeTest: TestConfiguration(
            testName: "Melt Test",
            description: "Check for vegetable fat adulteration in butter.",
            steps: [
                ProtocolStepData(number: 1, title: "Room Temperature", instruction: "Leave butter at room temperature.", icon: "thermometer"),
                ProtocolStepData(number: 2, title: "Observe Melting", instruction: "Watch how it melts and separates.", icon: "eye.fill")
            ],
            normalIndicators: ["Melts gradually", "Clear separation", "Natural yellow color"],
            abnormalIndicators: ["Melts too quickly", "Oily residue", "Unnatural color"]
        ),
        labTest: TestConfiguration(
            testName: "Fatty Acid Analysis",
            description: "Detailed fatty acid composition testing.",
            steps: [
                ProtocolStepData(number: 1, title: "Extraction", instruction: "Fat extracted from butter sample.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Chromatography", instruction: "GC analysis of fatty acids.", icon: "chart.line.uptrend.xyaxis")
            ],
            normalIndicators: ["Butterfat profile match", "Standard composition", "No foreign fats"],
            abnormalIndicators: ["Vegetable fat present", "Margarine markers", "Composition mismatch"]
        )
    ),
    
    AppFoodItem(
        name: "Curd",
        category: .dairy,
        imageName: "Curd",
        homeTest: TestConfiguration(
            testName: "Water Test",
            description: "Detect synthetic milk or starch in curd.",
            steps: [
                ProtocolStepData(number: 1, title: "Take Sample", instruction: "Take a spoon of curd in a glass.", icon: "spoon.fill"),
                ProtocolStepData(number: 2, title: "Add Water", instruction: "Add water and stir gently.", icon: "drop.fill"),
                ProtocolStepData(number: 3, title: "Check Consistency", instruction: "Observe dissolution and texture.", icon: "eye.fill")
            ],
            normalIndicators: ["Maintains thickness", "Smooth texture", "Natural sour smell"],
            abnormalIndicators: ["Watery consistency", "Lumpy texture", "Chemical odor"]
        ),
        labTest: TestConfiguration(
            testName: "Protein Analysis",
            description: "Protein content and quality verification.",
            steps: [
                ProtocolStepData(number: 1, title: "Protein Extraction", instruction: "Proteins extracted from curd.", icon: "atom"),
                ProtocolStepData(number: 2, title: "Quantification", instruction: "Protein content measured.", icon: "scalemass.fill")
            ],
            normalIndicators: ["Normal protein content", "Quality proteins", "No synthetic additives"],
            abnormalIndicators: ["Low protein content", "Synthetic proteins", "Starch detected"]
        )
    ),
    
    AppFoodItem(
        name: "Red Chilli Powder",
        category: .spices,
        imageName: "RedChilliPowder",
        homeTest: TestConfiguration(
            testName: "Water Sediment Test",
            description: "Detect brick powder and synthetic dyes.",
            steps: [
                ProtocolStepData(number: 1, title: "Add to Water", instruction: "Add one spoon of chilli powder to water.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Wait", instruction: "Let it stand for 2 minutes.", icon: "clock.fill"),
                ProtocolStepData(number: 3, title: "Check Sediment", instruction: "Observe color spread and sediment.", icon: "eye.fill")
            ],
            normalIndicators: ["Color spreads slowly", "No heavy sediment", "Natural red color"],
            abnormalIndicators: ["Heavy gritty sediment", "Color bleeds quickly", "Artificial dye visible"]
        ),
        labTest: TestConfiguration(
            testName: "GC-MS Dye Analysis",
            description: "Detect synthetic dyes and contaminants.",
            steps: [
                ProtocolStepData(number: 1, title: "Extraction", instruction: "Sample extract prepared.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Dye Separation", instruction: "Dye molecules separated by GC.", icon: "arrow.left.and.right"),
                ProtocolStepData(number: 3, title: "Spectrum Match", instruction: "Compared with dye standards.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["No synthetic dye", "Natural colorants only", "Safe composition"],
            abnormalIndicators: ["Synthetic dye detected", "Toxic colorants", "Adulteration confirmed"]
        )
    ),
    
    AppFoodItem(
        name: "Turmeric Powder",
        category: .spices,
        imageName: "TurmericPowder",
        homeTest: TestConfiguration(
            testName: "Acid Test",
            description: "Detect metanil yellow and other toxic dyes.",
            steps: [
                ProtocolStepData(number: 1, title: "Place Sample", instruction: "Place turmeric on a white plate.", icon: "circle.fill"),
                ProtocolStepData(number: 2, title: "Add Acid", instruction: "Add lemon juice or dilute acid.", icon: "drop.triangle.fill"),
                ProtocolStepData(number: 3, title: "Color Change", instruction: "Observe any color change.", icon: "eye.fill")
            ],
            normalIndicators: ["No color change", "Stays yellow", "Natural reaction"],
            abnormalIndicators: ["Pink or red color", "Immediate change", "Toxic dye present"]
        ),
        labTest: TestConfiguration(
            testName: "UV-Vis Spectroscopy",
            description: "Absorbance analysis for dye detection.",
            steps: [
                ProtocolStepData(number: 1, title: "Solution Prep", instruction: "Turmeric solution prepared.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Light Passage", instruction: "Light passed through sample.", icon: "lightbulb.fill"),
                ProtocolStepData(number: 3, title: "Curve Analysis", instruction: "Absorbance curve analyzed.", icon: "waveform.path.ecg")
            ],
            normalIndicators: ["Natural turmeric pattern", "Standard absorbance", "No synthetic peaks"],
            abnormalIndicators: ["Synthetic dye peak", "Metanil yellow detected", "Adulteration confirmed"]
        )
    ),
    
    AppFoodItem(
        name: "Coriander Powder",
        category: .spices,
        imageName: "CorianderPowder",
        homeTest: TestConfiguration(
            testName: "Water Float Test",
            description: "Detect husk and sawdust adulteration.",
            steps: [
                ProtocolStepData(number: 1, title: "Add to Water", instruction: "Add coriander powder to water.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Stir", instruction: "Stir and let settle.", icon: "arrow.clockwise"),
                ProtocolStepData(number: 3, title: "Check Residue", instruction: "Observe floating particles.", icon: "eye.fill")
            ],
            normalIndicators: ["Minimal floating matter", "Natural aroma", "Smooth texture"],
            abnormalIndicators: ["Excessive husk floating", "Sawdust particles", "Gritty texture"]
        ),
        labTest: TestConfiguration(
            testName: "Microscopic Analysis",
            description: "Cell structure examination.",
            steps: [
                ProtocolStepData(number: 1, title: "Slide Prep", instruction: "Sample mounted on slide.", icon: "scope"),
                ProtocolStepData(number: 2, title: "Microscopy", instruction: "Cell structures examined.", icon: "magnifyingglass")
            ],
            normalIndicators: ["Coriander cells only", "No foreign matter", "Pure sample"],
            abnormalIndicators: ["Husk fibers present", "Sawdust detected", "Adulteration found"]
        )
    ),
    
    AppFoodItem(
        name: "Black Pepper",
        category: .spices,
        imageName: "BlackPepper",
        homeTest: TestConfiguration(
            testName: "Floatation Test",
            description: "Detect papaya seeds and other fillers.",
            steps: [
                ProtocolStepData(number: 1, title: "Add to Water", instruction: "Add peppercorns to water.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Observe", instruction: "Watch which sink or float.", icon: "eye.fill")
            ],
            normalIndicators: ["Most sink immediately", "Uniform appearance", "Strong aroma"],
            abnormalIndicators: ["Many float", "Mixed sizes", "Weak smell"]
        ),
        labTest: TestConfiguration(
            testName: "DNA Barcoding",
            description: "Species identification verification.",
            steps: [
                ProtocolStepData(number: 1, title: "DNA Extraction", instruction: "DNA extracted from sample.", icon: "dna"),
                ProtocolStepData(number: 2, title: "Sequencing", instruction: "Genetic sequence analyzed.", icon: "line.3.horizontal")
            ],
            normalIndicators: ["Pure pepper DNA", "No papaya markers", "Authentic species"],
            abnormalIndicators: ["Papaya DNA found", "Mixed species", "Adulteration confirmed"]
        )
    ),
    
    AppFoodItem(
        name: "Garam Masala",
        category: .spices,
        imageName: "GaramMasala",
        homeTest: TestConfiguration(
            testName: "Visual Inspection",
            description: "Check for artificial fillers and quality.",
            steps: [
                ProtocolStepData(number: 1, title: "Spread Sample", instruction: "Spread on white paper.", icon: "doc.fill"),
                ProtocolStepData(number: 2, title: "Magnify", instruction: "Use magnifying glass if needed.", icon: "magnifyingglass"),
                ProtocolStepData(number: 3, title: "Check Texture", instruction: "Look for unusual particles.", icon: "eye.fill")
            ],
            normalIndicators: ["Uniform texture", "Rich aroma", "Natural colors"],
            abnormalIndicators: ["Chalky particles", "Dull smell", "Artificial colors"]
        ),
        labTest: TestConfiguration(
            testName: "Component Analysis",
            description: "Verify authentic spice composition.",
            steps: [
                ProtocolStepData(number: 1, title: "Separation", instruction: "Components separated.", icon: "arrow.left.and.right"),
                ProtocolStepData(number: 2, title: "Identification", instruction: "Each spice identified.", icon: "checkmark.seal.fill")
            ],
            normalIndicators: ["All authentic spices", "Correct proportions", "No fillers"],
            abnormalIndicators: ["Artificial fillers", "Missing key spices", "Adulteration found"]
        )
    ),
    
    AppFoodItem(
        name: "Asafoetida",
        category: .spices,
        imageName: "Asafoetida",
        homeTest: TestConfiguration(
            testName: "Burn Test",
            description: "Detect soapstone and resin adulteration.",
            steps: [
                ProtocolStepData(number: 1, title: "Take Sample", instruction: "Take small piece of hing.", icon: "circle.fill"),
                ProtocolStepData(number: 2, title: "Burn", instruction: "Burn on open flame.", icon: "flame.fill"),
                ProtocolStepData(number: 3, title: "Observe", instruction: "Check smell and residue.", icon: "eye.fill")
            ],
            normalIndicators: ["Pungent aroma", "Burns completely", "No residue"],
            abnormalIndicators: ["Weak smell", "Ash residue", "Soapstone detected"]
        ),
        labTest: TestConfiguration(
            testName: "Resin Analysis",
            description: "Chemical composition verification.",
            steps: [
                ProtocolStepData(number: 1, title: "Extraction", instruction: "Resinous compounds extracted.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "HPLC", instruction: "High-performance liquid chromatography.", icon: "chart.line.uptrend.xyaxis")
            ],
            normalIndicators: ["Authentic resin profile", "Standard compounds", "Pure asafoetida"],
            abnormalIndicators: ["Soapstone present", "Synthetic resin", "Adulteration confirmed"]
        )
    ),
    
    AppFoodItem(
        name: "Tea Powder",
        category: .spices,
        imageName: "TeaPowder",
        homeTest: TestConfiguration(
            testName: "Paper Filter Test",
            description: "Detect artificial color and iron filings.",
            steps: [
                ProtocolStepData(number: 1, title: "Wet Paper", instruction: "Place tea on wet white paper.", icon: "doc.fill"),
                ProtocolStepData(number: 2, title: "Rub", instruction: "Rub gently and observe color.", icon: "hand.tap.fill"),
                ProtocolStepData(number: 3, title: "Check Stain", instruction: "Check for unusual colors.", icon: "eye.fill")
            ],
            normalIndicators: ["Natural brown stain", "No bright colors", "Even spread"],
            abnormalIndicators: ["Bright color bleed", "Black spots (iron)", "Artificial dye"]
        ),
        labTest: TestConfiguration(
            testName: "Dye & Metal Analysis",
            description: "Test for synthetic dyes and heavy metals.",
            steps: [
                ProtocolStepData(number: 1, title: "Extraction", instruction: "Tea extract prepared.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Spectroscopy", instruction: "Color and metal analysis.", icon: "waveform")
            ],
            normalIndicators: ["Natural tea compounds", "No synthetic dyes", "Safe iron levels"],
            abnormalIndicators: ["Artificial colorants", "Excess iron", "Heavy metals"]
        )
    ),
    
    AppFoodItem(
        name: "Tomato",
        category: .vegetables,
        imageName: "Tomato",
        homeTest: TestConfiguration(
            testName: "Pressure Test",
            description: "Detect artificial ripening.",
            steps: [
                ProtocolStepData(number: 1, title: "Press Gently", instruction: "Press tomato with fingers.", icon: "hand.tap.fill"),
                ProtocolStepData(number: 2, title: "Check Firmness", instruction: "Check for uniform firmness.", icon: "eye.fill")
            ],
            normalIndicators: ["Slight give", "Uniform color", "Natural smell"],
            abnormalIndicators: ["Too hard", "Uneven ripening", "Chemical odor"]
        ),
        labTest: TestConfiguration(
            testName: "Ethylene & Pesticide Test",
            description: "Detect artificial ripening agents.",
            steps: [
                ProtocolStepData(number: 1, title: "Sample Prep", instruction: "Skin and pulp analyzed.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Chemical Analysis", instruction: "Test for ripening agents.", icon: "flask.fill")
            ],
            normalIndicators: ["Natural ripening markers", "No visible pesticide concern", "No ethylene carbide"],
            abnormalIndicators: ["Artificial ripening detected", "High pesticide residue", "Calcium carbide found"]
        )
    ),
    
    AppFoodItem(
        name: "Potato",
        category: .vegetables,
        imageName: "Potato",
        homeTest: TestConfiguration(
            testName: "Eye Inspection",
            description: "Check for pesticide residue and freshness.",
            steps: [
                ProtocolStepData(number: 1, title: "Check Eyes", instruction: "Examine potato eyes closely.", icon: "eye.fill"),
                ProtocolStepData(number: 2, title: "Scratch Test", instruction: "Scratch surface with nail.", icon: "hand.tap.fill")
            ],
            normalIndicators: ["Dry eyes", "No sprouts", "Natural color inside"],
            abnormalIndicators: ["Wet eyes", "Green patches", "Chemical smell"]
        ),
        labTest: TestConfiguration(
            testName: "Pesticide Residue Analysis",
            description: "Comprehensive pesticide testing.",
            steps: [
                ProtocolStepData(number: 1, title: "Extraction", instruction: "Surface residue extracted.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "GC-MS", instruction: "Pesticide compounds identified.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["Within expected range", "No banned pesticides", "Organic markers"],
            abnormalIndicators: ["High residue levels", "Banned pesticides", "Toxic compounds"]
        )
    ),
    
    AppFoodItem(
        name: "Green Peas",
        category: .vegetables,
        imageName: "GreenPeas",
        homeTest: TestConfiguration(
            testName: "Water Rub Test",
            description: "Detect synthetic green dye.",
            steps: [
                ProtocolStepData(number: 1, title: "Rub Peas", instruction: "Rub peas between wet fingers.", icon: "hand.tap.fill"),
                ProtocolStepData(number: 2, title: "Check Color", instruction: "Check if color bleeds.", icon: "eye.fill")
            ],
            normalIndicators: ["No color bleeding", "Natural green", "Firm texture"],
            abnormalIndicators: ["Green color on hands", "Dye bleeding", "Too bright color"]
        ),
        labTest: TestConfiguration(
            testName: "Dye & Preservative Test",
            description: "Chemical analysis for artificial additives.",
            steps: [
                ProtocolStepData(number: 1, title: "Extraction", instruction: "Color extracted from peas.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "HPLC", instruction: "Dye and preservative analysis.", icon: "chart.line.uptrend.xyaxis")
            ],
            normalIndicators: ["No synthetic dye", "Natural chlorophyll", "Safe preservatives"],
            abnormalIndicators: ["Malachite green detected", "Artificial colorants", "Concerning preservatives"]
        )
    ),
    
    AppFoodItem(
        name: "Spinach",
        category: .vegetables,
        imageName: "Spinach",
        homeTest: TestConfiguration(
            testName: "Stem Break Test",
            description: "Check for chemical preservatives.",
            steps: [
                ProtocolStepData(number: 1, title: "Break Stem", instruction: "Break spinach stem.", icon: "scissors"),
                ProtocolStepData(number: 2, title: "Check Sap", instruction: "Observe sap color and smell.", icon: "eye.fill")
            ],
            normalIndicators: ["White clear sap", "Fresh smell", "Crisp break"],
            abnormalIndicators: ["No sap", "Chemical smell", "Mushy texture"]
        ),
        labTest: TestConfiguration(
            testName: "Preservative Analysis",
            description: "Test for chemical preservatives.",
            steps: [
                ProtocolStepData(number: 1, title: "Sample Prep", instruction: "Leaves and stems ground.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Chemical Test", instruction: "Test for preservatives.", icon: "flask.fill")
            ],
            normalIndicators: ["No preservatives", "Natural compounds", "Freshness markers"],
            abnormalIndicators: ["Formaldehyde detected", "Sulfites present", "Concerning chemicals"]
        )
    ),
    
    AppFoodItem(
        name: "Cauliflower",
        category: .vegetables,
        imageName: "Cauliflower",
        homeTest: TestConfiguration(
            testName: "Water Dip Test",
            description: "Detect whitening agents.",
            steps: [
                ProtocolStepData(number: 1, title: "Prepare Water", instruction: "Take warm water in bowl.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Dip Florets", instruction: "Dip cauliflower for 2 minutes.", icon: "arrow.down.circle.fill"),
                ProtocolStepData(number: 3, title: "Check Water", instruction: "Observe any smell or color change.", icon: "eye.fill")
            ],
            normalIndicators: ["Clear water", "Natural smell", "No residue"],
            abnormalIndicators: ["Cloudy water", "Chemical smell", "White residue"]
        ),
        labTest: TestConfiguration(
            testName: "Bleaching Agent Test",
            description: "Detect concerning whitening chemicals.",
            steps: [
                ProtocolStepData(number: 1, title: "Extraction", instruction: "Surface compounds extracted.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Analysis", instruction: "Test for sulfites/bleaches.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["No bleaching agents", "Natural surface", "No obvious concern"],
            abnormalIndicators: ["Sulfur dioxide", "Concerning bleaches", "Toxic whitening agents"]
        )
    ),
    
    AppFoodItem(
        name: "Brinjal",
        category: .vegetables,
        imageName: "Brinjal",
        homeTest: TestConfiguration(
            testName: "Water Float Test",
            description: "Check for internal adulteration.",
            steps: [
                ProtocolStepData(number: 1, title: "Cut Open", instruction: "Cut brinjal lengthwise.", icon: "scissors"),
                ProtocolStepData(number: 2, title: "Check Inside", instruction: "Look for injection marks.", icon: "eye.fill"),
                ProtocolStepData(number: 3, title: "Float Test", instruction: "Place in water and observe.", icon: "drop.fill")
            ],
            normalIndicators: ["Uniform flesh", "No holes", "Sinks in water"],
            abnormalIndicators: ["Injection marks", "Discolored patches", "Floats abnormally"]
        ),
        labTest: TestConfiguration(
            testName: "Injection & Pesticide Test",
            description: "Detect injected dyes and pesticides.",
            steps: [
                ProtocolStepData(number: 1, title: "Section Analysis", instruction: "Cross-section examined.", icon: "scope"),
                ProtocolStepData(number: 2, title: "Chemical Test", instruction: "Test for injected substances.", icon: "flask.fill")
            ],
            normalIndicators: ["No injection marks", "No visible pesticide concern", "Natural color throughout"],
            abnormalIndicators: ["Dye injection detected", "High pesticide residue", "Artificial colorants"]
        )
    ),
    
    AppFoodItem(
        name: "Apple",
        category: .fruits,
        imageName: "Apple",
        homeTest: TestConfiguration(
            testName: "Wax Scratch Test",
            description: "Detect artificial wax coating.",
            steps: [
                ProtocolStepData(number: 1, title: "Scratch Surface", instruction: "Scratch apple with fingernail.", icon: "hand.tap.fill"),
                ProtocolStepData(number: 2, title: "Check Residue", instruction: "Look for white waxy residue.", icon: "eye.fill"),
                ProtocolStepData(number: 3, title: "Hot Water Test", instruction: "Pour hot water over apple.", icon: "drop.fill")
            ],
            normalIndicators: ["Minimal wax", "Natural shine", "No white flakes"],
            abnormalIndicators: ["Thick white wax", "Flakes in hot water", "Artificial coating"]
        ),
        labTest: TestConfiguration(
            testName: "Wax & Pesticide Analysis",
            description: "Chemical analysis of coating and residues.",
            steps: [
                ProtocolStepData(number: 1, title: "Wax Extraction", instruction: "Surface wax dissolved.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Analysis", instruction: "Test for concerning waxes and pesticides.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["Natural wax only", "Safe coating", "Pesticide within limits"],
            abnormalIndicators: ["Petroleum wax", "Concerning coating", "High pesticide residue"]
        )
    ),
    
    AppFoodItem(
        name: "Banana",
        category: .fruits,
        imageName: "Banana",
        homeTest: TestConfiguration(
            testName: "Stem & Skin Check",
            description: "Detect artificial ripening.",
            steps: [
                ProtocolStepData(number: 1, title: "Check Stem", instruction: "Look at stem color and texture.", icon: "eye.fill"),
                ProtocolStepData(number: 2, title: "Feel Skin", instruction: "Check if skin separates easily.", icon: "hand.tap.fill")
            ],
            normalIndicators: ["Greenish stem", "Firm skin", "Natural spots"],
            abnormalIndicators: ["Black stem", "Powdery residue", "Uniform yellow"]
        ),
        labTest: TestConfiguration(
            testName: "Ripening Agent Test",
            description: "Detect calcium carbide and ethylene.",
            steps: [
                ProtocolStepData(number: 1, title: "Gas Detection", instruction: "Test for acetylene gas traces.", icon: "wind"),
                ProtocolStepData(number: 2, title: "Residue Analysis", instruction: "Check for carbide residue.", icon: "magnifyingglass")
            ],
            normalIndicators: ["Naturally ripened", "No carbide traces", "Safe ethylene levels"],
            abnormalIndicators: ["Calcium carbide detected", "Acetylene traces", "Forced ripening"]
        )
    ),
    
    AppFoodItem(
        name: "Mango",
        category: .fruits,
        imageName: "Mango",
        homeTest: TestConfiguration(
            testName: "Juice & Smell Test",
            description: "Detect calcium carbide ripening.",
            steps: [
                ProtocolStepData(number: 1, title: "Check Aroma", instruction: "Smell near the stem.", icon: "nose.fill"),
                ProtocolStepData(number: 2, title: "Taste Juice", instruction: "Taste juice near stem.", icon: "mouth.fill"),
                ProtocolStepData(number: 3, title: "Check Texture", instruction: "Feel for uniform softness.", icon: "hand.tap.fill")
            ],
            normalIndicators: ["Sweet fruity smell", "Sweet taste", "Soft near stem first"],
            abnormalIndicators: ["Garlic-like smell", "Bitter taste", "Uniform hardness"]
        ),
        labTest: TestConfiguration(
            testName: "Carbide Residue Test",
            description: "Detect calcium carbide traces.",
            steps: [
                ProtocolStepData(number: 1, title: "Sample Prep", instruction: "Skin and pulp samples taken.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Chemical Test", instruction: "Test for arsenic and carbide.", icon: "flask.fill")
            ],
            normalIndicators: ["No carbide residue", "Natural ripening markers", "Safe arsenic levels"],
            abnormalIndicators: ["Calcium carbide present", "Arsenic traces", "Toxic ripening agent"]
        )
    ),
    
    AppFoodItem(
        name: "Orange",
        category: .fruits,
        imageName: "Orange",
        homeTest: TestConfiguration(
            testName: "Color Rub Test",
            description: "Detect synthetic coloring.",
            steps: [
                ProtocolStepData(number: 1, title: "Rub Skin", instruction: "Rub orange skin on wet cloth.", icon: "hand.tap.fill"),
                ProtocolStepData(number: 2, title: "Check Cloth", instruction: "See if color transfers.", icon: "eye.fill")
            ],
            normalIndicators: ["No color transfer", "Natural orange color", "Porous texture"],
            abnormalIndicators: ["Color on cloth", "Too bright orange", "Waxy feel"]
        ),
        labTest: TestConfiguration(
            testName: "Dye & Wax Analysis",
            description: "Test for artificial colors and waxes.",
            steps: [
                ProtocolStepData(number: 1, title: "Surface Extraction", instruction: "Color and wax extracted.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Chromatography", instruction: "Dye components separated.", icon: "chart.line.uptrend.xyaxis")
            ],
            normalIndicators: ["No synthetic dye", "Natural wax only", "Safe colorants"],
            abnormalIndicators: ["Synthetic dye detected", "Concerning wax", "Toxic colorants"]
        )
    ),
    
    AppFoodItem(
        name: "Grapes",
        category: .fruits,
        imageName: "Grapes",
        homeTest: TestConfiguration(
            testName: "Bloom Check",
            description: "Detect chemical preservatives.",
            steps: [
                ProtocolStepData(number: 1, title: "Check Coating", instruction: "Look for white powdery coating.", icon: "eye.fill"),
                ProtocolStepData(number: 2, title: "Rub Test", instruction: "Rub grapes and check if coating removes.", icon: "hand.tap.fill")
            ],
            normalIndicators: ["Natural bloom (removable)", "Firm grapes", "Natural shine"],
            abnormalIndicators: ["Unnatural shine", "Coating doesn't rub off", "Oily feel"]
        ),
        labTest: TestConfiguration(
            testName: "Preservative & Pesticide Test",
            description: "Chemical residue analysis.",
            steps: [
                ProtocolStepData(number: 1, title: "Residue Extraction", instruction: "Surface chemicals extracted.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Multi-residue Analysis", instruction: "Test for multiple chemicals.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["Natural bloom only", "No visible pesticide concern", "No listed preservative concern"],
            abnormalIndicators: ["Sulfur dioxide high", "Oiled grapes", "Toxic preservatives"]
        )
    ),
    
    AppFoodItem(
        name: "Rice",
        category: .staples,
        imageName: "Rice",
        homeTest: TestConfiguration(
            testName: "Water & Fire Test",
            description: "Detect plastic rice and polishing agents.",
            steps: [
                ProtocolStepData(number: 1, title: "Water Test", instruction: "Drop rice in water and stir.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Fire Test", instruction: "Burn few grains with match.", icon: "flame.fill"),
                ProtocolStepData(number: 3, title: "Mash Test", instruction: "Mash cooked rice with fingers.", icon: "hand.tap.fill")
            ],
            normalIndicators: ["Sinks immediately", "Burns like paper", "Mashes easily"],
            abnormalIndicators: ["Floats", "Melts/plastic smell", "Hard to mash"]
        ),
        labTest: TestConfiguration(
            testName: "Plastic & Chemical Analysis",
            description: "Detect synthetic polymers and chemicals.",
            steps: [
                ProtocolStepData(number: 1, title: "Solvent Test", instruction: "Sample dissolved in solvent.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Spectroscopy", instruction: "Polymer identification.", icon: "waveform")
            ],
            normalIndicators: ["No plastic polymers", "Natural starch only", "Safe polishing agents"],
            abnormalIndicators: ["Plastic detected", "Synthetic polymers", "Concerning chemicals"]
        )
    ),
    
    AppFoodItem(
        name: "Wheat Flour",
        category: .staples,
        imageName: "WheatFlour",
        homeTest: TestConfiguration(
            testName: "Dough & Ball Test",
            description: "Detect chalk and talc powder.",
            steps: [
                ProtocolStepData(number: 1, title: "Feel Test", instruction: "Rub flour between fingers.", icon: "hand.tap.fill"),
                ProtocolStepData(number: 2, title: "Ball Test", instruction: "Make tight ball and drop.", icon: "circle.fill"),
                ProtocolStepData(number: 3, title: "Water Test", instruction: "Add water and check residue.", icon: "drop.fill")
            ],
            normalIndicators: ["Smooth texture", "Ball breaks easily", "No grittiness"],
            abnormalIndicators: ["Gritty feel", "Ball stays tight", "White residue"]
        ),
        labTest: TestConfiguration(
            testName: "Mineral & Adulterant Test",
            description: "Detect chalk, talc, and other minerals.",
            steps: [
                ProtocolStepData(number: 1, title: "Ash Test", instruction: "Sample burned to ash.", icon: "flame.fill"),
                ProtocolStepData(number: 2, title: "Mineral Analysis", instruction: "Ash analyzed for minerals.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["Normal ash content", "No excess minerals", "Pure wheat"],
            abnormalIndicators: ["High ash content", "Chalk/talc detected", "Adulteration confirmed"]
        )
    ),
    
    AppFoodItem(
        name: "Sugar",
        category: .staples,
        imageName: "Sugar",
        homeTest: TestConfiguration(
            testName: "Dissolution & Residue Test",
            description: "Detect chalk powder in sugar.",
            steps: [
                ProtocolStepData(number: 1, title: "Water Test", instruction: "Dissolve in water and check.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Acid Test", instruction: "Add vinegar and observe.", icon: "vial.fill")
            ],
            normalIndicators: ["Dissolves completely", "Clear solution", "No fizzing"],
            abnormalIndicators: ["White residue", "Cloudy solution", "Fizzing with acid"]
        ),
        labTest: TestConfiguration(
            testName: "Purity Analysis",
            description: "Complete chemical purity testing.",
            steps: [
                ProtocolStepData(number: 1, title: "Solution Prep", instruction: "Sugar solution prepared.", icon: "vial.fill"),
                ProtocolStepData(number: 2, title: "Polarimetry", instruction: "Optical rotation measured.", icon: "lightbulb.fill")
            ],
            normalIndicators: ["Pure sucrose", "Standard polarization", "No adulterants"],
            abnormalIndicators: ["Chalk detected", "Abnormal rotation", "Impurities found"]
        )
    ),
    
    AppFoodItem(
        name: "Honey",
        category: .staples,
        imageName: "Honey",
        homeTest: TestConfiguration(
            testName: "Water Drop Test",
            description: "Detect sugar and corn syrup adulteration.",
            steps: [
                ProtocolStepData(number: 1, title: "Prepare Water", instruction: "Take cold water in glass.", icon: "drop.fill"),
                ProtocolStepData(number: 2, title: "Add Honey", instruction: "Add one drop of honey.", icon: "plus.circle.fill"),
                ProtocolStepData(number: 3, title: "Observe", instruction: "Watch if it dissolves or settles.", icon: "eye.fill")
            ],
            normalIndicators: ["Settles at bottom", "Doesn't dissolve", "Intact trail"],
            abnormalIndicators: ["Dissolves quickly", "Spreads immediately", "No trail"]
        ),
        labTest: TestConfiguration(
            testName: "NMR Spectroscopy",
            description: "Nuclear Magnetic Resonance for sugar fingerprinting.",
            steps: [
                ProtocolStepData(number: 1, title: "Sample Prep", instruction: "Honey sample placed in magnetic field.", icon: "magnet"),
                ProtocolStepData(number: 2, title: "Spectrum Analysis", instruction: "Sugar fingerprint analyzed.", icon: "waveform"),
                ProtocolStepData(number: 3, title: "Comparison", instruction: "Compared with authentic honey profile.", icon: "chart.bar.fill")
            ],
            normalIndicators: ["Natural honey spectrum", "Unique sugar profile", "No syrup markers"],
            abnormalIndicators: ["Corn syrup detected", "C3/C4 sugars abnormal", "Adulteration confirmed"]
        )
    ),
    
    AppFoodItem(
        name: "Mustard Oil",
        category: .staples,
        imageName: "MustardOil",
        homeTest: TestConfiguration(
            testName: "Chill Test",
            description: "Detect argemone oil adulteration.",
            steps: [
                ProtocolStepData(number: 1, title: "Refrigerate", instruction: "Keep oil bottle in refrigerator.", icon: "snowflake"),
                ProtocolStepData(number: 2, title: "Wait", instruction: "Wait for 1 hour.", icon: "clock.fill"),
                ProtocolStepData(number: 3, title: "Check", instruction: "Observe consistency.", icon: "eye.fill")
            ],
            normalIndicators: ["Becomes semi-solid", "Cloudy appearance", "Thick consistency"],
            abnormalIndicators: ["Remains liquid", "No change", "Serious adulteration concern"]
        ),
        labTest: TestConfiguration(
            testName: "HPLC Alkaloid Test",
            description: "High-Performance Liquid Chromatography for toxins.",
            steps: [
                ProtocolStepData(number: 1, title: "Injection", instruction: "Oil sample injected into HPLC.", icon: "arrow.right.circle.fill"),
                ProtocolStepData(number: 2, title: "Separation", instruction: "Compounds separated.", icon: "line.3.horizontal.decrease"),
                ProtocolStepData(number: 3, title: "Identification", instruction: "Toxic alkaloids identified.", icon: "exclamationmark.triangle.fill")
            ],
            normalIndicators: ["No argemone compounds", "Pure mustard oil", "No obvious concern"],
            abnormalIndicators: ["Argemone detected", "Toxic alkaloids present", "Dropsy risk confirmed"]
        )
    )
]
