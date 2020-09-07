//
//  UIBarButton+hide.swift
//  IUCA
//
//  Created by User on 9/1/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
