//
//  ImpactTrackerViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 01/12/2024.
//

import UIKit
import FirebaseFirestore
class ImpactTrackerViewController: UIViewController {
    
    @IBOutlet weak var co2progressView: UIProgressView!
    @IBOutlet weak var graphView: UIView!

    @IBOutlet weak var plasticProgressView: UIProgressView!
    @IBOutlet weak var impOnTreeProgressView: UIProgressView!
    @IBOutlet weak var bioProgressView: UIProgressView!
    @IBOutlet weak var co2Percentage: UILabel!
    @IBOutlet weak var plasticPercentage: UILabel!
    @IBOutlet weak var treePercentage: UILabel!
    @IBOutlet weak var bioPercentage: UILabel!
    
    @IBOutlet weak var resetBtn: UIButton!
    var totalCO2: Double = 0.0
    var totalPlastic: Double = 0.0
    var totalImpOnTree: Double = 0.0
    var BioCount: Int = 0
    var i: Float = 0.0
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        editGraphView()
        editProgressView()
        fetchData()
    }
    
    func editProgressView(){
        editProgress(co2progressView)
        editProgress(plasticProgressView)
        editProgress(impOnTreeProgressView)
        editProgress(bioProgressView)
        
    }
    func editProgress(_ progress: UIProgressView){
        
        progress.transform = progress.transform.scaledBy(x: 1, y: 5)
        progress.layer.cornerRadius = 10
        progress.clipsToBounds = true
        progress.layer.borderColor = UIColor.black.cgColor
        progress.layer.borderWidth = 0.1
        
        
    }
    func updateProgressView(){
        self.co2progressView.setProgress(Float(self.totalCO2) / i, animated: true)
        self.co2Percentage.text = String(self.totalCO2) + "kg"
        self.plasticProgressView.setProgress(Float(self.totalPlastic) / i, animated: true)
        self.plasticPercentage.text = String(self.totalPlastic) + "kg"
        self.impOnTreeProgressView.setProgress(Float(self.totalImpOnTree) / i, animated: true)
        self.treePercentage.text = String(self.totalImpOnTree) + "kg"
        self.bioProgressView.setProgress(Float(self.BioCount) / i, animated: true)
        self.bioPercentage.text = String(self.BioCount)
        }
        
    func resetProgressView(){
        self.co2progressView.setProgress(0, animated: true)
        self.plasticProgressView.setProgress(0, animated: true)
        self.impOnTreeProgressView.setProgress(0, animated: true)
        self.bioProgressView.setProgress(0, animated: true)
        self.co2Percentage.text = "0kg"
        self.plasticPercentage.text = "0kg"
        self.treePercentage.text = "0kg"
        self.bioPercentage.text = "0"
        resetValues()
    }
    func fetchData(){
        //query with the condition, seperated it to add action listener
        
        let query = self.db.collection("impactProd").whereField("userId", isEqualTo: "123")// id will be changed later
        
        query.addSnapshotListener(){ [weak self] (querySnapshot, error) in //action listener watches the database, updating any change happens. syntax should be the same
            guard let self else { return }
            if let error = error {
                self.showError(error: error.localizedDescription)
            }
            //get the documents and check if its not empty
            guard let documents = querySnapshot?.documents , !documents.isEmpty else {
                //TODO - make a text above saying "No product available to track" (make it inside the method)
                resetProgressView()
                return
            }
            self.resetValues()
            for document in documents{ //loop through each doc
                let metrics = document.data()["impactProd"] as? [String: Any] ?? [:] //get the map field
                let co2Progress = metrics["CO2"] as? Double ?? 0.0
                let plasticProgress = metrics["Plastic"] as? Double ?? 0.0
                let impOnTreeProgress = metrics["Tree"] as? Double ?? 0.0
                let bioProgress = metrics["Bio"] as? Bool ?? false
                //calculate using the class level variables (calculation will be changed later)
                self.totalCO2 += co2Progress
                self.totalPlastic += plasticProgress
                self.totalImpOnTree += impOnTreeProgress
                
                if bioProgress{
                    self.BioCount += 1
                }
                self.i += 1.0 //loops count (temporary)
            }
            print("action listner activated") //debug
            self.updateProgressView() //update ui
            
        }
        
    }
    
    
    func editGraphView(){
        //graph background
        graphView.layer.cornerRadius = 15
        graphView.layer.borderWidth = 2
        graphView.layer.borderColor = UIColor.systemGreen.cgColor
        graphView.layer.shadowColor = UIColor.black.cgColor
        
        //reset button
        resetBtn.layer.cornerRadius = 15
        
    }
    
    @IBAction func resetBtnTapped(_ sender: Any) {
        showAlert()
    }

    func showAlert(){
        let alert = UIAlertController(title: "Reset data?", message: "Are you sure you want to reset all data? This action cannot be undone", preferredStyle: .alert)
        
        let actionReset = UIAlertAction(title: "Confirm", style: .destructive){ action in
            self.resetData() // call reset data method
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCancel)
        alert.addAction(actionReset)
        
        present(alert, animated: true, completion: nil)
    
    }
    
    
    func resetData(){
        //user id will be changed later
        self.db.collection("impactProd").whereField("userId", isEqualTo: "123").getDocuments(){ querySnapshot, err in
            if let err = err {
                self.showError(error: err.localizedDescription)
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                self.showNoData()
                return
            }
                for document in querySnapshot!.documents {
                    print("\(document.data())")
                    self.db.collection("impactProd").document(document.documentID).delete() { err in
                        if let err = err {
                            self.showError(error: err.localizedDescription)
                        }
                        else {
                            
                            self.resetProgressView()
                            self.resetSuccess()
                        }
                    }
                }
            
        }
    }
        func resetSuccess(){
                let alert = UIAlertController(title: "Success", message: "Data reset successfully", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(actionOk)
                present(alert, animated: true, completion: nil)
            }
            
            func showError(error: String){
                let alert = UIAlertController(title: "Error", message: "Something went wrong\n\(error)", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "Ok", style: .default)
                alert.addAction(actionOk)
                present(alert, animated: true, completion: nil)
            }
    
    func showNoData(){
        let alert = UIAlertController(title: "Error", message: "No data available to reset", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    
    func resetValues(){
        self.totalCO2 = 0
        self.totalPlastic = 0
        self.totalImpOnTree = 0
        self.BioCount = 0
        self.i = 0
    }
    }
