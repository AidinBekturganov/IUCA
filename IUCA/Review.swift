//
//  Reviews.swift
//  IUCA
//
//  Created by User on 8/31/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var reviewUSerId: String
    var reviewUserEmail: String
    var date: Date
    var documentId: String
    
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        
        return ["title": title, "text": text, "reviewUSerId": reviewUSerId, "reviewUserEmail": reviewUserEmail, "date": timeIntervalDate]
    }
    
    init(title: String, text: String, reviewUSerId: String, reviewUserEmail: String, date: Date, documentId: String) {
        self.title = title
        self.text = text
        self.reviewUSerId = reviewUSerId
        self.reviewUserEmail = reviewUserEmail
        self.date = date
        self.documentId = documentId
    }
    
    convenience init() {
        let reviewUserId = Auth.auth().currentUser?.uid ?? ""
        let reviewUserEmail = Auth.auth().currentUser?.email ?? "Unknown user"
        self.init(title: "", text: "", reviewUSerId: reviewUserId, reviewUserEmail: reviewUserEmail, date: Date(), documentId: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let reviewUSerId = dictionary["reviewUSerId"] as! String?
            ?? ""
        let reviewUserEmail = dictionary["reviewUserEmail"] as! String? ?? ""
        let documentId = dictionary["documentId"] as! String? ?? ""
        self.init(title: title, text: text, reviewUSerId: reviewUSerId, reviewUserEmail: reviewUserEmail, date: date, documentId: documentId)
        
    }
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let dataSave: [String: Any] = self.dictionary
        
        if self.documentId == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentId).collection("reviews").addDocument(data: dataSave){ (error) in
                guard error == nil else {
                    return completion(false)
                }
                self.documentId = ref!.documentID
                completion(true)
            }
        } else { //set data
            let ref = db.collection("spots").document(spot.documentId).collection("reviews").document(self.documentId)
            ref.setData(dataSave) { (error) in
                guard error == nil else {
                    return completion(false)
                }
                completion(true)
            }
            
        }
        
    }
    
    func deleteData(spot: Spot, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentId).collection("reviews").document(documentId).delete { (error) in
            if let error = error {
                print("ERROR \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
            
        }
    }
}
