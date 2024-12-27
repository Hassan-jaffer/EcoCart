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
        print("🔍 Fetching product with ID: \(id)")
        let docRef = db.collection("product").document(id)
        let document = try await docRef.getDocument()
        
        guard let data = document.data() else {
            print("❌ No data found for product ID: \(id)")
            return nil
        }

        // Get metrics data
        let metricsData = data["metrics"] as? [String: Any] ?? [:]
        
        // Get location data from nested location object
        print("📍 Raw location data from Firebase:")
        var latitude: Double?
        var longitude: Double?

        if let locationData = data["location"] as? [String: Any] {
            print("   Found location object: \(locationData)")

            if let lat = locationData["latitude"] as? Double {
                latitude = lat
            }
            if let long = locationData["longtitude"] as? Double {  // Note the spelling in Firebase
                longitude = long
            }

            print("   Parsed location - lat: \(latitude ?? 0), long: \(longitude ?? 0)")
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

        print("🏷️ Created product: \(product.name)")
        print("   Final location: lat=\(product.latitude ?? 0), long=\(product.longitude ?? 0)")
        return product
    }

    func fetchAllProducts() async throws -> [Product] {
        print("📦 Fetching all products")
        let snapshot = try await db.collection("product").getDocuments()
        let products = try await parseProducts(from: snapshot.documents)
        print("✅ Fetched \(products.count) products")
        return products
    }

    func fetchProductsByCategory(_ category: String) async throws -> [Product] {
        print("🔍 Fetching products for category: \(category)")
        let snapshot = try await db.collection("product")
            .whereField("category", isEqualTo: category)
            .getDocuments()
        let products = try await parseProducts(from: snapshot.documents)
        print("✅ Fetched \(products.count) products for category \(category)")
        return products
    }
    
    private func parseProducts(from documents: [QueryDocumentSnapshot]) async throws -> [Product] {
        return documents.compactMap { document in
            let data = document.data()
            print("📄 Parsing product: \(document.documentID)")

            // Get metrics data
            let metricsData = data["metrics"] as? [String: Any] ?? [:]

            // Get location data from nested location object
            print("📍 Raw location data from Firebase:")
            var latitude: Double?
            var longitude: Double?

            if let locationData = data["location"] as? [String: Any] {
                print("   Found location object: \(locationData)")

                if let lat = locationData["latitude"] as? Double {
                    latitude = lat
                }
                if let long = locationData["longtitude"] as? Double {  // Note the spelling in Firebase
                    longitude = long
                }

                print("   Parsed location - lat: \(latitude ?? 0), long: \(longitude ?? 0)")
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

            print("🏷️ Created product: \(product.name)")
            print("   Final location: lat=\(product.latitude ?? 0), long=\(product.longitude ?? 0)")
            return product
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

        // Add location data directly at root level
        if let latitude = product.latitude, let longitude = product.longitude {
            data["location"] = [
                "latitude": latitude,
                "longitude": longitude
            ]
        }

        try await docRef.setData(data, merge: true)
    }
}
