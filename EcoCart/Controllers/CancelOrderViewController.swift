import UIKit

class CancelOrderViewController: UIViewController {
    @IBOutlet weak var orderDetailsLabel: UILabel!
    @IBOutlet weak var reasonTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    var order: Order?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Cancel Order"
        setupUI()
    }

    private func setupUI() {
        if let order = order {
            orderDetailsLabel.text = "\(order.productName) - Quantity: \(order.quantity) - \(order.location)"
        }
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let reason = reasonTextField.text, !reason.isEmpty else {
            showAlert(title: "Error", message: "Please provide a reason for cancellation.")
            return
        }

        print("Order canceled for reason: \(reason)")
        // Handle cancellation logic (e.g., Firestore update)

        navigationController?.popToRootViewController(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
