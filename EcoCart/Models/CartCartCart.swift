import Foundation
import FirebaseFirestore
import FirebaseAuth

class CartCartCart {
    static let shared = CartCartCart()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Add delegate property for table view updates
    weak var tableView: UITableView?
    private var cartItems: [CartItem] = []
    
    private init() {}
    
    // MARK: - Cart Operations
    
    func addToCart(name: String, imageURL: String, price: Double, productID: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        // First check if item already exists in cart
        db.collection("cart")
            .whereField("userID", isEqualTo: userID)
            .whereField("productID", isEqualTo: productID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(false, error)
                    return
                }
                
                if let existingDoc = snapshot?.documents.first {
                    // Update quantity of existing item
                    let currentQuantity = existingDoc.data()["quantity"] as? Int ?? 0
                    self.updateQuantity(documentID: existingDoc.documentID, quantity: currentQuantity + 1) { success in
                        completion(success, nil)
                    }
                } else {
                    // Add new item
                    let cartItem: [String: Any] = [
                        "name": name,
                        "imageURL": imageURL,
                        "price": price,
                        "quantity": 1,
                        "productID": productID,
                        "userID": userID,
                        "timestamp": FieldValue.serverTimestamp()
                    ]
                    
                    self.db.collection("cart").addDocument(data: cartItem) { error in
                        if let error = error {
                            print("Error adding to cart: \(error.localizedDescription)")
                            completion(false, error)
                        } else {
                            print("Successfully added to cart")
                            completion(true, nil)
                        }
                    }
                }
            }
    }
    
    func startListeningToCart(completion: @escaping ([CartItem]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        // Remove existing listener if any
        listener?.remove()
        
        listener = db.collection("cart")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else {
                    print("Error fetching cart items: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                self.cartItems = documents.map { CartItem(document: $0) }
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
                completion(self.cartItems)
            }
    }
    
    func stopListeningToCart() {
        listener?.remove()
        listener = nil
    }
    
    func updateQuantity(documentID: String, quantity: Int, completion: @escaping (Bool) -> Void) {
        guard quantity > 0 else {
            // If quantity is 0 or negative, remove the item
            removeFromCart(documentID: documentID, completion: completion)
            return
        }
        
        db.collection("cart").document(documentID).updateData([
            "quantity": quantity
        ]) { error in
            if let error = error {
                print("Error updating quantity: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func removeFromCart(documentID: String, completion: @escaping (Bool) -> Void) {
        db.collection("cart").document(documentID).delete { error in
            if let error = error {
                print("Error removing item: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func clearCart(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        db.collection("cart")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self,
                      let documents = snapshot?.documents else {
                    completion(false)
                    return
                }
                
                let batch = self.db.batch()
                documents.forEach { document in
                    batch.deleteDocument(document.reference)
                }
                
                batch.commit { error in
                    if let error = error {
                        print("Error clearing cart: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }
    
    func getCartTotal(completion: @escaping (Double) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(0.0)
            return
        }
        
        db.collection("cart")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion(0.0)
                    return
                }
                
                let total = documents.reduce(0.0) { result, document in
                    let quantity = document.data()["quantity"] as? Int ?? 0
                    let price = document.data()["price"] as? Double ?? 0.0
                    return result + (Double(quantity) * price)
                }
                
                completion(total)
            }
    }
}
