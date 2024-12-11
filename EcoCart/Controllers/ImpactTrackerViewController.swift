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
    
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()

        
        editGraphView()
        editProgressView()
        updateProgressView()
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
        co2progressView.setProgress(0.8, animated: true)
        co2Percentage.text = "80%"
        plasticProgressView.setProgress(0.6, animated: true)
        plasticPercentage.text = "60%"
        impOnTreeProgressView.setProgress(0.4, animated: true)
        treePercentage.text = "40%"
        bioProgressView.setProgress(0.2, animated: true)
        bioPercentage.text = "20%"
        //TODO - get user's data and update the progress views (above is demo only)
        
        
        
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
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.data())")
                    self.db.collection("impactProd").document(document.documentID).delete() { err in
                        if let err = err {
                            self.showError(error: err.localizedDescription)
                        }
                        else {
                            self.resetSuccess()
                        }
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
    }
