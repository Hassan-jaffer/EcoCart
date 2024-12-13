import UIKit

class ProductCell: UITableViewCell {
    
    
    
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // Any additional setup after loading the view
        }
    
    func update(with product: Product) {
        productNameLabel.text = product.name
        priceLabel.text = String(product.price)
        productDescriptionLabel.text = product.description
    }
}
