//
//  StoreDetailsVC.swift
//  EcoCart
//
//  Created by Huzaifa Abbasi on 26/12/2024.
//

import UIKit
import FirebaseFirestore

class StoreDetailsVC: UIViewController {
    var storeDetails: StoreModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeFirstName.text = storeDetails?.firstName
        storeLastName.text = storeDetails?.lastName
        storePhoneNumberTextField.text = storeDetails?.PhoneNumber
        storeEmail.text = storeDetails?.email
    }
    
    @IBOutlet weak var storeFirstName: BlackBorderedTextField!
    
    @IBOutlet weak var storeLastName: BlackBorderedTextField!
    
    
    @IBOutlet weak var storePhoneNumberTextField: BlackBorderedTextField!
    
    
    @IBOutlet weak var storeEmail: UILabel!
    
    
    @IBAction func editStoredButtonPressed(_ sender: Any) {
        guard let newStoreDetails = storeDetails else { return }

        let updatedFirstName = storeFirstName.text ?? ""
        let updatedLastName = storeLastName.text ?? ""
        let updatedPhoneNumber = storePhoneNumberTextField.text ?? ""

        // Check if any of the fields have changed
        let firstNameChanged = updatedFirstName != storeDetails?.firstName
        let lastNameChanged = updatedLastName != storeDetails?.lastName
        let phoneNumberChanged = updatedPhoneNumber != storeDetails?.PhoneNumber

        if firstNameChanged || lastNameChanged || phoneNumberChanged {
            // Prepare the updated data
            var updatedData: [String: Any] = [:]

            if firstNameChanged {
                updatedData["firstName"] = updatedFirstName
            }

            if lastNameChanged {
                updatedData["lastName"] = updatedLastName
            }

            if phoneNumberChanged {
                updatedData["phone"] = updatedPhoneNumber
            }

            // Update Firestore document
            Task {
                do {
                    let db = Firestore.firestore()
                    try await db.collection("users").document(storeDetails?.id ?? "").updateData(updatedData)

                    // Update the local newStoreDetails instance
                    if firstNameChanged {
                        storeDetails?.firstName = updatedFirstName
                    }
                    if lastNameChanged {
                        storeDetails?.lastName = updatedLastName
                    }
                    if phoneNumberChanged {
                        storeDetails?.PhoneNumber = updatedPhoneNumber
                    }

                    // Notify user of success
                    showAlert(title: "Success", message: "Store details updated successfully.")
                } catch {
                    // Handle errors
                    showAlert(title: "Error", message: "Failed to update store details: \(error.localizedDescription)")
                }
            }
        } else {
            // No changes detected
            showAlert(title: "No Changes", message: "No fields were changed.")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
