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
            Color(red: 0.04, green: 0.04, blue: 0.08)
                .ignoresSafeArea()

            // Blur кола на фоні
            GeometryReader { geo in
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: geo.size.width * 0.4, y: -80)

                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: -60, y: geo.size.height * 0.6)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // MARK: - Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.1, green: 0.37, blue: 0.65), Color(red: 0.64, green: 0.18, blue: 0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.blue.opacity(0.4), radius: 20, y: 8)

                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 24)

                // MARK: - Title
                VStack(spacing: 8) {
                    Text("Welcome 👋")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Your personal finance tracker.\nLet's get you set up in seconds.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.bottom, 40)

                // MARK: - Fields
                VStack(spacing: 16) {
                    fieldView(label: "YOUR NAME", placeholder: "Example: John", text: $nameInput, keyboard: .default)
                    fieldView(label: "CURRENT BALANCE ($)", placeholder: "Example: 1000", text: $balanceInput, keyboard: .decimalPad)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // MARK: - Button
                Button(action: save) {
                    Text("Get Started →")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            LinearGradient(
                                colors: isValid
                                    ? [Color(red: 0.1, green: 0.37, blue: 0.65), Color(red: 0.1, green: 0.5, blue: 0.83)]
                                    : [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: isValid ? Color.blue.opacity(0.4) : .clear, radius: 12, y: 6)
                }
                .disabled(!isValid)
                .padding(.horizontal, 24)

                Text("Your data stays on your device")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.top, 12)

                Spacer()
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private func fieldView(label: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .kerning(0.5)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .padding(14)
                .background(.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.12), lineWidth: 0.5)
                )
                .cornerRadius(14)
                .foregroundColor(.white)
                .tint(.white)
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
