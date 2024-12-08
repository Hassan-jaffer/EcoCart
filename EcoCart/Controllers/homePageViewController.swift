import UIKit
import FirebaseFirestore

class HomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Connect the collection view to the storyboard
    
    @IBOutlet weak var collectionView: UICollectionView!
    // Array to hold fetched products
    var products = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("collectionView: \(collectionView)")  // Add this line for debugging
        
        if collectionView == nil {
            print("❌ collectionView outlet is not connected.")
        } else {
            collectionView.dataSource = self
            collectionView.delegate = self
            fetchProducts()
        }
    }

    
    private func fetchProducts() {
        // Fetch products from Firestore asynchronously
        Task {
            do {
                let db = Firestore.firestore()
                let snapshot = try await db.collection("product").getDocuments()

                // Parse Firestore documents into Product models
                self.products = snapshot.documents.compactMap { document in
                    return Product(
                        id: document.documentID,
                        name: document["name"] as? String ?? "",
                        description: document["description"] as? String ?? "",
                        price: document["price"] as? Double ?? 0.0,
                        imageURL: document["imageURL"] as? String ?? "",
                        averageRating: document["averageRating"] as? Int ?? 0,
                        stockQuantity: document["stockQuantity"] as? Int ?? 0,
                        metrics: parseMetrics(from: document.data()) // Local function to parse metrics
                    )
                }
                
                // Reload the collection view on the main thread
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                print("❌ Error fetching products from Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseMetrics(from data: [String: Any]) -> [Product.Metric] {
        guard let metricsData = data["metrics"] as? [[String: Any]] else { return [] }
        return metricsData.map { metricData in
            Product.Metric(
                name: metricData["name"] as? String ?? "",
                value: metricData["value"] as? String ?? ""
            )
        }
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue the custom ProductCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        // Get the product at the given index path
        let product = products[indexPath.item]
        
        // Set the product data in the cell
        cell.productNameOutlet.text = product.name
        cell.priceOutlet.text = "$\(product.price)"
        cell.sellerOutlet.text = product.description // Assuming you want to show product description as "seller"
        
        // Load the image asynchronously from the URL (if imageURL is a URL)
        loadImage(from: product.imageURL, into: cell.imageOutlet)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.item]
        print("Selected product: \(selectedProduct.name)")
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200) // Adjust dimensions as needed
    }

    // Adjust section insets (optional)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Adjust insets as needed
    }

    // MARK: - Image Loading

    // Function to load an image from a URL asynchronously
    private func loadImage(from urlString: String, into imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }

        // Start a data task to fetch the image
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                // Handle any image loading errors (set a placeholder image, for example)
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "placeholder_image") // Set a placeholder image
                }
            }
        }.resume()
    }
}
