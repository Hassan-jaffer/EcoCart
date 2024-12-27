//
//  ImpactTrackerViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 01/12/2024.
//

import UIKit
import FirebaseFirestore
import DGCharts
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
    
    @IBOutlet weak var overallLbl: UILabel!
    
    @IBOutlet weak var rankLbl: UILabel!
    
    @IBOutlet weak var popupBtn: UIButton!
    
    
    var totalCO2: Float = 0.0, totalPlastic: Float = 0.0, totalImpOnTree: Float = 0.0
    var targetCO2: Float = 1000.0, targetPlastic: Float = 1000.0, targetImpOnTree: Float = 100.0
    var BioCount: Float = 0
    var productCount: Float = 0.0
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMenu() //create the popup button
        editGraphView() //round the corners of the view
        editProgressView() //adjust progress view size
        fetchData(period: "") //get all data from firestore (parameter is nil for default)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
                
                // Apply the initial theme
                ThemeManager.shared.applyTheme()
    }
    
    @objc func themeDidChange(notification: Notification) {
            // Update UI based on the new theme
            editGraphView()
        }
        
        func editGraphView() {
            // Update your UI elements based on the current theme
            if ThemeManager.shared.isDarkMode {
                graphView.backgroundColor = UIColor.darkGray
                barChart.backgroundColor = UIColor.darkGray
            } else {
                graphView.backgroundColor = UIColor.clear
                barChart.backgroundColor = UIColor.clear
            }

            // Apply existing configurations (works for both dark and light modes)
            graphView.layer.cornerRadius = 15
            graphView.layer.borderWidth = 2
            graphView.layer.borderColor = UIColor.systemGreen.cgColor
            graphView.layer.shadowColor = UIColor.black.cgColor
            
            resetBtn.layer.cornerRadius = 15
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    ///edit progress views
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
        var co2Percentage: Float = Float(Int((totalCO2 / (targetCO2 * productCount) * 100)))
        co2Percentage = min(co2Percentage, 100)
        var plasticPercentage: Float = Float(Int((totalPlastic / (targetPlastic * productCount) * 100)))
        plasticPercentage = min(plasticPercentage, 100)
        var treePercentage: Float = Float(Int((totalImpOnTree / targetImpOnTree * 100)))
        treePercentage = min(treePercentage, 100)
        var bioPercentage: Float = Float(Int((BioCount / productCount * 100)))
        bioPercentage = min(bioPercentage, 100)
        setRank(co2: co2Percentage, plastic: plasticPercentage, tree: treePercentage, bio: bioPercentage)
        self.co2progressView.setProgress(co2Percentage / 100, animated: true)
        self.plasticProgressView.setProgress(plasticPercentage / 100, animated: true)
        self.impOnTreeProgressView.setProgress(treePercentage / 100, animated: true)
        self.bioProgressView.setProgress(bioPercentage / 100, animated: true)
        self.co2Percentage.text = "\(Int(co2Percentage))%"
        self.plasticPercentage.text = "\(Int(plasticPercentage))%"
        self.treePercentage.text = "\(Int(treePercentage))%"
        self.bioPercentage.text = "\(Int(bioPercentage))%"
        updateBarChart()
    }
    
    func setRank(co2: Float, plastic: Float, tree: Float, bio: Float){
        let overall = Int((co2 + plastic + tree + bio) / 4)
        self.overallLbl.text = String(overall) + "%"
        if overall >= 80{
            self.rankLbl.textColor = UIColor.systemGreen
            self.rankLbl.text = "Champion"
            self.overallLbl.textColor = UIColor.systemGreen
        }else if overall >= 40{
            self.rankLbl.textColor = UIColor.systemCyan
            self.rankLbl.text = "Warrior"
            self.overallLbl.textColor = UIColor.systemCyan
        }else if overall >= 20{
            self.rankLbl.textColor = UIColor.systemYellow
            self.rankLbl.text = "Explorer"
            self.overallLbl.textColor = UIColor.systemYellow
        }else{
            self.rankLbl.textColor = UIColor.systemRed
            self.rankLbl.text = "Rookie"
            self.overallLbl.textColor = UIColor.systemRed
        }
        
        
    }
    
    func resetProgressView(){
        self.co2progressView.setProgress(0, animated: true)
        self.plasticProgressView.setProgress(0, animated: true)
        self.impOnTreeProgressView.setProgress(0, animated: true)
        self.bioProgressView.setProgress(0, animated: true)
        self.co2Percentage.text = "0%"
        self.plasticPercentage.text = "0%"
        self.treePercentage.text = "0%"
        self.bioPercentage.text = "0%"
        resetValues()
    }
    func fetchData(period: String){
        //query with the condition, seperated it to add action listener and date comparsion
        let query: Query //query to execute
        let user = UserDefaults.standard.string(forKey: "user_uid_key") // id for logged in user
        let time: Date //period filter
        if period != ""{
            switch period {
            case "day":
                time = Calendar.current.startOfDay(for: Date()) //filter by today's products only
            case "week":
                time = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())! //filter by a week
            case "month":
                time = Calendar.current.date(byAdding: .month, value: -1, to: Date())! //filter by a month
            case "year":
                time = Calendar.current.date(byAdding: .year, value: -1, to: Date())! //filter by a year
            default:
                time = Calendar.current.startOfDay(for: Date()) //default value for errors
                break
            }
            query = self.db.collection("impactProd").whereField("userId", isEqualTo: user!).whereField("impactProdPurchaseDate", isGreaterThanOrEqualTo: time) //apply user id and yime conditions
        }else{
            query = self.db.collection("impactProd").whereField("userId", isEqualTo: user!) //apply user id condition only
        }
        
        
        query.addSnapshotListener(){ [weak self] (querySnapshot, error) in //attach action listener to watch the database, updating any change happens. (querySnapshot is the results, error for fails)
            guard let self else { return } //required condition for action listener
            if let error = error {
                self.showError(error: error.localizedDescription)
            }
            //check the snapshot and see if its not empty
            guard let documents = querySnapshot?.documents , !documents.isEmpty else {
                
                resetProgressView() //reset the charts to zeros
                return
            }
            self.resetValues() //reset class level values
            for document in documents{ //loop through each doc
                let metrics = document.data()["impactProd"] as? [String: Any] ?? [:] //get the map field
                let co2Progress = metrics["CO2"] as? Float ?? 0.0 //co2 saved
                let plasticProgress = metrics["Plastic"] as? Float ?? 0.0 //plastic reduced
                let impOnTreeProgress = metrics["Tree"] as? Float ?? 0.0 //trees saved
                let bioProgress = metrics["Bio"] as? Bool ?? false //biodegradability
                //calculate using the class level variables
                self.totalCO2 += co2Progress
                self.totalPlastic += plasticProgress
                self.totalImpOnTree += impOnTreeProgress
                
                if bioProgress{
                    self.BioCount += 1
                }
                self.productCount += 1.0 //loops count (products ammount)
            }

            self.updateProgressView() //update ui
            
        }
        
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
    
    ///reset all data tracked from user
    func resetData(){
        resetBtn.isEnabled = false //close reset button to deny muiltple calls
        let user = UserDefaults.standard.string(forKey: "user_uid_key") //user id
        self.db.collection("impactProd").whereField("userId", isEqualTo: user!).getDocuments(){ querySnapshot, err in //get docs that match the user id
            if let err = err {
                self.showError(error: err.localizedDescription)
                return
            }
            //check snapshot
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                self.showNoData() //return an error to user - avoiding potential bug
                return
            }
            for document in documents { //loop through docs
                print("\(document.data())")
                self.db.collection("impactProd").document(document.documentID).delete() { err in
                    if let err = err {
                        self.showError(error: err.localizedDescription)
                    }
                    else {
                        
                        self.resetProgressView() //reset chart to zeros
                        self.resetSuccess() //show success
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
        resetBtn.isEnabled = true
    }
    
    func showError(error: String){
        let alert = UIAlertController(title: "Error", message: "Something went wrong\n\(error)", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
        resetBtn.isEnabled = true
    }
    
    func showNoData(){
        let alert = UIAlertController(title: "Error", message: "No data available to reset", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
        resetBtn.isEnabled = true
    }
    
    func resetValues(){
        self.totalCO2 = 0
        self.totalPlastic = 0
        self.totalImpOnTree = 0
        self.BioCount = 0
        self.productCount = 0
        setRank(co2: 0.0, plastic: 0.0, tree: 0.0, bio: 0.0)
        updateBarChart()
    }
    
    
    func createMenu(){
        let command1 = UIAction(title: "All-Time", handler: { _ in
            self.fetchData(period: "")
            
        })
        let command2 = UIAction(title: "Today", handler: { _ in
            self.fetchData(period: "day")
        })
        
        let command3 = UIAction(title: "Last Week", handler: { _ in
            self.fetchData(period: "week")
        } )
        
        let command4 = UIAction(title: "Last Month", handler: { _ in
            self.fetchData(period: "month")
        })
        let command5 = UIAction(title: "Last Year", handler: { _ in
            self.fetchData(period: "year")
        })
        
        let menu = UIMenu(title: "Select a period", children: [command1, command2, command3, command4, command5])
        popupBtn.menu = menu
        popupBtn.showsMenuAsPrimaryAction = true
    }
    
    
    /*------------------------------------------------------------------------------------
     
     BAR CHART VIEW
     
     
     ------------------------------------------------------------------------------------*/
    
    
    @IBOutlet weak var progressChart: UIView!
    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        
        
        if sender.selectedSegmentIndex == 0{
            showProgressView()
        }
        else{
            showBarChart()
        }
    }
    
    func showProgressView(){
        progressChart.isHidden = false
        barChart.isHidden = true
    }
    
    func showBarChart(){
        progressChart.isHidden = true
        barChart.isHidden = false
        
    }
    
    func updateBarChart(){
        //data part
        let dataEntries = [
            BarChartDataEntry(x: 0, y: Double(totalCO2) / 100),
            BarChartDataEntry(x: 1, y: Double(totalPlastic) / 100),
            BarChartDataEntry(x: 2, y: Double(totalImpOnTree)),
            BarChartDataEntry(x: 3, y: Double(BioCount))
        ]
        let dataSet = BarChartDataSet(entries: dataEntries, label: "Environment Benefits")
        
        dataSet.colors = ChartColorTemplates.joyful()
        
        let data = BarChartData(dataSet: dataSet)
        //data.barWidth = 0.8
        barChart.data = data
        
        //design part

        
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["CO2 (100KG)", "Plastic (100G)", "Trees (n)", "Biodegradabile (n)"])
        barChart.xAxis.granularity = 1
        barChart.xAxis.labelPosition = .bottom
        barChart.rightAxis.enabled = false
        barChart.drawGridBackgroundEnabled = false
        barChart.leftAxis.axisMinimum = 0
        barChart.leftAxis.axisMaximum = 100
        
    }
    


    }
