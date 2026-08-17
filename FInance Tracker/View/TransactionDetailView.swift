import SwiftUI
import CoreData

struct TransactionDetailView: View {

    var transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context

    private let categories = Categories()
    @State private var showDeleteAlert = false

    var body: some View {
        let category = transaction.category ?? "Other"
        let icon = categories.categoryIcons[category] ?? "questionmark"
        let isIncome = transaction.type == "income"

        ZStack(alignment: .bottom) {

            Color(red: 0.07, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                VStack(spacing: 5) {
                    infoRow(icon: "calendar", label: String(localized: "date")) {
                        if let date = transaction.date {
                            Text(date.formatted(date: .long, time: .shortened))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }

                    infoRow(icon: "tag", label: String(localized: "type")) {
                        Text(isIncome ? String(localized: "income") : String(localized: "expense"))
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(isIncome ? Color.green.opacity(0.15) : Color.red.opacity(0.1))
                            .foregroundColor(isIncome ? .green : Color(red: 0.64, green: 0.18, blue: 0.18))
                            .clipShape(Capsule())
                    }

                    infoRow(icon: "dollarsign.circle", label: String(localized: "currency")) {
                        Text("\(transaction.currency ?? "₴") USD")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                    }

                    if let note = transaction.note, !note.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "note"))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Text(note)
                                .font(.system(size: 13))
                                .foregroundColor(.primary)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }

                    Spacer()

                    Button {
                        showDeleteAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                            Text(String(localized: "delete_transaction"))
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .padding(.top, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
            }
            .frame(height: UIScreen.main.bounds.height * 0.58)
        }

        .overlay(alignment: .top) {
            VStack(spacing: 12) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.bottom, 8)

                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    Text(category)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.white.opacity(0.1))
                .clipShape(Capsule())

                Text("\(isIncome ? "+" : "−") \(transaction.currency ?? "₴") \(transaction.amount, specifier: "%.2f")")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(isIncome ? .green : Color(red: 0.94, green: 0.6, blue: 0.6))

                Text(transaction.title ?? "No title")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
        .ignoresSafeArea()
        .alert("Delete this transaction?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                context.delete(transaction)
                try? context.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    @ViewBuilder
    private func infoRow<Content: View>(icon: String, label: String, @ViewBuilder value: () -> Content) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            value()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator))
                .padding(.horizontal, 20),
            alignment: .bottom
        )
    }
}

// MARK: - Helper Shape
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
