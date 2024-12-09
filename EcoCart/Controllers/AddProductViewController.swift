//
//  AddProductViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 09/12/2024.
//

import UIKit
import FirebaseFirestore
class AddProductViewController: UITableViewController {

    
    
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var categoryTxtFld: UITextField!
    @IBOutlet weak var storeTxtFld: UITextField!
    @IBOutlet weak var purchaseDateDtPicker: UIDatePicker!
    @IBOutlet weak var priceTxtFld: UITextField!
    @IBOutlet weak var co2TxtFld: UITextField!
    @IBOutlet weak var plasticTxtFld: UITextField!
    @IBOutlet weak var treeTxtFld: UITextField!
    @IBOutlet weak var bioSwitch: UISwitch!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func confirmBtnTapped(_ sender: Any) {
    
    
        
        //get all info and store them in firebase
        guard let name = nameTxtFld.text,
        let category = categoryTxtFld.text,
        let store = storeTxtFld.text,
        
        let price = Double(priceTxtFld.text!),
        let co2 = Double(co2TxtFld.text!),
        let plastic = Double(plasticTxtFld.text!),
        let tree = Double(treeTxtFld.text!)
        else {
            alert()
            return
        }
        let purchaseDate = purchaseDateDtPicker.date
        let bio = bioSwitch.isOn
        
        //create a dictionary to store the data
//        let productData: [String: Any] = [
//            "name": name,
//            "category": category,
//            "store": store,
//            "price": price,
//            "co2": co2,
//            "plastic": plastic,
//            "tree": tree,
//            "purchaseDate": purchaseDate,
//            "bio": bio
//            ]
        
        //reference firestore
        //let db = Firestore.firestore()
        
        //add data
        
//        db.collection("products").addDocument(data: productData) { error in
//            if let error {
//                print("Error adding document: \(error)")
//            } else {
//                print("Document added successfully")
//            }
//        }
        
        //print all data taken from the text fields for debugging
        print("Name: \(name)")
        print("Category: \(category)")
        print("Store: \(store)")
        print("Price: \(price)")
        print("Co2: \(co2)")
        print("Plastic: \(plastic)")
        print("Tree: \(tree)")
        print("Purchase Date: \(purchaseDate)")
        print("Bio: \(bio)")
        
        }
        
        //create an alert function for when user submits empty text fields
    func alert() {
        let alert = UIAlertController(title: "Error", message: "Please fill out all fields", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
        
        
    }
    

    


