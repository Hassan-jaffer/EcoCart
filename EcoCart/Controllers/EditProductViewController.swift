import UIKit
import FirebaseFirestore

class EditProductViewController: UIViewController {
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productDescriptionTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var categoryPicker: UIPickerView! // Optional
    @IBOutlet weak var productImageView: UIImageView!

    var product: Product? // Pass the product to edit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Product"
        setupUI()
    }
    
    private func setupUI() {
        guard let product = product else { return }
        productNameTextField.text = product.name
        productDescriptionTextField.text = product.description
        priceTextField.text = "\(product.price)"
        quantityStepper.value = Double(product.stockQuantity)
        quantityLabel.text = "\(product.stockQuantity)"
        // Load product image if available
        if let imageUrl = product.imageURL, let url = URL(string: imageUrl) {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.productImageView.image = image
                }
            }
        }.resume()
    }

    @IBAction func quantityStepperChanged(_ sender: UIStepper) {
        quantityLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = productNameTextField.text, !name.isEmpty,
              let description = productDescriptionTextField.text, !description.isEmpty,
              let priceText = priceTextField.text, let price = Double(priceText) else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        guard let product = product else { return }

        let updatedProduct = Product(
            id: product.id,
            name: productNameTextField.text ?? product.name,
            description: productDescriptionTextField.text ?? product.description,
            price: Double(priceTextField.text ?? "") ?? product.price,
            imageURL: product.imageURL, // Keep the original imageURL
            averageRating: product.averageRating,
            numberOfRatings: product.numberOfRatings,
            totalRatings: product.totalRatings,
            stockQuantity: Int(quantityStepper.value),
            category: product.category,
            metrics: product.metrics,
            latitude: product.latitude,  // Keep original latitude
            longitude: product.longitude, // Keep original longitude
            storeName: product.storeName  // Keep original store name
        )
        
        saveProductToFirestore(updatedProduct)
    }
    
    private func saveProductToFirestore(_ product: Product) {
        let db = Firestore.firestore()
        let productRef = db.collection("product").document(product.id)
        
        productRef.updateData([
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "stockQuantity": product.stockQuantity
        ]) { error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.showAlert(title: "Success", message: "Product updated successfully.") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}
