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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActivityIndicator()
        fetchProducts()
        updateFilterButtonColor()

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




}
