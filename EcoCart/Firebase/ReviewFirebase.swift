//
//  ReviewFirebase.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 07/12/2024.
//

import Foundation
import FirebaseFirestore

enum ReviewError: Error {
    case invalidData
    case firestoreError(Error)
}

class ReviewFirebase {
    static let shared = ReviewFirebase()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchReviews(for productId: String) async throws -> [Review] {
        print("🔍 ReviewFirebase - Fetching reviews for productId: \(productId)")
        
        do {
            let snapshot = try await db.collection("review")
                .whereField("productID", isEqualTo: productId)
                .getDocuments()
            
            print("📄 Found \(snapshot.documents.count) review documents")
            
            return try snapshot.documents.compactMap { document in
                print("📝 Processing document: \(document.documentID)")
                let data = document.data()
                print("📝 Document data: \(data)")
                
                // Get rating value and ensure it's an Int
                let rating: Int
                if let ratingNumber = data["rating"] as? NSNumber {
                    rating = ratingNumber.intValue
                } else if let ratingInt = data["rating"] as? Int {
                    rating = ratingInt
                } else if let ratingString = data["rating"] as? String,
                          let parsedRating = Int(ratingString) {
                    rating = parsedRating
                } else {
                    print("⚠️ Invalid rating format in document: \(document.documentID)")
                    rating = 0
                }
                
                print("⭐️ Parsed rating: \(rating)")
                
                let review = Review(
                    id: document.documentID,
                    content: data["content"] as? String ?? "",
                    productId: data["productID"] as? String ?? "",
                    rating: rating,
                    userName: data["username"] as? String ?? "Anonymous"
                )
                print("✅ Successfully parsed review: \(review)")
                return review
            }
        } catch {
            print("❌ Error in fetchReviews: \(error)")
            throw ReviewError.firestoreError(error)
        }
    }
    
    func updateProductRatings(for productId: String) async throws {
        print("🔄 Updating product ratings for productId: \(productId)")
        
        do {
            // Fetch all reviews for the product
            let reviews = try await fetchReviews(for: productId)
            print("📊 Found \(reviews.count) reviews")
            print("📊 Individual ratings: \(reviews.map { $0.rating })")
            
            let totalRating = reviews.reduce(0) { $0 + $1.rating }
            print("📊 Total rating sum: \(totalRating)")
            
            let averageRating = reviews.isEmpty ? 0 : Int(round(Double(totalRating) / Double(reviews.count)))
            print("📊 Calculated average rating: \(averageRating)")
            
            // Update product document with new rating data
            try await db.collection("product").document(productId).updateData([
                "averageRating": averageRating,
                "numberOfRatings": reviews.count,
                "totalRatings": totalRating
            ])
            print("✅ Updated product ratings in Firestore:")
            print("  - Average: \(averageRating)")
            print("  - Count: \(reviews.count)")
            print("  - Total: \(totalRating)")
        } catch {
            print("❌ Error updating product ratings: \(error)")
            throw ReviewError.firestoreError(error)
        }
    }

    func addReview(_ review: Review) async throws {
        print("📝 Adding review for productId: \(review.productId)")
        print("⭐️ Rating value: \(review.rating) (type: \(type(of: review.rating)))")
        
        let data: [String: Any] = [
            "content": review.content,
            "productID": review.productId,
            "rating": Int(review.rating),
            "username": review.userName
        ]
        
        do {
            // Add the review
            let docRef = try await db.collection("review").addDocument(data: data)
            print("✅ Successfully added review with ID: \(docRef.documentID)")
            
            // Update product ratings using all reviews
            do {
                try await updateProductRatings(for: review.productId)
            } catch {
                print("❌ Error updating product ratings: \(error)")
                throw ReviewError.firestoreError(error)
            }
        } catch {
            print("❌ Error in addReview: \(error)")
            throw ReviewError.firestoreError(error)
        }
    }
}
