import SwiftUI

struct Categories {
    let categoryOrder: [String] = [
        String(localized: "food"), String(localized: "transport"), String(localized: "shopping"), String(localized: "fun"),
        String(localized: "health"), String(localized: "gas"), String(localized: "salary"), String(localized: "money_transfer") , String(localized: "other")
    ]

    let categoryIcons: [String: String] = [
        String(localized: "food"): "fork.knife",
        String(localized: "transport"): "car.fill",
        String(localized: "shopping"): "bag.fill",
        String(localized: "fun"): "gamecontroller.fill",
        String(localized: "health"): "cross.fill",
        String(localized: "gas"): "fuelpump.fill",
        String(localized: "salary"): "banknote.fill",
        String(localized: "money_transfer"): "arrow.left.arrow.right",
        String(localized: "other"): "questionmark"
    ]

    let categoryColors: [String: Color] = [
        String(localized: "food"): .orange,
        String(localized: "transport"): .blue,
        String(localized: "shopping"): .purple,
        String(localized: "fun"): .pink,
        String(localized: "health"): .red,
        String(localized: "gas"): .yellow,
        String(localized: "salary"): .green,
        String(localized: "money_transfer"): .black,
        String(localized: "other"): .gray
    ]
}
