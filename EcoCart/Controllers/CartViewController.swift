import UIKit

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!

    var cartItems: [CartItem] = [] // Replace with your cart item model

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Cart"
        setupTableView()
        loadCartItems()
        updateTotalPrice()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
    }

    private func loadCartItems() {
        // Simulate loading cart items (replace with database or API call if needed)
        cartItems = [
            CartItem(productName: "Hand bag", quantity: 2, price: 7.0, location: "road 701, Manama"),
            CartItem(productName: "Hand bag", quantity: 3, price: 11.0, location: "road 701, Manama")
        ]
        tableView.reloadData()
    }

    private func updateTotalPrice() {
        let total = cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        totalPriceLabel.text = "\(String(format: "%.3f", total)) BD"
    }

    @IBAction func checkoutButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Cart", bundle: nil)
        if let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CheckoutViewController") as? CheckoutViewController {
            checkoutVC.cartTotal = cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
            navigationController?.pushViewController(checkoutVC, animated: true)
        }
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
        cell.stepperAction = { [weak self] newQuantity in
            self?.cartItems[indexPath.row].quantity = newQuantity
            self?.updateTotalPrice()
        }
        return cell
    }
}
