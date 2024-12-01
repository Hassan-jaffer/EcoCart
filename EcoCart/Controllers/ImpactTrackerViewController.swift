//
//  ImpactTrackerViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 01/12/2024.
//

import UIKit
import DGCharts
class ImpactTrackerViewController: UIViewController {

    @IBOutlet weak var chartView: HorizontalBarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setData()
    }
    
    func setData() {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
