import SwiftUI
import CoreData

@main
struct FinanceTrackerApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showSetName = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    showSetName = !hasName()
                }
                .fullScreenCover(isPresented: $showSetName) {
                    SetNameView()
                }
        }
    }

    private func hasName() -> Bool {
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
