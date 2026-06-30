import Foundation

struct FoodItem: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let category: Category
    let imageName: String
    
    var homeTest: TestConfiguration?
    var labTest: TestConfiguration?
    
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
