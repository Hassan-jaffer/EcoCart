import UIKit

class OrderCell: UITableViewCell {
    
    
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var imageURL: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    
    override func awakeFromNib() {
            super.awakeFromNib()
            // Any additional setup after loading the view
        }
    
    func update(with order: Order) {
        name.text = order.productName
        username.text = order.username
        if(order.status){
            status.text = "Pending"
        }
        else{
            status.text = "Completed"
        }
        
        if let imageUrlString = order.imageURL, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        } else {
            imageURL.image = UIImage(named: "defaultImage")
        }
    }
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error loading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.imageURL.image = UIImage(named: "defaultImage")
                }
            } else if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageURL.image = image
                }
            }
        }.resume()
    }
}
