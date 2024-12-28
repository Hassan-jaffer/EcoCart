//
//  StoreHomeVC.swift
//  EcoCart
//
//  Created by ali on 27/12/2024.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth
class StoreOrderVC: UITabBarController, UITableViewDelegate, UITableViewDataSource, ProductXibTableViewDelegate {

    
    var productsListTable: UITableView! // TableView declared programmatically
    var products: [ProductModel] = []
    var activityIndicator: UIActivityIndicatorView!
    private var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupActivityIndicator()
        setupNoDataLabel()
        
        fetchProducts()
    }
}


// MARK: - Setup Table View Programmatically
extension StoreOrderVC {
    private func setupTableView() {
        // Create the table view
        productsListTable = UITableView(frame: self.view.bounds, style: .plain)
        productsListTable.translatesAutoresizingMaskIntoConstraints = false
        productsListTable.delegate = self
        productsListTable.dataSource = self
        productsListTable.rowHeight = 150
        
        // Register the custom cell
        productsListTable.register(UINib(nibName: "ProductXibTableView", bundle: nil), forCellReuseIdentifier: "ProductXibTableView")
        
        // Add the table view to the view hierarchy
        self.view.addSubview(productsListTable)
        
        // Add constraints to make the table view fill the entire view
        NSLayoutConstraint.activate([
            productsListTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            productsListTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            productsListTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            productsListTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
    }
    
    // MARK: - Setup Loader
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupNoDataLabel() {
        noDataLabel = UILabel()
        noDataLabel.text = "No Products available"
        noDataLabel.textColor = .gray
        noDataLabel.textAlignment = .center
        noDataLabel.font = UIFont.systemFont(ofSize: 18)
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noDataLabel)
        
        // Center the label in the view
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        noDataLabel.isHidden = true // Hide by default
    }
    
    
    // MARK: - Fetch Products
    private func fetchProducts() {
        activityIndicator.startAnimating()
        
        guard let id = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in or email is unavailable")
            activityIndicator.stopAnimating()
            return
        }
        
        let db = Firestore.firestore()
        getUser(id: id) { storeName in
            guard let storeName = storeName else {
                print("Failed to fetch store name.")
                return
            }
            db.collection("orders")
                .whereField("storeName", isEqualTo: storeName)
                .addSnapshotListener { [weak self] querySnapshot, error in
                    guard let self = self else { return }
                    
                    // Set up a listener for real-time updates
                    
                    
                    if let error = error {
                        print("Error fetching products: \(error.localizedDescription)")
                        self.activityIndicator.stopAnimating()
                        self.noDataLabel.isHidden = false
                        return
                    }
                    
                    // Parse the Firestore documents into ProductModel instances
                    self.products = querySnapshot?.documents.compactMap { document in
                        let data = document.data()
                        print("Data is: \(data)")
                        guard let name = data["username"] as? String else {
                            print("Invalid or missing field: name in document \(document.documentID)")
                            return nil
                        }
                        
                        guard let imageURL = data["imageURL"] as? String else {
                            print("Invalid or missing field: imageURL in document \(document.documentID)")
                            return nil
                        }
                        
                        guard let description = data["productName"] as? String else {
                            print("Invalid or missing field: description in document \(document.documentID)")
                            return nil
                        }
                        
                        guard let stockQuantity = data["pending"] as? Bool else {
                            print("Invalid or missing field: stockQuantity in document \(document.documentID)")
                            return nil
                        }
                        
                        guard let category = data["userID"] as? String else {
                            print("Invalid or missing field: Category in document \(document.documentID)")
                            return nil
                        }
                        
                        guard let price = data["price"] as? Double else {
                            print("Invalid or missing field: price in document \(document.documentID)")
                            return nil
                        }
                        
                        return ProductModel(
                            id: document.documentID, // Firestore document ID
                            productImage: imageURL,
                            productName: name,
                            productDescription: description,
                            productCategory: category,
                            productQuantity: String(stockQuantity),
                            productPrice: String(price)
                        )
                    } ?? []
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.noDataLabel.isHidden = !self.products.isEmpty
                        self.productsListTable.reloadData()
                    }
                }
        }
    }


    
    // MARK: - Delete Product
    func deleteProduct(cell: ProductXibTableView) {
        // Ensure we can get the index path of the cell
        guard let indexPath = productsListTable.indexPath(for: cell) else { return }
        
        // Get the store ID to delete
        let product = products[indexPath.row]
        let productID = product.id
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Store",
            message: "Are you sure you want to delete this product?",
            preferredStyle: .alert
        )
        
        // Confirm delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteProductFromFirebase(productID: productID, indexPath: indexPath)
        }))
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteProductFromFirebase(productID: String, indexPath: IndexPath) {
        let db = Firestore.firestore()
        
        // First, check if the indexPath.row is still valid
        guard indexPath.row < self.products.count else {
            print("Error: indexPath.row is out of range in products array")
            return
        }
        
        // Delete product document from Firestore
        db.collection("product").document(productID).delete { error in
            if let error = error {
                // Handle error (e.g., show an alert)
                print("Error deleting product: \(error.localizedDescription)")
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Failed to delete the product. Please try again.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                // Only proceed to remove the product from the local array if the index is valid
                if indexPath.row < self.products.count {
                    self.products.remove(at: indexPath.row)
                    
                    // Update the table view on the main thread
                    DispatchQueue.main.async {
                        self.productsListTable.deleteRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    print("Error: indexPath.row is out of range after deletion.")
                }
            }
        }
    }
    
    func getUser(id: String, completion: @escaping (String?) -> Void) {
        let userdb = Firestore.firestore()
        let userRef = userdb.collection("users").document(id)
        Task {
            do{
                let doc = try await userRef.getDocument()
                
                guard let data = doc.data() else {
                    print("❌ No data found for ID: \(id)")
                    completion(nil)
                    return
                }
                let storeName = data["storeName"] as? String ?? ""
                completion(storeName)
            }
            catch{
                print("Error getting user: \(error)")
                completion(nil)
            }
        }
    }

}

// MARK: - UITableView Delegate
extension StoreOrderVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productDetailsVC: ProductDetailsVC = ProductDetailsVC.instantiate(appStoryboard: .stores)
        productDetailsVC.productDetails = products[indexPath.row]
        navigationController?.pushViewController(productDetailsVC, animated: true)
    }
}

// MARK: - UITableView DataSource
extension StoreOrderVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductXibTableView", for: indexPath) as! ProductXibTableView
        cell.addCellDatawithProductData(productModel: products[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

