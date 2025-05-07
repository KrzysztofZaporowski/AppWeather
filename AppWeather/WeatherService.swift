//
//  WeatherService.swift
//  AppWeather
//
//  Created by Krzysztof Zaporowski on 07/05/2025.
//

import Foundation
import SwiftUI

class WeatherService: ObservableObject {
    @Published var forecastResponse: ForecastResponse?
    @Published var weatherResponse: WeatherResponse?
    @Published var errorMessage: String?
    let apiKey = "3dc7e50a5c984dc2a09f61e768170d52"
    
    func fetchWeather(for city: String) {
        let urlStringWeather = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(apiKey)"
        let urlStringForecast = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&units=metric&appid=\(apiKey)"
        errorMessage = nil
        guard let urlWeather = URL(string: urlStringWeather) else {
            self.errorMessage = "Nie udało się stworzyć URL"
            print("Invalid URL 1")
            return
        }
        
        URLSession.shared.dataTask(with: urlWeather) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Błąd sieci"
                }
                print("Error fetching data 1: \(error)")
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Błąd pobierania danych"
                }
                print("No data to decode 1")
                return
            }
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.weatherResponse = weatherResponse
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Błędna nazwa miasta"
                }
                print("Error decoding 1: \(error)")
            }
        }.resume()
        guard let urlForecast = URL(string: urlStringForecast) else {
            self.errorMessage = "Nie udało się stworzyć URL"
            print("Invalid URL 2")
            return
        }
        URLSession.shared.dataTask(with: urlForecast) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Błąd sieci"
                }
                print("Error fetching data 2: \(error)")
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Błąd pobierania danych"
                    
                }
                print( "No data to decode 2")
                return
            }
            do {
                let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                DispatchQueue.main.async {
                    self.forecastResponse = forecastResponse
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Błędna nazwa miasta"
                }
                print("Error decoding 2: \(error)")
            }
        }.resume()
    }
    // MARK: Procesed Forecast Data
    var todayForecast: [Forecast] {
        guard let list = forecastResponse?.list else {
            return []
        }
        let calendar = Calendar.current
        let today = Date()
        return list.filter {
            calendar.isDate(Date(timeIntervalSince1970: TimeInterval($0.dt)), inSameDayAs: today)
        }
    }
    struct DailyForecast: Identifiable {
        let id = UUID()
        let date: Date
        let minTemp: Double
        let maxTemp: Double
        let icon: String
    }
    var dailyForecasts: [DailyForecast] {
        guard let list = forecastResponse?.list else {
            return []
        }
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: list) { forecast -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            return calendar.startOfDay(for: date)
        }
        return grouped
            .sorted(by: { $0.key < $1.key})
            .map { (date, forecasts) in
                let temps = forecasts.map { $0.main.temp }
                
//                let sortedForecasts = forecasts.sorted(by: { $0.dt < $1.dt })
//                let icons = sortedForecasts.map { $0.weather.first?.icon ?? "01d" }
                
                let sortedForecasts = forecasts.sorted(by: { $0.dt < $1.dt })
                let icons = sortedForecasts.map { $0.weather.first?.icon ?? "01d" }

                let icon = icons
                    .reduce(into: [:]) { $0[$1, default: 0] += 1 }
                    .max(by: { $0.value < $1.value })?.key ?? "01d"

                return DailyForecast(
                    date: date,
                    minTemp: temps.min() ?? 0,
                    maxTemp: temps.max() ?? 0,
                    icon: icon
                )
            }
    }
    
    var nextFiveHours: [Forecast] {
        guard let list = forecastResponse?.list else { return [] }
        let now = Date()
        
        let nextHours = list.filter { forecast in
            let forecastDate = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            return forecastDate > now // Wybieramy prognozy po bieżącej godzinie
        }
        
        let nextTen = Array(nextHours.prefix(10))
        return nextTen
    }
}
