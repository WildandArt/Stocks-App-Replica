//
//  PersistenceManager.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//
//["AAPL, "MSFT"]
import Foundation
final class PersistenceManager{
    static let shared = PersistenceManager()
    private let userDefaults : UserDefaults = .standard

    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }

    private init(){}
    var watchList: [String]{
        if !hasOnboarded{
            userDefaults.setValue(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    public func watchListContains(symbol: String) -> Bool{
        return watchList.contains(symbol)
    }
    public func addToWatchList(symbol: String, companyName : String){
        var current = watchList
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlistKey)
        userDefaults.set(companyName, forKey: symbol)

        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    public func removeFromWatchList(symbol: String){
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)
        for item in watchList where item != symbol{
            newList.append(item)
        }
        print(symbol)
        print(newList)
        userDefaults.set(newList, forKey: Constants.watchlistKey)

    }
    private var hasOnboarded: Bool{
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    private func setUpDefaults(){
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Cooperation",
            "GOOG": "Alphabet",
            "AMZN": "Amamazon.com, Inc."
        ]
        let symbols = map.keys.map{$0}
        userDefaults.set(symbols, forKey: Constants.watchlistKey)

        for (symbol, name) in map{
            userDefaults.set(name, forKey: symbol)
        }
    }
}
