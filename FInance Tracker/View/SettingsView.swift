import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    @State private var showSalarySettings = false
    @AppStorage("salaryDays") private var salaryDays: String = ""
    @State private var nameInput = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var balanceInput = {
        let b = UserDefaults.standard.double(forKey: "initialBalance")
        return b == 0 ? "" : String(b)
    }()
    @State private var showResetAlert = false

    var isValid: Bool {
        !nameInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var avatarLetter: String {
        String(nameInput.prefix(1)).uppercased()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Avatar
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.1, green: 0.37, blue: 0.65), Color(red: 0.64, green: 0.18, blue: 0.18)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)

                            Text(avatarLetter.isEmpty ? "?" : avatarLetter)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text(String(localized: "tap_save_to_update_your_profile"))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    // MARK: - Profile section
                    settingsSection(String(localized:"profile")) {
                        settingsRow(icon: "person.fill", color: .blue, label: String(localized: "name")) {
                            TextField("Your name", text: $nameInput)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }

                        settingsRow(icon: "wallet.pass.fill", color: .orange, label: String(localized: "initial_balance")) {
                            TextField("0", text: $balanceInput)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        

                    }
                    // MARK: - Finance section
                    settingsSection(String(localized: "finance_section")) {
                        Button {
                            showSalarySettings = true
                        } label: {
                            settingsRow(icon: "banknote.fill", color: .green, label: String(localized: "salary")) {
                                Text(salaryDays.isEmpty ? String(localized: "not_configured") : String(localized: "configured"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // MARK: - App section
                    settingsSection(String(localized: "app")) {
                        settingsRow(icon: "hryvniasign.circle.fill", color: .purple, label: String(localized: "currency")) {
                            Text("$ USD")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        
                        Button {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(settingsUrl)
                        } label: {
                            settingsRow(icon: "globe", color: .gray, label: String(localized: "language")) {
                                EmptyView()
                            }
                        }
                    }

                    // MARK: - Reset
                    Button {
                        showResetAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text(String(localized: "reset_all_data"))
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(Color(red: 0.64, green: 0.18, blue: 0.18))
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.red.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.red.opacity(0.2), lineWidth: 0.5)
                        )
                        .cornerRadius(14)
                    }

                    // MARK: - Version
                    Text("Finance Tracker v1.0")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 8)
                }
                .padding()
            }
            .navigationTitle(String(localized: "settings"))
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
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .alert("Reset all data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) { resetAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all transactions. This action cannot be undone.")
            }
            .sheet(isPresented: $showSalarySettings) {
                            SalarySettingsView()
                        }
        }
    }

    // MARK: - Components

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(14)
        }
    }

    private func settingsRow<Content: View>(icon: String, color: Color, label: String, @ViewBuilder trailing: () -> Content) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 30, height: 30)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer()

            trailing()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator))
                .padding(.leading, 56),
            alignment: .bottom
        )
    }
    
 

    // MARK: - Actions

    private func save() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let normalized = balanceInput.replacingOccurrences(of: ",", with: ".")
        let balance = Double(normalized) ?? 0

        UserDefaults.standard.set(trimmed, forKey: "userName")
        UserDefaults.standard.set(balance, forKey: "initialBalance")
        UserDefaults.standard.synchronize() 

        dismiss()
    }

    private func resetAllData() {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        if let transactions = try? context.fetch(request) {
            transactions.forEach { context.delete($0) }
        }
        try? context.save()
        dismiss()
    }
}
