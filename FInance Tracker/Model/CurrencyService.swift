import Foundation
import Combine

struct CurrencyRate: Codable {
    let currencyCodeA: Int
    let currencyCodeB: Int
    let date: Int
    let rateBuy: Double?
    let rateSell: Double?
    let rateCross: Double?
}

class CurrencyService: ObservableObject {
    @Published var usdRate: Double = 0
    @Published var eurRate: Double = 0
    @Published var isLoading: Bool = false

    func fetchRates() {
        guard let url = URL(string: "https://api.monobank.ua/bank/currency") else { return }
        isLoading = true

        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { DispatchQueue.main.async { self.isLoading = false } }

            guard let data = data, error == nil else { return }

            if let rates = try? JSONDecoder().decode([CurrencyRate].self, from: data) {
                DispatchQueue.main.async {
                    // USD = 840, EUR = 978, UAH = 980
                    if let usd = rates.first(where: { $0.currencyCodeA == 840 && $0.currencyCodeB == 980 }) {
                        self.usdRate = usd.rateBuy ?? usd.rateCross ?? 0
                    }
                    if let eur = rates.first(where: { $0.currencyCodeA == 978 && $0.currencyCodeB == 980 }) {
                        self.eurRate = eur.rateBuy ?? eur.rateCross ?? 0
                    }
                }
            }
        }.resume()
    }
}
