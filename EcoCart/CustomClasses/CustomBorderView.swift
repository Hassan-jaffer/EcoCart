import UIKit

@IBDesignable
class CustomBorderView: UIView {
    
    // IBInspectable properties to be assigned in Storyboard
    @IBInspectable var borderRadius: CGFloat = 5 {
        didSet {
            self.layer.cornerRadius = borderRadius
            self.layer.masksToBounds = true // Ensure the corner radius applies
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    // This method ensures the custom view is set up correctly
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }

    private func setupView() {
        // Apply border properties
        self.layer.cornerRadius = borderRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}
