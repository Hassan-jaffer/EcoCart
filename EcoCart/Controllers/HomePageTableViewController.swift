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
    var areFiltersActive = false // To track if filters are applied
    var activityIndicator: UIActivityIndicatorView! // Loading spinner
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActivityIndicator()
        fetchProducts()
        updateFilterButtonColor()
       // addProductsToFirestore()

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
        activityIndicator.startAnimating()

        Task {
            do {
                let db = Firestore.firestore()
                let documents = try await db.collection("product").getDocuments()

                self.products = documents.documents.map { document in
                    let data = document.data()
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
                        category: data["Category"] as? String,
                        metrics: Product.Metrics(
                            bio: (data["metrics"] as? [String: Any])?["Bio"] as? Int ?? 0,
                            co2: (data["metrics"] as? [String: Any])?["C02"] as? Int ?? 0,
                            plastic: (data["metrics"] as? [String: Any])?["Plastic"] as? Int ?? 0,
                            tree: (data["metrics"] as? [String: Any])?["Tree"] as? Int ?? 0
                        ),
                        latitude: (data["location"] as? [String: Any])?["latitude"] as? Double ?? 0.0,
                        longitude: (data["location"] as? [String: Any])?["longtitude"] as? Double ?? 0.0,
                        storeName: data["storeName"] as? String ?? "Unknown"
                    )
                }

                // Sort products by average rating in descending order
                self.products.sort { $0.averageRating > $1.averageRating }

                // Initially show all products
                self.filteredProducts = self.products

                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Error fetching products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
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
        
        UIView.animate(withDuration: 0.2, delay: 0.02 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
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
        
        areFiltersActive = false
        updateFilterButtonColor()

    }

    
    
    func updateFilterButtonColor() {
            // Change button color based on filter state
        let filterIcon = UIImage(systemName: "line.horizontal.3.decrease.circle.fill")
        filterButton.setImage(filterIcon, for: .normal)
            UIView.animate(withDuration: 0.3) {
                self.filterButton.backgroundColor = self.areFiltersActive ? .coolLightGreen : .lightGray
            }
        }


    
    func didApplyAZFilter(az: Bool) {
        isAZFiltered = az
        
        // Update the areFiltersActive flag based on the AZ filter state
        areFiltersActive = isAZFiltered || selectedPriceOrder != nil || selectedCategory != nil || isAvailableFiltered != nil || selectedMetric != nil
        
        // Apply current filters, including A-Z filter
        didApplyFilters(priceOrder: nil, category: nil, availability: nil, metric: nil)
        
        // Update the filter button color
        updateFilterButtonColor()
    }


    func didApplyFilters(priceOrder: String?, category: String?, availability: Bool?, metric: String?) {
        // Save the selected filters
        selectedPriceOrder = priceOrder
        selectedCategory = category
        isAvailableFiltered = availability
        selectedMetric = metric

        // Start with the original product list
        filteredProducts = products

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

        // Apply Environmental Impact Filter
        if let metric = selectedMetric, !metric.isEmpty {
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

        // Check if any filter is applied
        areFiltersActive = (priceOrder != nil || category != nil || availability != nil || (metric != nil && !metric!.isEmpty))
        updateFilterButtonColor()

        // Apply Sorting
        if let priceOrder = priceOrder {
            // Price sorting takes priority over all other sorting
            if priceOrder == "High To Low" {
                filteredProducts.sort { $0.price > $1.price }
            } else if priceOrder == "Low To High" {
                filteredProducts.sort { $0.price < $1.price }
            }
        } else if let metric = selectedMetric {
            // If a metric filter is applied, don't sort by A-Z or ratings
            // (Metric sorting is already applied above)
        } else if isAZFiltered {
            // A-Z sorting overrides ratings (but not price)
            filteredProducts.sort { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            // Default to sorting by highest average rating when no other sorting is applied
            filteredProducts.sort { $0.averageRating > $1.averageRating }
        }

        // Reload the table view with the filtered and sorted products
        tableView.reloadData()
    }
    func addProductsToFirestore(){
        let Product7: [String: Any] = [
            "name": "Reusable Beeswax Food Wraps",
            "description": "Eco-friendly alternative to plastic wrap, made from natural beeswax.",
            "price": 15.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 4.6,
            "numberOfRatings": 130,
            "totalRatings": 598,
            "stockQuantity": 100,
            "Category": "Home & Lifestyle",
            "metrics": [
                "Bio": true,
                "CO2": 1.2, // CO2 saved in KG
                "Plastic": 200, // Plastic waste reduced in grams
                "Tree": 0
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Sustainable Kitchen"
        ]

        let Product8: [String: Any] = [
            "name": "Reusable Silicone Food Bags",
            "description": "Durable and eco-friendly food storage bags made from silicone.",
            "price": 19.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 4.7,
            "numberOfRatings": 150,
            "totalRatings": 705,
            "stockQuantity": 80,
            "Category": "Home & Lifestyle",
            "metrics": [
                "Bio": true,
                "CO2": 1.8, // CO2 saved in KG
                "Plastic": 250, // Plastic waste reduced in grams
                "Tree": 0
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Sustainable Kitchen"
        ]

        let Product9: [String: Any] = [
            "name": "Glass Food Storage Containers",
            "description": "A set of durable glass containers for sustainable food storage.",
            "price": 29.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 4.8,
            "numberOfRatings": 175,
            "totalRatings": 830,
            "stockQuantity": 50,
            "Category": "Home & Lifestyle",
            "metrics": [
                "Bio": true,
                "CO2": 2.2, // CO2 saved in KG
                "Plastic": 300, // Plastic waste reduced in grams
                "Tree": 0
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Sustainable Kitchen"
        ]

        let Product10: [String: Any] = [
            "name": "Organic Cotton Dish Towels",
            "description": "Highly absorbent and reusable dish towels made from organic cotton.",
            "price": 12.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 4.5,
            "numberOfRatings": 90,
            "totalRatings": 405,
            "stockQuantity": 60,
            "Category": "Home & Lifestyle",
            "metrics": [
                "Bio": true,
                "CO2": 1.1, // CO2 saved in KG
                "Plastic": 0, // Plastic waste reduced in grams
                "Tree": 1
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Eco Essentials"
        ]

        let Product11: [String: Any] = [
            "name": "Organic Cotton Hand Towels",
            "description": "Soft and reusable hand towels made from 100% organic cotton.",
            "price": 9.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 4.6,
            "numberOfRatings": 110,
            "totalRatings": 506,
            "stockQuantity": 70,
            "Category": "Home & Lifestyle",
            "metrics": [
                "Bio": true,
                "CO2": 1.3, // CO2 saved in KG
                "Plastic": 0, // Plastic waste reduced in grams
                "Tree": 1
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Eco Essentials"
        ]

        let Product12: [String: Any] = [
            "name": "Organic Cotton Bath Towels",
            "description": "Luxurious and eco-friendly bath towels made from organic cotton.",
            "price": 25.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 4.8,
            "numberOfRatings": 140,
            "totalRatings": 672,
            "stockQuantity": 40,
            "Category": "Home & Lifestyle",
            "metrics": [
                "Bio": true,
                "CO2": 1.9, // CO2 saved in KG
                "Plastic": 0, // Plastic waste reduced in grams
                "Tree": 1
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Eco Essentials"
        ]

        
        self.db.collection("product").addDocument(data: Product7)
        self.db.collection("product").addDocument(data: Product8)
        self.db.collection("product").addDocument(data: Product9)
        self.db.collection("product").addDocument(data: Product10)
        self.db.collection("product").addDocument(data: Product11)
        self.db.collection("product").addDocument(data: Product12)

    }
    // Add more products similarly for the rest of the list...
    



}
