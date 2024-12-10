import Foundation
import FirebaseFirestore

struct Product {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
    let averageRating: Int
    let stockQuantity: Int
    let metrics: [Metric]
    
    struct Metric {
        let name: String
        let value: String
    }

    static func fetchProduct(withId id: String) async throws -> Product? {
        let db = Firestore.firestore()
        let docRef = db.collection("product").document(id)
        let document = try await docRef.getDocument()
        
        guard let data = document.data() else { return nil }

        // Handle empty or missing fields safely
        return Product(
            id: document.documentID,
            name: data["name"] as? String ?? "No Name",
            description: data["description"] as? String ?? "No Description",
            price: data["price"] as? Double ?? 0.0,
            imageURL: data["imageURL"] as? String, // Keep as optional
            averageRating: data["averageRating"] as? Int ?? 0,
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            metrics: parseMetrics(from: data)
        )
    }

    static func parseMetrics(from data: [String: Any]) -> [Metric] {
        guard let metricsData = data["metrics"] as? [[String: Any]] else { return [] }
        return metricsData.map { metricData in
            Metric(
                name: metricData["name"] as? String ?? "Unknown",
                value: metricData["value"] as? String ?? "Unknown"
            )
        }
    }
}
