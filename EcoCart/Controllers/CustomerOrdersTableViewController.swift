//
//  CustomerOrdersTableViewController.swift
//  EcoCart
//
//  Created by Hasan Shehab on 21/12/2024.
//

import UIKit
import FirebaseFirestore
class CustomerOrdersTableViewController: UITableViewController {

    
    @IBOutlet weak var droplist: UIBarButtonItem!

    var orders: [Order] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        fetchProducts()
        createMenu()
    }
    
    
  
    
    private func fetchProducts() {
        Task {
            do {
                let db = Firestore.firestore()
                let documents = try await db.collection("orders").getDocuments()
                for document in documents.documents {
                    
                    
                    self.orders = documents.documents.map { document in
                        let data = document.data()
                        return Order(
                            productName: data["productName"] as! String,
                            productID: document.documentID,
                            userID: "user123", //temp
                            price: data["price"] as! Double,
                            status: data["pending"] as! Bool,
                            username: data["username"] as! String,
                            imageURL: data["imageURL"] as? String
                        )
                        
                    }
                }
                

                DispatchQueue.main.async {
                    
                    self.tableView.reloadData() // Reload table view
                }
            } catch {
                print("❌ Error fetching products: \(error.localizedDescription)")
                DispatchQueue.main.async {
                   
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return orders.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Step 1: Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell

        //Step 2: Fetch model object to display
        let order = orders[indexPath.row]

        //Step 3: Configure cell
        cell.update(with: order)
        cell.showsReorderControl = true

        //Step 4: Return cell
        return cell
    }

    func createMenu(){
        let command1 = UIAction(title: "Completed", handler: { _ in
            
            
        })
        let command2 = UIAction(title: "Pending", handler: { _ in
            
        })

        
        let menu = UIMenu(title: "", children: [command1, command2])
        droplist.menu = menu
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
