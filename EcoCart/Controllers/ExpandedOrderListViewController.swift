import UIKit

class ExpandedOrderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var category: String?
    var orders: [Order] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category ?? "Orders"
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExpandedOrderCell")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedOrderCell", for: indexPath)
        let order = orders[indexPath.row]
        cell.textLabel?.text = "\(order.productName) - Quantity: \(order.quantity) - \(order.location)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigateToCancelOrder(order: orders[indexPath.row])
    }

    private func navigateToCancelOrder(order: Order) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let cancelOrderVC = storyboard.instantiateViewController(withIdentifier: "CancelOrderViewController") as? CancelOrderViewController {
            cancelOrderVC.order = order
            navigationController?.pushViewController(cancelOrderVC, animated: true)
        }
    }
}
