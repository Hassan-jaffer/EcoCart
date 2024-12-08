import UIKit
import FirebaseFirestore

class HomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var productTableView: UITableView!
    var products: [Product] = [] // Array to hold product data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchProducts()
    }
    
    // Setup collection view
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
    }
    
    // Fetch product from Firestore
    private func fetchProducts() {
        Task {
            do {
                let db = Firestore.firestore()
                let productId = "E3a7t5anTprKCgJdrnpX"  // The actual product ID in Firebase
                let docRef = db.collection("product").document(productId)
                let document = try await docRef.getDocument()
                
                if document.exists {
                    if let data = document.data() {
                        print("Fetched product data: \(data)")  // Debugging line to check the data
                        
                        // Safely handle optional values and prevent force unwrapping
                        self.products = [
                            Product(
                                id: document.documentID,
                                name: data["name"] as? String ?? "No Name",  // Use default values if nil
                                description: data["description"] as? String ?? "No Description",  // Default
                                price: data["price"] as? Double ?? 0.0,
                                imageURL: data["imageURL"] as? String ?? "",
                                averageRating: 0,  // Not used
                                stockQuantity: 0,  // Not used
                                metrics: []  // Not used
                            )
                        ]
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    } else {
                        print("❌ No data found for product ID \(productId)")
                    }
                } else {
                    print("❌ No product found for ID \(productId)")
                }
            } catch {
                print("❌ Error fetching product: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            fatalError("Unable to dequeue ProductCell")
        }
        
        let product = products[indexPath.row]
        
        // Safely set product data to the cell
        cell.productNameLabel.text = product.name
        cell.priceLabel.text = String(format: "$%.2f", product.price)
        cell.productDescriptionLabel.text = product.description
        
        // Load image using loadImage function, directly using the imageURL string
        if let imageUrl = URL(string: product.imageURL) {
            loadImage(from: imageUrl, in: cell)
        } else {
            print("❌ Invalid image URL")
        }
        
        return cell
    }

    
    // MARK: - Image Loading
    private func loadImage(from url: URL, in cell: ProductCell) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    cell.productImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    print("❌ Error loading image: \(error?.localizedDescription ?? "No error")")
                }
            }
        }.resume()
    }
}
