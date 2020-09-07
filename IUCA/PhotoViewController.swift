//
//  PhotoViewController.swift
//  IUCA
//
//  Created by User on 9/2/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var dateLAbel: UILabel!
    @IBOutlet weak var descriptionLabe: UITextView!
    @IBOutlet weak var postedByLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    var spot: Spot!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard spot != nil else {
            return
        }
        
        if photo == nil {
            photo = Photo()
        }
        
        updateUserInterface()
    }
    
    func updateUserInterface() {
        postedByLabel.text = "by: \(photo.photoUserEmail)"
        dateLAbel.text = "on: \(dateFormatter.string(from: photo.date))"
        descriptionLabe.text = photo.description
        imageView.image = photo.image
        
        if photo.documentId == "" {
            addBordersToEditableObjects()
        } else {
            if photo.photoUserId == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                self.navigationController?.setToolbarHidden(false, animated: true)
            } else {
                saveBarButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted by: \(photo.photoUserEmail)"
                descriptionLabe.isEditable = false
                descriptionLabe.backgroundColor = .white
            }
        }
        
        guard let url = URL(string: photo.photoUrl) else {
            imageView.image = photo.image
            return
        }
        
        imageView.sd_imageTransition = .fade
        imageView.sd_imageTransition?.duration = 0.5
        imageView.sd_setImage(with: url)
        
    }
    
    func updateFromUserInterface() {
        photo.description = descriptionLabe.text!
        photo.image = imageView.image!
    }
    
    func addBordersToEditableObjects() {
        descriptionLabe.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func leaveViewController() {
        let isPresentingMode = presentingViewController is UINavigationController
        if isPresentingMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        photo.deleteData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR DELETING")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        photo.saveData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("Error")
            }
            
        }
        
        leaveViewController()
    }   
}
