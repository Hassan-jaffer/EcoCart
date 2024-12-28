struct History {
    let imageURL: String
    let pending: Bool
    let price: Int
    let productName: String?
    let storeName: String
    
    init(dictionary: [String: Any]) {
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.pending = dictionary["pending"] as? Bool ?? false
        self.price = dictionary["price"] as? Int ?? 0
        self.productName = dictionary["productName"] as? String ?? ""
        self.storeName = dictionary["storeName"] as? String ?? ""
    }
}
