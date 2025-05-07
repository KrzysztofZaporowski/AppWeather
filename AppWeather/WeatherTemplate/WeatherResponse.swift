//
//  WeatherResponse.swift
//  AppWeather
//
//  Created by Krzysztof Zaporowski on 07/05/2025.
//

import Foundation

struct WeatherResponse: Decodable {
    let name: String
    let timezone: Int
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Decodable {
    let description: String
    let icon: String
}
