//
//  QuoteManager.swift
//  ChuckNorrisQuotes
//
//  Created by Евгения Шевякова on 17.09.2023.
//

import Foundation
import RealmSwift
import KeychainSwift

class QuotesManager {
    
    static let shared = QuotesManager()
    
    var quotes: [Quote] = []
    
    private var encryptionConfig: Realm.Configuration
    
    private init() {
        let config = Realm.Configuration(schemaVersion: 2)
        Realm.Configuration.defaultConfiguration = config
        
        let keychain = KeychainSwift()
        var key = keychain.getData("key")
        if key != nil {
            encryptionConfig = Realm.Configuration(encryptionKey: key)
        } else {
            key = Data(count: 64)
            _ = key?.withUnsafeMutableBytes({ pointer in
                SecRandomCopyBytes(kSecRandomDefault, 64, pointer.baseAddress!)
            })
            encryptionConfig = Realm.Configuration(encryptionKey: key)
            keychain.set(key!, forKey: "key")
        }
        
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
        let realm = try! Realm(configuration: encryptionConfig)
        return realm.objects(Quote.self).map{$0}.sorted(by: { $0.downloadAt > $1.downloadAt })
    }
    
    func updateQuotes() {
        quotes = fetchQuotes()
    }
    
    func addToRealm(quote: Quote) {
        let realm = try! Realm(configuration: encryptionConfig)

        try! realm.write({
            realm.add(quote)
        })
       
        quotes = fetchQuotes()
    }
    
    func fetchCategorizedQuotes(completion: ([String: [Quote]]) -> Void) {
        let realm = try! Realm(configuration: encryptionConfig)

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
