import UIKit

class PaymentDetailsViewController: UIViewController {
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var cardholderNameTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!

    var paymentMethod: String = "Card" // Default to Card
    var totalAmount: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment Details"
        setupUI()
    }

    private func setupUI() {
        paymentMethodLabel.text = "Payment Method: \(paymentMethod)"
        totalAmountLabel.text = "\(String(format: "%.3f", totalAmount)) BD"

        // Hide card details if payment method is not "Card"
        let isCardPayment = paymentMethod == "Card"
        cardholderNameTextField.isHidden = !isCardPayment
        cardNumberTextField.isHidden = !isCardPayment
        expiryDateTextField.isHidden = !isCardPayment
        cvvTextField.isHidden = !isCardPayment
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        if paymentMethod == "Card" {
            // Validate card details
            guard let cardholderName = cardholderNameTextField.text, !cardholderName.isEmpty,
                  let cardNumber = cardNumberTextField.text, cardNumber.count == 16,
                  let expiryDate = expiryDateTextField.text, !expiryDate.isEmpty,
                  let cvv = cvvTextField.text, cvv.count == 3 else {
                showAlert(title: "Error", message: "Please fill in all card details.")
                return
            }
            
            print("Card Payment Details:")
            print("- Cardholder Name: \(cardholderName)")
            print("- Card Number: \(cardNumber)")
            print("- Expiry Date: \(expiryDate)")
            print("- CVV: \(cvv)")
        }
        
        // Show success alert and navigate to home screen
        showSuccessAlert()
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Your order is on the way!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigateToHomeScreen()
        })
        present(alert, animated: true)
    }

    private func navigateToHomeScreen() {
        navigationController?.popToRootViewController(animated: true)
    }


    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
