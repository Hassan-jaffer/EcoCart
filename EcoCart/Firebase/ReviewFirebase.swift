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
                print("📝 Document data: \(document.data())")
                
                let rating: Int
                if let ratingString = document.get("rating") as? String {
                    rating = Int(ratingString) ?? 0
                } else {
                    rating = document.get("rating") as? Int ?? 0
                }
                
                let review = Review(
                    id: document.documentID,
                    content: document.get("content") as? String ?? "",
                    productId: document.get("productID") as? String ?? "",
                    rating: rating,
                    userName: document.get("username") as? String ?? "Anonymous"
                )
                print("✅ Successfully parsed review: \(review)")
                return review
            }
        } catch {
            print("❌ Error in fetchReviews: \(error)")
            throw ReviewError.firestoreError(error)
        }
    }
    
    func addReview(_ review: Review) async throws {
        print("📝 Adding review for productId: \(review.productId)")
        
        let data: [String: Any] = [
            "content": review.content,
            "productID": review.productId,
            "rating": review.rating,
            "username": review.userName
        ]
        
        do {
            let docRef = try await db.collection("review").addDocument(data: data)
            print("✅ Successfully added review with ID: \(docRef.documentID)")
        } catch {
            print("❌ Error in addReview: \(error)")
            throw ReviewError.firestoreError(error)
        }
    }
}
