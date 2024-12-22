import UIKit
import FirebaseFirestore

class AlternativeProductsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var alternativeProducts: [Product] = []
    var selectedProduct: Product?
    
    @IBOutlet weak var repPrice: UILabel!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repImage: UIImageView!
    
    // Weights for each environmental metric (you can adjust these based on importance)
    let co2Weight: Double = 0.5
    let plasticWeight: Double = 0.3
    let treeWeight: Double = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchAlternativeProducts()
    }

    private func fetchAlternativeProducts() {
        guard let selectedProduct = selectedProduct else { return }
        
        // Debug print for selected product's metrics
        print("Selected Product Metrics: CO2 \(selectedProduct.metrics.co2), Plastic \(selectedProduct.metrics.plastic), Tree \(selectedProduct.metrics.tree)")

        Task {
            do {
                let allProducts = try await Product.fetchAllProducts()
                
                // Filter products that have a similar or better environmental impact
                alternativeProducts = allProducts.filter { product in
                    let score = calculateProductScore(product: product, selectedProduct: selectedProduct)
                    return score >= 0.5  // You can adjust this threshold for what qualifies as an alternative
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateReplacementProductDetails()
                }
            } catch {
                print("Error fetching alternative products: \(error)")
            }
        }
    }
    
    private func calculateProductScore(product: Product, selectedProduct: Product) -> Double {
        // Normalize metrics
        let maxCO2 = 1000 // Example max CO2 value
        let maxPlastic = 5000 // Example max plastic value
        let maxTree = 1000 // Example max tree value
        
        // Normalize the metrics between 0 and 1
        let normalizedCO2 = Double(selectedProduct.metrics.co2) / Double(maxCO2)
        let normalizedPlastic = Double(selectedProduct.metrics.plastic) / Double(maxPlastic)
        let normalizedTree = Double(selectedProduct.metrics.tree) / Double(maxTree)
        
        // Calculate a weighted score based on normalized values
        let score = (normalizedCO2 * co2Weight) + (normalizedPlastic * plasticWeight) + (normalizedTree * treeWeight)
        
        // Debug prints for scoring
        print("Scoring \(product.name): CO2 \(normalizedCO2), Plastic \(normalizedPlastic), Tree \(normalizedTree), Score \(score)")
        
        return score
    }
    
    private func updateReplacementProductDetails() {
        guard let selectedProduct = selectedProduct else { return }
        
        // Display selected product details
        repName.text = selectedProduct.name
        repPrice.text = "\(selectedProduct.price) BHD"
        
        if let imageUrlString = selectedProduct.imageURL, let imageUrl = URL(string: imageUrlString) {
            // Load image for the selected product
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.repImage.image = image
                    }
                }
            }.resume()
        }
    }
}

extension AlternativeProductsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alternativeProducts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = alternativeProducts[indexPath.row]
        
        cell.textLabel?.text = product.name
        cell.detailTextLabel?.text = "\(product.price) BHD"
        
        if let imageUrlString = product.imageURL, let imageUrl = URL(string: imageUrlString) {
            // Load image for product
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                    }
                }
            }.resume()
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = alternativeProducts[indexPath.row]
        
        // Navigate to the selected product's detail page
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: selectedProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
}
