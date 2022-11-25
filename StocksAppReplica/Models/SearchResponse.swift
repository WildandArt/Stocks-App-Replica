//
//  SearchResponse.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 22/11/2022.
//
// cdu8amqad3i5v3urh37gcdu8amqad3i5v3urh380
import Foundation
struct SearchResponse : Codable{
    let count : Int
    let result : [SearchResult]
}
struct SearchResult : Codable{
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
