import UIKit

class OrderManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var markAllSwitch: UISwitch!
    @IBOutlet weak var autoProcessSwitch: UISwitch!

    var orders: [Order] = [] // Replace with your order model

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Order Management"
        setupTableView()
        loadOrders()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "OrderCell", bundle: nil), forCellReuseIdentifier: "OrderCell")
    }

    private func loadOrders() {
        // Simulate loading orders (replace with Firestore logic if needed)
        orders = [
            Order(productName: "Handbag", quantity: 85, location: "road 901, Riffa", time: "10:02 AM", status: "Pending"),
            Order(productName: "Handbag", quantity: 43, location: "road 901, Riffa", time: "10:02 AM", status: "Pending")
        ]
        tableView.reloadData()
    }

    @IBAction func markAllSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            // Mark all orders as complete
            print("All orders marked as complete.")
        }
    }

    @IBAction func autoProcessSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            // Enable automatic processing
            print("Automatic order processing enabled.")
        } else {
            // Disable automatic processing
            print("Automatic order processing disabled.")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as? OrderCell else {
            return UITableViewCell()
        }
        let order = orders[indexPath.row]
        cell.configure(with: order)
        cell.updateButtonAction = {
            self.updateOrder(order)
        }
        cell.viewButtonAction = {
            self.viewOrderDetails(order)
        }
        return cell
    }

    private func updateOrder(_ order: Order) {
        print("Updating order: \(order.productName)")
        // Navigate to an order update screen or show an update form
    }

    private func viewOrderDetails(_ order: Order) {
        print("Viewing order details: \(order.productName)")
        // Navigate to an order details screen
    }
}
