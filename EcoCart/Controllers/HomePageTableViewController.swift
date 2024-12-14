import UIKit
import FirebaseFirestore

class HomePageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! // Reference to the search bar in static cell
    
    var products: [Product] = []          // All products fetched from Firestore
    var filteredProducts: [Product] = []  // Filtered products for search
    
    var searchTimer: Timer?               // Timer to control search delay
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch the search bar from the static cell
        if let searchCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UITableViewCell {
            // Manually access the UISearchBar from the cell
            searchBar = searchCell.contentView.subviews.compactMap { $0 as? UISearchBar }.first
            searchBar?.delegate = self
        }
        
        fetchProducts()
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
                        numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
                        totalRatings: data["totalRatings"] as? Int ?? 0,
                        stockQuantity: data["stockQuantity"] as? Int ?? 0,
                        metrics: Product.parseMetrics(from: data) // OR use `[]` if no parsing is available
                    )
                }
                
                self.filteredProducts = self.products // Initially show all products
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Error fetching products: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Section 0 for search bar, Section 1 for products
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Static cell for the search bar
        } else {
            return filteredProducts.count // Filtered products for search
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Static cell for search bar
            return tableView.dequeueReusableCell(withIdentifier: "SearchBarCell", for: indexPath)
        } else {
            // Dynamic cells for products
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
            let product = filteredProducts[indexPath.row]
            cell.update(with: product)
            return cell
        }
    }
    
    // MARK: - UISearchBarDelegate Method
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Check if the search text has at least 3 characters
        guard searchText.count >= 3 else {
            filteredProducts = products // Reset to all products if less than 3 characters
            tableView.reloadData()
            return
        }
        
        // If there is a search timer already running, invalidate it
        searchTimer?.invalidate()
        
        // Set up a new timer to wait for user input to stabilize (debouncing)
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.performSearch(searchText)
        }
    }
    
    // Perform the actual search
    private func performSearch(_ searchText: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let filtered = self.products.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased())
            }
            
            DispatchQueue.main.async {
                self.filteredProducts = filtered
                self.tableView.reloadData()
            }
        }
    }
}
