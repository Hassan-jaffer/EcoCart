//
//  StoreHomeVC.swift
//  EcoCart
//
//  Created by Huzaifa Abbasi on 27/12/2024.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth
class StoreHomeVC: UITabBarController, UITableViewDelegate, UITableViewDataSource, ProductXibTableViewDelegate {

    
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
extension StoreHomeVC {
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
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: User is not logged in or email is unavailable")
            activityIndicator.stopAnimating()
            return
        }
        
        let db = Firestore.firestore()
        
        // Set up a listener for real-time updates
        db.collection("product")
            .whereField("storeName", isEqualTo: userEmail)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
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
                    guard let name = data["name"] as? String else {
                        print("Invalid or missing field: name in document \(document.documentID)")
                        return nil
                    }

                    guard let imageURL = data["imageURL"] as? String else {
                        print("Invalid or missing field: imageURL in document \(document.documentID)")
                        return nil
                    }

                    guard let description = data["description"] as? String else {
                        print("Invalid or missing field: description in document \(document.documentID)")
                        return nil
                    }

                    guard let stockQuantity = data["stockQuantity"] as? Double else {
                        print("Invalid or missing field: stockQuantity in document \(document.documentID)")
                        return nil
                    }

                    guard let category = data["Category"] as? String else {
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
        
        // Delete store document from Firestore
        db.collection("product").document(productID).delete { error in
            if let error = error {
                // Handle error (e.g., show an alert)
                print("Error deleting store: \(error.localizedDescription)")
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Failed to delete the store. Please try again.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            } else {
                // Remove the store from the local array and update the table view
                self.products.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.productsListTable.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}

// MARK: - UITableView Delegate
extension StoreHomeVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productDetailsVC: ProductDetailsVC = ProductDetailsVC.instantiate(appStoryboard: .stores)
        productDetailsVC.productDetails = products[indexPath.row]
        navigationController?.pushViewController(productDetailsVC, animated: true)
    }
}

// MARK: - UITableView DataSource
extension StoreHomeVC {
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

