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
    
    @IBOutlet weak var categoryPopup: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMenu()
    }
    
    @IBAction func confirmBtnTapped(_ sender: Any) {
    
    
        let user = UserDefaults.standard.string(forKey: "user_uid_key") //id will be changed to logged in user
        //get all info and store them in firebase
        guard let name = nameTxtFld.text, !name.isEmpty,
              let category = categoryTxtFld.text, !category.isEmpty,
              let store = storeTxtFld.text, !store.isEmpty,
              let price = priceTxtFld.text, !price.isEmpty,
              let co2 = co2TxtFld.text, !co2.isEmpty,
              let plastic = plasticTxtFld.text, !plastic.isEmpty,
              let tree = treeTxtFld.text, !tree.isEmpty
        else {
            alert(message: "Please fill all fields")
            return
        }
        guard let price = Double(price),
              let co2 = Double(co2),
              let plastic = Double(plastic),
              let tree = Double(tree) else {
            alert(message: "Please enter valid numbers")
            return
        }
        //let dateFormatter = ISO8601DateFormatter()
        //let format = DateFormatter()
        //format.dateFormat = "yyyy-MM-dd"
        //let purchaseDate = format.string(from: purchaseDateDtPicker.date)
        let purchaseDate = purchaseDateDtPicker.date
        let bio = bioSwitch.isOn
        confirmBtn.isEnabled = false
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
            "userId": user!
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
    func alert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
        confirmBtn.isEnabled = true
    }
    
    
    func createMenu(){
        
        let catAcc = UIAction(title: "Accessories", handler: { _ in
            self.categoryTxtFld.text = "Accessories"
        })
        let catClothes = UIAction(title: "Clothes", handler: { _ in
            self.categoryTxtFld.text = "Clothes"
            
        })
        let catHome = UIAction(title: "Home & Lifestyle", handler: { _ in
            self.categoryTxtFld.text = "Home & Lifestyle"
        })

        let categoryMenu = UIMenu(title: "Select a Category", children: [catAcc, catClothes, catHome])
        categoryPopup.menu = categoryMenu
        categoryPopup.showsMenuAsPrimaryAction = true
        
    }
    
    
    }
    

    


