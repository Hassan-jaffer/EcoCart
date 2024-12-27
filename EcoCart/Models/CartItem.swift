import Foundation
struct CartItem {
    let productName: String
    var quantity: Int
    let price: Double
    let imageURL: String
    let productID: String
    
    var totalPrice: Double {
        return price * Double(quantity)
    }
}
