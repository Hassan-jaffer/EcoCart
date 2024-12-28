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
        
        guard let data = document.data() else {
            return nil
        }

        let metricsData = data["metrics"] as? [String: Any] ?? [:]
        
        var latitude: Double?
        var longitude: Double?

        if let locationData = data["location"] as? [String: Any] {
            if let lat = locationData["latitude"] as? Double {
                latitude = lat
            }
            if let long = locationData["longtitude"] as? Double {
                longitude = long
            }
        }

        let product = Product(
            id: document.documentID,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String ?? "",
            averageRating: data["averageRating"] as? Int ?? 0,
            numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
            totalRatings: data["totalRatings"] as? Int ?? 0,
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            category: data["category"] as? String ?? "",
            metrics: Product.Metrics(
                bio: metricsData["Bio"] as? Int ?? 0,
                co2: metricsData["C02"] as? Int ?? 0,
                plastic: metricsData["Plastic"] as? Int ?? 0,
                tree: metricsData["Tree"] as? Int ?? 0
            ),
            latitude: latitude,
            longitude: longitude,
            storeName: data["storeName"] as? String
        )

        return product
    }

    func fetchAllProducts() async throws -> [Product] {
        let snapshot = try await db.collection("product").getDocuments()
        return try await parseProducts(from: snapshot.documents)
    }

    func fetchProductsByCategory(_ category: String) async throws -> [Product] {
        let snapshot = try await db.collection("product")
            .whereField("category", isEqualTo: category)
            .getDocuments()
        return try await parseProducts(from: snapshot.documents)
    }
    
    private func parseProducts(from documents: [QueryDocumentSnapshot]) async throws -> [Product] {
        return documents.compactMap { document in
            let data = document.data()

            let metricsData = data["metrics"] as? [String: Any] ?? [:]

            var latitude: Double?
            var longitude: Double?

            if let locationData = data["location"] as? [String: Any] {
                if let lat = locationData["latitude"] as? Double {
                    latitude = lat
                }
                if let long = locationData["longtitude"] as? Double {
                    longitude = long
                }
            }

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
                category: data["category"] as? String ?? "",
                metrics: Product.Metrics(
                    bio: metricsData["Bio"] as? Int ?? 0,
                    co2: metricsData["C02"] as? Int ?? 0,
                    plastic: metricsData["Plastic"] as? Int ?? 0,
                    tree: metricsData["Tree"] as? Int ?? 0
                ),
                latitude: latitude,
                longitude: longitude,
                storeName: data["storeName"] as? String
            )
        }
    }

    func updateProduct(_ product: Product) async throws {
        let docRef = db.collection("product").document(product.id)

        var data: [String: Any] = [
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageURL": product.imageURL ?? "",
            "averageRating": product.averageRating,
            "numberOfRatings": product.numberOfRatings,
            "totalRatings": product.totalRatings,
            "stockQuantity": product.stockQuantity,
            "category": product.category ?? "",
            "metrics": [
                "Bio": product.metrics.bio,
                "C02": product.metrics.co2,
                "Plastic": product.metrics.plastic,
                "Tree": product.metrics.tree
            ],
            "storeName": product.storeName ?? ""
        ]

        if let latitude = product.latitude, let longitude = product.longitude {
            data["location"] = [
                "latitude": latitude,
                "longitude": longitude
            ]
        }

        try await docRef.setData(data, merge: true)
    }
}
