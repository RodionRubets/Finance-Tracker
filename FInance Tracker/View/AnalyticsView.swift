import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var currencyService: CurrencyService

    let transactions: [Transaction]
    private let categories = Categories()

    private var expenseByCategory: [(String, Double)] {
        let expenses = transactions.filter { $0.type == "expense" }
        var dict: [String: Double] = [:]
        for t in expenses {
            let cat = t.category ?? "Other"
            dict[cat, default: 0] += t.amount
        }
        return dict.sorted { $0.value > $1.value }
    }

    private var topCategories: [(String, Double)] {
        Array(expenseByCategory.prefix(3))
    }

    private var totalExpense: Double {
        transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
    }

    private var totalIncome: Double {
        transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Summary
                    HStack(spacing: 12) {
                        summaryCard(String(localized: "income"), amount: totalIncome, color: .green, icon: "arrow.down.circle.fill")
                        summaryCard(String(localized: "expense"), amount: totalExpense, color: .red, icon: "arrow.up.circle.fill")
                    }
                    .padding(.horizontal)

                    // MARK: - Currency rates
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(String(localized: "exchange_rates"))
                                .font(.headline)
                            Spacer()
                            if currencyService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Button {
                                    currencyService.fetchRates()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)

                        if currencyService.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)

                        } else if currencyService.rates.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "wifi.slash")
                                    .foregroundStyle(.secondary)
                                Text(String(localized: "failed_to_load_rates. tap _↻_to_retry."))
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)

                        } else {
                            VStack(spacing: 0) {
                                ForEach(currencyService.rates, id: \.code) { rate in
                                    HStack(spacing: 12) {
                                        Text(rate.flag)
                                            .font(.system(size: 22))
                                            .frame(width: 36, height: 36)
                                            .background(Color(.systemBackground))
                                            .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(rate.code)
                                                .font(.system(size: 14, weight: .medium))
                                            Text(rate.name)
                                                .font(.system(size: 11))
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("\(String(localized: "buy_₴")) \(rate.buy, specifier: "%.2f")")
                                                .font(.system(size: 13, weight: .medium))
                                            Text("\(String(localized: "sell_₴")) \(rate.sell, specifier: "%.2f")")
                                                .font(.system(size: 11))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)

                                    if rate.code != currencyService.rates.last?.code {
                                        Divider().padding(.leading, 64)
                                    }
                                }

                                if let updated = currencyService.updatedAt {
                                    Text("\(String(localized: "updated:")) \(updated.formatted(date: .omitted, time: .shortened)) · monobank")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.tertiary)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 8)
                                }
                            }
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - Pie chart
                    if !expenseByCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "expenses_by_category"))
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(expenseByCategory, id: \.0) { item in
                                SectorMark(
                                    angle: .value("Amount", item.1),
                                    innerRadius: .ratio(0.55),
                                    angularInset: 2
                                )
                                .foregroundStyle(categories.categoryColors[item.0] ?? .gray)
                                .cornerRadius(4)
                            }
                            .frame(height: 220)
                            .padding(.horizontal)

                            VStack(spacing: 8) {
                                ForEach(expenseByCategory, id: \.0) { item in
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(categories.categoryColors[item.0] ?? .gray)
                                            .frame(width: 10, height: 10)

                                        Text(item.0)
                                            .font(.system(size: 13))

                                        Spacer()

                                        Text("$ \(item.1, specifier: "%.2f")")
                                            .font(.system(size: 13, weight: .medium))

                                        let percent = totalExpense > 0 ? item.1 / totalExpense * 100 : 0
                                        Text("\(percent, specifier: "%.0f")%")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.secondary)
                                            .frame(width: 36, alignment: .trailing)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // MARK: - Top 3
                    if !topCategories.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "top_categories") )
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(Array(topCategories.enumerated()), id: \.1.0) { index, item in
                                HStack(spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .frame(width: 20)

                                    ZStack {
                                        Circle()
                                            .fill((categories.categoryColors[item.0] ?? .gray).opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: categories.categoryIcons[item.0] ?? "questionmark")
                                            .font(.system(size: 14))
                                            .foregroundColor(categories.categoryColors[item.0] ?? .gray)
                                    }

                                    Text(item.0)
                                        .font(.system(size: 14))

                                    Spacer()

                                    Text("$ \(item.1, specifier: "%.2f")")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal)

                                if index < topCategories.count - 1 {
                                    Divider().padding(.leading, 68)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    if expenseByCategory.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text(String(localized: "no_expenses"))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }

                    Spacer().frame(height: 16)
                }
                .padding(.top, 8)
            }
            .navigationTitle(String(localized: "analytics"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
            }
            .onAppear {
                currencyService.fetchRates()
            }
        }
    }

    private func summaryCard(_ title: String, amount: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("$ \(amount, specifier: "%.2f")")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .cornerRadius(14)
    }
}
