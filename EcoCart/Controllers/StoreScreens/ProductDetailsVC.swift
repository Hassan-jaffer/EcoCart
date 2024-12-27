//
//  ProductDetailsVC.swift
//  EcoCart
//
//  Created by ali on 27/12/2024.
//
import UIKit
import FirebaseFirestore
class ProductDetailsVC: UIViewController {
    
    var productDetails: ProductModel?
    
    @IBOutlet weak var productNameTextField: BlackBorderedTextField!
    
    @IBOutlet weak var productDescriptionTextField: BlackBorderedTextField!
    
    @IBOutlet weak var productCategoryTextField: BlackBorderedTextField!
    
    
    @IBOutlet weak var productQuantityTextField: BlackBorderedTextField!
    
    
    @IBOutlet weak var productPriceTextField: BlackBorderedTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productNameTextField.text = productDetails?.productName
        productDescriptionTextField.text = productDetails?.productDescription
        productCategoryTextField.text = productDetails?.productCategory
        productQuantityTextField.text = productDetails?.productQuantity
        productPriceTextField.text = productDetails?.productPrice
    }
    
    
    @IBAction func updateProductButtonPressed(_ sender: Any) {
        guard let productDetails = productDetails else {
             print("Product details not available.")
             return
         }
         
         // Get the updated values from the text fields
         let updatedName = productNameTextField.text ?? ""
         let updatedDescription = productDescriptionTextField.text ?? ""
         let updatedCategory = productCategoryTextField.text ?? ""
         let updatedQuantity = productQuantityTextField.text ?? ""
         let updatedPrice = productPriceTextField.text ?? ""
         
         // Check if any of the fields have changed
         if updatedName == productDetails.productName &&
             updatedDescription == productDetails.productDescription &&
             updatedCategory == productDetails.productCategory &&
             updatedQuantity == productDetails.productQuantity &&
             updatedPrice == productDetails.productPrice {
             
             // No changes detected
             print("No changes detected. No update required.")
             return
         }
         
         // Prepare the updated data dictionary
         var updatedData: [String: Any] = [:]
         
        if updatedName != productDetails.productName {
             updatedData["name"] = updatedName
         }
        if updatedDescription != productDetails.productDescription {
             updatedData["description"] = updatedDescription
         }
        if updatedCategory != productDetails.productCategory {
             updatedData["Category"] = updatedCategory
         }
        if updatedQuantity != productDetails.productQuantity {
             updatedData["stockQuantity"] = updatedQuantity
         }
        if updatedPrice != productDetails.productPrice {
             updatedData["price"] = updatedPrice
         }
         
         // Update the product document in Firebase Firestore
        let db = Firestore.firestore()
        print("The product id is \(productDetails.id)")
        let productId = productDetails.id
        if productId.isEmpty {
            print("Product ID not available.")
            return
        }
         
         db.collection("product").document(productId).updateData(updatedData) { error in
             if let error = error {
                 print("Error updating product: \(error.localizedDescription)")
             } else {
                 self.showAlert(message: "Product successfully updated.")
                 // Optionally, show a success message or navigate back
             }
         }
    }
    
}
