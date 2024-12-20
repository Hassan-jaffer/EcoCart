//
//  ProductDetailsViewController.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 05/12/2024.
//

import UIKit
import FirebaseFirestore
import Foundation

class ProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var ecoFriendlyCertificateImage: UIImageView!
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
    @IBOutlet weak var topRatedImage1: UIImageView!
    @IBOutlet weak var topRatedImage2: UIImageView!
    @IBOutlet weak var topRatedImage3: UIImageView!
    
    static func instantiate(with productId: String) -> ProductDetailsViewController? {
        let storyboard = UIStoryboard(name: "ProductDetails", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController
        viewController?.productId = productId
        return viewController
    }
    
    var productId: String?
    var product: Product?
    private var selectedQuantity: Int = 1
    private var topRatedProducts: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProductDetails()
        
        // Add observer for product updates
        NotificationCenter.default.addObserver(self, selector: #selector(handleProductUpdate(_:)), name: NSNotification.Name("ProductUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleProductUpdate(_ notification: Notification) {
        if let updatedProduct = notification.userInfo?["product"] as? Product {
            product = updatedProduct
            updateUI(with: updatedProduct)
        }
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
        setupTopRatedViews()
        fetchTopRatedProducts()
    }
    
    private func fetchProductDetails() {
        guard let productId = self.productId else {
            print("❌ No product ID available")
            return 
        }
        
        print("🔍 Fetching product details for ID: \(productId)")
        Task {
            do {
                if let product = try await Product.fetchProduct(withId: productId) {
                    print("📊 Metrics received: Bio=\(product.metrics.bio), CO2=\(product.metrics.co2), Plastic=\(product.metrics.plastic), Tree=\(product.metrics.tree)")
                    self.product = product
                    self.productId = product.id
                    updateUI(with: product)
                } else {
                    showAlert(title: "Error", message: "Failed to load product details")
                }
            } catch {
                print("❌ Error fetching product: \(error)")
                showAlert(title: "Error", message: "Failed to load product details")
            }
        }
    }
    
    private func updateUI(with product: Product) {
        print("🌟 Updating UI with product: \(product.id)")
        print("🌟 Average Rating: \(product.averageRating)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            nameLabel.text = product.name
            productPrice.text = String(format: "%.2f BHD", product.price)
            productDescription.text = product.description
            
            let starButtons = [self.ratingButton1, self.ratingButton2, self.ratingButton3, self.ratingButton4, self.ratingButton5]
            starButtons.enumerated().forEach { index, button in
                button?.setImage(UIImage(systemName: "star.fill"), for: .normal)
                button?.tintColor = index < product.averageRating ? .systemYellow : .systemGray4
            }
            
            print("📊 Metrics values: Bio=\(product.metrics.bio), CO2=\(product.metrics.co2), Plastic=\(product.metrics.plastic), Tree=\(product.metrics.tree)")
            
            // Show/hide eco-friendly certificate based on Bio metric
            self.ecoFriendlyCertificateImage.isHidden = product.metrics.bio != 1
            if product.metrics.bio == 1 {
                self.ecoFriendlyCertificateImage.image = UIImage(named: "eco-certificate")
            }
            
            // Format metrics text
            let metricsText = """
            Environmental Impact:
            Bio-Based: \(product.metrics.bio == 1 ? "Yes" : "No")
            CO₂ Saved: \(product.metrics.co2) kg
            Plastic Saved: \(product.metrics.plastic) kg
            Trees Saved: \(product.metrics.tree)
            """
            self.impactTextView.text = metricsText
            
            self.productQuantityStepper.maximumValue = Double(product.stockQuantity)
            self.productQuantityStepper.value = 1
            self.quantityLabel.text = "1"
            
            if let imageUrlString = product.imageURL, let imageUrl = URL(string: imageUrlString) {
                self.loadImage(from: imageUrl)
            } else {
                self.productImage.image = UIImage(named: "placeholderImage")
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
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        print("📱 Starting image download from: \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error downloading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    print("📱 Successfully loaded image")
                    imageView.image = image
                }
            } else {
                print("❌ Failed to create image from data")
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
        guard let productId = self.productId else { 
            print("⚠️ No product ID available")
            return 
        }
        
        let storyboard = UIStoryboard(name: "ProductDetails", bundle: nil)
        guard let reviewVC = storyboard.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else {
            print("⚠️ Could not instantiate ReviewViewController from storyboard")
            return
        }
        
        reviewVC.productId = productId
        reviewVC.title = "Reviews"
        navigationController?.pushViewController(reviewVC, animated: true)
    }
    
    // MARK: - Top Rated Products
    private func setupTopRatedViews() {
        // Configure image views
        [topRatedImage1, topRatedImage2, topRatedImage3].forEach { imageView in
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
            imageView?.layer.cornerRadius = 8
            
            // Add tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(topRatedImageTapped(_:)))
            imageView?.isUserInteractionEnabled = true
            imageView?.addGestureRecognizer(tapGesture)
        }
    }
    
    private func fetchTopRatedProducts() {
        print("📱 Starting to fetch top rated products")
        Task {
            do {
                topRatedProducts = try await Product.fetchTopRatedEcoProducts(limit: 3)
                print("📱 Fetched \(topRatedProducts.count) top rated products")
                DispatchQueue.main.async { [weak self] in
                    print("📱 Updating UI with top rated products")
                    self?.updateTopRatedUI()
                }
            } catch {
                print("❌ Error fetching top rated products: \(error)")
            }
        }
    }
    
    private func updateTopRatedUI() {
        print("📱 Starting updateTopRatedUI")
        let imageViews = [topRatedImage1, topRatedImage2, topRatedImage3]
        print("📱 Image views status: \(imageViews.map { $0 != nil })")
        
        for (index, product) in topRatedProducts.enumerated() {
            guard index < 3,
                  let imageView = imageViews[index] else {
                print("❌ Failed to get image view at index \(index)")
                continue
            }
            
            print("📱 Processing product at index \(index): \(product.name)")
            if let imageUrlString = product.imageURL,
               let imageUrl = URL(string: imageUrlString) {
                print("📱 Loading image from URL: \(imageUrlString)")
                loadImage(from: imageUrl, into: imageView)
            } else {
                print("❌ No image URL for product at index \(index)")
                imageView.image = UIImage(named: "placeholderImage")
            }
        }
    }
    
    @objc private func topRatedImageTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedImageView = gesture.view as? UIImageView else { return }
        
        let index: Int
        switch tappedImageView {
        case topRatedImage1: index = 0
        case topRatedImage2: index = 1
        case topRatedImage3: index = 2
        default: return
        }
        
        guard index < topRatedProducts.count else { return }
        
        let selectedProduct = topRatedProducts[index]
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: selectedProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
}
