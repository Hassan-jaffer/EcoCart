//
//  AddNewProductVC.swift
//  EcoCart
//
//  Created by ali on 27/12/2024.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth
class AddNewProductVC: UIViewController {
    
    
    @IBOutlet weak var productNameTextField: BlackBorderedTextField!
    
    @IBOutlet weak var productDescriptionTextField: BlackBorderedTextField!
    
    @IBOutlet weak var productCategoryTextField: BlackBorderedTextField!
    
    
    @IBOutlet weak var productStockTextField: BlackBorderedTextField!
    
    @IBOutlet weak var productPriceTextField: BlackBorderedTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func addProductButtonPressed(_ sender: Any) {
        // Validate inputs
        guard let productName = productNameTextField.text, !productName.isEmpty,
              let productDescription = productDescriptionTextField.text, !productDescription.isEmpty,
              let productCategory = productCategoryTextField.text, !productCategory.isEmpty,
              let productStock = productStockTextField.text, let stockQuantity = Int(productStock),
              let productPrice = productPriceTextField.text, let price = Double(productPrice) else {
            showAlert(title: "Error", message: "Please fill in all fields correctly.")
            return
        }
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: User is not logged in or email is unavailable")
            return
        }
        // Prepare Firestore data
        let db = Firestore.firestore()
        let productData: [String: Any] = [
            "name": productName,
            "description": productDescription,
            "Category": productCategory,
            "stockQuantity": Double(stockQuantity),
            "price": Double(price),
            "averageRating": 0, // Default value
            "numberOfRatings": 0, // Default value
            "totalRatings": 0, // Default value
            "imageURL": "https://www.bosshunting.com.au/cdn-cgi/imagedelivery/izM8XxyLg9MD6py1ribxJw/www.bosshunting.com.au/2020/11/swatch-am51.jpg/w=1077,h=1200", // Empty by default
            "location": [ // Nested location structure
                "latitude": 26.2361,
                "longitude": 50.576
            ],
            "metrics": [ // Nested metrics structure
                "Bio": false,
                "CO2": 323,
                "Plastic": 2121,
                "Tree": 98
            ], // Default value
            "storeName": userEmail // Empty by default
        ]

        // Add product to Firestore
        db.collection("product").addDocument(data: productData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to add product: \(error.localizedDescription)")
            } else {
                self.showAlert(title: "Success", message: "Product added successfully!") {
                    self.productNameTextField.text = ""
                    
                    self.productDescriptionTextField.text = ""
                    
                    self.productCategoryTextField.text = ""
                    
                    
                    self.productStockTextField.text = ""
                    self.productPriceTextField.text = ""
                     // Navigate back
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
}
