import UIKit

class OrderCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!

    var updateButtonAction: (() -> Void)?
    var viewButtonAction: (() -> Void)?

    func configure(with order: Order) {
        productNameLabel.text = order.productName
        quantityLabel.text = "Quantity: \(order.quantity)"
        locationLabel.text = order.location
        timeLabel.text = order.time
        productImageView.image = UIImage(named: "placeholder") // Replace with actual image logic
    }

    @IBAction func updateButtonTapped(_ sender: UIButton) {
        updateButtonAction?()
    }

    @IBAction func viewButtonTapped(_ sender: UIButton) {
        viewButtonAction?()
    }
}
