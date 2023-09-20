//
//  QuoteManager.swift
//  ChuckNorrisQuotes
//
//  Created by Евгения Шевякова on 17.09.2023.
//

import Foundation
import RealmSwift

class QuotesManager {
    
    static let shared = QuotesManager()
    
    var quotes: [Quote] = []
    
    private init() {
        let config = Realm.Configuration(schemaVersion: 2)
        Realm.Configuration.defaultConfiguration = config
        
        self.quotes = fetchQuotes()
    }
    
    func downloadQuote(completion: ((_ textQuote: String?, _ errorText: String?) -> Void)?) {
        
        let url = URL(string: "https://api.chucknorris.io/jokes/random")!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if let error {
                completion?(nil, error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(nil, "Error when getting response")
                return
            }
            
            if !((200..<300).contains(httpResponse.statusCode)) {
                completion?(nil, "Error, status code = \(httpResponse.statusCode)")
                return
            }
            
            guard let data else {
                completion?(nil, "Error, data is nil")
                return
            }
            
            do {
                
                let quote = try JSONDecoder().decode(Quote.self, from: data)
                quote.downloadAt = Date()
                
                completion?(quote.value, nil)
                
                DispatchQueue.main.async {
                    self.addToRealm(quote: quote)
                }
                
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    private func fetchQuotes() -> [Quote] {
        let realm = try! Realm()
        return realm.objects(Quote.self).map{$0}.sorted(by: { $0.downloadAt > $1.downloadAt })
    }
    
    func addToRealm(quote: Quote) {
        let realm = try! Realm()

        try! realm.write({
            realm.add(quote)
        })
       
        quotes = fetchQuotes()
    }
    
    func fetchCategorizedQuotes(completion: ([String: [Quote]]) -> Void) {
        let realm = try! Realm()

        let quotes = realm.objects(Quote.self)
        
        let categorized = quotes.where {
            $0.categories.count > 0
        }
        
        print(categorized)
        
        var result = [String: [Quote]]()
        
        for q in categorized {
            guard q.categories.count > 0 else {
                continue
            }
            for c in q.categories {
                var tmpQuotes = result[c]
                if tmpQuotes == nil {
                    tmpQuotes = [Quote]()
                }
                tmpQuotes?.append(q)
                result[c] = tmpQuotes
            }
        }
        
        completion(result)
    }
    
    
    
}
