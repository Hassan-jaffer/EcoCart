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
        do {
            let snapshot = try await db.collection("review")
                .whereField("productID", isEqualTo: productId)
                .getDocuments()
            
            return try snapshot.documents.compactMap { document in
                let data = document.data()
                
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
                    rating = 0
                }
                
                return Review(
                    id: document.documentID,
                    content: data["content"] as? String ?? "",
                    productId: data["productID"] as? String ?? "",
                    rating: rating,
                    userName: data["username"] as? String ?? "Anonymous"
                )
            }
        } catch {
            throw ReviewError.firestoreError(error)
        }
    }
    
    func updateProductRatings(for productId: String) async throws {
        do {
            // Fetch all reviews for the product
            let reviews = try await fetchReviews(for: productId)
            
            let totalRating = reviews.reduce(0) { $0 + $1.rating }
            let averageRating = reviews.isEmpty ? 0 : Int(round(Double(totalRating) / Double(reviews.count)))
            
            // Update product document with new rating data
            try await db.collection("product").document(productId).updateData([
                "averageRating": averageRating,
                "numberOfRatings": reviews.count,
                "totalRatings": totalRating
            ])
        } catch {
            throw ReviewError.firestoreError(error)
        }
    }

    func addReview(_ review: Review) async throws {
        let data: [String: Any] = [
            "content": review.content,
            "productID": review.productId,
            "rating": Int(review.rating),
            "username": review.userName
        ]
        
        do {
            // Add the review
            _ = try await db.collection("review").addDocument(data: data)
            
            // Update product ratings using all reviews
            try await updateProductRatings(for: review.productId)
        } catch {
            throw ReviewError.firestoreError(error)
        }
    }
}
