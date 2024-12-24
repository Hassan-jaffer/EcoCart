import UIKit
import FirebaseFirestore

class AlternativeProductsViewController: UIViewController {
    
    @IBOutlet weak var repExp: UILabel!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repImage: UIImageView!
    @IBOutlet weak var AltMsg: UILabel!
    @IBOutlet weak var repPrice: UILabel!
    
    var selectedProduct: Product?
    var alternativeProduct: Product? // Store the alternative product to show on the UI
    
    // Weights for each environmental metric (can be adjusted dynamically or fetched from a config)
    let co2Weight: Double = 0.5
    let plasticWeight: Double = 0.3
    let treeWeight: Double = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load - Fetching alternative products.")
        fetchAlternativeProduct()
        
        // Create a tap gesture recognizer for the entire UIView that contains the product details
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAlternativeProduct))
        repName.superview?.isUserInteractionEnabled = true // Enable interaction for the parent view
        repName.superview?.addGestureRecognizer(tapGesture)  // Add gesture to the parent view
        
        // You can repeat the same for other UI elements if necessary (e.g., price, image) or wrap them all in one parent view
    }

    @objc private func didTapAlternativeProduct() {
        // Ensure an alternative product exists
        guard let alternativeProduct = alternativeProduct else {
            print("No alternative product to display.")
            return
        }
        
        // Instantiate and navigate to the ProductDetailsViewController
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: alternativeProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
            print("Navigating to product details for: \(alternativeProduct.name)")
        } else {
            print("Failed to instantiate ProductDetailsViewController.")
        }
    }

    
    private func fetchAlternativeProduct() {
        guard let selectedProduct = selectedProduct else {
            print("Selected product is nil.")
            showNoAlternativeMessage("No product selected.")
            return
        }
        
        Task {
            do {
                let allProducts = try await Product.fetchAllProducts()
                print("Fetched \(allProducts.count) products.")
                
                // Filter products by keyword similarity (ignoring category)
                let similarProducts = allProducts.filter { product in
                    let isSimilar = productContainsSimilarKeywords(selected: selectedProduct, candidate: product)
                    if isSimilar {
                        print("Similar product found: \(product.name)")
                    }
                    return isSimilar
                }
                
                print("Filtered \(similarProducts.count) similar products based on keywords.")
                
                // If no similar products are found, notify the user
                guard !similarProducts.isEmpty else {
                    DispatchQueue.main.async {
                        self.showNoAlternativeMessage("No alternatives found based on keywords.")
                    }
                    return
                }
                
                let selectedProductScore = calculateFootprintScore(product: selectedProduct)
                print("Selected Product Score: \(selectedProductScore)")
                
                // Filter and sort products based on footprint score
                let alternatives = similarProducts
                    .filter { calculateFootprintScore(product: $0) < selectedProductScore }
                    .sorted {
                        let scoreDiff = calculateFootprintScore(product: $0) - calculateFootprintScore(product: $1)
                        if abs(scoreDiff) < 0.01 { // If scores are nearly equal, prefer cheaper product
                            return $0.price < $1.price
                        }
                        return scoreDiff < 0
                    }
                
                print("Filtered and sorted alternatives: \(alternatives.count) alternatives found.")
                
                // Select the best alternative if available
                if let bestAlternative = alternatives.first {
                    alternativeProduct = bestAlternative
                    print("Best alternative product found: \(bestAlternative.name), Price: \(bestAlternative.price), Footprint Score: \(calculateFootprintScore(product: bestAlternative))")
                } else {
                    alternativeProduct = nil
                    print("No suitable alternative found.")
                }
                
                DispatchQueue.main.async {
                    self.updateReplacementProductDetails()
                }
            } catch {
                print("Error fetching alternative products: \(error)")
                showNoAlternativeMessage("Failed to fetch products.")
            }
        }
    }

    
    private func calculateFootprintScore(product: Product) -> Double {
        // Use the metrics directly, with inversion (higher = better score)
        let co2Saved = product.metrics.co2
        let plasticSaved = product.metrics.plastic
        let treesSaved = product.metrics.tree
        
        // Ensure values are non-negative
        let co2Score = co2Saved > 0 ? 1 / Double(co2Saved) : 0
        let plasticScore = plasticSaved > 0 ? 1 / Double(plasticSaved) : 0
        let treeScore = treesSaved > 0 ? 1 / Double(treesSaved) : 0
        
        // Sum the weighted metrics: higher values of saved CO2, plastic, and trees = better environmental score
        return (co2Weight * co2Score) + (plasticWeight * plasticScore) + (treeWeight * treeScore)
    }

    
    
    private func classifyProduct(product: Product) -> String {
        // Assign thresholds for each metric, where higher values = better product
        let co2Saved = product.metrics.co2
        let plasticSaved = product.metrics.plastic
        let treesSaved = product.metrics.tree
        
        // Define a threshold for "good" environmental impact
        if co2Saved > 500 && plasticSaved > 500 && treesSaved > 500 {
            return "Good Product for the Environment"
        } else if co2Saved > 100 && plasticSaved > 100 && treesSaved > 100 {
            return "Average Product"
        } else {
            return "Not Good for the Environment"
        }
        

    }



    
    private func productContainsSimilarKeywords(selected: Product, candidate: Product) -> Bool {
        // Extract keywords from product names
        let selectedKeywords = extractKeywords(from: selected.name)
        let candidateKeywords = extractKeywords(from: candidate.name)
        
        // Check if the sets of keywords intersect
        let matchingKeywords = selectedKeywords.intersection(candidateKeywords)
        print("Matching keywords: \(matchingKeywords)")
        return !matchingKeywords.isEmpty
    }
    
    private func extractKeywords(from name: String) -> Set<String> {
        // Convert the product name to lowercase, remove special characters, and split into words
        let words = name
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty } // Remove empty strings
        
        return Set(words)
    }
    
    private func updateReplacementProductDetails() {
        guard let alternativeProduct = alternativeProduct else {
            showNoAlternativeMessage("The selected product already has a low environmental impact, Good choice!")
            AltMsg.textColor = UIColor.systemGreen // Change text color to green
            return
        }
        
        print("Updating UI with alternative product details.")
        
        // Show the recommendation message
        AltMsg.text = "The selected product has a high environmental footprint. We recommend this eco-friendlier alternative:"
        AltMsg.isHidden = false
        
        repName.superview?.isHidden = false // This assumes `repName` is inside the view you want to unhide

                           repPrice.superview?.isHidden = false
                           repImage.superview?.isHidden = false
        // Update UI with the alternative product details
        repName.text = alternativeProduct.name
        repPrice.text = "\(alternativeProduct.price) BHD"
        
        if let imageUrlString = alternativeProduct.imageURL, let imageUrl = URL(string: imageUrlString) {
            print("Loading image for alternative product: \(imageUrlString)")
            // Load image for the alternative product
            URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                if let error = error {
                    print("Error loading image: \(error)")
                }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.repImage.image = image
                        print("Image loaded successfully.")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.repImage.image = UIImage(named: "placeholder") // Default placeholder image
                        print("Failed to load image for product \(alternativeProduct.name).")
                    }
                }
            }.resume()
        } else {
            repImage.image = UIImage(named: "placeholder") // Default placeholder if no image URL is available
        }
    }
    
    private func showNoAlternativeMessage(_ message: String) {
        // Display a message if no alternatives are found
        AltMsg.text = message
        AltMsg.isHidden = false
        
        // Clear out the other fields
        repName.text = "No alternatives found"
        repPrice.text = ""
        repImage.image = UIImage(named: "placeholder") // Default placeholder image
    }
}
