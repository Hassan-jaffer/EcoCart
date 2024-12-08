//
//  ReviewCell.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 07/12/2024.
//

import Foundation
import UIKit

class ReviewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var reviewContentTextView: UITextView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var ratingStarButton1: UIButton!
    @IBOutlet weak var ratingStarButton2: UIButton!
    @IBOutlet weak var ratingStarButton3: UIButton!
    @IBOutlet weak var ratingStarButton4: UIButton!
    @IBOutlet weak var ratingStarButton5: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        reviewContentTextView.isEditable = false
        reviewContentTextView.isScrollEnabled = false
        reviewContentTextView.backgroundColor = .clear
        
        let stars = [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5]
        stars.forEach { button in
            button?.isUserInteractionEnabled = false
            button?.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button?.tintColor = .systemGray4
        }
    }
    
    func configure(with review: Review) {
        print("🔵 Configuring cell with review: \(review)")
        reviewContentTextView.text = review.content
        reviewerNameLabel.text = "By: \(review.userName)"
        
        let rating = max(0, min(5, review.rating))
        print("⭐️ Setting rating to: \(rating)")
        
        let stars = [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5]
        stars.enumerated().forEach { index, button in
            if let button = button {
                button.tintColor = index < rating ? .systemYellow : .systemGray4
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reviewContentTextView.text = nil
        reviewerNameLabel.text = nil
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].forEach { button in
            button?.tintColor = .systemGray4
        }
    }
}
