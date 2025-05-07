//
//  ContentView.swift
//  AppWeather
//
//  Created by Krzysztof Zaporowski on 07/05/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var weatherService = WeatherService()
    @AppStorage("savedCity") private var city: String = ""
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                TextField("City", text: $city, onCommit: {weatherService.fetchWeather(for: city)})
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                //MARK: Current weather
                if let weather = weatherService.weatherResponse {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(weather.name)
                        Text("Today")
                        if let icon = weather.weather.first?.icon {
                            Image(systemName: iconName(for: icon))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .symbolRenderingMode(.multicolor)
                        }
                        Text(weather.weather.first?.description.capitalized ?? "")
                        Text("\(Int(weather.main.temp))°C")
                    }
                }
                let offset = weatherService.forecastResponse?.city.timezone ?? 0
                //MARK: Hourly forecast
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(weatherService.nextFiveHours, id: \.dt) { forecast in
                            VStack {
                                Text(hourFormatter(forecast.dt, timezoneOffset: offset))
                                if let icon = forecast.weather.first?.icon {
                                    Image(systemName: iconName(for: icon))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .symbolRenderingMode(.multicolor)
                                }
                                Text("\(Int(forecast.main.temp))°C")
                            }
                        }
                    }
                }
                // MARK: Daily forecast (next 5 days, excluding today)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(weatherService.dailyForecasts.dropFirst().prefix(5)) { day in
                            VStack(spacing: 4) {
                                Text(shortPolishDayName(from: day.date))
                                    .font(.headline)
                                Image(systemName: iconName(for: day.icon))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .symbolRenderingMode(.multicolor)
                                Text("↑ \(Int(day.maxTemp))°C")
                                Text("↓ \(Int(day.minTemp))°C")
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
            .onAppear{
                weatherService.fetchWeather(for: city)
            }
        }
        .background(.blue)
    }
    
    func iconName(for iconCode: String) -> String {
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow.fill"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark"
        }
    }
    
    func hourFormatter(_ timestamp: Int, timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        let timezone = TimeZone(secondsFromGMT: timezoneOffset)
        formatter.timeZone = timezone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func shortPolishDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).capitalized
    }
}

#Preview {
    ContentView()
}
