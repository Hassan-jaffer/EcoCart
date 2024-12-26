//
//  HistoryTableViewCell.swift
//  WeSide
//
//  Created by iOSdev on 17/04/2023.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(request: Order) {
        
//        imageOutlet.clipsToBounds = false
//        imageOutlet.contentMode = .scaleAspectFill
//        imageOutlet.layer.masksToBounds = true
//        imageOutlet.layer.cornerRadius = imageOutlet.frame.height / 2
    //    Database.Storage.loadImage(view: serivceProviderImage, uuid: serviceProvider.image)
        
//        Database.Storage.loadImage(view: imageOutlet, uuid: request.image)
        
        nameOutlet.text = request.productName
       // price.text = request.requestType
    }

}
