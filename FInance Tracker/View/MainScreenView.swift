import SwiftUI
import CoreData

struct ContentView: View {

    let vm = MainScreenViewModel()
    
    @StateObject private var currencyService = CurrencyService()
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showAddView = false
    @State private var selectedTransaction: Transaction?
    @State private var filter: String = "all"
    @State private var name: String = "User"
    @State private var showAnalytics = false
    @State private var showSettings = false

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
                        Text("Hi, \(name)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .bold()
                        
                        Text("Your Finance")
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
                    
                    Text("Balance")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text("\(vm.totalBalance(transactions: Array(transactions)), specifier: "%.2f") ₴")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack {
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Income")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text("\(vm.totalIncome(transactions: Array(transactions)), specifier: "%.2f") ₴")
                                .foregroundColor(.white)
                                .font(.callout)
                                .bold()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("Expense")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text("\(vm.totalExpense(transactions: Array(transactions)), specifier: "%.2f") ₴")
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
                HStack(spacing: 10) {
                    currencyChip(code: "USD", rate: currencyService.usdRate, flag: "🇺🇸")
                    currencyChip(code: "EUR", rate: currencyService.eurRate, flag: "🇪🇺")

                    Spacer()

                    if currencyService.isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Button {
                            currencyService.fetchRates()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                .onAppear {
                    currencyService.fetchRates()
                }
                
                HStack(spacing: 8) {
                    filterChip("All", "all")
                    filterChip("Expense", "expense")
                    filterChip("Income", "income")
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
                AnalyticsView(transactions: Array(transactions))
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            
            .fullScreenCover(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .onAppear { loadUserName() }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                loadUserName()
            }
        }
    }
    
    private func currencyChip(code: String, rate: Double, flag: String) -> some View {
        HStack(spacing: 6) {
            Text(flag)
                .font(.system(size: 14))
            Text(code)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
            Text(rate > 0 ? "₴ \(rate, specifier: "%.2f")" : "—")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
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
