import SwiftUI
import CoreData

struct MainScreenViewModel {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ],
        animation: .default
    )
    
    private var transactions: FetchedResults<Transaction>
    
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
    
    func deleteTransaction(offsets: IndexSet,
                            transactions: FetchedResults<Transaction>,
                            context: NSManagedObjectContext) {
        
        for index in offsets {
            let transaction = transactions[index]
            context.delete(transaction)
        }
        
        try? context.save()
    }
    
    func groupedTransactions(_ transactions: [Transaction]) -> [(String, [Transaction])] {
        
        let grouped = Dictionary(grouping: transactions) { transaction -> String in
            
            guard let date = transaction.date else { return "Unknown" }
            
            if Calendar.current.isDateInToday(date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                return "Yesterday"
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


