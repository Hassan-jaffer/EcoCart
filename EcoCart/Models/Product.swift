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
    let category: String? // Added category field
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
        
        guard let data = document.data() else {
            print("Document data is nil.")
            return nil
        }

        // Get the metrics dictionary
        guard let metricsData = data["metrics"] as? [String: Any] else {
            print("No metrics data found")
            return nil
        }
        
        // Debug prints
        print("=== DEBUG INFO ===")
        print("Metrics data: \(metricsData)")
        
        // Convert metrics values
        let bioValue = metricsData["Bio"] as? Int ?? 0
        let c02Value = metricsData["C02"] as? Int ?? 0
        let plasticValue = metricsData["Plastic"] as? Int ?? 0
        let treeValue = metricsData["Tree"] as? Int ?? 0
        
        print("Converted metrics values:")
        print("Bio: \(bioValue)")
        print("C02: \(c02Value)")
        print("Plastic: \(plasticValue)")
        print("Tree: \(treeValue)")
        print("=================")
        
        // Print all keys in the data to check for Category
        print("Document data: \(data)") // Debugging: print all fields in the document
        
        // Check if the category exists
        let category = data["Category"] as? String
        print("Fetched product category: \(category ?? "No category")") // Debugging category
        
        // Debug print for C02 value
        print("C02 value from Firebase: \(data["C02"] ?? "nil")")
        
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
            category: category, // Add the category here
            metrics: Metrics(
                bio: bioValue,
                co2: c02Value,
                plastic: plasticValue,
                tree: treeValue
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
                category: data["Category"] as? String, 
                metrics: Metrics(
                    bio: (data["Bio"] as? Bool ?? false) ? 1 : 0,
                    co2: data["C02"] as? Int ?? 0,  // Changed from CO2 to C02
                    plastic: data["Plastic"] as? Int ?? 0,
                    tree: data["Tree"] as? Int ?? 0
                )
            )
        }
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
                let bioValue = metricsData["Bio"] as? Bool ?? false
                let co2Value = metricsData["C02"] as? Int ?? 0
                let plasticValue = metricsData["Plastic"] as? Int ?? 0
                let treeValue = metricsData["Tree"] as? Int ?? 0
                
                // Print the metrics values
                print("Bio: \(bioValue ? 1 : 0), CO2: \(co2Value), Plastic: \(plasticValue), Tree: \(treeValue)")
                
                // Calculate score
                let score = Double(co2Value + plasticValue + treeValue) / 3.0
                print("Calculated Score: \(score)")
                
                // Create and return the Product object
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
                        bio: bioValue ? 1 : 0,
                        co2: co2Value,
                        plastic: plasticValue,
                        tree: treeValue
                    )
                )
            } else {
                print("No metrics data found for document ID: \(document.documentID)")
                return nil // Return nil if metrics are missing
            }
        }
    }



        
    }




