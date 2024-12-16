    import UIKit
    import FirebaseFirestore

    class HomePageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterDelegate {


        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var searchBar: UISearchBar!
        var isAZFiltered: Bool = false // Tracks whether A-Z filter is applied
        @IBOutlet weak var filterButton: UIButton!
        var selectedPriceOrder: String? = nil
        var selectedCategory: String? = nil
        
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
        
        // Debugging in fetchProducts()
        private func fetchProducts() {
            activityIndicator.startAnimating() // Start the spinner

            Task {
                do {
                    let db = Firestore.firestore()
                    let documents = try await db.collection("product").getDocuments()

                    self.products = documents.documents.map { document in
                        let data = document.data()
                        let category = data["Category"] as? String // Match exact case here
                        print("🌟 Fetched product category: \(category ?? "No Category")") // Debugging category
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
                                bio: data["Bio"] as? Int ?? 0,
                                co2: data["CO2"] as? Int ?? 0,
                                plastic: data["Plastic"] as? Int ?? 0,
                                tree: data["Tree"] as? Int ?? 0
                            )
                        )
                    }

                    print("✅ Total Products Fetched: \(self.products.count)")
                    for product in self.products {
                        print("🛒 Product: \(product.name), Category: \(product.category ?? "No Category")")
                    }

                    self.filteredProducts = self.products // Initially show all products
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
                didApplyFilters(priceOrder: selectedPriceOrder, category: selectedCategory)
            } else {
                // Start with filtered products based on filters
                let filteredList = products.filter { product in
                    // Apply filters first
                    if let category = selectedCategory, product.category?.lowercased() != category.lowercased() {
                        return false
                    }
                    return true
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

            // Reset the filtered products to the full list
            filteredProducts = products

            // Reload the table view to reflect the reset
            tableView.reloadData()
        }




        
        func didApplyAZFilter(az: Bool) {
            isAZFiltered = az
            didApplyFilters(priceOrder: nil, category: nil) // Apply current filters
        }

        func didApplyFilters(priceOrder: String?, category: String?) {
            // Save the filter selections
            selectedPriceOrder = priceOrder
            selectedCategory = category

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

            // Apply Category Filter
            if let category = category {
                filteredProducts = filteredProducts.filter {
                    $0.category?.lowercased() == category.lowercased()
                }
            }

            // Debugging: Check filtered products after category filter
            print("Filtered products after category filter: \(filteredProducts.count) products")

            // Apply A-Z Sorting if enabled
            if isAZFiltered {
                filteredProducts.sort { $0.name.lowercased() < $1.name.lowercased() }
                print("Products after A-Z sorting: \(filteredProducts.count) products")
            }

            // Reload the table view with the filtered and sorted products
            tableView.reloadData()
        }

        
        
        


    }
