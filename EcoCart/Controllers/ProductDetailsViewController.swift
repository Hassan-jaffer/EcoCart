//
//  ProductDetailsViewController.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 05/12/2024.
//

import UIKit
import FirebaseFirestore

class ProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var impactTextView: UITextView!
    @IBOutlet weak var productQuantityStepper: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var ratingButton1: UIButton!
    @IBOutlet weak var ratingButton2: UIButton!
    @IBOutlet weak var ratingButton3: UIButton!
    @IBOutlet weak var ratingButton4: UIButton!
    @IBOutlet weak var ratingButton5: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    
    static func instantiate(with productId: String) -> ProductDetailsViewController? {
        let storyboard = UIStoryboard(name: "ProductDetails", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController
        viewController?.productId = productId
        return viewController
    }
    
    private var productId: String?
    private var product: Product?
    private var selectedQuantity: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProductDetails()
    }
    
    private func setupUI() {
        productDescription.isEditable = false
        impactTextView.isEditable = false
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        productQuantityStepper.value = Double(selectedQuantity)
        quantityLabel.text = "\(selectedQuantity)"
        productQuantityStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
    }
    
    private func fetchProductDetails() {
        guard let productId = self.productId else { return }
        
        Task {
            do {
                if let product = try await Product.fetchProduct(withId: productId) {
                    self.product = product
                    updateUI(with: product)
                } else {
                    showAlert(title: "Error", message: "Failed to load product details")
                }
            } catch {
                showAlert(title: "Error", message: "Failed to load product details")
            }
        }
    }
    
    private func updateUI(with product: Product) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.nameLabel.text = product.name
            self.productPrice.text = String(format: "%.2f BHD", product.price)
            self.productDescription.text = product.description
            
            let starButtons = [self.ratingButton1, self.ratingButton2, self.ratingButton3, self.ratingButton4, self.ratingButton5]
            starButtons.enumerated().forEach { index, button in
                button?.setImage(UIImage(systemName: "star.fill"), for: .normal)
                button?.tintColor = index < product.rating ? .systemYellow : .systemGray4
            }
            
            let metricsText = product.metrics.map { metric in
                return "\(metric.name): \(metric.value)"
            }.joined(separator: "\n")
            self.impactTextView.text = " \n\n\(metricsText)"
            
            self.productQuantityStepper.maximumValue = Double(product.stockQuantity)
            self.productQuantityStepper.value = 1
            self.quantityLabel.text = "1"
            
            if let imageUrl = URL(string: product.imageURL) {
                self.loadImage(from: imageUrl)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.productImage.image = image
                }
            }
        }.resume()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func stepperValueChanged() {
        selectedQuantity = Int(productQuantityStepper.value)
        quantityLabel.text = "\(selectedQuantity)"
    }
    
    @IBAction func addToCartTapped(_ sender: Any) {
        guard let product = product else { return }
        showAlert(title: "Success", message: "\(selectedQuantity) x \(product.name) added to cart!")
    }
    
    @IBAction func viewRatingsTapped(_ sender: Any) {
        //later
    }
}
