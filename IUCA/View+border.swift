//
//  View+border.swift
//  IUCA
//
//  Created by User on 9/1/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(width: CGFloat, radius: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    
    func noBorder() {
        self.layer.borderWidth = 0.0
    }
    
}
