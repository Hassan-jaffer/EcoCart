import UIKit

class CartItemCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!

    var stepperAction: ((Int) -> Void)?

    func configure(with cartItem: CartItem) {
        productNameLabel.text = cartItem.productName
        locationLabel.text = cartItem.location
        priceLabel.text = "\(cartItem.price) BD"
        quantityLabel.text = "\(cartItem.quantity)"
        quantityStepper.value = Double(cartItem.quantity)
    }

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let newQuantity = Int(sender.value)
        quantityLabel.text = "\(newQuantity)"
        stepperAction?(newQuantity)
    }
}
