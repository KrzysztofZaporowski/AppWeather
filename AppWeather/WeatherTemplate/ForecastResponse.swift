//
//  ForecastResponse.swift
//  AppWeather
//
//  Created by Krzysztof Zaporowski on 07/05/2025.
//

import Foundation

struct ForecastResponse: Decodable {
    let list: [Forecast]
}

struct Forecast: Decodable {
    let dt: Int
    let main: Main
    let weather: [Weather]
}

