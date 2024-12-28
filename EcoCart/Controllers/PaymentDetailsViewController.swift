import UIKit
import FirebaseFirestore

class PaymentDetailsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var creditCardTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var totalAmountLabel: UILabel!

    // MARK: - Properties
    var totalAmount: Double = 0.0 // Passed from CheckoutViewController
    var userID: String = "" // Passed from CheckoutViewController
    var username: String = "" // Passed from CheckoutViewController
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Display the total amount
        totalAmountLabel.text = String(format: "Total Amount: %.3f BHD", totalAmount)
    }

    @IBAction func confirmPaymentButtonTapped(_ sender: UIButton) {
        // Validate user input
        guard let fullName = fullNameTextField.text, !fullName.isEmpty,
              let creditCard = creditCardTextField.text, !creditCard.isEmpty,
              let expiryDate = expiryDateTextField.text, !expiryDate.isEmpty,
              let cvv = cvvTextField.text, !cvv.isEmpty else {
            showErrorAlert(message: "Please fill in all fields.")
            return
        }

        // Save payment details to Firestore
        savePaymentDetails(fullName: fullName, creditCard: creditCard, expiryDate: expiryDate, cvv: cvv)
    }

    private func savePaymentDetails(fullName: String, creditCard: String, expiryDate: String, cvv: String) {
        let paymentDetails: [String: Any] = [
            "fullName": fullName,
            "creditCard": creditCard,
            "expiryDate": expiryDate,
            "cvv": cvv,
            "pending": false // Mark as processed
        ]

        db.collection("orders").whereField("userID", isEqualTo: userID).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching orders: \(error)")
                self?.showErrorAlert(message: "Failed to update payment details. Please try again.")
                return
            }

            guard let documents = snapshot?.documents else { return }
            let batch = self?.db.batch()

            // Update all pending orders for this user
            for document in documents {
                let ref = document.reference
                batch?.updateData(paymentDetails, forDocument: ref)
            }

            batch?.commit { error in
                if let error = error {
                    print("Error updating payment details: \(error)")
                    self?.showErrorAlert(message: "Failed to update payment details. Please try again.")
                } else {
                    self?.showSuccessAlert(message: "Payment successful!")
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
}
