//
//  BlackBorderedTextField.swift
//  greenBag
//
//  Created by Huzaifa Abbasi on 24/12/2024.
//

import UIKit

class BlackBorderedTextField: UITextField, UITextFieldDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        layer.cornerRadius = 10

        // Add padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: frame.height))
        leftView = paddingView
        leftViewMode = .always

        // Set colors
        backgroundColor = UIColor.white
        textColor = UIColor.black
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        delegate = self
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.black.cgColor // Set border color to blue when editing
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor // Reset border color to gray after editing
    }
}

