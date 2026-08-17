import SwiftUI

struct SalarySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("salaryAmount") private var salaryAmount: Double = 0.0
    @AppStorage("salaryDays") private var salaryDays: String = ""

    @State private var amountInput: String = ""
    @State private var selectedDays: Set<Int> = []

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var isValid: Bool {
        !amountInput.trimmingCharacters(in: .whitespaces).isEmpty && !selectedDays.isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "salary_per_month"))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                        
                        TextField(String(localized: "salary_example_input"), text: $amountInput)
                            .keyboardType(.decimalPad)
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(14)
                        
                        Text(String(localized: "salary_every_month_notification"))
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                            .padding(.leading, 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "accrual_days"))
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                        
                        VStack {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(1...31, id: \.self) { day in
                                    let isSelected = selectedDays.contains(day)
                                    
                                    Button {
                                        if isSelected {
                                            selectedDays.remove(day)
                                        } else {
                                            selectedDays.insert(day)
                                        }
                                    } label: {
                                        Text("\(day)")
                                            .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                                            .foregroundColor(isSelected ? .white : .primary)
                                            .frame(height: 40)
                                            .frame(maxWidth: .infinity)
                                            .background(isSelected ? Color.green : Color.gray.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(14)
                        
                        Text(String(localized: "accrual_days_notification"))
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                            .padding(.leading, 4)
                    }
                }
                .padding()
            }
            .navigationTitle(String(localized: "salary"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "save")) { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .onAppear {
                amountInput = salaryAmount > 0 ? String(salaryAmount) : ""
                let daysArray = salaryDays
                    .split(separator: ",")
                    .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                selectedDays = Set(daysArray)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    private func save() {
        let normalized = amountInput.replacingOccurrences(of: ",", with: ".")
        salaryAmount = Double(normalized) ?? 0.0
        let sortedDays = selectedDays.sorted().map { String($0) }.joined(separator: ", ")
        salaryDays = sortedDays
        dismiss()
    }
}
