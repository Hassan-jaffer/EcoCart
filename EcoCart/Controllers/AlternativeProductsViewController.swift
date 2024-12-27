import UIKit
import FirebaseFirestore


struct MetricProduct {
    var product: Product
    var metric: String // This can be "CO2", "Plastic", "Trees", etc.
    var metricValue: Double // Store the value of the metric (e.g., CO2, Plastic, Trees)
}

class AlternativeProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var repExp: UILabel!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repImage: UIImageView!
    var currentMetric = "CO2" // Default metric to use
    @IBOutlet weak var AltMsg: UILabel!
    @IBOutlet weak var repPrice: UILabel!
    var metricProducts: [MetricProduct] = [] // Make sure this array is populated
    @IBOutlet weak var metricsTableView: UITableView!
    var selectedProduct: Product?
    var alternativeProduct: Product? // Store the alternative product to show on the UI
    
    @IBOutlet weak var statusImage: UIImageView!
    // Weights for each environmental metric (can be adjusted dynamically or fetched from a config)
    let co2Weight: Double = 0.5
    let plasticWeight: Double = 0.3
    let treeWeight: Double = 0.2
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //print("View did load - Fetching alternative products.")
        fetchAlternativeProduct()
        metricsTableView.delegate = self
        metricsTableView.dataSource = self
        
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

                // Filter products by keyword similarity (ignoring category) and exclude the selected product
                let similarProducts = allProducts.filter { product in
                    let isSimilar = productContainsSimilarKeywords(selected: selectedProduct, candidate: product)
                    let isNotSelected = product.id != selectedProduct.id // Exclude selected product
                    return isSimilar && isNotSelected
                }

                print("Filtered \(similarProducts.count) similar products based on keywords.")

                // Calculate footprint score for the selected product
                let selectedProductScore = calculateFootprintScore(product: selectedProduct)
                print("Selected Product Score: \(selectedProductScore)")

                // Filter and sort similar products based on footprint score (for suggested alternatives)
                let filteredProducts = similarProducts
                    .filter { calculateFootprintScore(product: $0) >= selectedProductScore } // Lower footprint score
                    .sorted {
                        let scoreDiff = calculateFootprintScore(product: $0) - calculateFootprintScore(product: $1)
                        if abs(scoreDiff) < 0.01 { // If scores are nearly equal, prefer cheaper product
                            return $0.price < $1.price
                        }
                        return scoreDiff < 0
                    }

                print("Filtered and sorted alternatives: \(filteredProducts.count) alternatives found.")

                // Set the best alternative product to be shown in the header
                self.alternativeProduct = filteredProducts.first

                // --------------------- For Metric Table ---------------------
                var validMetricProducts: [MetricProduct] = []
                var usedProductIDs: Set<String> = [] // Track product IDs to prevent duplicates

                // CO2: Find product with highest CO2 saved
                if let co2Product = similarProducts
                    .filter({ !usedProductIDs.contains($0.id) && $0.metrics.co2 > 0 }) // Exclude products with 0 CO2
                    .max(by: { $0.metrics.co2 < $1.metrics.co2 }) {
                    validMetricProducts.append(MetricProduct(product: co2Product, metric: "CO2", metricValue: Double(co2Product.metrics.co2)))
                    usedProductIDs.insert(co2Product.id) // Mark this product as used
                }
                print("CO2 Product: \(validMetricProducts.last?.product.name ?? "None") CO2: \(validMetricProducts.last?.metricValue ?? 0)")

                // Plastic: Find product with highest Plastic saved
                if let plasticProduct = similarProducts
                    .filter({ !usedProductIDs.contains($0.id) && $0.metrics.plastic > 0 }) // Exclude products with 0 Plastic
                    .max(by: { $0.metrics.plastic < $1.metrics.plastic }) {
                    validMetricProducts.append(MetricProduct(product: plasticProduct, metric: "Plastic", metricValue: Double(plasticProduct.metrics.plastic)))
                    usedProductIDs.insert(plasticProduct.id) // Mark this product as used
                }
                print("Plastic Product: \(validMetricProducts.last?.product.name ?? "None") Plastic: \(validMetricProducts.last?.metricValue ?? 0)")

                // Trees: Find product with highest Trees saved
                if let treeProduct = similarProducts
                    .filter({ !usedProductIDs.contains($0.id) && $0.metrics.tree > 0 }) // Exclude products with 0 Trees
                    .max(by: { $0.metrics.tree < $1.metrics.tree }) {
                    validMetricProducts.append(MetricProduct(product: treeProduct, metric: "Trees", metricValue: Double(treeProduct.metrics.tree)))
                    usedProductIDs.insert(treeProduct.id) // Mark this product as used
                }
                print("Tree Product: \(validMetricProducts.last?.product.name ?? "None") Trees: \(validMetricProducts.last?.metricValue ?? 0)")

                // Check if no valid alternatives exist
                print("validMetricProducts count before check: \(validMetricProducts.count)")
                guard !validMetricProducts.isEmpty else {
                    DispatchQueue.main.async {
                        print("No valid products found. Updating UI.")
                        self.showNoAlternativeMessage("No valid alternative products found.")
                        self.statusImage.image = UIImage(named: "Magni")
                        self.statusImage.isHidden = false
                    }
                    return
                }

                // Update the table with valid alternatives
                self.metricProducts = validMetricProducts

                print("Metric products count: \(self.metricProducts.count)")

                // Reload the table data on the main thread
                DispatchQueue.main.async {
                    self.metricsTableView.reloadData()
                }

                // If the selected product already has a low footprint, show confirmation
                if(classifyProduct(product: selectedProduct) == true) {
                    showNoAlternativeMessage("The selected product already has a low environmental impact, Good choice!")
                    AltMsg.textColor = UIColor.systemGreen // Change text color to green
                    statusImage.image = UIImage.thumbs
                    statusImage.isHidden = false
                } else {
                    self.updateReplacementProductDetails()
                }

            } catch {
                print("Error fetching alternative products: \(error)")
                showNoAlternativeMessage("Failed to fetch products.")
            }
        }
    }



    private func calculateFootprintScore(product: Product) -> Double {
        // Extract metric values
        let co2Saved = product.metrics.co2
        let plasticSaved = product.metrics.plastic
        let treesSaved = product.metrics.tree
        let bio = product.metrics.bio // Assuming this is an Int (1 for biodegradable, 0 for not)

        // Log the extracted values
        print("CO2 Saved: \(co2Saved), Plastic Saved: \(plasticSaved), Trees Saved: \(treesSaved), Biodegradable: \(bio != 0)")

        // Calculate scores based on contributions
        let co2Score = co2Saved > 0 ? Double(co2Saved) : 0.0
        let plasticScore = plasticSaved > 0 ? Double(plasticSaved) : 0.0
        let treeScore = treesSaved > 0 ? Double(treesSaved) : 0.0

        // Compute weighted scores
        let weightedCo2Score = co2Weight * co2Score
        let weightedPlasticScore = plasticWeight * plasticScore
        let weightedTreeScore = treeWeight * treeScore

        // Combine the weighted scores
        let footprintScore = weightedCo2Score + weightedPlasticScore + weightedTreeScore

        // Log weighted footprint score
        print("Weighted Footprint Score (before adjustment): \(footprintScore)")

        // Biodegradable adjustment (positive for biodegradable)
        let biodegradableAdjustment = bio != 0 ? 0.005 : 0.0

        // Log the adjustment
        print("Biodegradable Adjustment: \(biodegradableAdjustment)")

        // Final score
        let finalScore = footprintScore + biodegradableAdjustment

        // Log the final score
        print("Final Footprint Score: \(finalScore)")

        return finalScore
    }

    private func classifyProduct(product: Product) -> Bool {
        let footprintScore = calculateFootprintScore(product: product)
        let threshold = 50.00 // Adjusted threshold

        // Check if the product meets the footprint score threshold
        if footprintScore >= threshold {
            return true // Product is environmentally friendly
        }

        // Additional checks can be added here
        let metrics = product.metrics
        return metrics.co2 > 100 || metrics.plastic > 100 || metrics.tree > 10 // Example criteria
    }


    
    private let stopWords: Set<String> = [
        "recyclable", "eco", "green", "sustainable", "environmentally", "friendly",
        "product", "the", "and", "a", "of", "in", "to", "for", "is", "that", "on",
        "with", "as", "by", "from", "this", "which", "be", "are", "at", "it", "recycled"
        // Add more as needed
    ]

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
            .filter { !$0.isEmpty && !stopWords.contains($0) } // Remove empty strings and stop words

        return Set(words)
    }
    private func updateReplacementProductDetails() {
         guard let alternativeProduct = alternativeProduct else {
            
            return
        }

        print("Updating UI with alternative product details.")

        // Show the recommendation message
        AltMsg.text = "The selected product has a high environmental footprint. We recommend this eco-friendlier alternative:"
        AltMsg.isHidden = false

        repName.superview?.isHidden = false
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

        // Generate the explanation for choosing this alternative product
        let selectedProductScore = calculateFootprintScore(product: selectedProduct!)
        let alternativeProductScore = calculateFootprintScore(product: alternativeProduct)
        
        // Explanation logic: compare footprint scores
        var explanation = "This alternative has a lower environmental footprint."

        if selectedProductScore > alternativeProductScore {
            explanation += "\nThe selected product has a higher footprint."
        } else {
            explanation += "\nThe alternative has a better footprint."
        }

        // Set the explanation text
        repExp.text = explanation


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
    
    
    // When a row is selected, navigate to ProductDetailsViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected MetricProduct
        let selectedMetricProduct = metricProducts[indexPath.row]

        // Get the associated Product
        let selectedProduct = selectedMetricProduct.product

        // Instantiate and navigate to the ProductDetailsViewController
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: selectedProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
            print("Navigating to product details for: \(selectedProduct.name)")
        } else {
            print("Failed to instantiate ProductDetailsViewController.")
        }
    }

    // Number of sections in the table view (1 section in this case)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows in each section (count of products to show)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metricProducts.count
    }

    // Configure each cell in the table view dynamically
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell from the prototype
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricCell", for: indexPath)
        
        // Get the metric product to show in the cell
        let metricProduct = metricProducts[indexPath.row]
        
        // Set the product name to the first label (label1)
        if let label1 = cell.viewWithTag(1) as? UILabel {
            label1.text = metricProduct.product.name
        }
        
        // Set the metric type to the second label (label2)
        if let label2 = cell.viewWithTag(2) as? UILabel {
            label2.text = metricProduct.metric
        }
        
        // Set the metric value to the third label (label3)
        if let label3 = cell.viewWithTag(3) as? UILabel {
            label3.text = "\(metricProduct.metricValue)"
        }
        
        // Load the product image (with error handling)
        if let imageView = cell.viewWithTag(4) as? UIImageView {
            if let imageUrlString = metricProduct.product.imageURL, let imageUrl = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: imageUrl) { data, _, error in
                    if let error = error {
                        print("Error loading image: \(error)")
                    }
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            imageView.image = UIImage(named: "placeholder")
                        }
                    }
                }.resume()
            } else {
                imageView.image = UIImage(named: "placeholder")
            }
        }
        
        return cell
    }






}
