import UIKit

class CheckoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cardSwitch: UISwitch!
    @IBOutlet weak var cashSwitch: UISwitch!
    @IBOutlet weak var deliveryNotesTextField: UITextField!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!

    var cartItems: [CartItem] = [] // Replace with your cart item model
    var deliveryFee: Double = 1.0
    var cartTotal: Double = 0.0


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Checkout"
        setupTableView()
        updatePaymentSummary()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
    }

    private func updatePaymentSummary() {
        let subtotal = cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        let totalAmount = subtotal + deliveryFee
        subtotalLabel.text = "\(String(format: "%.3f", subtotal)) BD"
        deliveryFeeLabel.text = "\(String(format: "%.3f", deliveryFee)) BD"
        totalAmountLabel.text = "\(String(format: "%.3f", totalAmount)) BD"
    }

    @IBAction func cardSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            cashSwitch.setOn(false, animated: true)
        }
    }

    @IBAction func cashSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            cardSwitch.setOn(false, animated: true)
        }
    }

    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        let paymentMethod = cardSwitch.isOn ? "Card" : "Cash on Delivery"
        let deliveryNotes = deliveryNotesTextField.text ?? ""

        print("Order confirmed with:")
        print("- Payment Method: \(paymentMethod)")
        print("- Delivery Notes: \(deliveryNotes)")
        print("- Total Amount: \(totalAmountLabel.text ?? "")")

        // Proceed to a success screen or perform backend submission
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }
        let cartItem = cartItems[indexPath.row]
        cell.configure(with: cartItem)
        return cell
    }
}
