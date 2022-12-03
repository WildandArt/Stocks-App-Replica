//
//  FinancialMetricsResponse.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 02/12/2022.
//

import Foundation
struct FinancialMetricsResponse: Codable{
    let metric : Metrics
}
struct Metrics: Codable{
       let tenDayAverageTradingVolume : Float
       let annualWeekLow: Double
       let annualWeekHigh : Double
       let annualWeekLowDate: String
       let annualWeekPriceReturnDaily : Float
       let beta: Float
        enum CodingKeys: String, CodingKey  {
            case tenDayAverageTradingVolume = "10DayAverageTradingVolume"
            case annualWeekHigh = "52WeekHigh"
            case annualWeekLow = "52WeekLow"
            case annualWeekLowDate = "52WeekLowDate"
            case annualWeekPriceReturnDaily = "52WeekPriceReturnDaily"
            case beta
        }
}
