//
//  CardView.swift
//  MostraAR
//
//  Created by Matteo Ercolino on 18/05/22.
//

import UIKit

class CardView: UIView {

    override func layoutSubviews() {
        self.layer.cornerRadius = 20
        if self.traitCollection.userInterfaceStyle == .light {
            self.backgroundColor = .systemBackground
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowRadius = 5
            self.layer.shadowOpacity = 0.3
            self.layer.shadowOffset = .zero
        } else {
            self.layer.shadowColor = UIColor.gray.cgColor
            self.backgroundColor = .secondarySystemBackground
            self.layer.shadowRadius = 5
            self.layer.shadowOpacity = 0
            self.layer.shadowOffset = .zero
        }
    }

}
