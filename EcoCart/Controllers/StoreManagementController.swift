//
//  StoreManagementController.swift
//  EcoCart
//
//
import UIKit

class StoreManagementViewController: UIViewController {

    @IBOutlet weak var manageProductsButton: UIButton!
    @IBOutlet weak var manageOrdersButton: UIButton!
    @IBOutlet weak var manageOwnersButton: UIButton!
    @IBOutlet weak var deleteStoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
    }
    
    private func styleButtons() {
        // General Button Styling
        let buttons = [manageProductsButton, manageOrdersButton, manageOwnersButton]
        buttons.forEach { button in
            button?.layer.cornerRadius = 10
            button?.backgroundColor = UIColor.systemGray6
            button?.layer.shadowColor = UIColor.black.cgColor
            button?.layer.shadowOffset = CGSize(width: 0, height: 2)
            button?.layer.shadowOpacity = 0.2
            button?.layer.shadowRadius = 4
        }
        
        // Delete Button Styling
        deleteStoreButton.layer.cornerRadius = 10
        deleteStoreButton.backgroundColor = UIColor.systemRed
        deleteStoreButton.setTitleColor(.white, for: .normal)
    }
    
    // Example Navigation Actions
    @IBAction func manageProductsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toProductManagement", sender: nil)
    }

    @IBAction func deleteStoreTapped(_ sender: UIButton) {
        print("Store Deleted")
    }
}
