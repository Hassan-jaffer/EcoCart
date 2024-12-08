//
//  ImpactTrackerViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 01/12/2024.
//

import UIKit

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        editGraphView()
        editProgressView()
        updateProgressView()
    }
    
    func editProgressView(){
        //co2 bar
        co2progressView.transform = co2progressView.transform.scaledBy(x: 1, y: 5)
        co2progressView.layer.cornerRadius = 10
        co2progressView.clipsToBounds = true
        co2progressView.layer.borderColor = UIColor.black.cgColor
        co2progressView.layer.borderWidth = 0.1
        
        //plastic bar
        plasticProgressView.transform = plasticProgressView.transform.scaledBy(x: 1, y: 5)
        plasticProgressView.layer.cornerRadius = 10
        plasticProgressView.clipsToBounds = true
        plasticProgressView.layer.borderColor = UIColor.black.cgColor
        plasticProgressView.layer.borderWidth = 0.1
        
        //tree bar
        impOnTreeProgressView.transform = impOnTreeProgressView.transform.scaledBy(x: 1, y: 5)
        impOnTreeProgressView.layer.cornerRadius = 10
        impOnTreeProgressView.clipsToBounds = true
        impOnTreeProgressView.layer.borderColor = UIColor.black.cgColor
        impOnTreeProgressView.layer.borderWidth = 0.1
        
        //bio bar
        bioProgressView.transform = bioProgressView.transform.scaledBy(x: 1, y: 5)
        bioProgressView.layer.cornerRadius = 10
        bioProgressView.clipsToBounds = true
        bioProgressView.layer.borderColor = UIColor.black.cgColor
        bioProgressView.layer.borderWidth = 0.1
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
    /*func setData() {
        let labels = ["CO2 Saved", "Plastic Waste Reduced", "Impact on Trees", "Biodegradability"]
        let values: [Double] = [100, 200, 300, 400]
        var entries: [BarChartDataEntry] = []
        for (i, value) in values.enumerated() {
            let entry = BarChartDataEntry(x: Double(i), y: value)
            entries.append(entry)
        }
        let dataSet = BarChartDataSet(entries: entries,label: "Impact Metrics")
        dataSet.valueFormatter = DefaultValueFormatter(decimals: 0)
        dataSet.colors = [NSUIColor.systemGreen]
        dataSet.valueColors = [NSUIColor.black]
        
        let data = BarChartData(dataSet: dataSet)
        chartView.data = data
        
        chartView.leftAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        chartView.rightAxis.enabled = false
        chartView.xAxis.enabled = true
        chartView.xAxis.labelPosition = .bottom
        
        }
     */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
