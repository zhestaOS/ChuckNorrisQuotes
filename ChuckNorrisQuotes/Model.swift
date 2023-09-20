//
//  Model.swift
//  ChuckNorrisQuotes
//
//  Created by Евгения Шевякова on 17.09.2023.
//

import Foundation
import RealmSwift

class Quote: Object, Decodable {
    @Persisted var categories: List<String>
    @Persisted var createdAt: String
    @Persisted var value: String
    @Persisted var downloadAt: Date
    

    enum CodingKeys: String, CodingKey {
        case categories
        case createdAt = "created_at"
        case value
    }
}
