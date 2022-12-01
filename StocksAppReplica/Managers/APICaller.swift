//
//  APICaller.swift
//  StocksAppReplica
//
//  Created by Artemy Ozerski on 21/11/2022.
//

import Foundation
final class APICaller{

    static let shared = APICaller()

    var results = [String]()
    private init(){}

    private struct Constants{
        static let apiKey = "cdu8amqad3i5v3urh37gcdu8amqad3i5v3urh380"
        static let sandboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    public func marketData(
        for symbol : String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse, Error>)->Void
    ){
        let today = Date()
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        let url = url(for: .marketData,
                      queryParams: [
                        "symbol" : symbol,
                        "resolution" : "1",
                        "from" : "\(Int(prior.timeIntervalSince1970))",
                        "to" : "\(Int(today.timeIntervalSince1970))"
                      ])
        request(url: url,
                expecting: MarketDataResponse.self,
                completion: completion)
    }
    public func news(
        for type : TopStoriesVC.`Type`,
        completion: @escaping (Result<[NewsStory], Error>)->Void
    ){
        switch type{
        case .topStories:
            request(url: url(for: .topStories,
                             queryParams: ["category" : "general"]),
                    expecting: [NewsStory].self,
            completion: completion)
        case .company(let symbol):
            let today = Date()
            let oneWeekBack = today.addingTimeInterval(-(Constants.day * 7))
            request(
                url: url(
                    for: .companyNews,
                    queryParams: [
                        "symbol": symbol,
                        "from" : DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                        "to": DateFormatter.newsDateFormatter.string(from: today)
                    ]
                ),
                expecting: [NewsStory].self,
                completion: completion)
        }
    }
    private enum EndPoint: String{
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
    }

    private enum APIError: Error{
        case invalidURl
        case noDataReturned
    }

    public func search(query: String,
                       completion: @escaping (Result<SearchResponse,Error>)->Void
    ){
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        request(url: url(for: .search,
                         queryParams: ["q": safeQuery]),
                expecting: SearchResponse.self,
                completion: completion)
    }

    private func url(for endpoint: EndPoint,
                     queryParams: [String : String] = [:]
    )->URL?{
        var urlString = Constants.baseUrl + endpoint.rawValue
        var queryItems = [URLQueryItem]()
        for (name, value) in queryParams{
            queryItems.append(.init(name: name, value: value))
        }
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        let queryString = queryItems.map{
            "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        urlString += "?" + queryString
       // print(urlString)
        return URL(string: urlString)
    }
    private func request<T:Codable>(url: URL?,
                                    expecting: T.Type,
                                    completion: @escaping(Result<T, Error>)->Void){
        guard let url = url else{
            completion(.failure(APIError.invalidURl))
            return}

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else{
                if let error = error{
                    completion(.failure(error))
                }
                return
            }
            let jsonDecoder = JSONDecoder()
            do {
                let decoded = try jsonDecoder.decode(expecting, from: data)
                completion(.success(decoded))
            } catch  {
                completion(.failure(APIError.noDataReturned))
            }
        }
        task.resume()
    }
}
