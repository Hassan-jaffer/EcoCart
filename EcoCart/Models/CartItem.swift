import Foundation

struct CartItem {
    let productID: String
    let productName: String
    let imageURL: String
    let price: Double
    var quantity: Int
    let stockQuantity: Int
    
    var totalPrice: Double {
        return price * Double(quantity)
    }
    
    init(productID: String, productName: String, imageURL: String, price: Double, quantity: Int, stockQuantity: Int) {
        self.productID = productID
        self.productName = productName
        self.imageURL = imageURL
        self.price = price
        self.quantity = quantity
        self.stockQuantity = stockQuantity
    }
}
