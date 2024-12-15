//
//  FilterViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 10/12/2024.
//
protocol FilterDelegate: AnyObject {
    func didApplyAZFilter(az: Bool)
}


import UIKit

class FilterViewController: UIViewController {
    weak var delegate: FilterDelegate?

    var isAZFiltered = false

    @IBOutlet weak var priceBtn: UIButton!
    @IBOutlet weak var availabilityBtn: UIButton!
    @IBOutlet weak var enviroBtn: UIButton!
    @IBOutlet weak var azBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this is a method i created to make buttons round and add borders, if you know how to edit them in the inspector remove it. - Hasan Shehab
        roundButtons()
        
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
        resetBtn(priceBtn)
        resetBtn(availabilityBtn)
        resetBtn(enviroBtn)
        resetBtn(azBtn)
        resetBtn(categoryBtn)
    }
    
    
    
    
}
