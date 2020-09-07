//
//  Photos.swift
//  IUCA
//
//  Created by User on 9/2/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photosArray: [Photo] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentId != "" else {
            return
        }
        db.collection("spots").document(spot.documentId).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                return completed()
            }
            self.photosArray = []
            
            for document in querySnapshot!.documents {
                let photo = Photo(dictionary: document.data())
                photo.documentId = document.documentID
                self.photosArray.append(photo)
            }
            completed()
        }
    }
}
