import UIKit
import FirebaseFirestore

class AdminHomeVC: UITabBarController, StoresListXibDelegate, UITableViewDelegate, UITableViewDataSource {

    
    
    
    var storesListTable: UITableView! // TableView declared programmatically
    var stores: [StoreModel] = []
    var activityIndicator: UIActivityIndicatorView!
    private var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupActivityIndicator()
        setupNoDataLabel()
        
        fetchStores()
    }
    
    // MARK: - Setup Table View Programmatically
    private func setupTableView() {
        // Create the table view
        storesListTable = UITableView(frame: self.view.bounds, style: .plain)
        storesListTable.translatesAutoresizingMaskIntoConstraints = false
        storesListTable.delegate = self
        storesListTable.dataSource = self
        storesListTable.rowHeight = 120
        
        // Register the custom cell
        storesListTable.register(UINib(nibName: "StoresListXib", bundle: nil), forCellReuseIdentifier: "StoresListXib")
        
        // Add the table view to the view hierarchy
        self.view.addSubview(storesListTable)
        
        // Add constraints to make the table view fill the entire view
        NSLayoutConstraint.activate([
            storesListTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            storesListTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
            storesListTable.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            storesListTable.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupNoDataLabel() {
        noDataLabel = UILabel()
        noDataLabel.text = "No stores available"
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
    
    private func fetchStores() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        // Add a snapshot listener for real-time updates
        db.collection("users").whereField("userType", isEqualTo: "storemanager").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for store updates: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            // Update the `stores` array with the latest data
            self.stores = snapshot.documents.compactMap { document in
                let data = document.data()
                
                guard let firstName = data["firstName"] as? String,
                      let lastName = data["lastName"] as? String,
                      let email = data["email"] as? String,
                      let phoneNumber = data["storeName"] as? String else {
                    return nil
                }
                
                return StoreModel(
                    id: document.documentID, // Use Firestore document ID
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    PhoneNumber: phoneNumber
                )
            }
            
            // Update UI on the main thread
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.noDataLabel.isHidden = !self.stores.isEmpty
                self.storesListTable.reloadData()
            }
        }
    }

    
    func deleteStore(cell: StoresListXib) {
        // Ensure we can get the index path of the cell
        guard let indexPath = storesListTable.indexPath(for: cell) else { return }
        
        // Get the store ID to delete
        let store = stores[indexPath.row]
        let storeID = store.id
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Delete Store",
            message: "Are you sure you want to delete this store?",
            preferredStyle: .alert
        )
        
        // Confirm delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteStoreFromFirebase(storeID: storeID, indexPath: indexPath)
        }))
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteStoreFromFirebase(storeID: String, indexPath: IndexPath) {
        let db = Firestore.firestore()
        
        // First, check if the indexPath is still valid
        guard indexPath.row < self.stores.count else {
            print("Error: indexPath.row is out of range in stores array")
            return
        }
        
        // Delete store document from Firestore
        db.collection("users").document(storeID).delete { error in
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
                // Remove the store from the local array only if the indexPath is still valid
                if indexPath.row < self.stores.count {
                    self.stores.remove(at: indexPath.row)
                    
                    // Update the table view on the main thread
                    DispatchQueue.main.async {
                        self.storesListTable.deleteRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    print("Error: indexPath.row is out of range after deletion.")
                }
            }
        }
    }

}

// MARK: - UITableView Delegate
extension AdminHomeVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeDetailsVC: StoreDetailsVC = StoreDetailsVC.instantiate(appStoryboard: .admin)
        storeDetailsVC.storeDetails = stores[indexPath.row]
        navigationController?.pushViewController(storeDetailsVC, animated: true)
    }
}

// MARK: - UITableView DataSource
extension AdminHomeVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoresListXib", for: indexPath) as! StoresListXib
        cell.addCellDatawithStoreData(storeModel: stores[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}
