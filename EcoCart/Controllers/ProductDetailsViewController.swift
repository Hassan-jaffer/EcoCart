//
//  ProductDetailsViewController.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 05/12/2024.
//

import UIKit
import FirebaseFirestore
import Foundation
import FirebaseAuth
import MapKit
import CoreLocation

class ProductDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var ImageUIView: UIView!
    
    @IBOutlet weak var ReviewView: UIView!
    
    
    @IBOutlet weak var DescriptionView: UIView!
    
    
    @IBOutlet weak var EnviroImpactView: UIView!
    
    
    @IBOutlet weak var TopRatedView: UIView!
    
    
    @IBOutlet weak var ProductsView: UIView!
    
    
    
    @IBOutlet weak var ProductsStack: UIStackView!
    
    
    
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
    
    @IBOutlet weak var viewAlternativeOutlet: UIButton!
    @IBOutlet weak var storeLocationButton: UIButton!
    @IBOutlet weak var storeNameLabel: UILabel!
    
    @IBAction func viewAlternativeTapped(_ sender: Any) {
        guard let product = product else { return }
        
        // Instantiate the AlternativeProductsViewController
        let storyboard = UIStoryboard(name: "AlternativeProducts", bundle: nil)
        guard let alternativeVC = storyboard.instantiateViewController(withIdentifier: "AlternativeProductsViewController") as? AlternativeProductsViewController else {
            return
        }

        // Pass the selected product to the AlternativeProductsViewController
        alternativeVC.selectedProduct = product
        
        // Navigate to the AlternativeProductsViewController
        navigationController?.pushViewController(alternativeVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProductDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleProductUpdate(_:)), name: NSNotification.Name("ProductUpdated"), object: nil)
        
        configureStoreLocationButton()
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
    
    @objc private func handleThemeChange() {
        setupUI() // Reapply theme settings dynamically
    }

    
    private func setupUI() {
        // Apply colors based on theme
        let backgroundColor = ThemeManager.shared.isDarkMode ? UIColor.darkGray : UIColor.white
        let textColor = ThemeManager.shared.isDarkMode ? UIColor.white : UIColor.black
        
        if(ThemeManager.shared.isDarkMode) {
            ImageUIView.backgroundColor = UIColor.black
            DescriptionView.backgroundColor = UIColor.black
            TopRatedView.backgroundColor = UIColor.black
            ReviewView.backgroundColor = UIColor.black
            TopRatedView.backgroundColor = UIColor.black
            EnviroImpactView.backgroundColor = UIColor.black
        }else{
            ImageUIView.backgroundColor = UIColor.white
            DescriptionView.backgroundColor = UIColor.white
            TopRatedView.backgroundColor = UIColor.white
            ReviewView.backgroundColor = UIColor.white
            TopRatedView.backgroundColor = UIColor.white
            EnviroImpactView.backgroundColor = UIColor.white

        }
        view.backgroundColor = backgroundColor
        
        // Apply theme to labels and text views
        nameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nameLabel.textColor = textColor
        
        productDescription.isEditable = false
        productDescription.textColor = textColor
        impactTextView.isEditable = false
        impactTextView.textColor = textColor
        quantityLabel.textColor = textColor
        storeNameLabel.textColor = textColor
        
        // Configure stepper
        productQuantityStepper.minimumValue = 1
        productQuantityStepper.value = 1
        selectedQuantity = 1
        quantityLabel.text = "1"
        productQuantityStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        

        setupTopRatedViews()
        fetchTopRatedProducts()
    }
    
    private func configureStoreLocationButton() {
        storeLocationButton.isEnabled = true
        storeLocationButton.alpha = 1.0
        storeLocationButton.addTarget(self, action: #selector(storeLocationButtonTapped(_:)), for: .touchUpInside)
        
        // Add tap gesture recognizer as backup
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(storeLocationButtonTapped(_:)))
        storeLocationButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func storeLocationButtonTapped(_ sender: Any) {
        guard let product = product else {
            let alert = UIAlertController(title: "Error",
                                        message: "Product information not available",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Check if location is available
        guard let latitude = product.latitude,
              let longitude = product.longitude else {
            // Show alert if no location is available
            let alert = UIAlertController(title: "Location Unavailable",
                                        message: "No location available for this store",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Create a map view controller
        let mapVC = UIViewController()
        let mapView = MKMapView(frame: mapVC.view.bounds)
        mapVC.view = mapView
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Use the product's actual coordinates
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
        // Add a pin for the store location
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = product.storeName ?? "Store Location"
        annotation.subtitle = product.name
        mapView.addAnnotation(annotation)
        
        // Add close button
        let closeButton = UIButton(frame: CGRect(x: 16, y: 50, width: 80, height: 40))
        closeButton.setTitle("Close", for: .normal)
        closeButton.backgroundColor = .systemGreen
        closeButton.layer.cornerRadius = 8
        closeButton.addTarget(self, action: #selector(dismissMap), for: .touchUpInside)
        mapVC.view.addSubview(closeButton)
        
        // Present the map modally
        mapVC.modalPresentationStyle = .fullScreen
        present(mapVC, animated: true)
    }
    
    @objc private func dismissMap() {
        dismiss(animated: true)
    }
    
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
    
    private func fetchProductDetails() {
        guard let productId = self.productId else {
            return
        }
        
        Task {
            do {
                if let product = try await Product.fetchProduct(withId: productId) {
                    self.product = product
                    self.productId = product.id
                    updateUI(with: product)
                } else {
                    showAlert(title: "Error", message: "Failed to load product details")
                }
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func updateUI(with product: Product) {
        // Update UI elements with product data
        nameLabel.text = product.name
        productDescription.text = product.description
        productPrice.text = String(format: "%.2f BHD", product.price)
        storeNameLabel.text = product.storeName ?? "Store name not available"
        
        // Load product image
        if let imageURLString = product.imageURL, let imageURL = URL(string: imageURLString) {
            loadImage(from: imageURL, into: productImage)
        }
        
        let starButtons = [ratingButton1, ratingButton2, ratingButton3, ratingButton4, ratingButton5]
        starButtons.enumerated().forEach { index, button in
            button?.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button?.tintColor = index < product.averageRating ? .systemYellow : .systemGray4
        }
        
        // Show/hide eco-friendly certificate based on Bio metric
        ecoFriendlyCertificateImage.isHidden = product.metrics.bio != 1
        if product.metrics.bio == 1 {
            ecoFriendlyCertificateImage.image = UIImage(named: "eco-certificate")
        }
        
        // Format metrics text
        let metricsText = """
        Bio-Based: \(product.metrics.bio == 1 ? "Yes" : "No")
        CO₂ Saved: \(product.metrics.co2) kg
        Plastic Saved: \(product.metrics.plastic) g
        Trees Saved: \(product.metrics.tree)
        """
        impactTextView.text = metricsText
        
        productQuantityStepper.maximumValue = Double(product.stockQuantity)
        
        // Configure store location button based on location availability
        if let _ = product.latitude, let _ = product.longitude {
            storeLocationButton.isEnabled = true
            storeLocationButton.alpha = 1.0
        } else {
            storeLocationButton.isEnabled = true
            storeLocationButton.alpha = 1.0
        }
    }

    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.productImage.image = image
                }
            }
        }.resume()
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                return
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
        
        // Check if we have enough stock
        if product.stockQuantity < selectedQuantity {
            showAlert(title: "Error", message: "Not enough items in stock!")
            return
        }
        
        // Update product quantity in Firebase
        Task {
            do {
                let db = Firestore.firestore()
                let productRef = db.collection("product").document(product.id)
                
                // Fixed transaction signature
                _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let productDoc: DocumentSnapshot
                    do {
                        productDoc = try transaction.getDocument(productRef)
                    } catch let fetchError as NSError {
                        errorPointer?.pointee = fetchError
                        return nil
                    }
                    
                    guard let currentStock = productDoc.data()?["stockQuantity"] as? Int else {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Could not get current stock"]
                        )
                        errorPointer?.pointee = error
                        return nil
                    }
                    
                    // Check stock again in transaction
                    if currentStock < self.selectedQuantity {
                        let error = NSError(
                            domain: "AppErrorDomain",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Not enough stock"]
                        )
                        errorPointer?.pointee = error
                        return nil
                    }
                    
                    // Update stock quantity
                    let newStock = currentStock - self.selectedQuantity
                    transaction.updateData(["stockQuantity": newStock], forDocument: productRef)
                    
                    // Add to cart collection with exact field names from Firebase
                    let cartItemData: [String: Any] = [
                        "imageURL": product.imageURL ?? "",
                        "name": product.name,
                        "price": product.price,
                        "productID": product.id,
                        "quantity": self.selectedQuantity,
                        "userID": Auth.auth().currentUser?.uid ?? "guest"
                    ]
                    
                    let cartRef = db.collection("cart").document()
                    transaction.setData(cartItemData, forDocument: cartRef)
                    
                    return nil
                })
                
                // Success
                DispatchQueue.main.async {
                    self.showAlert(title: "Success", message: "\(self.selectedQuantity) x \(product.name) added to cart!")
                    // Update the UI to reflect new stock quantity
                    self.product?.stockQuantity -= self.selectedQuantity
                    self.productQuantityStepper.maximumValue = Double(self.product?.stockQuantity ?? 0)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func viewRatingsTapped(_ sender: Any) {
        guard let productId = self.productId else {
            return
        }
        
        let storyboard = UIStoryboard(name: "ProductDetails", bundle: nil)
        guard let reviewVC = storyboard.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else {
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
        Task {
            do {
                topRatedProducts = try await Product.fetchTopRatedEcoProducts(limit: 3)
                DispatchQueue.main.async { [weak self] in
                    self?.updateTopRatedUI()
                }
            } catch {
                return
            }
        }
    }
    
    private func updateTopRatedUI() {
        let imageViews = [topRatedImage1, topRatedImage2, topRatedImage3]
        
        for (index, product) in topRatedProducts.enumerated() {
            guard index < 3,
                  let imageView = imageViews[index] else {
                continue
            }
            
            if let imageUrlString = product.imageURL,
               let imageUrl = URL(string: imageUrlString) {
                loadImage(from: imageUrl, into: imageView)
            } else {
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
