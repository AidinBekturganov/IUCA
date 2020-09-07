//
//  SpotReviewTableViewCell.swift
//  IUCA
//
//  Created by User on 9/1/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit

class SpotReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewTextLabel: UILabel!
    
    var review: Review! {
        didSet {
            reviewTitleLabel.text = review.title
            reviewTextLabel.text = review.text
        }
    }
}
