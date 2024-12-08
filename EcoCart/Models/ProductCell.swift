import UIKit

class ProductCell: UICollectionViewCell {
    
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // Any additional setup after loading the view
        }
}
