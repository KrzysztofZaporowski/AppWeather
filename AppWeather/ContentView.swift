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
    @State private var cityInput: String = ""
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(colors: isDarkMode ? [.blue, .cyan] : [.black, .gray], startPoint: .topTrailing, endPoint: .bottomTrailing)
                .ignoresSafeArea(.all)
            VStack (alignment: .center, spacing: 20){
                Text("Pogoda")
                    .font(.title)
                    .bold()
                Spacer()
                TextField("Wprowadź nazwę miasta", text: $cityInput, onCommit: {
                    city = cityInput
                    weatherService.fetchWeather(for: city)})
                    .padding()
                    .foregroundColor(Color.black)
                    .background(Color.white.opacity(0.65))
                    .cornerRadius(8)
                    .padding(.horizontal)
                if let error = weatherService.errorMessage {
                    Text("Błąd: \(error)")
                }
                //MARK: Current weather
                if let currentWeather = weatherService.weatherResponse {
                    VStack(alignment: .center, spacing: 10){
                        Text(currentWeather.name)
                            .font(.title2)
                            .bold()
                        Text("\(Int(currentWeather.main.temp))°C")
                            .font(.largeTitle)
                            .bold()
                        if let icon = currentWeather.weather.first?.icon {
                            Image(systemName: iconName(for: icon))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .symbolRenderingMode(.multicolor)
                        }
                        Text(currentWeather.weather.first?.description ?? "Brak opisu pogody")
                            .textCase(.uppercase)
                    }
                }
                //MARK: Hourly weather
                let offset = weatherService.forecastResponse?.city.timezone ?? 0
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(weatherService.nextFiveHours, id: \.dt) { forecast in
                            VStack {
                                Text(hourFormatter(forecast.dt, timezoneOffset: offset))
                                if let icon = forecast.weather.first?.icon {
                                    Image(systemName: iconName(for: icon))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .symbolRenderingMode(.multicolor)
                                }
                                Text("\(Int(forecast.main.temp))°C")
                            }
                            .frame(width: 60, height: 120)
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                //MARK: Weather for next 5 days
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(weatherService.dailyForecasts.dropFirst().prefix(5), id: \.date) { day in
                            VStack {
                                Text(shortPolishDayName(from: day.date))
                                Image(systemName: iconName(for: day.icon))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .symbolRenderingMode(.multicolor)
                                Text("↑ \(Int(day.maxTemp))°C")
                                Text("↓ \(Int(day.minTemp))°C")
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 60, height: 120)
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                    }
                    .padding(.horizontal)
                }
                Toggle(isOn: $isDarkMode) {
                    Text("Tryb ciemny")
                }
                .toggleStyle(SwitchToggleStyle(tint: .gray))
                .padding(.horizontal)
                .padding(.bottom)
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
            .onAppear {
                cityInput = city
                if !city.isEmpty {
                    weatherService.fetchWeather(for: city)
                }
                if UserDefaults.standard.object(forKey: "isDarkMode") == nil {
                    isDarkMode = (colorScheme == .dark)
                }
            }
        }
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
