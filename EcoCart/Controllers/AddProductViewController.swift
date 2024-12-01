//
//  AddProductViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 27/11/2024.
//

import UIKit
//import FirebaseFirestore
class AddProductViewController: UITableViewController {

    
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var categoryTxtFld: UITextField!
    @IBOutlet weak var storeTxtFld: UITextField!
    @IBOutlet weak var purchasedateDatePicker: UIDatePicker!
    @IBOutlet weak var priceTxtFld: UITextField!
    @IBOutlet weak var co2TxtFld: UITextField!
    @IBOutlet weak var plasticTxtFld: UITextField!
    @IBOutlet weak var treeTxtFld: UITextField!
    @IBOutlet weak var biodegradabilitySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func confirmBtn(_ sender: UIButton) {
        //get data from the text fields
        let name = nameTxtFld.text!
        let category = categoryTxtFld.text!
        let store = storeTxtFld.text!
        let purchasedate = purchasedateDatePicker.date
        let price = priceTxtFld.text!
        let co2 = co2TxtFld.text!
        let plastic = plasticTxtFld.text!
        let tree = treeTxtFld.text!
        let biodegradability = biodegradabilitySwitch.isOn
        //TODO - Create an object and store it in firebase
        //let newProduct = Product(name: name, category: category, store: store, purchasedate: purchasedate, price: price, co2: co2, plastic: plastic, tree: tree, biodegradability: biodegradability)
    }
    
}
