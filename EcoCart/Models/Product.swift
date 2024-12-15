import Foundation
import FirebaseFirestore

struct Product {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
    let averageRating: Int
    let numberOfRatings: Int
    let totalRatings: Int
    let stockQuantity: Int
    let metrics: Metrics
    
    struct Metrics {
        let bio: Int
        let co2: Int
        let plastic: Int
        let tree: Int
    }

    static func fetchProduct(withId id: String) async throws -> Product? {
        let db = Firestore.firestore()
        let docRef = db.collection("product").document(id)
        let document = try await docRef.getDocument()
        
        guard let data = document.data() else { return nil }
        
        // Get the metrics map from Firestore
        let metricsData = data["metrics"] as? [String: Any] ?? [:]
        
        print(" Raw Firestore metrics data:", metricsData)
        print(" CO2 value from metrics:", metricsData["CO2"] ?? "nil")

        return Product(
            id: document.documentID,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String,
            averageRating: data["averageRating"] as? Int ?? 0,
            numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
            totalRatings: data["totalRatings"] as? Int ?? 0,
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            metrics: Metrics(
                bio: (metricsData["Bio"] as? Bool ?? false) ? 1 : 0,
                co2: metricsData["CO2"] as? Int ?? 0,
                plastic: metricsData["Plastic"] as? Int ?? 0,
                tree: metricsData["Tree"] as? Int ?? 0
            )
        )
    }
    
    static func fetchTopRatedEcoProducts(limit: Int = 3) async throws -> [Product] {
        let db = Firestore.firestore()
        
        // Query products sorted by average rating
        let snapshot = try await db.collection("product")
            .order(by: "averageRating", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.map { document in
            let data = document.data()
            return Product(
                id: document.documentID,
                name: data["name"] as? String ?? "",
                description: data["description"] as? String ?? "",
                price: data["price"] as? Double ?? 0.0,
                imageURL: data["imageURL"] as? String,
                averageRating: data["averageRating"] as? Int ?? 0,
                numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
                totalRatings: data["totalRatings"] as? Int ?? 0,
                stockQuantity: data["stockQuantity"] as? Int ?? 0,
                metrics: Metrics(
                    bio: data["Bio"] as? Int ?? 0,
                    co2: data["CO2"] as? Int ?? 0,
                    plastic: data["Plastic"] as? Int ?? 0,
                    tree: data["Tree"] as? Int ?? 0
                )
            )
        }
    }
}
