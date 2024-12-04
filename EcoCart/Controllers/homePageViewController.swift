import UIKit

class homePageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    let products = [
        Product(name: "T-Shirt", imageName: "tshirt", price: 19.99),
        Product(name: "Shoes", imageName: "shoes", price: 49.99),
        Product(name: "Bag", imageName: "bag", price: 29.99)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = products[indexPath.item]

        cell.productNameLabel.text = product.name
        cell.productImageView.image = UIImage(named: product.imageName)
        cell.productPriceLabel.text = "$\(product.price)"

        return cell
    }
}
