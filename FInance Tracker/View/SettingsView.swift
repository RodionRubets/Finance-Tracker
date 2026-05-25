import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var nameInput = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var balanceInput = {
        let b = UserDefaults.standard.double(forKey: "initialBalance")
        return b == 0 ? "" : String(b)
    }()

    var isValid: Bool {
        !nameInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your name")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Enter name", text: $nameInput)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }

                    // Balance
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Initial balance (₴)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Enter amount", text: $balanceInput)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                    }

                    // Save
                    Button(action: save) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? Color.blue : Color.gray.opacity(0.4))
                            .cornerRadius(12)
                    }
                    .disabled(!isValid)
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let normalized = balanceInput.replacingOccurrences(of: ",", with: ".")
        let balance = Double(normalized) ?? 0

        UserDefaults.standard.set(trimmed, forKey: "userName")
        UserDefaults.standard.set(balance, forKey: "initialBalance")

        dismiss()
    }
}
