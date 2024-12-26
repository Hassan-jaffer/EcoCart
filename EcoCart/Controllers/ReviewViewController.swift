//
//  ReviewViewController.swift
//  EcoCart
//
//  Created by Mohammed Mahmood on 07/12/2024.
//

import UIKit
import FirebaseFirestore
import Foundation

class ReviewViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var reviewView: UIView!
    
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var newReviewTextView: UITextView!
    @IBOutlet weak var submitReviewButton: UIButton!
    @IBOutlet weak var ratingStarButton1: UIButton!
    @IBOutlet weak var ratingStarButton2: UIButton!
    @IBOutlet weak var ratingStarButton3: UIButton!
    @IBOutlet weak var ratingStarButton4: UIButton!
    @IBOutlet weak var ratingStarButton5: UIButton!
    
    var productId: String?
    private var reviews: [Review] = []
    private var selectedRating: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("⚠️ ReviewViewController loaded with productId: \(String(describing: productId))")
        NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChange), name: .themeDidChange, object: nil)
        setupUI()
        fetchReviews()
    }
    
    private func setupUI() {
        title = "Reviews"
        
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        reviewTableView.rowHeight = UITableView.automaticDimension
        reviewTableView.estimatedRowHeight = 150
        reviewTableView.tableFooterView = UIView()
        if(ThemeManager.shared.isDarkMode){
            reviewView.backgroundColor = UIColor.black
        }else{
            reviewView.backgroundColor = UIColor.white
        }
        
        if let nib = Bundle.main.loadNibNamed("ReviewCell", owner: nil, options: nil) {
            reviewTableView.register(UINib(nibName: "ReviewCell", bundle: Bundle.main), forCellReuseIdentifier: "ReviewCell")
        } else {
            print("❌ Failed to load ReviewCell.xib")
        }

        
        newReviewTextView.layer.borderWidth = 1
        newReviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        newReviewTextView.layer.cornerRadius = 5
        newReviewTextView.text = ""
        newReviewTextView.backgroundColor = .systemBackground
        
        let starButtons = [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5]
        starButtons.enumerated().forEach { index, button in
            button?.setImage(UIImage(systemName: "star.fill"), for: .normal)
            button?.tintColor = .systemGray4
            button?.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            button?.tag = index + 1
        }
        
        updateStars()
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
    }
    
    @objc private func handleThemeChange() {
        setupUI() // Reapply theme settings dynamically
    }
    
    private func updateStars() {
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].enumerated().forEach { index, button in
            button?.tintColor = index < selectedRating ? .systemYellow : .gray
        }
    }
    
    @IBAction func submitReviewTapped(_ sender: Any) {
        print("📝 Submit review tapped")
        guard let productId = productId,
              let content = newReviewTextView.text,
              !content.isEmpty,
              selectedRating > 0 else {
            print("❌ Validation failed:")
            print("  - ProductId: \(String(describing: productId))")
            print("  - Content empty: \(String(describing: newReviewTextView.text?.isEmpty))")
            print("  - Rating: \(selectedRating)")
            showAlert(title: "Error", message: "Please enter a review and select a rating")
            return
        }
        
        print("✅ Creating review with:")
        print("  - ProductId: \(productId)")
        print("  - Content: \(content)")
        print("  - Rating: \(selectedRating)")
        
        let review = Review(
            content: content,
            productId: productId,
            rating: selectedRating,
            userName: "User"
        )
        
        Task {
            do {
                print("🔄 Submitting review to Firebase...")
                try await ReviewFirebase.shared.addReview(review)
                print("✅ Review submitted successfully")
                
                // Fetch updated product details
                if let updatedProduct = try await Product.fetchProduct(withId: productId) {
                    // Notify the product details view controller to update
                    NotificationCenter.default.post(name: NSNotification.Name("ProductUpdated"), object: nil, userInfo: ["product": updatedProduct])
                }
                
                DispatchQueue.main.async { [weak self] in
                    print("🧹 Clearing review form")
                    self?.newReviewTextView.text = ""
                    self?.selectedRating = 0
                    self?.updateStars()
                    print("🔄 Refreshing reviews")
                    self?.fetchReviews()
                }
                showAlert(title: "Success", message: "Review submitted successfully!")
            } catch {
                print("❌ Error submitting review: \(error)")
                showAlert(title: "Error", message: "Failed to submit review: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchReviews() {
        guard let productId = productId else {
            print("❌ No productId found")
            return
        }
        
        print("🔍 Fetching reviews for productId: \(productId)")
        Task {
            do {
                let fetchedReviews = try await ReviewFirebase.shared.fetchReviews(for: productId)
                print("✅ Found \(fetchedReviews.count) reviews")
                print("📝 Reviews: \(fetchedReviews)")
                
                DispatchQueue.main.async { [weak self] in
                    print("🔄 Updating UI with reviews")
                    self?.reviews = fetchedReviews
                    self?.reviewTableView.reloadData()
                }
            } catch {
                print("❌ Error fetching reviews: \(error)")
                print("Error details: \(error)")
                showAlert(title: "Error", message: "Failed to load reviews")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ReviewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 Number of reviews: \(reviews.count)")
        if reviews.isEmpty {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
            messageLabel.text = "No reviews yet. Be the first to review!"
            messageLabel.textAlignment = .center
            messageLabel.textColor = .gray
            tableView.backgroundView = messageLabel
        } else {
            tableView.backgroundView = nil
        }
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
            print("❌ Failed to dequeue ReviewCell")
            return UITableViewCell()
        }
        
        let review = reviews[indexPath.row]
        print("🔵 Configuring cell at index \(indexPath.row) with review: \(review)")
        cell.configure(with: review)
        return cell
    }
}
