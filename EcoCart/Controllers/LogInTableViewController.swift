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

            let userType = UserDefaults.standard.string(forKey: "user_type")
            
            if userType == nil {
                return
            }
            switch userType!.lowercased() {
            case "regular":
                UserDefaults.standard.set("regular", forKey: "user_type")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let regularVC = storyboard.instantiateViewController(withIdentifier: "main") as? MainTabBarController {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            if let window = windowScene.windows.first {
                                // Set the new root view controller
                                window.rootViewController = regularVC
                                window.makeKeyAndVisible()
                            }
                        }
                }
            case "admin":
                UserDefaults.standard.set("admin", forKey: "user_type")
                let storyboard = UIStoryboard(name: "AdminScreens", bundle: nil)
                if let adminHomeViewController = storyboard.instantiateViewController(withIdentifier: "AdminTabBarVC") as? UITabBarController {
                    self.navigationController?.setViewControllers([adminHomeViewController], animated: true)
                }
            case "storemanager":
                UserDefaults.standard.set("storemanager", forKey: "user_type")
                let storyboard = UIStoryboard(name: "StoreScreens", bundle: nil)
                if let adminHomeViewController = storyboard.instantiateViewController(withIdentifier: "StoreTabBarController") as? UITabBarController {
                    self.navigationController?.setViewControllers([adminHomeViewController], animated: true)
                }
            default:
                print("Invalid user type")
                self.showAlert(title: "Error", message: "Invalid user type")
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = storyboard.instantiateViewController(withIdentifier: "main") as? MainTabBarController {
                self.navigationController?.setViewControllers([mainVC], animated: false)

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
            
            // Check user type in Firestore
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { [weak self] document, error in
                guard let self = self else { return }
                
                if let document = document, document.exists,
                   let userType = document.data()?["userType"] as? String {
                    
                    
                    switch userType.lowercased() {
                    case "regular":
                        UserDefaults.standard.set("regular", forKey: "user_type")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let regularVC = storyboard.instantiateViewController(withIdentifier: "main") as? MainTabBarController {
                            // Replace the entire navigation stack
                            self.navigationController?.setViewControllers([regularVC], animated: true)
                        }
                    case "admin":
                        UserDefaults.standard.set("admin", forKey: "user_type")
                        
                        let storyboard = UIStoryboard(name: "AdminScreens", bundle: nil)
                        if let adminHomeViewController = storyboard.instantiateViewController(withIdentifier: "AdminTabBarVC") as? UITabBarController {
                            self.navigationController?.setViewControllers([adminHomeViewController], animated: true)
                        }
                        
                    case "storemanager":
                        UserDefaults.standard.set("storemanager", forKey: "user_type")
                        
                        let storyboard = UIStoryboard(name: "StoreScreens", bundle: nil)
                        if let adminHomeViewController = storyboard.instantiateViewController(withIdentifier: "StoreTabBarController") as? UITabBarController {
                            self.navigationController?.setViewControllers([adminHomeViewController], animated: true)
                        }
                    default:
                        print("Invalid user type")
                        self.showAlert(title: "Error", message: "Invalid user type")
                    }
                } else {
                    print("Could not find user or user type")
                    self.showAlert(title: "Error", message: "Could not find user type")
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
