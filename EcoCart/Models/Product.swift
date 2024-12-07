//
//  Product.swift
//  EcoCart
//
//  Created by Hasan Shehab on 01/12/2024.
//

import Foundation
import FirebaseFirestore

struct Product: Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String
    let averageRating: Int
    let stockQuantity: Int
    let metrics: [Metric]
    
    struct Metric: Codable {
        let name: String
        let value: String
    }
    
    static func fetchProduct(withId id: String) async throws -> Product? {
        let db = Firestore.firestore()
        let docRef = db.collection("product").document(id)
        let document = try await docRef.getDocument()
        
        guard let data = document.data() else { return nil }
        
        // Create product with document ID as the product ID
        return Product(
            id: document.documentID, // Use Firestore document ID
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String ?? "",
            averageRating: data["averageRating"] as? Int ?? 0,
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            metrics: parseMetrics(from: data)
        )
    }
    
    private static func parseMetrics(from data: [String: Any]) -> [Metric] {
        guard let metricsData = data["metrics"] as? [[String: Any]] else { return [] }
        return metricsData.map { metricData in
            Metric(
                name: metricData["name"] as? String ?? "",
                value: metricData["value"] as? String ?? ""
            )
        }
    }
}
