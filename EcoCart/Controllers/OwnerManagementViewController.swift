import UIKit

class OwnerManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var owners: [Owner] = [] // Replace with your owner model

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Store Owners"
        setupTableView()
        loadOwners()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "OwnerCell", bundle: nil), forCellReuseIdentifier: "OwnerCell")
    }

    private func loadOwners() {
        // Simulate loading owners (replace with Firestore logic if needed)
        owners = [
            Owner(name: "Ali"),
            Owner(name: "Hasan"),
            Owner(name: "Malik")
        ]
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return owners.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OwnerCell", for: indexPath) as? OwnerCell else {
            return UITableViewCell()
        }
        let owner = owners[indexPath.row]
        cell.configure(with: owner)
        cell.editButtonAction = {
            self.editOwner(owner)
        }
        return cell
    }

    private func editOwner(_ owner: Owner) {
        print("Editing owner: \(owner.name)")
        // Navigate to an owner edit screen or show an edit form
    }
}
