import UIKit
import FirebaseFirestore

class HomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var products: [Product] = [] // Assume Product is a model struct/class

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchProducts()
    }

    func fetchProducts() {
        // Fetch products from Firestore or any source
        // Ensure your network call is correctly implemented
        // For example:
        // Firestore.firestore().collection("products").getDocuments { (snapshot, error) in
        //     if let error = error {
        //         print("Error fetching products: \(error)")
        //         return
        //     }
        //     // Process snapshot and populate products array
        // }
    }

    // UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            fatalError("Unable to dequeue ProductCell")
        }
        
        let product = products[indexPath.row]
        
        // Set product details safely
        cell.productNameLabel.text = product.name
        cell.productDescriptionLabel.text = product.description
        
        if let price = product.price {
            cell.priceLabel.text = String(format: "$%.2f", price)
        } else {
            cell.priceLabel.text = "N/A"
        }

        // Safe image URL handling
        if let imageUrlString = product.imageURL, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl, in: cell)
        } else {
            print("Invalid image URL: \(product.imageURL ?? "nil")")
            cell.productImageView.image = UIImage(named: "defaultImage")
        }
        
        return cell
    }

    func loadImage(from url: URL, in cell: ProductCell) {
        // Asynchronously load the image
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to load image: \(error)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            DispatchQueue.main.async {
                // Ensure that the cell is still visible
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    self.products[indexPath.row].image = image // Assuming you have an image property in your Product model
                    cell.productImageView.image = image
                }
            }
        }.resume()
    }
}
