import UIKit

class OwnerCell: UITableViewCell {
    @IBOutlet weak var ownerImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    var editButtonAction: (() -> Void)?

    func configure(with owner: Owner) {
        ownerNameLabel.text = owner.name
        ownerImageView.image = UIImage(named: "placeholder") // Replace with actual image logic
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        editButtonAction?()
    }
}
