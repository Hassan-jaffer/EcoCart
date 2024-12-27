//
//  AdminLogoutVC.swift
//  EcoCart
//
//  Created by Huzaifa Abbasi on 27/12/2024.
//

import UIKit
import FirebaseAuth
class AdminLogoutVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Are you sure you want to log out?",
            message: "",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.signOut()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "user_uid_key")
            
            let storyboard = UIStoryboard(name: "LogInPage", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "login") as? LogInTableViewController {
                let navigationController = UINavigationController(rootViewController: loginVC)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    
}
