import UIKit

class CustomStepper: UIStepper {
    override var minimumValue: Double {
        get { return 0 }
        set { super.minimumValue = 0 }
    }
}

protocol CartItemCellDelegate: AnyObject {
    func quantityDidChange(at index: Int, newQuantity: Int, isIncrementing: Bool)
}

class CartItemCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper! {
        didSet {
            if let customStepper = stepper as? CustomStepper {
                customStepper.minimumValue = 0
            }
        }
    }
    
    // MARK: - Properties
    weak var delegate: CartItemCellDelegate?
    private var item: CartItem?
    private var imageTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView()
        setupStepper()
    }
    
    private func setupImageView() {
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = .systemGray6
    }
    
    private func setupStepper() {
        stepper.maximumValue = 99
        stepper.stepValue = 1
        stepper.wraps = false
        stepper.autorepeat = true
        stepper.minimumValue = 0
    }
    
    // MARK: - Configuration
    func configure(with item: CartItem) {
        self.item = item
        
        productNameLabel.text = item.productName
        quantityLabel.text = "\(item.quantity)"
        priceLabel.text = String(format: "%.3f BHD", item.totalPrice)
        
        // Set maximum value based on stock quantity
        stepper.maximumValue = Double(item.stockQuantity)
        stepper.value = Double(item.quantity)
        
        // Update quantity label with stock info if near maximum
        if item.quantity >= item.stockQuantity {
            quantityLabel.text = "\(item.quantity) (Max)"
        }
        
        loadImage(from: item.imageURL)
    }
    
    private func loadImage(from urlString: String) {
        imageTask?.cancel()
        productImageView.image = UIImage(systemName: "photo")
        
        guard let url = URL(string: urlString) else {
            print("Invalid image URL")
            return
        }
        
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
        let newValue = Int(sender.value)
        let currentQuantity = item?.quantity ?? 1
        
        if newValue == 0 {
            // Trigger deletion
            delegate?.quantityDidChange(at: tag, newQuantity: 0, isIncrementing: false)
            return
        }
        
        // Check if we're trying to exceed stock quantity
        if let item = item, newValue > item.stockQuantity {
            // Reset to maximum stock quantity
            sender.value = Double(item.stockQuantity)
            quantityLabel.text = "\(item.stockQuantity) (Max)"
            return
        }
        
        let isIncrementing = newValue > currentQuantity
        quantityLabel.text = newValue >= (item?.stockQuantity ?? 99) ? "\(newValue) (Max)" : "\(newValue)"
        delegate?.quantityDidChange(at: tag, newQuantity: newValue, isIncrementing: isIncrementing)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        productImageView.image = UIImage(systemName: "photo")
        productNameLabel.text = nil
        quantityLabel.text = nil
        priceLabel.text = nil
        stepper.value = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        productImageView.layer.cornerRadius = 8
    }
}
