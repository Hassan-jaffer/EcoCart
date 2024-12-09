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
        setupUI()
        setupKeyboardHandling()
        fetchReviews()
    }
    
    private func setupUI() {
        title = "Reviews"
        
        // TableView setup
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        reviewTableView.rowHeight = UITableView.automaticDimension
        reviewTableView.estimatedRowHeight = 150
        reviewTableView.tableFooterView = UIView()
        reviewTableView.keyboardDismissMode = .interactive
        
        // Register cell
        if let nib = Bundle.main.loadNibNamed("ReviewCell", owner: nil, options: nil) {
            reviewTableView.register(UINib(nibName: "ReviewCell", bundle: Bundle.main), forCellReuseIdentifier: "ReviewCell")
        } else {
            print("❌ Failed to load ReviewCell.xib")
        }
        
        // Text view setup with better spacing
        newReviewTextView.layer.borderWidth = 1
        newReviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        newReviewTextView.layer.cornerRadius = 8
        newReviewTextView.text = "Write your review here..."
        newReviewTextView.textColor = .lightGray
        newReviewTextView.backgroundColor = .systemBackground
        newReviewTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        newReviewTextView.delegate = self
        
        // Star buttons setup with better spacing
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].enumerated().forEach { index, button in
            if let button = button {
                button.setImage(UIImage(systemName: "star.fill"), for: .normal)
                button.tintColor = .systemGray4
                button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
                button.tag = index + 1
                // Increase touch area
                button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            }
        }
        
        // Submit button setup with better visibility
        submitReviewButton.layer.cornerRadius = 8
        submitReviewButton.backgroundColor = .systemGreen
        submitReviewButton.setTitleColor(.white, for: .normal)
        submitReviewButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        submitReviewButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        
        updateStars()
        
        // Debug info
        print("🎨 UI Setup completed")
    }
    
    private func setupKeyboardHandling() {
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, 
            selector: #selector(keyboardWillShow), 
            name: UIResponder.keyboardWillShowNotification, 
            object: nil)
        NotificationCenter.default.addObserver(self, 
            selector: #selector(keyboardWillHide), 
            name: UIResponder.keyboardWillHideNotification, 
            object: nil)
            
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        reviewTableView.contentInset = contentInsets
        reviewTableView.scrollIndicatorInsets = contentInsets
        
        // Scroll to make the text view visible
        if newReviewTextView.isFirstResponder {
            let rect = newReviewTextView.convert(newReviewTextView.bounds, to: reviewTableView)
            reviewTableView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset content insets
        reviewTableView.contentInset = .zero
        reviewTableView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
    }
    
    private func updateStars() {
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].enumerated().forEach { index, button in
            button?.tintColor = index < selectedRating ? .systemYellow : .gray
        }
    }
    
    @IBAction func submitReviewTapped(_ sender: Any) {
        print("🔘 Submit button tapped!")
        print("📝 Current review text: \(String(describing: newReviewTextView.text))")
        print("⭐️ Current rating: \(selectedRating)")
        
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
        
        submitReviewButton.isEnabled = true
        print("🔘 Submit button enabled state: \(submitReviewButton.isEnabled)")
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

extension ReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your review here..."
            textView.textColor = .lightGray
        }
    }
}
