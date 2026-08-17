import SwiftUI
import CoreData

struct AddExpenseView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var amount = ""
    @State private var title = ""
    @State private var note = ""
    @State private var category = String(localized: "food")
    @State private var currency = "$"
    @State private var type = "expense"

    private let categories = Categories()

    var isValid: Bool {
        !amount.trimmingCharacters(in: .whitespaces).isEmpty &&
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                VStack(spacing: 6) {
                    Text(String(localized: "amount"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.secondary)

                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .medium))
                            .multilineTextAlignment(.center)
                            .frame(minWidth: 80)
                            .fixedSize()
                            .onChange(of: amount) { newValue in
                                    filterAmount(newValue)
                                }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.separator)),
                    alignment: .bottom
                )

                ScrollView {
                    VStack(spacing: 20) {

                        HStack(spacing: 10) {
                            typeButton(String(localized: "expense"), "expense", .red)
                            typeButton(String(localized: "income"), "income", .green)
                        }
                        .padding(.top, 16)

                        fieldSection(String(localized: "name_transaction")) {
                            TextField(String(localized: "example: Lunch at café"), text: $title)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text(String(localized: "category"))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(categories.categoryOrder, id: \.self) { key in
                                        categoryChip(key)
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                        
                        fieldSection(String(localized: "note_optional")) {
                            TextField(String(localized: "add_details"), text: $note)
                                .padding(12)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }

                        Spacer(minLength: 16)
                    }
                    .padding(.horizontal)
                }

                Button(action: save) {
                    Text(String(localized: "add_transaction"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(isValid ? Color.blue : Color.gray.opacity(0.4))
                        .cornerRadius(14)
                }
                .disabled(!isValid)
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(.separator)),
                    alignment: .top
                )
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(String(localized: "new_transaction"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel")) { dismiss() }
                }
            }
        }
    }

    // MARK: - Components

    private func typeButton(_ label: String, _ value: String, _ color: Color) -> some View {
        let selected = type == value
        return Button {
            type = value
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selected ? color.opacity(0.15) : Color(.secondarySystemBackground))
                .foregroundColor(selected ? color : .secondary)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selected ? color.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
    }

    private func categoryChip(_ key: String) -> some View {
        let isSelected = category == key
        let icon = categories.categoryIcons[key] ?? "questionmark"
        let color = categories.categoryColors[key] ?? .gray

        return Button {
            category = key
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? color : .secondary)

                Text(key)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? color : .secondary)
            }
            .frame(width: 64, height: 64)
            .background(isSelected ? color.opacity(0.12) : Color(.secondarySystemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
    }
    
    private func filterAmount(_ newValue: String) {
        let normalized = newValue.replacingOccurrences(of: ",", with: ".")
        
        let filtered = normalized.filter { $0.isNumber || $0 == "." }
        
        let parts = filtered.components(separatedBy: ".")
        guard parts.count <= 2 else {
            amount = String(filtered.dropLast())
            return
        }
        
        let intPart = parts[0]
        if intPart.count > 9 {
            amount = String(filtered.dropLast())
            return
        }
        
        if parts.count == 2 {
            let decPart = parts[1]
            if decPart.count > 2 {
                amount = String(filtered.dropLast())
                return
            }
        }
        
        amount = filtered
    }

    @ViewBuilder
    private func fieldSection<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
    }

    // MARK: - Save

    private func save() {
        guard isValid else { return }

        let newItem = Transaction(context: context)
        let normalized = amount.replacingOccurrences(of: ",", with: ".")

        newItem.title = title
        newItem.amount = Double(normalized) ?? 0
        newItem.category = category.isEmpty ? "Other" : category
        newItem.currency = currency
        newItem.note = note
        newItem.type = type
        newItem.date = Date()

        try? context.save()
        dismiss()
    }
}

#Preview {
    AddExpenseView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
