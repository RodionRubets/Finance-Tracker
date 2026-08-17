import Foundation
import Combine

struct CurrencyRate: Codable {
    let currencyCodeA: Int
    let currencyCodeB: Int
    let date: Int64
    let rateBuy: Double?
    let rateSell: Double?
    let rateCross: Double?
}

struct DisplayRate {
    let code: String
    let name: String
    let flag: String
    let buy: Double
    let sell: Double
}

class CurrencyService: ObservableObject {
    @Published var rates: [DisplayRate] = []
    @Published var isLoading: Bool = false
    @Published var updatedAt: Date? = nil

    func fetchRates() {
        // Якщо дані є і свіжіші за 5 хвилин — не запитуємо
        if let updated = updatedAt, Date().timeIntervalSince(updated) < 300, !rates.isEmpty {
            print("✅ Using cached rates")
            return
        }

        guard let url = URL(string: "https://api.monobank.ua/bank/currency") else { return }
        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { DispatchQueue.main.async { self.isLoading = false } }

            if let error = error {
                print("❌ Network error:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            // Перевіряємо чи не помилка від API
            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
               let errCode = errorResponse["errCode"] {
                print("❌ API error:", errCode)
                DispatchQueue.main.async { self.isLoading = false }
                return
            }

            do {
                let raw = try JSONDecoder().decode([CurrencyRate].self, from: data)
                DispatchQueue.main.async {
                    let wanted: [(Int, String, String, String)] = [
                        (978, "EUR", "Euro", "🇪🇺"),
                        (826, "GBP", "British Pound", "🇬🇧"),
                        (985, "PLN", "Zloty", "🇵🇱")
                    ]
                    self.rates = wanted.compactMap { (code, abbr, name, flag) in
                        guard let r = raw.first(where: { $0.currencyCodeA == code && $0.currencyCodeB == 980 }) else { return nil }
                        return DisplayRate(
                            code: abbr,
                            name: name,
                            flag: flag,
                            buy: r.rateBuy ?? r.rateCross ?? 0,
                            sell: r.rateSell ?? r.rateCross ?? 0
                        )
                    }
                    self.updatedAt = Date()
                }
            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }
}
