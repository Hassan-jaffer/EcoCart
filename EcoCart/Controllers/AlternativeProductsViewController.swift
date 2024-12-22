import UIKit
import FirebaseFirestore

class AlternativeProductsViewController: UIViewController {
    
    @IBOutlet weak var repExp: UILabel!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repImage: UIImageView!
    
    var selectedProduct: Product?
    var alternativeProduct: Product?  // Store the alternative product to show on the UI
    
    @IBOutlet weak var AltMsg: UILabel!
    
    
    @IBOutlet weak var repPrice: UILabel!
    // Weights for each environmental metric (you can adjust these based on importance)
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
            return
        }

        print("Fetching alternative products for: \(selectedProduct.name)")
        
        Task {
            do {
                let allProducts = try await Product.fetchAllProducts()
                print("Fetched \(allProducts.count) products.")
                
                // Debug: Check the fetched products and their metrics
                for product in allProducts {
                    print("Fetched Product: \(product.name)")
                    print("Fetched Metrics: CO2 \(product.metrics.co2), Plastic \(product.metrics.plastic), Tree \(product.metrics.tree)")
                }

                // Define the criteria for high environmental footprint
                let highFootprintThreshold = 100 // Adjust this value as necessary
                let isHighFootprint = selectedProduct.metrics.co2 < highFootprintThreshold ||
                                      selectedProduct.metrics.plastic < highFootprintThreshold ||
                                      selectedProduct.metrics.tree < highFootprintThreshold

                print("Selected Product Footprint - CO2: \(selectedProduct.metrics.co2), Plastic: \(selectedProduct.metrics.plastic), Tree: \(selectedProduct.metrics.tree)")
                print("Is selected product high footprint? \(isHighFootprint)")

                // Filter products based on metrics
                if isHighFootprint {
                    print("Selected product has a high footprint. Filtering for products with better metrics.")
                    if let suggestedProduct = allProducts.filter({ product in
                        product.metrics.co2 > selectedProduct.metrics.co2 ||
                        product.metrics.plastic > selectedProduct.metrics.plastic ||
                        product.metrics.tree > selectedProduct.metrics.tree
                    }).first {
                        alternativeProduct = suggestedProduct // Store the alternative product
                        print("Alternative product found: \(alternativeProduct?.name ?? "None")")
                    } else {
                        alternativeProduct = nil // No suitable alternative found
                        print("No suitable alternative found.")
                    }
                } else {
                    // If the selected product is not high in footprint, use the existing scoring method
                    alternativeProduct = allProducts.filter { product in
                        let score = calculateProductScore(product: product, allProducts: allProducts)
                        return score >= 0.5
                    }.first // Pick the first product with a score above 0.5
                    print("Alternative product based on score: \(alternativeProduct?.name ?? "None")")
                }

                // Debug: Check the alternative product
                if let altProduct = alternativeProduct {
                    print("Alternative Product found: \(altProduct.name)")
                } else {
                    print("No alternative product found.")
                }

                DispatchQueue.main.async {
                    self.updateReplacementProductDetails() // Update UI with alternative product details
                }
            } catch {
                print("Error fetching alternative products: \(error)")
            }
        }
    }

    private func calculateProductScore(product: Product, allProducts: [Product]) -> Double {
        let co2 = product.metrics.co2
        let plastic = product.metrics.plastic
        let tree = product.metrics.tree

        // Return a score of zero if all metrics are zero
        guard co2 > 0 || plastic > 0 || tree > 0 else {
            print("Product \(product.name) has all zero metrics.")
            return 0.0
        }

        // Find the maximum values for normalization
        let maxCO2 = allProducts.map { $0.metrics.co2 }.max() ?? 1
        let maxPlastic = allProducts.map { $0.metrics.plastic }.max() ?? 1
        let maxTree = allProducts.map { $0.metrics.tree }.max() ?? 1

        // Normalize metrics
        let normalizedCO2 = Double(co2) / Double(maxCO2)
        let normalizedPlastic = Double(plastic) / Double(maxPlastic)
        let normalizedTree = Double(tree) / Double(maxTree)

        // Calculate the weighted score
        let score = (normalizedCO2 * co2Weight) + (normalizedPlastic * plasticWeight) + (normalizedTree * treeWeight)
        
        print("Calculated Score for product \(product.name): \(score)")
        
        return score
    }

    private func updateReplacementProductDetails() {
        guard let alternativeProduct = alternativeProduct else {
            print("No alternative product to display.")
            repName.text = "No alternatives found"
            repPrice.text = ""
            repImage.image = nil
            return
        }

        print("Updating UI with alternative product details.")
        
        // Unhide the view that contains the replacement product details
        AltMsg.superview?.isHidden = false
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
                    print("Failed to load image for product \(alternativeProduct.name).")
                }
            }.resume()
        }
    }
}
