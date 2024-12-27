import UIKit

protocol CartItemCellDelegate: AnyObject {
    func quantityDidChange(at index: Int, newQuantity: Int)
}

class CartItemCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    // MARK: - Properties
    weak var delegate: CartItemCellDelegate?
    private var item: CartItem?
    private var imageTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
    }
    
    private func setupImageView() {
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = .systemGray6
    }
    
    // MARK: - Configuration
    func configure(with item: CartItem) {
        self.item = item
        
        productNameLabel.text = item.productName
        quantityLabel.text = "\(item.quantity)"
        priceLabel.text = String(format: "%.3f BHD", item.totalPrice)
        
        stepper.value = Double(item.quantity)
        stepper.minimumValue = 1
        stepper.maximumValue = 99
        
        // Load image using URLSession
        loadImage(from: item.imageURL)
    }
    
    private func loadImage(from urlString: String) {
        // Cancel any existing image loading task
        imageTask?.cancel()
        
        // Set placeholder image
        productImageView.image = UIImage(systemName: "photo")
        
        // Check if URL is valid
        guard let url = URL(string: urlString) else {
            print("Invalid image URL")
            return
        }
        
        // Create and start image loading task
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            DispatchQueue.main.async {
                UIView.transition(with: self.productImageView,
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                    self.productImageView.image = image
                })
            }
        }
        imageTask?.resume()
    }
    
    // MARK: - Actions
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let newQuantity = Int(sender.value)
        quantityLabel.text = "\(newQuantity)"
        delegate?.quantityDidChange(at: tag, newQuantity: newQuantity)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        productImageView.image = UIImage(systemName: "photo")
        productNameLabel.text = nil
        quantityLabel.text = nil
        priceLabel.text = nil
        stepper.value = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productImageView.layer.cornerRadius = 8
    }
}
