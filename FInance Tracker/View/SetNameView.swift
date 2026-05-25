import SwiftUI

struct SetNameView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var nameInput = ""
    @State private var balanceInput = ""

    var isValid: Bool {
        !nameInput.trimmingCharacters(in: .whitespaces).isEmpty &&
        !balanceInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }

                VStack(spacing: 8) {
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Let's set up your finance tracker")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your name")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))

                        TextField("Example: John", text: $nameInput)
                            .padding()
                            .background(.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .tint(.white)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Current balance (₴)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))

                        TextField("Example: 10000", text: $balanceInput)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(.white.opacity(0.15))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .tint(.white)
                    }
                }
                .padding(.horizontal)

                Button(action: save) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.5)

                Spacer()
            }
        }
    }

    private func save() {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespaces)
        let normalized = balanceInput.replacingOccurrences(of: ",", with: ".")
        let balance = Double(normalized) ?? 0

        UserDefaults.standard.set(trimmedName, forKey: "userName")
        UserDefaults.standard.set(balance, forKey: "initialBalance")

        dismiss()
    }
}

#Preview {
    SetNameView()
}
