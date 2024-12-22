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
        return try await ProductFirebase.shared.fetchAllProducts()
    }
}
