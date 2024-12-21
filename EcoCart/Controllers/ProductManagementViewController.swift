import UIKit

class ProductManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var products: [Product] = [] // Replace with your product model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Product Management"
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
    }
    
    @IBAction func addProductTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let addProductVC = storyboard.instantiateViewController(withIdentifier: "AddProductManagementViewController") as? AddProductViewController {
            navigationController?.pushViewController(addProductVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UITableViewCell()
        }
        let product = products[indexPath.row]
//        cell.configure(with: product)
//        cell.notifyButtonAction = {
//            self.showNotifyAlert(for: product)
//        }
//        cell.editButtonAction = {
//            self.navigateToEditProduct(product: product)
//        }
        return cell
    }
    
    private func showNotifyAlert(for product: Product) {
        let alert = UIAlertController(title: "Notified!", message: "We are excited to deliver your products!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToEditProduct(product: Product) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let editProductVC = storyboard.instantiateViewController(withIdentifier: "EditProductViewController") as? EditProductViewController {
            editProductVC.product = product
            navigationController?.pushViewController(editProductVC, animated: true)
        }
    }
}
