//
//  FilterViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 10/12/2024.
//
protocol FilterDelegate: AnyObject {
    func didApplyAZFilter(az: Bool)
    func didApplyFilters(priceOrder: String?, category: String?)
    func didResetFilters()
}



import UIKit

class FilterViewController: UIViewController {
    weak var delegate: FilterDelegate?

    var isAZFiltered = false
    var selectedPriceOrder: String? = nil
    var selectedCategory: String? = nil

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
        // Update A-Z button color
        if isAZFiltered {
            azBtn.backgroundColor = .systemGreen // Green when applied
        } else {
            azBtn.backgroundColor = .white // Default color
        }

        // Update Price button
        if let priceOrder = selectedPriceOrder {
            PricePopupBtn.setTitle(priceOrder, for: .normal)
            priceBtn.backgroundColor = .systemGreen // Change the whole button to green
        } else {
            priceBtn.backgroundColor = .white // Default color
        }

        // Update Category button
        if let category = selectedCategory {
            CategoryPopupBtn.setTitle(category, for: .normal)
            categoryBtn.backgroundColor = .systemGreen // Change the whole button to green
        } else {
            categoryBtn.backgroundColor = .white // Default color
        }
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
        if button.backgroundColor == .white {
            button.backgroundColor = .systemGreen
        }
        else {
            button.backgroundColor = .white
        }
    }

    func resetBtn(_ button: UIButton) {
        button.backgroundColor = .white
    }

    @IBAction func applyFiltersBtnTapped(_ sender: Any) {
        delegate?.didApplyAZFilter(az: isAZFiltered) // Pass A-Z filter state
        delegate?.didApplyFilters(priceOrder: selectedPriceOrder, category: selectedCategory)
        navigationController?.popViewController(animated: true)
    }

    @IBAction func availabilityBtnTapped(_ sender: Any) {
        changeColor(availabilityBtn)
    }
    
    @IBAction func enviroBtnTapped(_ sender: Any) {
        changeColor(enviroBtn)
    }

    @IBAction func azBtnTapped(_ sender: Any) {
        isAZFiltered.toggle()
        changeColor(azBtn)
    }

    @IBAction func resetFilterBtnTapped(_ sender: Any) {
        // Reset all filter states
        isAZFiltered = false
        selectedPriceOrder = nil
        selectedCategory = nil
        
        // Update UI
        resetBtn(priceBtn)
        resetBtn(availabilityBtn)
        resetBtn(enviroBtn)
        resetBtn(azBtn)
        resetBtn(categoryBtn)
        
        // Notify the delegate to reset filters and navigate back
        delegate?.didResetFilters()
        navigationController?.popViewController(animated: true)
    }

    func createMenu() {
        // Price Options
        let priceHL = UIAction(title: "High To Low", handler: { _ in
            self.selectedPriceOrder = "High To Low"
            self.updateButtonStates() // Update button state after selection
        })
        let priceLH = UIAction(title: "Low To High", handler: { _ in
            self.selectedPriceOrder = "Low To High"
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
    }
}
