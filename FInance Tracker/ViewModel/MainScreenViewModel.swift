import SwiftUI
import CoreData
import Combine

class MainScreenViewModel: ObservableObject {

    func totalBalance(transactions: [Transaction]) -> Double {
        let initialBalance = UserDefaults.standard.double(forKey: "initialBalance")
        let transactionsBalance = transactions.reduce(0) { result, item in
            item.type == "income" ? result + item.amount : result - item.amount
        }
        return initialBalance + transactionsBalance
    }

    func totalIncome(transactions: [Transaction]) -> Double {
        transactions
            .filter { $0.type == "income" }
            .reduce(0) { $0 + $1.amount }
    }

    func totalExpense(transactions: [Transaction]) -> Double {
        transactions
            .filter { $0.type == "expense" }
            .reduce(0) { $0 + $1.amount }
    }

    func groupedTransactions(_ transactions: [Transaction]) -> [(String, [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction -> String in
            guard let date = transaction.date else { return "Unknown" }
            if Calendar.current.isDateInToday(date) {
                return String(localized: "today")
            } else if Calendar.current.isDateInYesterday(date) {
                return String(localized: "yesterday")
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return formatter.string(from: date)
            }
        }
        return grouped.sorted {
            ($0.value.first?.date ?? Date()) > ($1.value.first?.date ?? Date())
        }
    }
}
