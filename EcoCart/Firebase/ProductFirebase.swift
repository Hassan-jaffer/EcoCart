//
//  ProductFirebase.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 05/12/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Firebase

class ProductFirebase {
    static let shared = ProductFirebase()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchProduct(withId id: String) async throws -> Product? {
        let docRef = db.collection("product").document(id)
        let document = try await docRef.getDocument()
        
        guard let data = document.data() else { return nil }
        
        return Product(
            id: document.documentID,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String ?? "",
            averageRating: data["averageRating"] as? Int ?? 0,
            numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
            totalRatings: data["totalRatings"] as? Int ?? 0,
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            metrics: Product.Metrics(
                bio: data["Bio"] as? Int ?? 0,
                co2: data["CO2"] as? Int ?? 0,
                plastic: data["Plastic"] as? Int ?? 0,
                tree: data["Tree"] as? Int ?? 0
            )
        )
    }
}
