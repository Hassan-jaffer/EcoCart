//
//  LogInTableViewController.swift
//  WeSide
//
//  Created by iOSdev on 01/04/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LogInTableViewController: UITableViewController {
    
    @IBOutlet weak var userRegistrationButton: UIButton!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var viewUI: UIView!
    
    // Create Firestore reference
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if user is already logged in
        if let _ = UserDefaults.standard.string(forKey: "user_uid_key") {
            // User is logged in, navigate to ProfilePageTableViewController
            let storyboard = UIStoryboard(name: "ProfilePage", bundle: nil)
            if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfilePageTableViewController") as? ProfilePageTableViewController {
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
             setupUI()
         
    }
    
    private func setupUI() {
        viewUI.layer.cornerRadius = 40
        userRegistrationButton.layer.cornerRadius = 15.0
        usernameField.layer.cornerRadius = 20
        passwordField.layer.cornerRadius = 20
        LoginButton.layer.cornerRadius = 25.0
        if let _ = self.navigationController {
                // Set the navigation bar title
                self.title = "Login"
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        usernameField.text = String()
        passwordField.text = String()
    }
    
    func checkIfLoggedIn() {
        guard let uid = User.uid else { return }
        
        // Check regular users collection
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                if let userType = document.data()?["userType"] as? String, userType == "regular" {
                    print("is regular user")
                    self.performSegue(withIdentifier: "home", sender: self)
                    return
                }
            }
            
            // If not found in regular users, check service providers
            self.db.collection("serviceProviders").document(uid).getDocument { document, error in
                if let document = document, document.exists {
                    print("is service provider")
                    self.performSegue(withIdentifier: "serviceproviderhome", sender: self)
                }
            }
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        guard let username = usernameField.text, !username.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Missing field data", message: "Please fill in the required fields")
            return
        }


        FirebaseAuth.Auth.auth().signIn(withEmail: username, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                self.showAlert(title: "Invalid credentials!", message: "Invalid credentials, please try again")
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                print("Error fetching uid")
                return
            }
            
            UserDefaults.standard.set(uid, forKey: "user_uid_key")
            // User is logged in, navigate to ProfilePageTableViewController
            let storyboard = UIStoryboard(name: "ProfilePage", bundle: nil)
            if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfilePageTableViewController") as? ProfilePageTableViewController {
                self.navigationController?.pushViewController(profileVC, animated: true)
            }
        }
    }
    
    func loginSegue() {
        guard let uid = User.uid else { return }
        
        // First check regular users
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                self.performSegue(withIdentifier: "home", sender: self)
                return
            }
            
            // If not found in regular users, check service providers
            self.db.collection("serviceProviders").document(uid).getDocument { document, error in
                if let document = document, document.exists {
                    self.performSegue(withIdentifier: "serviceproviderhome", sender: self)
                } else {
                    print("could not find the user type")
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            performSegue(withIdentifier: "TabBar", sender: nil)
        }
    }
    
    @IBAction func eyeButtonTapped(_ sender: Any) {
        if eyeButton.isSelected == false {
            passwordField.isSecureTextEntry = false
            eyeButton.isSelected = true
        } else {
            passwordField.isSecureTextEntry = true
            eyeButton.isSelected = false
        }
    }
    
    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue) {}
}
