import UIKit
import FirebaseFirestore

class AddProductManagementViewController: UIViewController {
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productDescriptionTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!

    private let categories = ["Electronics", "Fashion", "Groceries", "Home", "Other"] // Example categories
    private var selectedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Product"
        setupUI()
    }

    private func setupUI() {
        quantityStepper.value = 1
        quantityLabel.text = "1"
//        categoryPicker.delegate = self
//        categoryPicker.dataSource = self
        selectedCategory = categories.first // Default category
    }

    @IBAction func quantityStepperChanged(_ sender: UIStepper) {
        quantityLabel.text = "\(Int(sender.value))"
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let name = productNameTextField.text, !name.isEmpty,
              let description = productDescriptionTextField.text, !description.isEmpty,
              let priceText = priceTextField.text, let price = Double(priceText) else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        guard let category = selectedCategory else {
            showAlert(title: "Error", message: "Please select a category.")
            return
        }

        saveProductToFirestore(
            name: name,
            description: description,
            price: price,
            stockQuantity: Int(quantityStepper.value),
            category: category
        )
    }

    private func saveProductToFirestore(name: String, description: String, price: Double, stockQuantity: Int, category: String) {
        let db = Firestore.firestore()
        let productRef = db.collection("product").document()
        
        let productData: [String: Any] = [
            "name": name,
            "description": description,
            "price": price,
            "stockQuantity": stockQuantity,
            "category": category,
            "imageURL": "", // Add image upload logic later
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "metrics": [
                "Bio": 0,
                "C02": 0,
                "Plastic": 0,
                "Tree": 0
            ]
        ]

        productRef.setData(productData) { error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.showAlert(title: "Success", message: "Product added successfully.") {
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

//extension AddProductViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }

//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return categories.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
////        return categories[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
////        selectedCategory = categories[row]
//    }
