//
//  Spots.swift
//  IUCA
//
//  Created by User on 8/28/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import Firebase

class Spots {
    var spotArray: [Spot] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("spots").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                return completed()
            }
            self.spotArray = []
            
            for document in querySnapshot!.documents {
                let spot = Spot(dictionary: document.data())
                spot.documentId = document.documentID
                self.spotArray.append(spot)
            }
            completed()
        }
    }
}
