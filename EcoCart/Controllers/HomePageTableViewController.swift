import UIKit
import FirebaseFirestore

class HomePageTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var isAZFiltered: Bool = false // Tracks whether A-Z filter is applied
    @IBOutlet weak var filterButton: UIButton!
    var selectedPriceOrder: String? = nil
    var selectedCategory: String? = nil
    var isAvailableFiltered: Bool? = nil
    var selectedMetric: String? = nil
    var products: [Product] = []          // All products fetched from Firestore
    var filteredProducts: [Product] = []  // Filtered products for search
    var areFiltersActive = false // To track if filters are applied
    var activityIndicator: UIActivityIndicatorView! // Loading spinner
    let db = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActivityIndicator()
        fetchProducts()
        updateFilterButtonColor()
         addProductsToFirestore()

    }
    
    // MARK: - Setup UI
    private func setupUI() {
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Setup Activity Indicator
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func fetchProducts() {
        activityIndicator.startAnimating()

        Task {
            do {
                let db = Firestore.firestore()
                let documents = try await db.collection("product").getDocuments()

                self.products = documents.documents.map { document in
                    let data = document.data()
                    return Product(
                        id: document.documentID,
                        name: data["name"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        price: data["price"] as? Double ?? 0.0,
                        imageURL: data["imageURL"] as? String,
                        averageRating: data["averageRating"] as? Int ?? 0,
                        numberOfRatings: data["numberOfRatings"] as? Int ?? 0,
                        totalRatings: data["totalRatings"] as? Int ?? 0,
                        stockQuantity: data["stockQuantity"] as? Int ?? 0,
                        category: data["Category"] as? String,
                        metrics: Product.Metrics(
                            bio: (data["metrics"] as? [String: Any])?["Bio"] as? Int ?? 0,
                            co2: (data["metrics"] as? [String: Any])?["C02"] as? Int ?? 0,
                            plastic: (data["metrics"] as? [String: Any])?["Plastic"] as? Int ?? 0,
                            tree: (data["metrics"] as? [String: Any])?["Tree"] as? Int ?? 0
                        ),
                        latitude: (data["location"] as? [String: Any])?["latitude"] as? Double ?? 0.0,
                        longitude: (data["location"] as? [String: Any])?["longtitude"] as? Double ?? 0.0,
                        storeName: data["storeName"] as? String ?? "Unknown"
                    )
                }

                // Sort products by average rating in descending order
                self.products.sort { $0.averageRating > $1.averageRating }

                // Initially show all products
                self.filteredProducts = self.products

                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch {
                print("❌ Error fetching products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }



    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let product = filteredProducts[indexPath.row]
        cell.update(with: product)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedProduct = filteredProducts[indexPath.row]
        if let productDetailsVC = ProductDetailsViewController.instantiate(with: selectedProduct.id) {
            navigationController?.pushViewController(productDetailsVC, animated: true)
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search bar is empty, keep current filters
            didApplyFilters(priceOrder: selectedPriceOrder, category: selectedCategory, availability: isAvailableFiltered, metric: selectedMetric)
        } else {
            // Start with products already filtered based on category and availability
            let filteredList = products.filter { product in
                var isValid = true

                // Apply Category Filter
                if let category = selectedCategory, product.category?.lowercased() != category.lowercased() {
                    isValid = false
                }
                
                // Apply Availability Filter
                if let availability = isAvailableFiltered, availability == true, product.stockQuantity <= 0 {
                    isValid = false
                }

                return isValid
            }
            
            // Then apply search text filtering
            filteredProducts = filteredList.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Reload only the visible section of the table view
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
    }


    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 50) // Start position below
        
        UIView.animate(withDuration: 0.2, delay: 0.02 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
            cell.alpha = 1.0
            cell.transform = .identity // Return to default position
        }, completion: nil)
    }

    
    func applyFilters() {
        filteredProducts = products

        if isAZFiltered {
            filteredProducts.sort { $0.name.lowercased() < $1.name.lowercased() }
        }
    }


    
    
    @IBAction func filterButton(_ sender: UIButton) {
        let targetStoryboard = UIStoryboard(name: "Filter", bundle: nil)
        if let destinationVC = targetStoryboard.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            destinationVC.delegate = self

            // Pass the current states to the filter screen
            destinationVC.isAZFiltered = isAZFiltered
            destinationVC.selectedPriceOrder = selectedPriceOrder
            destinationVC.selectedCategory = selectedCategory
            destinationVC.isAvailableFiltered = isAvailableFiltered
            destinationVC.selectedMetric = selectedMetric
            
            // Smooth transition
                  destinationVC.modalTransitionStyle = .crossDissolve  // Fade transition
                  destinationVC.modalPresentationStyle = .fullScreen
            
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }


    func didResetFilters() {
        isAZFiltered = false
        selectedPriceOrder = nil
        selectedCategory = nil
        selectedMetric = nil

        // Reset the filtered products to the full list
        filteredProducts = products

        // Reload the table view to reflect the reset
        tableView.reloadData()
        
        areFiltersActive = false
        updateFilterButtonColor()

    }

    
    
    func updateFilterButtonColor() {
            // Change button color based on filter state
        let filterIcon = UIImage(systemName: "line.horizontal.3.decrease.circle.fill")
        filterButton.setImage(filterIcon, for: .normal)
            UIView.animate(withDuration: 0.3) {
                self.filterButton.backgroundColor = self.areFiltersActive ? .coolLightGreen : .lightGray
            }
        }


    
    func didApplyAZFilter(az: Bool) {
        isAZFiltered = az
        
        // Update the areFiltersActive flag based on the AZ filter state
        areFiltersActive = isAZFiltered || selectedPriceOrder != nil || selectedCategory != nil || isAvailableFiltered != nil || selectedMetric != nil
        
        // Apply current filters, including A-Z filter
        didApplyFilters(priceOrder: nil, category: nil, availability: nil, metric: nil)
        
        // Update the filter button color
        updateFilterButtonColor()
    }


    func didApplyFilters(priceOrder: String?, category: String?, availability: Bool?, metric: String?) {
        // Save the selected filters
        selectedPriceOrder = priceOrder
        selectedCategory = category
        isAvailableFiltered = availability
        selectedMetric = metric

        // Start with the original product list
        filteredProducts = products

        // Apply Availability Filter
        if let availability = isAvailableFiltered, availability == true {
            filteredProducts = filteredProducts.filter { $0.stockQuantity > 0 }
        }

        // Apply Category Filter
        if let category = category {
            filteredProducts = filteredProducts.filter {
                $0.category?.lowercased() == category.lowercased()
            }
        }

        // Apply Environmental Impact Filter
        if let metric = selectedMetric, !metric.isEmpty {
            switch metric {
            case "C02":
                filteredProducts.sort { $0.metrics.co2 > $1.metrics.co2 }
            case "Plastic":
                filteredProducts.sort { $0.metrics.plastic > $1.metrics.plastic }
            case "Tree":
                filteredProducts.sort { $0.metrics.tree > $1.metrics.tree }
            default:
                break
            }
        }

        // Check if any filter is applied
        areFiltersActive = (priceOrder != nil || category != nil || availability != nil || (metric != nil && !metric!.isEmpty))
        updateFilterButtonColor()

        // Apply Sorting
        if let priceOrder = priceOrder {
            // Price sorting takes priority over all other sorting
            if priceOrder == "High To Low" {
                filteredProducts.sort { $0.price > $1.price }
            } else if priceOrder == "Low To High" {
                filteredProducts.sort { $0.price < $1.price }
            }
        } else if let metric = selectedMetric {
            // If a metric filter is applied, don't sort by A-Z or ratings
            // (Metric sorting is already applied above)
        } else if isAZFiltered {
            // A-Z sorting overrides ratings (but not price)
            filteredProducts.sort { $0.name.lowercased() < $1.name.lowercased() }
        } else {
            // Default to sorting by highest average rating when no other sorting is applied
            filteredProducts.sort { $0.averageRating > $1.averageRating }
        }

        // Reload the table view with the filtered and sorted products
        tableView.reloadData()
    }
    func addProductsToFirestore(){
        
        let Product1: [String: Any] = [
            "name": "Recycled Wool Jacket",
            "description": "Warm and durable jacket made from recycled wool.",
            "price": 129.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 40,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 4.0, // CO2 saved in KG
                "Plastic": 100, // Plastic waste reduced in grams
                "Tree": 2
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Eco Supplies"
        ]

        let Product2: [String: Any] = [
            "name": "Organic Cotton Jacket",
            "description": "Stylish jacket made from 100% organic cotton.",
            "price": 89.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 50,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 3.5, // CO2 saved in KG
                "Plastic": 90, // Plastic waste reduced in grams
                "Tree": 1
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Green Market"
        ]

        let Product3: [String: Any] = [
            "name": "Hemp Winter Jacket",
            "description": "Eco-friendly winter jacket made from sustainable hemp fibers.",
            "price": 159.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 30,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 5.0, // CO2 saved in KG
                "Plastic": 120, // Plastic waste reduced in grams
                "Tree": 3
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Life Care"
        ]

        
        let Product4: [String: Any] = [
            "name": "Organic Cotton Jeans",
            "description": "Classic jeans made from 100% organic cotton.",
            "price": 69.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 60,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 3.0, // CO2 saved in KG
                "Plastic": 50, // Plastic waste reduced in grams
                "Tree": 1
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Eco Supplies"
        ]

        let Product5: [String: Any] = [
            "name": "Recycled Denim Pants",
            "description": "Sustainable pants made from recycled denim materials.",
            "price": 79.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 40,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 4.0, // CO2 saved in KG
                "Plastic": 80, // Plastic waste reduced in grams
                "Tree": 2
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Green Market"
        ]

        let Product6: [String: Any] = [
            "name": "Hemp Cargo Pants",
            "description": "Durable cargo pants made from sustainable hemp fibers.",
            "price": 84.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 50,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 4.5, // CO2 saved in KG
                "Plastic": 100, // Plastic waste reduced in grams
                "Tree": 2
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Life Care"
        ]

        
        let Product7: [String: Any] = [
            "name": "Organic Cotton T-Shirt",
            "description": "Soft and breathable t-shirt made from organic cotton.",
            "price": 24.99,
            "imageURL": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBw0NDg0NDQ0NDQ0NDQ0NDQ0NDQ8NDQ0NFREWFhURFRUYHSggGBolGxUVITEhJSkrLi4uFx8zODMtNygtLisBCgoKDQ0OFQ8PFisZFR0rLSsrKysrLSstKys3KysrKy0rKysrKysrLTcrKzcrLS0tLS0rNysrNys3LTctKysrK//AABEIARMAtwMBIgACEQEDEQH/xAAaAAEBAQEBAQEAAAAAAAAAAAAAAQIEAwUH/8QAMhABAQABAgMGBAQGAwAAAAAAAAECAxEhMWEEMkFRcYETIpHBEqGx8CMkQmLR4RQ0Uv/EABcBAQEBAQAAAAAAAAAAAAAAAAABAgP/xAAaEQEBAQEBAQEAAAAAAAAAAAAAARECMRJR/9oADAMBAAIRAxEAPwD9oBQAAAAAAAUEFQAAAAEABEVAAAAAaUAAAAAAAFQgKAAigIAAioCAAgAAgD0AABQRQAAARQAAAAEFQBFQCotSgiKAgAPQABQAAAGblI8s9byS2Rce1uzF1sZ5/Ry5Z2pvf3wZvS47pd+SuCXb97Vv4187+p9JjsY1NTHGb27OW6uX/p52b9etPpcd2GrjlysrThk28vo3hr2c+KzpMdaMYa2N6Xyr0aREVAEVAQUBsFAAAeepn4RrUy2jnyvC3ox1VkYuVv5omjPlhuw0tRqpsCAoECKCJsqwHhqd7Gee710u0XHbe7436xz6+W2ph6ZVcZ8vWVZcH1Jdxy9l1f6b7Op0l1hEaRRAAbVFATK7Frn1M/xXozbiyJct6zr3bGtyPHtV5Tq5tN6XKPPHnfV6Y8p9XlgD1qACKigIqKg1iy1AcPar/F0/Sx7Txc3aL/Mac6WulFSXxnOO/R1PxTf6uCN6Gp+HLpebXNxLH0EJR0ZQAGwTKXbgDy1c9+EYkX14VdnKtEcmtd8nVlXJjxySrHtvxvTFjBd+/esn7+oQrYiiIqCqqCCKsZbiK+Xq/wDbx6ae/wCddlcuvP5nG/2SfnXXUVnFMo1IzlVR1dk1d/lvOfo6Xy8LcbLOcfSwu83dObrNUVGkegigxnhL9r4x427XbL2vhf8AbpZyxlm1m8SzV1ya2W0rx0ZwtevadDLb5fmnl/VP8uftHxPwbaePG8N8vDq52VqWPXDuzrbkW8WscdpJfDGT6RjxQejTMaojIlWCiAA1GasBw9qx/jY3p93Tkx2jRuWUss3xnCXlfdcLbwuNl9OBlGpF/C3hp10YaPm3Of1LXhpaLqxmyyDbJUUBoAFEUEY1JwejOpyByZPLxeudePi4tvWLWcWqCUiACKyC1ZWSAs73s6sMN45cO97O3Hk6c+M31ZjIoNIiKgAANAAAArOpyaY1OVBx5868vF6Zc68/FxdHritZxWiIBAKggG5EUVdLve33d+L5+l3vb7x3x058YvrQg0gACAAqooAACanKqzqcqDivP3ZkM7xXFxdGotSFERIACJQClEFXS73t94+hHztHv+1+z6OLpz4xVBGkAAAQGgAUQBWdTlVZz5UHz7zajMVxdG5SkBE3RACpuVkVU3VlBvR789K+jHztHvz3fRjrx4xfQWo0gAAAAqAKAAzqcr6VpnIHz8ZwakMY1s4ugVEyoiJuSVZBWakWxJAGbWr6pZ1Qa0L82Pr9n04+X2efPj7/AKPpx148Y6VFGkQAAQBQAFQBUsFBz3Q8qxdLJ1iZDXH8LJPhV3IZF1xTSqzRrsDIa4/gVZ2euwMia5J2Zr/jR0oo8cNCR7SKgKgAIqAAgAAKIoCoAoigAAqACiKAAAioAACAAgAIqAKIAqoAqoAogCgAAAAAAAAgAIAFAZABRFAVAFEUFEUAAFEAUQBRAAABAAQAZUAAAFAAAFAAUAAAAAAAKgAIAFQAf//Z",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 80,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 1.5, // CO2 saved in KG
                "Plastic": 20, // Plastic waste reduced in grams
                "Tree": 0
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Eco Supplies"
        ]

        let Product8: [String: Any] = [
            "name": "Hemp Polo Shirt",
            "description": "Sustainable polo shirt made from hemp fibers.",
            "price": 39.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 70,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 2.0, // CO2 saved in KG
                "Plastic": 25, // Plastic waste reduced in grams
                "Tree": 1
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Green Market"
        ]

        let Product9: [String: Any] = [
            "name": "Recycled Polyester Shirt",
            "description": "Eco-friendly shirt made from recycled polyester fibers.",
            "price": 34.99,
            "imageURL": "data:image/jpeg;base64,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",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 60,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 2.5, // CO2 saved in KG
                "Plastic": 60, // Plastic waste reduced in grams
                "Tree": 0
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Life Care"
        ]

        let Product10: [String: Any] = [
            "name": "Bamboo Long Sleeve Shirt",
            "description": "Comfortable long sleeve shirt made from sustainable bamboo fibers.",
            "price": 44.99,
            "imageURL": "data:image/jpeg;base64,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EREBERAREQEREBERAREQEREBERAREQEREBERAREQEREBERAREQEREBERAREQEREBERB//9k=",
            "averageRating": 0,
            "numberOfRatings": 0,
            "totalRatings": 0,
            "stockQuantity": 50,
            "Category": "Clothes",
            "metrics": [
                "Bio": true,
                "CO2": 3.0, // CO2 saved in KG
                "Plastic": 40, // Plastic waste reduced in grams
                "Tree": 1
            ],
            "latitude": 0.0,
            "longitude": 0.0,
            "storeName": "Eco Supplies"
        ]



        //self.db.collection("product").addDocument(data: Product1)
     //  self.db.collection("product").addDocument(data: Product2)
     //  self.db.collection("product").addDocument(data: Product3)
     //  self.db.collection("product").addDocument(data: Product4)
      // self.db.collection("product").addDocument(data: Product5)
      // self.db.collection("product").addDocument(data: Product6)
      // self.db.collection("product").addDocument(data: Product7)
   // self.db.collection("product").addDocument(data: Product8)
    self.db.collection("product").addDocument(data: Product9)
    self.db.collection("product").addDocument(data: Product10)

    }
    // Add more products similarly for the rest of the list...
    



}
