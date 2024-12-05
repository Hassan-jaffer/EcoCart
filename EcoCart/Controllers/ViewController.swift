//
//  ViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 22/11/2024.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var testButton: UIButton!
    
    // MARK: - Properties
    let testProductId = "E3a7t5anTprKCgJdrnpX"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "EcoCart"
        
        testButton.backgroundColor = .systemGreen
        testButton.setTitle("Test Product Details", for: .normal)
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 10
        testButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        
        testButton.layer.shadowColor = UIColor.black.cgColor
        testButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        testButton.layer.shadowRadius = 4
        testButton.layer.shadowOpacity = 0.1
    }
    
    @IBAction func testButtonTapped(_ sender: Any) {
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: testProductId) {
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = backButton
            
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
}
