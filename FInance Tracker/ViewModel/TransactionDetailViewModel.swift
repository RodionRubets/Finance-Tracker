import SwiftUI
import CoreData

struct TransactionDetailViewModel {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ],
        animation: .default
    )
    
    private var transactions: FetchedResults<Transaction>
    
    func deleteTransaction(offsets: IndexSet,
                            transactions: FetchedResults<Transaction>,
                            context: NSManagedObjectContext) {
        
        for index in offsets {
            let transaction = transactions[index]
            context.delete(transaction)
        }
        
        try? context.save()
    }
}
