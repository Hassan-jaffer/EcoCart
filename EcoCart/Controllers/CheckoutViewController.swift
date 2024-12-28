import UIKit
import FirebaseFirestore

class CheckoutViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var cardSwitch: UISwitch!
    @IBOutlet weak var cashOnDeliverySwitch: UISwitch!

    // MARK: - Properties
    var totalAmount: Double = 0.0 // Passed from CartViewController
    var userID: String = "user123" // Replace with actual user ID from authentication
    var username: String = "hasan Shehab" // Replace with actual username from user profile
    var cartItems: [CartItem] = [] // Passed from CartViewController
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Calculate the total amount from cart items
        totalAmount = cartItems.reduce(0) { $0 + $1.totalPrice }
        // Display the total amount
        totalAmountLabel.text = String(format: "Total Amount: %.3f BHD", totalAmount)
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        // Determine the selected payment method
        let paymentMethod = cardSwitch.isOn ? "Card" : "Cash on Delivery"

        // Save the order to Firestore
        saveOrder(paymentMethod: paymentMethod) { [weak self] success in
            if success {
                if self?.cardSwitch.isOn == true {
                    // Navigate to PaymentDetailsViewController if Card is selected
                    self?.performSegue(withIdentifier: "toPaymentDetails", sender: nil)
                } else {
                    // Show success message for Cash on Delivery
                    self?.showSuccessAlert(message: "Order confirmed with Cash on Delivery.")
                }
            } else {
                self?.showErrorAlert(message: "Failed to save the order. Please try again.")
            }
        }
    }

    private func saveOrder(paymentMethod: String, completion: @escaping (Bool) -> Void) {
        

        // Save each cart item as a separate order document
        for item in cartItems {
            let data: [String: Any] = [
            
                "userID": userID,
                "username": username,
                "productName": item.productName,
                "price": item.price,
                "quantity": item.quantity,
                "imageURL": item.imageURL,
                "stockQuantity": item.stockQuantity,
                "pending": true,
                "paymentMethod": paymentMethod
            ]
        

            db.collection("orders").addDocument(data: data) { error in
                if let error{
                    self.showErrorAlert(message: error.localizedDescription)
                    completion(false)
                } else {
                    self.showSuccessAlert(message: "Successfully ordered!")
                    completion(true)
                }
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPaymentDetails", let destination = segue.destination as? PaymentDetailsViewController {
            // Pass total amount and user info to PaymentDetailsViewController
            destination.totalAmount = totalAmount
            destination.userID = userID
            destination.username = username
        }
    }
}
