//
//  ForgotPassViewController.swift
//  WeSide
//
//  Created by iOSdev on 30/03/2023.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPassViewController: UIViewController {

    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.layer.cornerRadius = 20
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        
        guard let emaill = email.text, !emaill.isEmpty  else {
            print("Missing field data")

            let alert = UIAlertController(title: "Missing field data", message: "Please fill in the required fields", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .cancel))

            self.present(alert, animated: true)

            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email.text!) {(error) in
            
            if error == nil {
                
                print("Check your Email")
                let alert = UIAlertController(title: "Check your Email", message: "Email has been sent to you!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                self.present(alert, animated: true)
                
                
                return
                
            } else {
                print("Invalid credentials!")
                let alert = UIAlertController(title: "Invalid credentials!", message: "Invalid credentials, please try again", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                self.present(alert, animated: true)
                return
            }
        }
        
        email.text?.removeAll()
    }
    


    

}
