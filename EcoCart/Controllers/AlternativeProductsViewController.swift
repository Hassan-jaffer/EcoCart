import UIKit
import FirebaseFirestore

struct MetricProduct {
    var product: Product
    var metric: String
    var metricValue: Double //the value of the metric CO2, Plastic, Trees
}

class AlternativeProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var suggestAlternativeView: UIView!
    
    @IBOutlet weak var MetricTitle: UILabel!
    @IBOutlet weak var repExp: UILabel!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repImage: UIImageView!
    var currentMetric = "CO2" // Default metric to use
    @IBOutlet weak var AltMsg: UILabel!
    @IBOutlet weak var repPrice: UILabel!
    var metricProducts: [MetricProduct] = []
    @IBOutlet weak var metricsTableView: UITableView!
    var selectedProduct: Product?
    var alternativeProduct: Product? //the alternative product to show on the UI
    
    @IBOutlet weak var statusImage: UIImageView!
    // Weights for each environmental metric
    let co2Weight: Double = 0.5
    let plasticWeight: Double = 0.3
    let treeWeight: Double = 0.2
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAlternativeProduct()
        metricsTableView.delegate = self
        metricsTableView.dataSource = self
        setupViewColor()
        // tap gesture for the entire UIView that contains the product details
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAlternativeProduct))
        repName.superview?.isUserInteractionEnabled = true // Enable interaction for the parent view
        repName.superview?.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
                
                // Apply the initial theme
                ThemeManager.shared.applyTheme()
        
    }
    
    
    @objc func themeDidChange(notification: Notification) {
            // Update UI based on the new theme
            setupViewColor()
        }
    
    func setupViewColor() {
        print("Setting up view color...")
        if ThemeManager.shared.isDarkMode {
            print("Dark mode detected")
            suggestAlternativeView.backgroundColor = .darkGray // Emerald Green
            repExp.textColor = UIColor.green
        }else{
            print("Light mode detected")
            suggestAlternativeView.backgroundColor = .appGreen
            repExp.textColor = UIColor.systemCyan
        }
    }
    
    
    @objc private func didTapAlternativeProduct() {
       
        guard let alternativeProduct = alternativeProduct else {
            print("No alternative product to display.")
            return
        }
        
        //navigate to the ProductDetailsViewController
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
                
                // Filter products by keyword similarity and exclude the selected product
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
                    .filter { calculateFootprintScore(product: $0) >= selectedProductScore }
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
                
                // --------------------- this part is for Metric Table --------------------
                var validMetricProducts: [MetricProduct] = []
                var usedProductIDs: Set<String> = [] // get the product id to exclude it from the list
                
                // CO2 Saved Metric
                if let co2Product = similarProducts
                    .filter({
                        !usedProductIDs.contains($0.id) &&
                        $0.metrics.co2 > selectedProduct.metrics.co2 // CO2 saved is higher than selected product
                    })
                        .max(by: { $0.metrics.co2 < $1.metrics.co2 }) {
                    validMetricProducts.append(MetricProduct(product: co2Product, metric: "CO2", metricValue: Double(co2Product.metrics.co2)))
                    usedProductIDs.insert(co2Product.id)
                }
                
                // Plastic Saved Metric
                if let plasticProduct = similarProducts
                    .filter({
                        !usedProductIDs.contains($0.id) &&
                        $0.metrics.plastic > selectedProduct.metrics.plastic // Plastic saved is higher than selected product
                    })
                        .max(by: { $0.metrics.plastic < $1.metrics.plastic }) {
                    validMetricProducts.append(MetricProduct(product: plasticProduct, metric: "Plastic", metricValue: Double(plasticProduct.metrics.plastic)))
                    usedProductIDs.insert(plasticProduct.id)
                }
                
                // Trees Saved Metric
                if let treesProduct = similarProducts
                    .filter({
                        !usedProductIDs.contains($0.id) &&
                        $0.metrics.tree > selectedProduct.metrics.tree // Trees saved is higher than selected product
                    })
                        .max(by: { $0.metrics.tree < $1.metrics.tree }) {
                    validMetricProducts.append(MetricProduct(product: treesProduct, metric: "Trees", metricValue: Double(treesProduct.metrics.tree)))
                    usedProductIDs.insert(treesProduct.id)
                }
                
                
                
                // After calculating validMetricProducts
                print("validMetricProducts count before check: \(validMetricProducts.count)")
                
                // Check if the selected product is environmentally friendly
                if classifyProduct(product: selectedProduct) {
                    // Inform the user that the selected product is a good choice
                    showNoAlternativeMessage("The selected product already has a low environmental impact. Good choice!")
                    AltMsg.textColor = UIColor.systemGreen // Change text color to green
                    statusImage.image = UIImage.thumbs
                    statusImage.isHidden = false
                } else {
                    // If there are no valid alternatives, show a different message
                    guard !validMetricProducts.isEmpty else {
                        DispatchQueue.main.async {
                            print("No valid products found. Updating UI.")
                            self.showNoAlternativeMessage("This product has a high environmental footprint. However, no alternative products were found.")
                            self.statusImage.image = UIImage(named: "Magni")
                            self.statusImage.isHidden = false
                        }
                        return
                    }
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
        let bio = product.metrics.bio
        
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
        let biodegradableAdjustment = bio != 0 ? 3 : 0.0
        
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
        let threshold = 25.00 // Adjusted threshold
        
        // Check if the product meets the footprint score threshold
        if footprintScore >= threshold {
            return true // Product is environmentally friendly
        }else{
            return false
        }
        
        
    }
    
    
    
    private let stopWords: Set<String> = [
        "recyclable", "eco", "green", "sustainable", "environmentally", "friendly",
        "product", "the", "and", "a", "of", "in", "to", "for", "is", "that", "on",
        "with", "as", "by", "from", "this", "which", "be", "are", "at", "it", "recycled", "Cotton", "Organic", "Hemp", "hemp", "cotton", "organic", "Bamboo", "bamboo"
        // if you see a similarity problem, add common words here - Hasan
    ]
    
    private func productContainsSimilarKeywords(selected: Product, candidate: Product) -> Bool {
        // get keywords from product names
        let selectedKeywords = extractKeywords(from: selected.name)
        let candidateKeywords = extractKeywords(from: candidate.name)
        
        // check if the sets of keywords are the same
        let matchingKeywords = selectedKeywords.intersection(candidateKeywords)
        print("Matching keywords: \(matchingKeywords)")
        return !matchingKeywords.isEmpty
    }
    
    private func extractKeywords(from name: String) -> Set<String> {
        // extract the words from the product name
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
        
        // Update the UI
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
        
        
        // Explanation:
        let explanation = "This alternative has a lower environmental footprint. We recommend giving it a look!"
        
        
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
        
        let selectedMetricProduct = metricProducts[indexPath.row]
        
        
        let selectedProduct = selectedMetricProduct.product
        
        //navigate to the ProductDetailsViewController
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: selectedProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
            print("Navigating to product details for: \(selectedProduct.name)")
        } else {
            print("Failed to instantiate ProductDetailsViewController.")
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // (count of products to show)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(metricProducts.count == 0){
            MetricTitle.isHidden = true
        }else{
            MetricTitle.isHidden = false
        }
        return metricProducts.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell from the prototype
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetricCell", for: indexPath)
        
        // Get the metric product to show in the cell
        let metricProduct = metricProducts[indexPath.row]
        
        // Set the product name to the first label (label1)
        if let label1 = cell.viewWithTag(1) as? UILabel {
            label1.text = metricProduct.product.name
        }
        
        
        if let label2 = cell.viewWithTag(2) as? UILabel {
            label2.text = "This product has higher \(metricProduct.metric) saved!"
        }
        
        
        if let label3 = cell.viewWithTag(3) as? UILabel {
            label3.text = "\(metricProduct.metricValue) \(metricProduct.metric) saved"
        }
        
        // Load the product image 
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
