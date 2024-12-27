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
        priceLabel.text = "BHD\(String(product.price))"
        productDescriptionLabel.text = product.description
        
        if let imageUrlString = product.imageURL, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        } else {
            productImageView.image = UIImage(named: "defaultImage")
        }
    }
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.productImageView.image = UIImage(named: "defaultImage")
                }
            } else if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.productImageView.image = image
                }
            }
        }.resume()
    }
}
