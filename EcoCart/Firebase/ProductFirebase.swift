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

struct Metric: Codable {
    let name: String
    let value: String
}

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let imageURL: String
    let stockQuantity: Int
    let storeOwnerId: String
    let averageRating: String
    let rating: Int
    let metrics: [Metric]
}

extension Product {
    static func fetchProduct(withId id: String) async throws -> Product? {
        let db = Firestore.firestore()
        let docRef = db.collection("product").document(id)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data() else { return nil }
        
        var metricsArray: [Metric] = []
        if let metrics = data["metrics"] as? [String: Any] {
            if let name = metrics["name"] as? String,
               let value = metrics["value"] as? String {
                metricsArray.append(Metric(name: name, value: value))
            }
        }
        
        return Product(
            id: snapshot.documentID,
            name: data["name"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            description: data["description"] as? String ?? "",
            imageURL: data["imageURL"] as? String ?? "",
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            storeOwnerId: data["storeOwnerID"] as? String ?? "",
            averageRating: data["averageRating"] as? String ?? "0",
            rating: data["rating"] as? Int ?? 0,
            metrics: metricsArray
        )
    }
}
