//
//  UserSIGNUPTableViewController.swift
//  WeSide
//
//  Created by iOSdev on 30/03/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserSIGNUPTableViewController: UITableViewController {
    
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    @IBOutlet weak var phoneNumberOutlet: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passwordLabel: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UITextField!
    @IBOutlet weak var userAccountLabel: UILabel!
    @IBOutlet weak var signUpButtonLabel: UIButton!
    
    // Create Firestore reference
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userAccountLabel.layer.cornerRadius = 20
        signUpButtonLabel.layer.cornerRadius = 20
    }
    
    @IBAction func signUpLabel(_ sender: UIButton) {
        guard let userFirstname = firstNameLabel.text, !userFirstname.isEmpty,
              let userLastName = lastNameLabel.text, !userLastName.isEmpty,
              let phone = phoneNumberOutlet.text, !phone.isEmpty,
              let email = emailLabel.text, !email.isEmpty,
              let password = passwordLabel.text, !password.isEmpty,
              let confPassword = confirmPasswordLabel.text, !confPassword.isEmpty else {
            
            let alert = UIAlertController(title: "Missing field data",
                                        message: "Please fill in all the fields",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
            return
        }
        
        // Verify passwords match
        guard password == confPassword else {
            let alert = UIAlertController(title: "Error",
                                        message: "Passwords do not match",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
            return
        }
        
        // Create user with Firebase Auth
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error",
                                            message: "Signup Failed: \(error.localizedDescription)",
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                print("Failed to get user UID")
                return
            }
            
            // Create user document in Firestore
            let userData: [String: Any] = [
                "email": email,
                "firstName": userFirstname,
                "lastName": userLastName,
                "phone": phone,
                "userType": "regular",
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            // Add user to Firestore
            self.db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "Error",
                                                message: "Failed to save user data",
                                                preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                    return
                }
                
                // Success alert
//                let alert = UIAlertController(title: "Success",
//                                            message: "Account Successfully created",
//                                            preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK",
//                                            style: .cancel,
//                                            handler: { _ in
//                    self.navigationController?.popToRootViewController(animated: true)
//                }))
//                self.present(alert, animated: true)
                // Navigate to the next page
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ShowSuccess", sender: self)
                }
            }
        }
    }
    
    @IBAction func eyeButtonTapped(_ sender: Any) {
        if eyeButton.isSelected == false {
            passwordLabel.isSecureTextEntry = false
            eyeButton.isSelected = true
        } else {
            passwordLabel.isSecureTextEntry = true
            eyeButton.isSelected = false
        }
    }
}
