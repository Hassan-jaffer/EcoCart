//
//  FilterViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 10/12/2024.
//
protocol FilterDelegate: AnyObject {
    func didApplyAZFilter(az: Bool)
    func didResetFilters()

}


import UIKit

class FilterViewController: UIViewController {
    weak var delegate: FilterDelegate?

    var isAZFiltered = false

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
        
        //this is a method i created to make buttons round and add borders, if you know how to edit them in the inspector remove it. - Hasan Shehab
        roundButtons()
        updateButtonStates() // Update button states based on current filters

        
    }
    
    func updateButtonStates() {
        if isAZFiltered {
            azBtn.backgroundColor = .systemGreen
        } else {
            azBtn.backgroundColor = .white
        }
    }
    ///round all buttons and add borders (functionality on another method for optimization)
    func roundButtons() {
        roundButton(priceBtn)
        roundButton(availabilityBtn)
        roundButton(enviroBtn)
        roundButton(azBtn)
        roundButton(categoryBtn)
    }
    
    ///add border and increase round value
    func roundButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }
    ///change color button (white to green and vice versa)
    func changeColor(_ button: UIButton) {
        if button.backgroundColor == .white {
            button.backgroundColor = .systemGreen
        }
        else {
            button.backgroundColor = .white
        }
        
    }
    
    
    
    ///reset button to default
    func resetBtn(_ button: UIButton) {
        button.backgroundColor = .white
        //you can add more functionality later
    }
    
    @IBAction func applyFiltersBtnTapped(_ sender: Any) {
        delegate?.didApplyAZFilter(az: isAZFiltered)
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
    ///reset all color buttons to white (functionality on another method for optimization
    @IBAction func resetFilterBtnTapped(_ sender: Any) {
        // Reset all filter states
        isAZFiltered = false
        
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

    
    
    func createMenu(){
        let priceHL = UIAction(title: "High To Low", handler: { _ in
            
        })
        let priceLH = UIAction(title: "Low To High", handler: { _ in
        })
        
        
        
        let priceMenu = UIMenu(title: "", children: [priceHL, priceLH])
        PricePopupBtn.menu = priceMenu
        PricePopupBtn.showsMenuAsPrimaryAction = true
        
        
        
        
        
        let CatAcc = UIAction(title: "Accessories", handler: { _ in
            
        })
        let CatClot = UIAction(title: "Clothes", handler: { _ in
        })
        let CatElec = UIAction(title: "Electronics", handler: { _ in
        })
        
        
        let categoryMenu = UIMenu(title: "", children: [CatClot, CatAcc, CatElec])
        CategoryPopupBtn.menu = categoryMenu
        CategoryPopupBtn.showsMenuAsPrimaryAction = true
        
    }
    
    
    
    
}
