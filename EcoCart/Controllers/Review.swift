//
//  Review.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 07/12/2024.
//

import Foundation
import FirebaseFirestore

struct Review: Codable {
    let id: String
    let content: String
    let productId: String
    let rating: Int
    let userName: String
    
    init(id: String = UUID().uuidString,
         content: String,
         productId: String,
         rating: Int,
         userName: String) {
        self.id = id
        self.content = content
        self.productId = productId
        self.rating = rating
        self.userName = userName
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case productId
        case rating
        case userName
    }
}
