//
//  SpotPhotoCollectionViewCell.swift
//  IUCA
//
//  Created by User on 9/2/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit
import SDWebImage

class SpotPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var spot: Spot!
    
    var photo: Photo! {
        didSet {
            if let url = URL(string: photo.photoUrl) {
                self.photoImageView.sd_imageTransition = .fade
                self.photoImageView.sd_imageTransition?.duration = 0.2
                self.photoImageView.sd_setImage(with: url)
            } else {
                print(Error.self)
                self.photo.loadImage(spot: self.spot) { (success) in
                    self.photo.saveData(spot: self.spot) { (success) in
                        print("Done")
                    }
                }
            }
            
        }
    }
}
