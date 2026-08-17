import SwiftUI
import CoreData
import Combine

struct ContentView: View {

    @StateObject private var vm = MainScreenViewModel()
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showAddView = false
    @State private var selectedTransaction: Transaction?
    @State private var filter: String = "all"
    @State private var name: String = "User"
    @State private var showAnalytics = false
    @State private var showSettings = false
    @StateObject private var currencyService = CurrencyService()



    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Transaction.date, ascending: false)
        ],
        animation: .default
    )
    private var transactions: FetchedResults<Transaction>
    
    private let categories = Categories()
    
    private var filteredTransactions: [Transaction] {
        switch filter {
        case "expense": return transactions.filter { $0.type == "expense" }
        case "income": return transactions.filter { $0.type == "income" }
        default: return Array(transactions)
        }
    }
    

    var body: some View {
        
        NavigationView {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                       //b Text("Hi, \(name)")
                        Text("\(String(localized: "hi")), \(name)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .bold()
                        
                        Text(String(localized: "your_finance"))
                            .font(.title)
                            .fontWeight(.bold)
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Button {
                            showAnalytics = true
                        } label: {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Circle())
                        }

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.top)
                
                //  CARD
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text(String(localized: "balance"))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text("\(vm.totalBalance(transactions: Array(transactions)), specifier: "%.2f") $")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(String(localized: "income"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text("\(vm.totalIncome(transactions: Array(transactions)), specifier: "%.2f") $")
                                .foregroundColor(.white)
                                .font(.callout)
                                .bold()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(String(localized: "expense"))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text("\(vm.totalExpense(transactions: Array(transactions)), specifier: "%.2f") $")
                                .foregroundColor(.white)
                                .font(.callout)
                                .bold()
                        }
                    }
                    .padding(.top, 6)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.blue, .red],
                        startPoint: .bottomLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .padding()
                
                // MARK: - Currency rates
                
                HStack(spacing: 8) {
                    filterChip(String(localized: "all"), "all")
                    filterChip(String(localized: "expense"), "expense")
                    filterChip(String(localized: "income"), "income")
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                
                ScrollView {
                    let grouped = vm.groupedTransactions(filteredTransactions)

                    VStack(alignment: .leading, spacing: 16) {

                        ForEach(grouped, id: \.0) { section in

                            Text(section.0)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)

                            VStack(spacing: 10) {
                                ForEach(section.1) { transaction in
                                    Button {
                                        selectedTransaction = transaction
                                    } label: {
                                        transactionRow(transaction)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showAddView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            .fullScreenCover(isPresented: $showAddView) {
                AddExpenseView()
            }
            
            .fullScreenCover(isPresented: $showAnalytics) {
                AnalyticsView(currencyService: currencyService, transactions: Array(transactions))
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            
            .fullScreenCover(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .onAppear {
                loadUserName()
                checkAndAccrueSalary()
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                loadUserName()
                vm.objectWillChange.send()
            }
        }
    }
    
    private func filterChip(_ label: String, _ value: String) -> some View {
        let selected = filter == value

        let bgColor: Color = {
            guard selected else { return Color(.secondarySystemBackground) }
            switch value {
            case "expense": return Color.red.opacity(0.12)
            case "income": return Color.green.opacity(0.12)
            default: return Color.blue.opacity(0.12)
            }
        }()

        let fgColor: Color = {
            guard selected else { return .secondary }
            switch value {
            case "expense": return Color(red: 0.64, green: 0.18, blue: 0.18)
            case "income": return Color(red: 0.23, green: 0.43, blue: 0.07)
            default: return .blue
            }
        }()

        let borderColor: Color = {
            guard selected else { return .clear }
            switch value {
            case "expense": return Color.red.opacity(0.25)
            case "income": return Color.green.opacity(0.25)
            default: return Color.blue.opacity(0.25)
            }
        }()

        return Button {
            filter = value
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(bgColor)
                .foregroundColor(fgColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        }
    }
    
    private func checkAndAccrueSalary() {
        let amount = UserDefaults.standard.double(forKey: "salaryAmount")
        let daysString = UserDefaults.standard.string(forKey: "salaryDays") ?? ""
        let lastAccrual = UserDefaults.standard.string(forKey: "lastSalaryAccrualDate") ?? ""

        guard amount > 0, !daysString.isEmpty else { return }

        let daysArray = daysString.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard !daysArray.isEmpty else { return }

        let todayDay = Calendar.current.component(.day, from: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())

        if daysArray.contains(todayDay) && lastAccrual != todayString {
            
            let fractionAmount = amount / Double(daysArray.count)
            
            let newTransaction = Transaction(context: context)
            newTransaction.title = String(localized: "salary")
            newTransaction.amount = fractionAmount
            newTransaction.category = String(localized: "salary")
            newTransaction.type = "income"
            newTransaction.date = Date()
            newTransaction.currency = transactions.first?.currency ?? "$"
            newTransaction.note = String(localized: "payroll_calculation")

            do {
                try context.save()
                UserDefaults.standard.set(todayString, forKey: "lastSalaryAccrualDate")
                print("ЗП успішно нараховано!")
            } catch {
                print("Помилка збереження ЗП: \(error)")
            }
        }
    }

    
    private func transactionRow(_ transaction: Transaction) -> some View {

        let icon = categories.categoryIcons[transaction.category ?? "Other"] ?? "questionmark"
        let color = categories.categoryColors[transaction.category ?? "Other"] ?? .gray

        return HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title ?? "No title")
                    .font(.headline)

                Text(transaction.category ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(transaction.amount, specifier: "%.2f") \(transaction.currency ?? "₴")")
                .foregroundColor(transaction.type == "income" ? .green : .red)
                .font(.headline)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
    
    private func loadUserName() {
        let stored = UserDefaults.standard.string(forKey: "userName") ?? ""
        name = stored.trimmingCharacters(in: .whitespaces).isEmpty ? "User" : stored
    }
    
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
