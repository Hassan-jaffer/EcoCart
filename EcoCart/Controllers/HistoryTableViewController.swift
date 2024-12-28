import UIKit
import FirebaseFirestore

class HistoryTableViewController: UITableViewController {
    
    var orders: [History] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchOrders()
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func fetchOrders() {
        let db = Firestore.firestore()
        db.collection("orders").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching orders: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No orders found")
                return
            }
            
            self.orders = documents.compactMap { History(dictionary: $0.data()) }
            // Filter out orders that have no name
            self.orders = self.orders.filter { order in
                if let name = order.productName {
                    return !name.isEmpty
                }
                return false
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryTableViewCell
        let order = orders[indexPath.row]
        cell.configureCell(order: order)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
