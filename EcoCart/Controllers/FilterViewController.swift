//
//  FilterViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 10/12/2024.
//
protocol FilterDelegate: AnyObject {
    func didApplyAZFilter(az: Bool)
    func didApplyFilters(priceOrder: String?, category: String?, availability: Bool?, metric: String?)
    func didResetFilters()
}



import UIKit

class FilterViewController: UIViewController {
    weak var delegate: FilterDelegate?

    
    @IBOutlet weak var FilterView: UIView!
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: .themeDidChange, object: nil)
        createMenu()
        roundButtons()
        updateButtonStates() // Update button states based on current filters
        
        // Ensure all buttons' translatesAutoresizingMaskIntoConstraints is set to false
            priceBtn.translatesAutoresizingMaskIntoConstraints = false
            PricePopupBtn.translatesAutoresizingMaskIntoConstraints = false
            enviroBtn.translatesAutoresizingMaskIntoConstraints = false
            Metric.translatesAutoresizingMaskIntoConstraints = false
            categoryBtn.translatesAutoresizingMaskIntoConstraints = false
            CategoryPopupBtn.translatesAutoresizingMaskIntoConstraints = false

            // Set constraints for Price Popup Button inside priceBtn (aligned to the right edge)
            NSLayoutConstraint.activate([
                PricePopupBtn.trailingAnchor.constraint(equalTo: priceBtn.trailingAnchor, constant: -10), // Adjust the constant for padding
                PricePopupBtn.centerYAnchor.constraint(equalTo: priceBtn.centerYAnchor), // Keep it vertically centered
                PricePopupBtn.widthAnchor.constraint(equalTo: priceBtn.widthAnchor, multiplier: 0.6),
                PricePopupBtn.heightAnchor.constraint(equalTo: priceBtn.heightAnchor, multiplier: 0.6)
            ])

            // Set constraints for Metric Button inside enviroBtn (aligned to the right edge)
            NSLayoutConstraint.activate([
                Metric.trailingAnchor.constraint(equalTo: enviroBtn.trailingAnchor, constant: 10), // Adjust the constant for padding
                Metric.centerYAnchor.constraint(equalTo: enviroBtn.centerYAnchor), // Keep it vertically centered
                Metric.widthAnchor.constraint(equalTo: enviroBtn.widthAnchor, multiplier: 0.6),
                Metric.heightAnchor.constraint(equalTo: enviroBtn.heightAnchor, multiplier: 0.6)
            ])

            // Set constraints for Category Popup Button inside categoryBtn
            NSLayoutConstraint.activate([
                CategoryPopupBtn.trailingAnchor.constraint(equalTo: categoryBtn.trailingAnchor, constant: -20),
                CategoryPopupBtn.centerYAnchor.constraint(equalTo: categoryBtn.centerYAnchor),
                CategoryPopupBtn.widthAnchor.constraint(equalTo: categoryBtn.widthAnchor, multiplier: 0.6),
                CategoryPopupBtn.heightAnchor.constraint(equalTo: categoryBtn.heightAnchor, multiplier: 0.6)
            ])
    }
    
    @objc private func handleThemeChange(_ notification: Notification) {
        if ThemeManager.shared.isDarkMode {
            FilterView.backgroundColor = UIColor.black
        } else {
            FilterView.backgroundColor = UIColor.gray
        }
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
            
            // Update Availability button
            if self.isAvailableFiltered == true {
                self.availabilityBtn.backgroundColor = .coolLightGreen
            } else {
                self.availabilityBtn.backgroundColor = .white
            }
            
            // Update Metric button
                    if let metric = self.selectedMetric {
                        self.Metric.setTitle("\(metric)", for: .normal)
                        self.enviroBtn.backgroundColor = .coolLightGreen
                    } else {
                        self.Metric.setTitle("Metric", for: .normal)
                        self.enviroBtn.backgroundColor = .white

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
        delegate?.didApplyFilters(priceOrder: selectedPriceOrder, category: selectedCategory, availability: isAvailableFiltered, metric: selectedMetric )
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

    }

    @IBAction func azBtnTapped(_ sender: Any) {
        // Toggle A-Z filter
        isAZFiltered.toggle()
        if isAZFiltered {
            // Deselect price filter if A-Z is selected
            selectedPriceOrder = nil
            PricePopupBtn.setTitle("Price Filter", for: .normal)
            selectedMetric = nil
            Metric.setTitle("Metric", for: .normal)
        }
        updateButtonStates()
    }

    @IBAction func resetFilterBtnTapped(_ sender: Any) {
        // Reset all filter states
        isAZFiltered = false
        selectedPriceOrder = nil
        selectedCategory = nil
        isAvailableFiltered = nil
        selectedMetric = nil  // Reset selected metric


        
        // Reset Button Colors
        resetBtn(priceBtn)
        resetBtn(availabilityBtn)
        resetBtn(enviroBtn)
        resetBtn(azBtn)
        resetBtn(categoryBtn)
        resetBtn(enviroBtn)

        
        // Reset Button Titles
        PricePopupBtn.setTitle("Price Filter", for: .normal) // Reset to default title
        CategoryPopupBtn.setTitle("Category Filter", for: .normal) // Reset to default title
        Metric.setTitle("Metric", for: .normal)
        
        // Notify the delegate to reset filters and navigate back
        delegate?.didResetFilters()
    }
    
    


    func createMenu() {
        // Price Options
        let priceHL = UIAction(title: "High To Low", handler: { _ in
            self.selectedPriceOrder = "High To Low"
            self.isAZFiltered = false // Deselect A-Z filter
            self.selectedMetric = nil
            self.Metric.setTitle("Metric", for: .normal)
            self.updateButtonStates() // Update button state after selection
        })
        let priceLH = UIAction(title: "Low To High", handler: { _ in
            self.selectedPriceOrder = "Low To High"
            self.isAZFiltered = false // Deselect A-Z filter
            self.selectedMetric = nil
            self.Metric.setTitle("Metric", for: .normal)
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
        let catElec = UIAction(title: "Home & Lifestyle", handler: { _ in
            self.selectedCategory = "Home & Lifestyle"
            self.updateButtonStates() // Update button state after selection
        })

        let categoryMenu = UIMenu(title: "Select Category", children: [catAcc, catClothes, catElec])
        CategoryPopupBtn.menu = categoryMenu
        CategoryPopupBtn.showsMenuAsPrimaryAction = true
        
        
        // Category Options
               let MetCO2 = UIAction(title: "CO2 saved", handler: { _ in
                   self.selectedMetric = "C02"
                   self.isAZFiltered = false // Deselect A-Z filter
                   self.selectedPriceOrder = nil
                   self.PricePopupBtn.setTitle("Price Filter", for: .normal)
                   self.updateButtonStates() // Update button state after selection
               })
               let MetPlastic = UIAction(title: "Plastic saved", handler: { _ in
                   self.selectedMetric = "Plastic"
                   self.isAZFiltered = false // Deselect A-Z filter
                   self.selectedPriceOrder = nil
                   self.PricePopupBtn.setTitle("Price Filter", for: .normal)
                   self.updateButtonStates() // Update button state after selection
               })
               let MetTree = UIAction(title: "Trees saved", handler: { _ in
                   self.selectedMetric = "Tree"
                   self.isAZFiltered = false // Deselect A-Z filter
                   self.selectedPriceOrder = nil
                   self.PricePopupBtn.setTitle("Price Filter", for: .normal)
                   self.updateButtonStates() // Update button state after selection
               })

               let metricMenu = UIMenu(title: "Select metric", children: [MetCO2, MetPlastic, MetTree])
               Metric.menu = metricMenu
               Metric.showsMenuAsPrimaryAction = true
               
               
               
           
    }
}
