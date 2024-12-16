import UIKit
import FirebaseFirestore

class HomePageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterDelegate {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isAZFiltered: Bool = false // Tracks whether A-Z filter is applied
    @IBOutlet weak var filterButton: UIButton!
    
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
                    let category = data["category"] as? String
                    print("Fetched product category: \(category ?? "No category")") // Debugging category
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

                // Log the number of fetched products
                print("Fetched \(self.products.count) products.")
                
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
            didApplyFilters(priceOrder: nil, category: nil)
        } else {
            filteredProducts = products.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
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
            destinationVC.isAZFiltered = isAZFiltered // Pass the current state
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }

    func didResetFilters() {
        isAZFiltered = false
        searchBar.text = "" // Clear search bar text
        filteredProducts = products // Reset to the full product list
        tableView.reloadData()
    }



    
    func didApplyAZFilter(az: Bool) {
        isAZFiltered = az
        didApplyFilters(priceOrder: nil, category: nil) // Apply current filters
    }

    
    func didApplyFilters(priceOrder: String?, category: String?) {
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
        if let selectedCategory = category {
            filteredProducts = filteredProducts.filter { product in
                // Safely unwrap the category for each product
                guard let productCategory = product.category else { return false }
                return productCategory.lowercased() == selectedCategory.lowercased()
            }
        }


        
        // Apply A-Z Sorting if already enabled
        if isAZFiltered {
            filteredProducts.sort { $0.name.lowercased() < $1.name.lowercased() }
        }

        tableView.reloadData()
    }

    
    
    


}
