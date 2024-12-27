//
//  StoresListXib.swift
//  EcoCart
//
//  Created by Huzaifa Abbasi on 26/12/2024.
//

import UIKit

protocol StoresListXibDelegate: AnyObject {
    func deleteStore(cell: StoresListXib)
}


class StoresListXib: UITableViewCell{
    
    weak var delegate: StoresListXibDelegate?

    @IBOutlet weak var firstName: UILabel!
    
    @IBOutlet weak var lastName: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var phoneNumber: UILabel!
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func deleteStoreButtonPressed(_ sender: Any) {
        delegate?.deleteStore(cell: self)
    }
    
    func addCellDatawithStoreData(storeModel: StoreModel) {
        firstName.text = storeModel.firstName
        lastName.text = storeModel.lastName
        email.text = storeModel.email
        phoneNumber.text = storeModel.PhoneNumber
    }
    
}
