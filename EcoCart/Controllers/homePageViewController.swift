import UIKit
import FirebaseFirestore

class HomePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton! // Add IBOutlet for the Filter Button
    
    var products: [Product] = [] // Array to hold all products
    var filteredProducts: [Product] = [] // Array to hold search results
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchController()  // Configure the search bar functionality
        fetchProducts()
    }
    
    // MARK: - Setup Table View
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
    }
    
    // MARK: - Setup Search Controller
    private func setupSearchController() {
        searchBar.delegate = self  // Set the search bar delegate
        searchBar.placeholder = "Search Products"
    }
    
    // MARK: - Fetch Products from Firestore
    private func fetchProducts() {
        Task {
            do {
                let db = Firestore.firestore()
                let documents = try await db.collection("product").getDocuments()
                
                self.products = documents.documents.map { document in
                    let data = document.data()
                    return Product(
                        id: document.documentID,
                        name: data["name"] as? String ?? "No Name",
                        description: data["description"] as? String ?? "No Description",
                        price: data["price"] as? Double ?? 0.0,
                        imageURL: data["imageURL"] as? String,
                        averageRating: data["averageRating"] as? Int ?? 0,
                        stockQuantity: data["stockQuantity"] as? Int ?? 0,
                        metrics: Product.parseMetrics(from: data)
                    )
                }
                
                self.filteredProducts = self.products // Initially, show all products
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Error fetching products: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredProducts = products // Show all products when search bar is empty
            tableView.reloadData()
            return
        }
        
        // Filter products by name or description
        filteredProducts = products.filter { product in
            return product.name.lowercased().contains(searchText.lowercased()) ||
                   product.description.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            fatalError("Unable to dequeue ProductCell")
        }
        
        let product = filteredProducts[indexPath.row]
        cell.productNameLabel.text = product.name
        cell.priceLabel.text = String(format: "$%.2f", product.price)
        cell.productDescriptionLabel.text = product.description
        
        if let imageUrlString = product.imageURL, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl, in: cell)
        } else {
            cell.productImageView.image = UIImage(named: "defaultImage")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProduct = filteredProducts[indexPath.row]
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: selectedProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
    
    // MARK: - Helper Method to Load Images
    private func loadImage(from url: URL, in cell: ProductCell) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    cell.productImageView.image = UIImage(named: "defaultImage")
                }
            } else if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    cell.productImageView.image = image
                }
            }
        }.resume()
    }
    
    // MARK: - Filter Button Action
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        if let filterVC = storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            navigationController?.pushViewController(filterVC, animated: true)
        }
    }
}

extension HomePageViewController: UISearchBarDelegate {
    // Search Bar delegate methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter products as text is entered
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter { product in
                return product.name.lowercased().contains(searchText.lowercased()) ||
                       product.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        tableView.reloadData()
    }
}
