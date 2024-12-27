import UIKit
import SDWebImage

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
        
        // Load image using SDWebImage
        if let url = URL(string: item.imageURL) {
            productImageView.sd_setImage(
                with: url,
                placeholderImage: UIImage(systemName: "photo"),
                options: [.retryFailed, .refreshCached],
                progress: { (receivedSize, expectedSize, _) in
                    // Handle progress if needed
                    let progress = Float(receivedSize) / Float(expectedSize)
                    print("Loading progress: \(progress)")
                },
                completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                    if let error = error {
                        print("Error loading image: \(error)")
                        self?.productImageView.image = UIImage(systemName: "photo")
                    }
                }
            )
        } else {
            productImageView.image = UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Actions
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let newQuantity = Int(sender.value)
        quantityLabel.text = "\(newQuantity)"
        delegate?.quantityDidChange(at: tag, newQuantity: newQuantity)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        productImageView.sd_cancelCurrentImageLoad()
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


//import UIKit
//
//class CartItemCell: UITableViewCell {
//    @IBOutlet weak var productImageView: UIImageView!
//    @IBOutlet weak var productNameLabel: UILabel!
//    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet weak var priceLabel: UILabel!
//    @IBOutlet weak var quantityStepper: UIStepper!
//    @IBOutlet weak var quantityLabel: UILabel!
//
//    var stepperAction: ((Int) -> Void)?
//
//    func configure(with cartItem: CartItem) {
//        productNameLabel.text = cartItem.productName
//        locationLabel.text = cartItem.location
//        priceLabel.text = "\(cartItem.price) BD"
//        quantityLabel.text = "\(cartItem.quantity)"
//        quantityStepper.value = Double(cartItem.quantity)
//    }
//
//    @IBAction func stepperValueChanged(_ sender: UIStepper) {
//        let newQuantity = Int(sender.value)
//        quantityLabel.text = "\(newQuantity)"
//        stepperAction?(newQuantity)
//    }
//}
