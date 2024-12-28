//
//  HistoryTableViewCell.swift
//  WeSide
//
//  Created by iOSdev on 17/04/2023.
//

import UIKit
class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(order: History) {
        nameOutlet.text = order.productName
        priceLabel.text = "\(order.price) BD"
        storeNameLabel.text = order.storeName
        
        if order.pending {
            statusLabel.text = "Status: Pending"
            statusLabel.textColor = .systemOrange
        } else {
            statusLabel.text = "Status: Completed"
            statusLabel.textColor = .systemGreen
        }
        
        if let url = URL(string: order.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Invalid image data")
                    return
                }
                
                DispatchQueue.main.async {
                    self.imageOutlet.image = image
                }
            }.resume()
        }
    }
}
