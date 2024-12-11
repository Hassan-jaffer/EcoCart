import UIKit
import FirebaseFirestore

class HomePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var products: [Product] = [] // Array to hold product data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchProducts()
    }
    
    // MARK: - Setup Table View
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell") // Register the XIB
    }

    
    // MARK: - Fetch Products from Firestore
    private func fetchProducts() {
        Task {
            do {
                let db = Firestore.firestore()
                let productId = "E3a7t5anTprKCgJdrnpX"
                let document = try await db.collection("product").document(productId).getDocument()

                if let data = document.data() {
                    print("Fetched product data: \(data)")  // Debugging

                    self.products = [
                        Product(
                            id: document.documentID,
                            name: data["name"] as? String ?? "No Name",
                            description: data["description"] as? String ?? "No Description",
                            price: data["price"] as? Double ?? 0.0,
                            imageURL: data["imageURL"] as? String,  // Ensure it's treated as optional
                            averageRating: data["averageRating"] as? Int ?? 0,  // Safe default
                            stockQuantity: data["stockQuantity"] as? Int ?? 0,  // Safe default
                            metrics: Product.parseMetrics(from: data)
                        )
                    ]

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("❌ No data found for product ID \(productId)")
                }
            } catch {
                print("❌ Error fetching product: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            fatalError("Unable to dequeue ProductCell")
        }
        
        let product = products[indexPath.row]
        
        // Set product data in the cell
        cell.productNameLabel.text = product.name
        cell.priceLabel.text = String(format: "$%.2f", product.price)
        cell.productDescriptionLabel.text = product.description
        
        // Load image safely
        if let imageUrlString = product.imageURL, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl, in: cell)
        } else {
            // Set default image if URL is nil or invalid
            cell.productImageView.image = UIImage(named: "defaultImage")
        }
        
        return cell // This works because ProductCell is a subclass of UITableViewCell
    }


    // MARK: - UITableViewDelegate (Optional: Adjust for Row Height)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0 // Adjust based on your design
    }

    // MARK: - Helper Method to Load Images
    private func loadImage(from url: URL, in cell: ProductCell) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    cell.productImageView.image = UIImage(named: "defaultImage") // Fallback on error
                }
            } else if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    cell.productImageView.image = image
                }
            }
        }.resume()
    }
}
