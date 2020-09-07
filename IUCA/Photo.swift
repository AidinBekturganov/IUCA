//
//  Photo.swift
//  IUCA
//
//  Created by User on 9/2/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var photoUserId: String
    var photoUserEmail: String
    var date: Date
    var photoUrl: String
    var documentId: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["description": description, "photoUserId": photoUserId, "photoUserEmail": photoUserEmail, "date": timeIntervalDate, "photoUrl": photoUrl]
    }
    
    init(image: UIImage, description: String, photoUserId: String, photoUserEmail: String, date: Date, photoUrl: String, documentId: String) {
        self.image = image
        self.description = description
        self.photoUserId = photoUserId
        self.photoUserEmail = photoUserEmail
        self.date = date
        self.photoUrl = photoUrl
        self.documentId = documentId
    }
    
    
    convenience init() {
        let photoUserId = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.email ?? "Unknown user"
        self.init(image: UIImage(), description: "", photoUserId: photoUserId, photoUserEmail: photoUserEmail, date: Date(), photoUrl: "", documentId: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let photoUserId = dictionary["photoUserId"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoUrl = dictionary["photoUrl"] as! String? ?? ""
        
        self.init(image: UIImage(), description: description, photoUserId: photoUserId, photoUserEmail: photoUserEmail, date: date, photoUrl: photoUrl, documentId: "")
    }
    
    func saveData(spot: Spot, completion: @escaping (Bool) -> ()) {
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        if documentId == "" {
            documentId = UUID().uuidString
        }
        
        let storageRef = storage.reference().child(spot.documentId).child(documentId)
        
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metaData, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("UPLOADED")
            
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    return completion(false)
                }
                
                guard let url = url else {
                    return completion(false)
                }
                
                self.photoUrl = "\(url)"
                let dataSave = self.dictionary
                let ref = db.collection("spots").document(spot.documentId).collection("photos").document(self.documentId)
                ref.setData(dataSave) { (error) in
                    guard error == nil else {
                        return completion(false)
                    }
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print(error.localizedDescription)
            }
            completion(false)
        }  
    }
    
    func loadImage(spot: Spot, completion: @escaping (Bool) -> ()) {
        guard spot.documentId != "" else {
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentId).child(documentId)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    
    func deleteData(spot: Spot, completion: @escaping(Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentId).collection("photos").document(documentId).delete { (error) in
            if let error = error {
                print("ERROR \(error.localizedDescription)")
                completion(false)
            } else {
                self.deleteImage(spot: spot)
                completion(true)
            }
            
        }
    }
    
    private func deleteImage(spot: Spot) {
        guard spot.documentId != nil else {
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child(spot.documentId).child(documentId)
        storageRef.delete { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("DELETED")
            }
        }
    }
    
}
