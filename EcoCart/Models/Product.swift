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
    var stockQuantity: Int
    let category: String?
    let metrics: Metrics
    let latitude: Double?
    let longitude: Double?
    let storeName: String?

    struct Metrics {
        let bio: Int
        let co2: Int
        let plastic: Int
        let tree: Int
    }

    init(id: String, name: String, description: String, price: Double, imageURL: String?, averageRating: Int, numberOfRatings: Int, totalRatings: Int, stockQuantity: Int, category: String?, metrics: Metrics, latitude: Double?, longitude: Double?, storeName: String?) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.averageRating = averageRating
        self.numberOfRatings = numberOfRatings
        self.totalRatings = totalRatings
        self.stockQuantity = stockQuantity
        self.category = category
        self.metrics = metrics
        self.latitude = latitude
        self.longitude = longitude
        self.storeName = storeName
    }

    static func fetchProduct(withId id: String) async throws -> Product? {
        return try await ProductFirebase.shared.fetchProduct(withId: id)
    }

    static func fetchTopRatedEcoProducts(limit: Int = 3) async throws -> [Product] {
        let products = try await ProductFirebase.shared.fetchAllProducts()
        return Array(products.sorted { $0.averageRating > $1.averageRating }.prefix(limit))
    }

    static func fetchProductsForCategory(_ category: String) async throws -> [Product] {
        return try await ProductFirebase.shared.fetchProductsByCategory(category)
    }

    static func fetchAllProducts() async throws -> [Product] {
        let db = Firestore.firestore()
        
        // Fetch documents from the "product" collection
        let snapshot = try await db.collection("product").getDocuments()
        var products: [Product] = []

        for document in snapshot.documents {
            let data = document.data()

            // Extract metrics data
            guard let metricsData = data["metrics"] as? [String: Any] else {
                continue // Skip this product if metrics are missing
            }

            // Extract latitude and longitude
            let latitudeValue = data["latitude"] as? Double ?? 0.0
            let longitudeValue = data["longitude"] as? Double ?? 0.0

            // Extract and handle the category with a fallback if necessary
            let categoryValue = (data["Category"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Category"

            // Create and append product to the list
            let product = Product(
                id: document.documentID,
                name: data["name"] as? String ?? "Unknown",
                description: data["description"] as? String ?? "",
                price: data["price"] as? Double ?? 0.0,
                imageURL: data["imageURL"] as? String,
                averageRating: data["averageRating"] as? Int ?? 0,
                numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
                totalRatings: data["totalRatings"] as? Int ?? 0,
                stockQuantity: data["stockQuantity"] as? Int ?? 0,
                category: categoryValue,
                metrics: Metrics(
                    bio: metricsData["Bio"] as? Int ?? 0,
                    co2: metricsData["C02"] as? Int ?? 0,
                    plastic: metricsData["Plastic"] as? Int ?? 0,
                    tree: metricsData["Tree"] as? Int ?? 0
                ),
                latitude: latitudeValue,
                longitude: longitudeValue,
                storeName: data["storeName"] as? String ?? "Unknown"
            )

            products.append(product)
        }

        return products
    }
}
