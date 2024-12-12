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
        //let dateFormatter = ISO8601DateFormatter()
        //let format = DateFormatter()
        //format.dateFormat = "yyyy-MM-dd"
        //let purchaseDate = format.string(from: purchaseDateDtPicker.date)
        let purchaseDate = purchaseDateDtPicker.date
        let bio = bioSwitch.isOn
        
        //create a dictionary to store the data
        let productData: [String: Any] = [
        //--------------------------------------
            //this is a map field
            "impactProd": [ //map field start
            "CO2": co2, //name : value
            "Plastic": plastic,
            "Tree": tree,
            "Bio": bio
            ], //map field end
         //-------------------------------------
            //these are normal field
            "impactProdCategory": category,
            "impactProdName": name,
            "impactProdPrice": price,
            "impactProdPurchaseDate": purchaseDate,
            "impactProdStore": store,
            "userId": "123" //temporary, later will be changed
            ]
        
        //reference firestore
        let db = Firestore.firestore()
        
        
        //db is the firestore reference, collection("name") is the name of the collection stored in firebase, addDocument(data) is the fields you want to store (i created above). document id will be auto generated, to create your own you will have to use document("path), for example: db.document("ImpactProducts/00001"). this will create a collection named ImpactProducts and a document id with 00001. but of course, the id must be uniquely generated in the code.
        db.collection("impactProd").addDocument(data: productData) { error in
            if let error{
                self.showError(error: error.localizedDescription)
            } else {
                self.successAlert()
            }
        }
        
        }
        
        //create an alert function for when user submits empty text fields
    func alert() {
        let alert = UIAlertController(title: "Error", message: "Please fill out all fields", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func successAlert() {
        let alert = UIAlertController(title: "Success", message: "Product added successfully", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { action in
            self.dismissPage()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
        
    func dismissPage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showError(error: String){
        let alert = UIAlertController(title: "Error", message: "Something went wrong\n\(error)", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    }
    

    


