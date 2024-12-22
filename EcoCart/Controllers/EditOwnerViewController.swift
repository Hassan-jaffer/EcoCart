import UIKit

class EditOwnerViewController: UIViewController {
    @IBOutlet weak var ownerNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    var owner: Owner?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Owner"
        if let owner = owner {
            ownerNameTextField.text = owner.name
        }
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let name = ownerNameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a name.")
            return
        }

        print("Saving owner: \(name)")
        // Save updated owner details to database
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
