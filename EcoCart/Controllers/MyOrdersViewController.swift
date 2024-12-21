import UIKit

class MyOrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    let orderCategories = ["Paid On Delivery Orders", "Completed Orders", "Pending Orders", "On The Way"]
    var orders: [[Order]] = [] // Replace with Firestore or database logic

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Active Orders"
        setupTableView()
        loadOrders()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCategoryCell")
    }

    private func loadOrders() {
        // Simulated data (replace with Firestore or database logic)
        orders = [
            [Order(productName: "Hand bag", quantity: 2, location: "road 701, Manama", time: "01:54:23", status: "Paid")], // Paid On Delivery
            [Order(productName: "Hand bag", quantity: 1, location: "road 901, Riffa", time: "03:12:10", status: "Completed")], // Completed
            [Order(productName: "Hand bag", quantity: 5, location: "road 701, Manama", time: "Pending", status: "Pending")], // Pending
            [Order(productName: "Hand bag", quantity: 3, location: "road 701, Riffa", time: "ET 4 Days", status: "On The Way")] // On The Way
        ]
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return orderCategories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return orderCategories[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCategoryCell", for: indexPath)
        let order = orders[indexPath.section][indexPath.row]
        cell.textLabel?.text = "\(order.productName) - Quantity: \(order.quantity) - \(order.location)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigateToExpandedOrderList(category: orderCategories[indexPath.section])
    }

    private func navigateToExpandedOrderList(category: String) {
        let storyboard = UIStoryboard(name: "MyOrders", bundle: nil)
        if let expandedOrderListVC = storyboard.instantiateViewController(withIdentifier: "ExpandedOrderListViewController") as? ExpandedOrderListViewController {
            expandedOrderListVC.category = category
            expandedOrderListVC.orders = orders.first(where: { $0.first?.status == category }) ?? []
            navigationController?.pushViewController(expandedOrderListVC, animated: true)
        }
    }
}
