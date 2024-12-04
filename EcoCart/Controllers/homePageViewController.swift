import UIKit

class homePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // Connect the collection view to the storyboard

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Data Model
    struct Product {
        let name: String
        let price: Double
        let seller: String
        let imageName: String
    }

    // Array of products
    let products = [
        Product(name: "T-Shirt", price: 19.99, seller: "Seller A", imageName: "tshirt"),
        Product(name: "Shoes", price: 49.99, seller: "Seller B", imageName: "shoes"),
        Product(name: "Bag", price: 29.99, seller: "Seller C", imageName: "bag")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the data source and delegate for the collection view
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell

        let product = products[indexPath.item]

        // Configure the cell using outlets in ProductCell
        cell.productNameOutlet.text = product.name
        cell.priceOutlet.text = "$\(product.price)"
        cell.sellerOutlet.text = product.seller
        cell.imageOutlet.image = UIImage(named: product.imageName)

        return cell
    }

    // MARK: - UICollectionViewDelegate (Optional)

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.item]
        print("Selected product: \(selectedProduct.name)")
    }
}
    
