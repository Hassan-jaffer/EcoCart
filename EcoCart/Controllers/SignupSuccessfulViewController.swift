//
//  SignupSuccessfulViewController.swift
//  WeSide
//
//  Created by iOSdev on 28/03/2023.
//

import UIKit

class SignupSuccessfulViewController: UIViewController {

    @IBOutlet weak var continueButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        continueButtonOutlet.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ContinueButton(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
