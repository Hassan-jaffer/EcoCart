import UIKit
import FirebaseFirestore

class HomePageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isAZFiltered: Bool = false // Tracks whether A-Z filter is applied
    @IBOutlet weak var filterButton: UIButton!
    var selectedPriceOrder: String? = nil
    var selectedCategory: String? = nil
    var isAvailableFiltered: Bool? = nil
    var selectedMetric: String? = nil
    var products: [Product] = []          // All products fetched from Firestore
    var filteredProducts: [Product] = []  // Filtered products for search
    
    var activityIndicator: UIActivityIndicatorView! // Loading spinner
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActivityIndicator()
        fetchProducts()

    }
    
    // MARK: - Setup UI
    private func setupUI() {
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Setup Activity Indicator
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func fetchProducts() {
        activityIndicator.startAnimating() // Start the spinner

        Task {
            do {
                let db = Firestore.firestore()
                let documents = try await db.collection("product").getDocuments()

                self.products = documents.documents.map { document in
                    let data = document.data()
                    
                    // Print out the entire data dictionary for debugging
                    print("Fetched document data: \(data)")

                    // Extract and print category for debugging
                    let category = data["Category"] as? String
                    print("🌟 Fetched product category: \(category ?? "No Category")") // Debugging category
                    
                    // Extract location data
                    let latitude = (data["location"] as? [String: Any])?["latitude"] as? Double ?? 0.0
                    let longitude = (data["location"] as? [String: Any])?["longtitude"] as? Double ?? 0.0
                    print("📍 Fetched location - Latitude: \(latitude), Longitude: \(longitude)")

                    // Extract metrics data
                    let metricsData = data["metrics"] as? [String: Any] ?? [:]
                    let bio = metricsData["Bio"] as? Int ?? 0
                    let co2 = metricsData["C02"] as? Int ?? 0
                    let plastic = metricsData["Plastic"] as? Int ?? 0
                    let tree = metricsData["Tree"] as? Int ?? 0
                    print("🔋 Fetched metrics - Bio: \(bio), CO2: \(co2), Plastic: \(plastic), Tree: \(tree)")

                    return Product(
                        id: document.documentID,
                        name: data["name"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        price: data["price"] as? Double ?? 0.0,
                        imageURL: data["imageURL"] as? String,
                        averageRating: data["averageRating"] as? Int ?? 0,
                        numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
                        totalRatings: data["totalRatings"] as? Int ?? 0,
                        stockQuantity: data["stockQuantity"] as? Int ?? 0,
                        category: category,
                        metrics: Product.Metrics(
                            bio: bio,
                            co2: co2,
                            plastic: plastic,
                            tree: tree
                        ),
                        latitude: latitude,
                        longitude: longitude,
                        storeName: data["storeName"] as? String ?? "Unknown"
                    )
                }

                // Debug the number of products fetched and their categories
                print("✅ Total Products Fetched: \(self.products.count)")
                for product in self.products {
                    print("🛒 Product: \(product.name), Category: \(product.category ?? "No Category"), Metric: \(product.metrics.plastic), \(product.metrics.tree), \(product.metrics.co2), \(product.metrics.bio), Location: \(product.latitude), \(product.longitude)")
                }

                // Initially show all products
                self.filteredProducts = self.products

                // Update the UI on the main thread
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating() // Stop spinner
                    self.tableView.reloadData() // Reload table view
                }
            } catch {
                print("❌ Error fetching products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating() // Stop spinner on error
                }
            }
        }
    }

    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = filteredProducts[indexPath.row]
        cell.update(with: product)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedProduct = filteredProducts[indexPath.row]
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: selectedProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search bar is empty, keep current filters
            didApplyFilters(priceOrder: selectedPriceOrder, category: selectedCategory, availability: isAvailableFiltered, metric: selectedMetric)
        } else {
            // Start with products already filtered based on category and availability
            let filteredList = products.filter { product in
                var isValid = true

                // Apply Category Filter
                if let category = selectedCategory, product.category?.lowercased() != category.lowercased() {
                    isValid = false
                }
                
                // Apply Availability Filter
                if let availability = isAvailableFiltered, availability == true, product.stockQuantity <= 0 {
                    isValid = false
                }

                return isValid
            }
            
            // Then apply search text filtering
            filteredProducts = filteredList.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Reload only the visible section of the table view
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }


    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 50) // Start position below
        
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
            cell.alpha = 1.0
            cell.transform = .identity // Return to default position
        }, completion: nil)
    }

    
    func applyFilters() {
        filteredProducts = products

        if isAZFiltered {
            filteredProducts.sort { $0.name.lowercased() < $1.name.lowercased() }
        }
    }


    
    
    @IBAction func filterButton(_ sender: UIButton) {
        let targetStoryboard = UIStoryboard(name: "Filter", bundle: nil)
        if let destinationVC = targetStoryboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            destinationVC.delegate = self

            // Pass the current states to the filter screen
            destinationVC.isAZFiltered = isAZFiltered
            destinationVC.selectedPriceOrder = selectedPriceOrder
            destinationVC.selectedCategory = selectedCategory
            destinationVC.isAvailableFiltered = isAvailableFiltered
            destinationVC.selectedMetric = selectedMetric
            
            // Smooth transition
                  destinationVC.modalTransitionStyle = .crossDissolve  // Fade transition
                  destinationVC.modalPresentationStyle = .fullScreen
            
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }


    func didResetFilters() {
        isAZFiltered = false
        selectedPriceOrder = nil
        selectedCategory = nil
        selectedMetric = nil

        // Reset the filtered products to the full list
        filteredProducts = products

        // Reload the table view to reflect the reset
        tableView.reloadData()
    }




    
    func didApplyAZFilter(az: Bool) {
        isAZFiltered = az
        didApplyFilters(priceOrder: nil, category: nil, availability: nil, metric: nil) // Apply current filters
    }

    func didApplyFilters(priceOrder: String?, category: String?, availability: Bool?, metric: String?) {
        // Save the filter selections
        selectedPriceOrder = priceOrder
        selectedCategory = category
        isAvailableFiltered = availability
        selectedMetric = metric


        // Start with the original products list
        filteredProducts = products

        // Apply Price Sorting
        if let priceOrder = priceOrder {
            if priceOrder == "High To Low" {
                filteredProducts.sort { $0.price > $1.price }
            } else if priceOrder == "Low To High" {
                filteredProducts.sort { $0.price < $1.price }
            }
        }
        
        // Apply Availability Filter
            if let availability = isAvailableFiltered, availability == true {
                filteredProducts = filteredProducts.filter { $0.stockQuantity > 0 }
            }

        // Apply Category Filter
        if let category = category {
            filteredProducts = filteredProducts.filter {
                $0.category?.lowercased() == category.lowercased()
            }
        }

        // Debugging: Check filtered products after category filter
        print("Filtered products after category filter: \(filteredProducts.count) products")

        
        // Apply Environmental Impact Filter
            if let metric = selectedMetric {
                switch metric {
                case "C02":
                    filteredProducts.sort { $0.metrics.co2 > $1.metrics.co2 }
                case "Plastic":
                    filteredProducts.sort { $0.metrics.plastic > $1.metrics.plastic }
                case "Tree":
                    filteredProducts.sort { $0.metrics.tree > $1.metrics.tree }
                default:
                    break
                }
            }
        
        // Apply A-Z Sorting if enabled
        if isAZFiltered {
            filteredProducts.sort { $0.name.lowercased() < $1.name.lowercased() }
            print("Products after A-Z sorting: \(filteredProducts.count) products")
        }

        // Reload the table view with the filtered and sorted products
        tableView.reloadData()
    }

}
