import SwiftUI

struct Categories {
    let categoryOrder: [String] = [
        "Food", "Transport", "Shopping", "Fun",
        "Health", "Gas", "Salary", "Money Transfer", "Other"
    ]

    let categoryIcons: [String: String] = [
        "Food": "fork.knife",
        "Transport": "car.fill",
        "Shopping": "bag.fill",
        "Fun": "gamecontroller.fill",
        "Health": "cross.fill",
        "Gas": "fuelpump.fill",
        "Salary": "banknote.fill",
        "Money Transfer": "arrow.left.arrow.right",
        "Other": "questionmark"
    ]

    let categoryColors: [String: Color] = [
        "Food": .orange,
        "Transport": .blue,
        "Shopping": .purple,
        "Fun": .pink,
        "Health": .red,
        "Gas": .yellow,
        "Salary": .green,
        "Money Transfer": .black,
        "Other": .gray
    ]
}
