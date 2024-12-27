//
//  AddNewSotreVC.swift
//  EcoCart
//
//  Created by ali on 27/12/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddNewStoreVC: UIViewController {
    
    @IBOutlet weak var firstNameTextField: BlackBorderedTextField!
    
    @IBOutlet weak var lastNameTextField: BlackBorderedTextField!
    
    
    @IBOutlet weak var phoneNumberTextField: BlackBorderedTextField!
    
    
    @IBOutlet weak var emailTextField: BlackBorderedTextField!
    
    @IBOutlet weak var passwordTextField: BlackBorderedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    @IBAction func addNewStoreButtonPressed(_ sender: Any) {
        // Validate inputs
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let phone = phoneNumberTextField.text, !phone.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        // Create a new user in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else {
                self.showAlert(title: "Error", message: "Unable to create user.")
                return
            }
            
            // Add user data to Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "phone": phone,
                "email": email,
                "userType": "storemanager", // Default user type
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    self.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
                } else {
                    self.showAlert(title: "Success", message: "New store owner added successfully!") {
                        self.firstNameTextField.text = ""
                        self.lastNameTextField.text = ""
                        self.emailTextField.text = ""
                        self.phoneNumberTextField.text = ""
                        self.passwordTextField.text = ""
                    }
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
