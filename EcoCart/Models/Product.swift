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
        
        // Fetch all products from Firestore
        let snapshot = try await db.collection("product").getDocuments()
        print("Fetched \(snapshot.documents.count) products.")

        return snapshot.documents.compactMap { document in
            let data = document.data()
            
            // Check if the metrics field exists and print it
            if let metricsData = data["metrics"] as? [String: Any] {
                print("Fetched Metrics Dictionary: \(metricsData)")
                
                // Extract metrics values
                let bioValue = metricsData["Bio"] as? Int ?? 0
                let co2Value = metricsData["C02"] as? Int ?? 0
                let plasticValue = metricsData["Plastic"] as? Int ?? 0
                let treeValue = metricsData["Tree"] as? Int ?? 0
                
                // Extract latitude, longitude, and store name with fallback default values
                let latitudeValue = data["latitude"] as? Double ?? 0.0
                let longitudeValue = data["longitude"] as? Double ?? 0.0
                let storeNameValue = data["storeName"] as? String ?? "Unknown"
                
                // Print the metrics values
                print("Bio: \(bioValue), CO2: \(co2Value), Plastic: \(plasticValue), Tree: \(treeValue)")
                
                // Calculate score (you may need to refine this logic)
                let score = Double(co2Value + plasticValue + treeValue) / 3.0
                print("Calculated Score: \(score)")
                
                // Return the Product object with all required parameters
                return Product(
                    id: document.documentID,
                    name: data["name"] as? String ?? "Unknown",
                    description: data["description"] as? String ?? "",
                    price: data["price"] as? Double ?? 0.0,
                    imageURL: data["imageURL"] as? String,
                    averageRating: data["averageRating"] as? Int ?? 0,
                    numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
                    totalRatings: data["totalRatings"] as? Int ?? 0,
                    stockQuantity: data["stockQuantity"] as? Int ?? 0,
                    category: data["Category"] as? String,
                    metrics: Metrics(
                        bio: bioValue,
                        co2: co2Value,
                        plastic: plasticValue,
                        tree: treeValue
                    ),
                    latitude: latitudeValue,
                    longitude: longitudeValue,
                    storeName: storeNameValue
                )
            } else {
                print("No metrics data found for document ID: \(document.documentID)")
                return nil // Return nil if metrics are missing
            }
        }
    }


}
