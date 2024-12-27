import UIKit
import FirebaseFirestore
import FirebaseAuth

class CartViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet private weak var totalLabel: UILabel? {
        didSet {
            updateTotalPrice()
        }
    }
    
    // MARK: - Properties
    var cartItems: [CartItem] = [] {
        didSet {
            updateTotalPrice()
        }
    }
    private let db = Firestore.firestore()
    private var cartDocuments: [String: [String]] = [:] // productID: [documentIDs]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        fetchCartItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCart()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CartItemCell", bundle: nil), forCellReuseIdentifier: "CartItemCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 120
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCart), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func refreshCart() {
        fetchCartItems()
    }
    
    private func updateTotalPrice() {
        let total = cartItems.reduce(0) { $0 + $1.totalPrice }
        totalLabel?.text = String(format: "Total: %.3f BHD", total)
    }
    
    // MARK: - Cart Management
    private func fetchCartItems() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            tableView.refreshControl?.endRefreshing()
            return
        }
        
        db.collection("cart")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting cart items: \(error)")
                    self?.tableView.refreshControl?.endRefreshing()
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No cart items found")
                    self?.cartItems = []
                    self?.cartDocuments = [:]
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.tableView.refreshControl?.endRefreshing()
                    }
                    return
                }
                
                // Group items by productID
                var groupedItems: [String: (CartItem, [String])] = [:]
                
                for document in documents {
                    let data = document.data()
                    
                    guard let name = data["name"] as? String,
                          let price = data["price"] as? Double,
                          let quantity = data["quantity"] as? Int,
                          let imageURL = data["imageURL"] as? String,
                          let productID = data["productID"] as? String else {
                        continue
                    }
                    
                    if var existingItem = groupedItems[productID]?.0 {
                        // Update quantity for existing item
                        existingItem.quantity += quantity
                        var documentIDs = groupedItems[productID]?.1 ?? []
                        documentIDs.append(document.documentID)
                        groupedItems[productID] = (existingItem, documentIDs)
                    } else {
                        // Create new item
                        let cartItem = CartItem(
                            productName: name,
                            quantity: quantity,
                            price: price,
                            imageURL: imageURL,
                            productID: productID
                        )
                        groupedItems[productID] = (cartItem, [document.documentID])
                    }
                }
                
                // Convert grouped items to arrays
                self?.cartItems = groupedItems.values.map { $0.0 }
                self?.cartDocuments = Dictionary(uniqueKeysWithValues: groupedItems.map { ($0.key, $0.value.1) })
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
    }
    
    private func updateQuantityInFirebase(productID: String, newQuantity: Int) {
        guard let userID = Auth.auth().currentUser?.uid,
              let documentIDs = cartDocuments[productID] else { return }
        
        // If quantity is 0 or negative, delete the item
        if newQuantity <= 0 {
            deleteItemFromFirebase(productID: productID) { [weak self] success in
                if success {
                    if let index = self?.cartItems.firstIndex(where: { $0.productID == productID }) {
                        self?.cartItems.remove(at: index)
                        DispatchQueue.main.async {
                            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        }
                    }
                }
            }
            return
        }
        
        // Update all documents for this product
        let batch = db.batch()
        let quantityPerDocument = newQuantity / documentIDs.count
        let remainder = newQuantity % documentIDs.count
        
        for (index, documentID) in documentIDs.enumerated() {
            let docRef = db.collection("cart").document(documentID)
            let quantity = index == 0 ? quantityPerDocument + remainder : quantityPerDocument
            batch.updateData(["quantity": quantity], forDocument: docRef)
        }
        
        batch.commit { [weak self] error in
            if let error = error {
                print("Error updating quantities: \(error)")
            } else {
                self?.refreshCart()
            }
        }
    }
    
    private func deleteItemFromFirebase(productID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid,
              let documentIDs = cartDocuments[productID] else {
            completion(false)
            return
        }
        
        let batch = db.batch()
        
        for documentID in documentIDs {
            let docRef = db.collection("cart").document(documentID)
            batch.deleteDocument(docRef)
        }
        
        batch.commit { [weak self] error in
            if let error = error {
                print("Error removing items from cart: \(error)")
                completion(false)
            } else {
                self?.refreshCart()
                completion(true)
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }
        
        let item = cartItems[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        cell.tag = indexPath.row
        
        // Configure stepper
        cell.stepper.minimumValue = 1
        cell.stepper.maximumValue = 99
        cell.stepper.value = Double(item.quantity)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = cartItems[indexPath.row]
            deleteItemFromFirebase(productID: itemToDelete.productID) { [weak self] success in
                if success {
                    self?.cartItems.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
}

// MARK: - CartItemCellDelegate
extension CartViewController: CartItemCellDelegate {
    func quantityDidChange(at index: Int, newQuantity: Int, isIncrementing: Bool) {
        guard index < cartItems.count else { return }
        let item = cartItems[index]
        
        // Handle deletion
        if newQuantity == 0 {
            deleteItemFromFirebase(productID: item.productID) { [weak self] success in
                guard let self = self else { return }
                
                if success {
                    DispatchQueue.main.async {
                        // Make sure the index is still valid
                        guard index < self.cartItems.count else { return }
                        
                        // Remove the item from the data source first
                        self.cartItems.remove(at: index)
                        
                        // Then update the UI
                        if !self.cartItems.isEmpty {
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        } else {
                            self.tableView.reloadData()
                        }
                    }
                } else {
                    // If deletion failed, reset the stepper
                    DispatchQueue.main.async {
                        if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CartItemCell {
                            cell.stepper.value = 1
                            cell.quantityLabel.text = "1"
                        }
                    }
                }
            }
            return
        }
        
        // Otherwise update the quantity
        cartItems[index].quantity = newQuantity
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        updateQuantityInFirebase(productID: item.productID, newQuantity: newQuantity)
    }
}
