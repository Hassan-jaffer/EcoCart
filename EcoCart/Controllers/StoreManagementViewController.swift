import UIKit

class StoreManagementViewController: UIViewController {
    @IBAction func manageProductsTapped(_ sender: UIButton) {
        navigateToStoryboard(withIdentifier: "ManageProductsViewController")
    }

    @IBAction func manageOrdersTapped(_ sender: UIButton) {
        navigateToStoryboard(withIdentifier: "ManageOrdersViewController")
    }

    @IBAction func manageOwnersTapped(_ sender: UIButton) {
        navigateToStoryboard(withIdentifier: "ManageOwnersViewController")
    }

    @IBAction func deleteStoreTapped(_ sender: UIButton) {
        navigateToStoryboard(withIdentifier: "DeleteStoreViewController")
    }

    private func navigateToStoryboard(withIdentifier storyboardID: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" if using a different storyboard
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardID)
        navigationController?.pushViewController(viewController, animated: true)
    }
    override func viewDidLoad() {
        
    }

}
