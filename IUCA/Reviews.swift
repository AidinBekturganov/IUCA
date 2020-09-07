//
//  Reviews.swift
//  IUCA
//
//  Created by User on 9/1/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray: [Review] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()) {
        guard spot.documentId != "" else {
            return
        }
        db.collection("spots").document(spot.documentId).collection("reviews").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                return completed()
            }
            self.reviewArray = []
            
            for document in querySnapshot!.documents {
                let review = Review(dictionary: document.data())
                review.documentId = document.documentID
                self.reviewArray.append(review)
            }
            completed()
        }
    }
}

