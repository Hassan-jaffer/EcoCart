import UIKit
import FirebaseFirestore

class HomePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
       
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
           
           // Register the ProductCell class
           collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
       }
       
       // Fetch product from Firestore
       private func fetchProducts() {
           Task {
               do {
                   let db = Firestore.firestore()
                   let productId = "0"  // The product ID in Firebase
                   let docRef = db.collection("product").document(productId)
                   let document = try await docRef.getDocument()
                   
                   if let data = document.data() {
                       self.products = [
                           Product(
                               id: document.documentID,
                               name: data["name"] as? String ?? "",
                               description: data["description"] as? String ?? "",
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
                       print("❌ No product found for ID \(productId)")
                   }
               } catch {
                   print("❌ Error fetching product: \(error)")
               }
           }
       }
   }

   // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
   extension HomePageViewController {
       
       // Number of items in section
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return products.count
       }
       
       // Configure the cell
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
           
           let product = products[indexPath.row]
           
           // Set product data to the cell
           cell.productNameLabel.text = product.name
           cell.priceLabel.text = String(format: "$%.2f", product.price)
           cell.productDescriptionLabel.text = product.description
           
           // Load image using loadImage function
           if let imageUrl = URL(string: product.imageURL) {
               loadImage(from: imageUrl, in: cell)
           }
           
           return cell
       }
       
   }

   // MARK: - Image Loading
   extension HomePageViewController {
       
       // Load image from URL
       private func loadImage(from url: URL, in cell: ProductCell) {
           URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
               if let data = data, let image = UIImage(data: data) {
                   DispatchQueue.main.async {
                       // Set image for the specific cell's image view
                       cell.productImageView.image = image
                   }
               } else {
                   print("Error loading image: \(error?.localizedDescription ?? "No error")")
               }
           }.resume()
       }
}
