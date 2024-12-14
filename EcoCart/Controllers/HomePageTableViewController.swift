import UIKit
import FirebaseFirestore

class HomePageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    

   
    var products: [Product] = [] // All products fetched from Firestore
    var filteredProducts: [Product] = [] // Products matching search/filter criteria
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //setupTableView()
        fetchProducts()
    }
    

    
   
    
    // MARK: - Fetch Products from Firestore
    private func fetchProducts() {
        Task {
            do {
                let db = Firestore.firestore()
                let documents = try await db.collection("product").getDocuments()
                
                self.products = documents.documents.map { document in
                    let data = document.data()
                    return Product(
                        id: document.documentID,
                        name: data["name"] as? String ?? "No Name",
                        description: data["description"] as? String ?? "No Description",
                        price: data["price"] as? Double ?? 0.0,
                        imageURL: data["imageURL"] as? String,
                        averageRating: data["averageRating"] as? Int ?? 0,
                        numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
                        totalRatings: data["totalRatings"] as? Int ?? 0,
                        stockQuantity: data["stockQuantity"] as? Int ?? 0,
                        metrics: Product.parseMetrics(from: data)
                    )
                }
                
                self.filteredProducts = self.products // Initially, show all products
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Error fetching products: \(error.localizedDescription)")
            }
        }
    }
    
    

    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return products.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return products.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Step 1: Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell

        //Step 2: Fetch model object to display
        let product = products[indexPath.row]

        //Step 3: Configure cell
        cell.update(with: product)
        cell.showsReorderControl = true

        //Step 4: Return cell
        return cell
    }

    
    // MARK: - Load Images
    
    

}
