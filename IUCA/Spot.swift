//
//  Spot.swift
//  IUCA
//
//  Created by User on 8/28/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import Firebase

class Spot {
    var name: String
    var description: String
    var numberOfReviews: Int
    var postingUserId: String
    var documentId: String
    
    var dictionary: [String: Any] {
        return ["name": name, "description": description, "numberOfReviews": numberOfReviews, "postingUserId": postingUserId]
    }
    
    init(name: String, description: String, numberOfReviews: Int, postingUserId: String, documentId: String) {
        self.name = name
        self.description = description
        self.numberOfReviews = numberOfReviews
        self.postingUserId = postingUserId
        self.documentId = documentId
    }
    
    convenience init() {
        self.init(name: "", description: "", numberOfReviews: 0, postingUserId: "", documentId: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let description = dictionary["description"] as! String? ?? ""
        let numberOfReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserId = dictionary["postingUserId"] as! String? ?? ""
        self.init(name: name, description: description, numberOfReviews: numberOfReviews, postingUserId: postingUserId, documentId: "")
        
    }
    
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        guard let postingUserId = Auth.auth().currentUser?.uid else {
            print("NO POSTINGUSERID")
            return completion(false)
        }
        self.postingUserId = postingUserId
        let dataSave: [String: Any] = self.dictionary
        
        if self.documentId == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").addDocument(data: dataSave){ (error) in
                guard error == nil else {
                    return completion(false)
                }
                self.documentId = ref!.documentID
                completion(true)
            }
        } else { //set data
            let ref = db.collection("spots").document(self.documentId)
            ref.setData(dataSave) { (error) in
                guard error == nil else {
                    return completion(false)
                }
            }
            completion(true)
        }
    }
}
