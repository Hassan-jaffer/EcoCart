//
//  ProductXibTableView.swift
//  EcoCart
//
//  Created by ali on 27/12/2024.
//

import UIKit
import SDWebImage

protocol ProductXibTableViewDelegate: AnyObject {
    func deleteProduct(cell: ProductXibTableView)
}

class ProductXibTableView: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    
    @IBOutlet weak var productDescription: UILabel!
    
    weak var delegate: ProductXibTableViewDelegate?
    
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func deleteProductPressed(_ sender: Any) {
        delegate?.deleteProduct(cell: self)
    }
    
    func addCellDatawithProductData(productModel: ProductModel) {
        if let imageUrl = URL(string: productModel.productImage) {
            productImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "dummyEventImage"))
        }  else {
            productImage.image = UIImage(named: "dummyEventImage") // Fallback image
        }
        name.text = productModel.productName
        price.text = productModel.productPrice
        quantity.text = productModel.productQuantity
        productDescription.text = productModel.productDescription
        
        
    }
    
}
