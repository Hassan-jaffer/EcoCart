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
                
                let selectedProductScore = calculateFootprintScore(product: selectedProduct)
                print("Selected Product Score: \(selectedProductScore)")
                
                // Filter and sort products based on footprint score
                let alternatives = allProducts
                    .filter { calculateFootprintScore(product: $0) < selectedProductScore }
                    .sorted {
                        let scoreDiff = calculateFootprintScore(product: $0) - calculateFootprintScore(product: $1)
                        if abs(scoreDiff) < 0.01 { // If scores are nearly equal, prefer cheaper product
                            return $0.price < $1.price
                        }
                        return scoreDiff < 0
                    }
                
                // Select the best alternative if available
                if let bestAlternative = alternatives.first {
                    alternativeProduct = bestAlternative
                    print("Best alternative product found: \(bestAlternative.name)")
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
        let co2 = product.metrics.co2 > 0 ? product.metrics.co2 : 100 // Default penalty for missing metrics
        let plastic = product.metrics.plastic > 0 ? product.metrics.plastic : 100
        let tree = product.metrics.tree > 0 ? product.metrics.tree : 100
        
        return (co2Weight * Double(co2)) + (plasticWeight * Double(plastic)) + (treeWeight * Double(tree))
    }
    
    private func updateReplacementProductDetails() {
        guard let alternativeProduct = alternativeProduct else {
            showNoAlternativeMessage("The selected product already has a low environmental impact.")
            return
        }
        
        print("Updating UI with alternative product details.")
        
        repName.superview?.isHidden = false // This assumes `repName` is inside the view you want to unhide

                    repPrice.superview?.isHidden = false
                    repImage.superview?.isHidden = false
        // Show the recommendation message
        AltMsg.text = "We recommend this eco-friendlier alternative:"
        AltMsg.isHidden = false
        
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
