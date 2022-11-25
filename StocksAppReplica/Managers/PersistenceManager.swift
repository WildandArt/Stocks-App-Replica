//
//  PersistenceManager.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import Foundation
final class PersistenceManager{
    static let shared = PersistenceManager()
    private let userDefaults = UserDefaults.standard
    private struct Constants {
        
    }
    private init(){}
    var watchList: [String]{
        return []
    }
    public func addToWatchList(){

    }
    public func removeFromWatchList(){

    }
}
