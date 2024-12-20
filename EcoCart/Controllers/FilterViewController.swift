//
//  FilterViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 10/12/2024.
//
protocol FilterDelegate: AnyObject {
    func didApplyAZFilter(az: Bool)
    func didApplyFilters(priceOrder: String?, category: String?, availability: Bool?)
    func didResetFilters()
}



import UIKit

class FilterViewController: UIViewController {
    weak var delegate: FilterDelegate?

    
    @IBOutlet weak var Metric: UIButton!
    var isAvailableFiltered: Bool? = nil
    var isAZFiltered = false
    var selectedPriceOrder: String? = nil
    var selectedCategory: String? = nil
    var selectedMetric: String? = nil


    @IBOutlet weak var PricePopupBtn: UIButton!
    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var availabilityBtn: UIButton!
    @IBOutlet weak var enviroBtn: UIButton!
    @IBOutlet weak var azBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var CategoryPopupBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateButtonStates() // Update the button appearance when the view appears
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createMenu()
        roundButtons()
        updateButtonStates() // Update button states based on current filters
    }

    func updateButtonStates() {
        UIView.animate(withDuration: 0.5) { // Add smooth animation for color updates
            // Update A-Z button color
            if self.isAZFiltered {
                self.azBtn.backgroundColor = .coolLightGreen
            } else {
                self.azBtn.backgroundColor = .white
            }

            // Update Price button
            if let priceOrder = self.selectedPriceOrder {
                self.PricePopupBtn.setTitle(priceOrder, for: .normal)
                self.priceBtn.backgroundColor = .coolLightGreen
            } else {
                self.priceBtn.backgroundColor = .white
            }

            // Update Category button
            if let category = self.selectedCategory {
                self.CategoryPopupBtn.setTitle(category, for: .normal)
                self.categoryBtn.backgroundColor = .coolLightGreen
            } else {
                self.categoryBtn.backgroundColor = .white
            }
            
            // **Update Availability button**
            if self.isAvailableFiltered == true {
                self.availabilityBtn.backgroundColor = .coolLightGreen
            } else {
                self.availabilityBtn.backgroundColor = .white
            }
        }
    }





    
    
    

    
    func areFiltersApplied() -> Bool {
        return isAZFiltered || selectedPriceOrder != nil || selectedCategory != nil
    }



    func roundButtons() {
        roundButton(priceBtn)
        roundButton(availabilityBtn)
        roundButton(enviroBtn)
        roundButton(azBtn)
        roundButton(categoryBtn)
    }

    func roundButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }

    func changeColor(_ button: UIButton) {
        UIView.animate(withDuration: 0.5) { // Animate over 0.3 seconds
            if button.backgroundColor == .white {
                button.backgroundColor = .coolLightGreen
            } else {
                button.backgroundColor = .white
            }
        }
    }


    func resetBtn(_ button: UIButton) {
        UIView.animate(withDuration: 0.5) {
            button.backgroundColor = .white
        }
    }

    @IBAction func applyFiltersBtnTapped(_ sender: Any) {
          
            // Notify the delegate about the applied filters
            delegate?.didApplyAZFilter(az: isAZFiltered)
        delegate?.didApplyFilters(priceOrder: selectedPriceOrder, category: selectedCategory, availability: isAvailableFiltered)
            navigationController?.popViewController(animated: true)
        
    }


    @IBAction func availabilityBtnTapped(_ sender: Any) {
        // Toggle availability state
        isAvailableFiltered = (isAvailableFiltered == true) ? nil : true
        
        // Update button color based on state
        UIView.animate(withDuration: 0.5) {
            self.availabilityBtn.backgroundColor = self.isAvailableFiltered == true ? .coolLightGreen : .white
        }
    }

    
    @IBAction func enviroBtnTapped(_ sender: Any) {
        changeColor(enviroBtn)
    }

    @IBAction func azBtnTapped(_ sender: Any) {
        // Toggle A-Z filter
        isAZFiltered.toggle()
        if isAZFiltered {
            // Deselect price filter if A-Z is selected
            selectedPriceOrder = nil
            PricePopupBtn.setTitle("Price Filter", for: .normal)
        }
        updateButtonStates()
    }

    @IBAction func resetFilterBtnTapped(_ sender: Any) {
        // Reset all filter states
        isAZFiltered = false
        selectedPriceOrder = nil
        selectedCategory = nil
        isAvailableFiltered = nil

        
        // Reset Button Colors
        resetBtn(priceBtn)
        resetBtn(availabilityBtn)
        resetBtn(enviroBtn)
        resetBtn(azBtn)
        resetBtn(categoryBtn)
        
        // Reset Button Titles
        PricePopupBtn.setTitle("Price Filter", for: .normal) // Reset to default title
        CategoryPopupBtn.setTitle("Category Filter", for: .normal) // Reset to default title
        
        // Notify the delegate to reset filters and navigate back
        delegate?.didResetFilters()
    }
    
    


    func createMenu() {
        // Price Options
        let priceHL = UIAction(title: "High To Low", handler: { _ in
            self.selectedPriceOrder = "High To Low"
            self.isAZFiltered = false // Deselect A-Z filter
            self.updateButtonStates() // Update button state after selection
        })
        let priceLH = UIAction(title: "Low To High", handler: { _ in
            self.selectedPriceOrder = "Low To High"
            self.isAZFiltered = false // Deselect A-Z filter
            self.updateButtonStates() // Update button state after selection
        })

        let priceMenu = UIMenu(title: "Sort by Price", children: [priceHL, priceLH])
        PricePopupBtn.menu = priceMenu
        PricePopupBtn.showsMenuAsPrimaryAction = true

        // Category Options
        let catAcc = UIAction(title: "Accessories", handler: { _ in
            self.selectedCategory = "Accessories"
            self.updateButtonStates() // Update button state after selection
        })
        let catClothes = UIAction(title: "Clothes", handler: { _ in
            self.selectedCategory = "Clothes"
            self.updateButtonStates() // Update button state after selection
        })
        let catElec = UIAction(title: "Electronics", handler: { _ in
            self.selectedCategory = "Electronics"
            self.updateButtonStates() // Update button state after selection
        })

        let categoryMenu = UIMenu(title: "Select Category", children: [catAcc, catClothes, catElec])
        CategoryPopupBtn.menu = categoryMenu
        CategoryPopupBtn.showsMenuAsPrimaryAction = true
        
        
        // Category Options
               let MetCO2 = UIAction(title: "CO2 saved", handler: { _ in
                   self.selectedMetric = "CO2"
                   self.updateButtonStates() // Update button state after selection
               })
               let MetPlastic = UIAction(title: "Plastic saved", handler: { _ in
                   self.selectedMetric = "Plastic"
                   self.updateButtonStates() // Update button state after selection
               })
               let MetTree = UIAction(title: "Trees saved", handler: { _ in
                   self.selectedMetric = "Tree"
                   self.updateButtonStates() // Update button state after selection
               })

               let metricMenu = UIMenu(title: "Select metric", children: [MetCO2, MetPlastic, MetTree])
               Metric.menu = metricMenu
               Metric.showsMenuAsPrimaryAction = true
               
               
               
           
    }
}
