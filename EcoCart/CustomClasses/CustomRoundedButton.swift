//
//  CustomRoundedButton.swift
//  EcoCart
//
//  Created by ali on 26/12/2024.
//

import UIKit

class CustomRoundedButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {
        let cornerRadiusPercentage: CGFloat = 0.2
        let cornerRadius = bounds.height * cornerRadiusPercentage
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
