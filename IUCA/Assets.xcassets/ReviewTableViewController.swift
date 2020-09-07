//
//  ReviewTableViewController.swift
//  IUCA
//
//  Created by User on 8/28/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class ReviewTableViewController: UITableViewController {
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewDateLabel: UILabel!
    @IBOutlet weak var textFieldForTitle: UITextField!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var postedByLabel: UILabel!
    
    var review: Review!
    var spot: Spot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        guard spot != nil else {
            return
        }
        
        if review == nil {
            review = Review()
        }
        
        updateUserInterface()
        
    }
    
    func updateUserInterface() {
        nameLabel.text = spot.name
        reviewTextView.text = review.text
        textFieldForTitle.text = review.title
        reviewDateLabel.text = "posted: \(dateFormatter.string(from: review.date))"
        postedByLabel.isHidden = false
        
        if review.documentId == "" {
            addBordersToEditableObjects()
            postedByLabel.isHidden = true
            
        } else {
            postedByLabel.isHidden = false
            if review.reviewUSerId == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            } else {
                saveButton.hide()
                cancelBarButton.hide()
                postedByLabel.text = "Posted by: \(review.reviewUserEmail)"
                reviewTextView.isEditable = false
                textFieldForTitle.isEnabled = false
                textFieldForTitle.borderStyle = .none
                textFieldForTitle.backgroundColor = .white
                reviewTextView.backgroundColor = .white
            }
        }
    }
    
    func updateFromUserInterface() {
        review.title = textFieldForTitle.text!
        review.text = reviewTextView.text!
        
    }
    
    func addBordersToEditableObjects() {
        textFieldForTitle.addBorder(width: 0.5, radius: 5.0, color: .black)
        reviewTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func leaveViewController() {
        let isPresentingMode = presentingViewController is UINavigationController
        if isPresentingMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func reviewChanged(_ sender: UITextField) {
        let noSpaces = textFieldForTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func reviewTitileDonePressed(_ sender: Any) {
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        review.deleteData(spot: spot) { (success) in
            if success{
                self.leaveViewController()
            } else {
                print("ERROR")
            }
        }
    }
    
    @IBAction func cancelBarButtonPressed(_ sender: Any) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        updateFromUserInterface()
        
        review.saveData(spot: spot) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("Error")
            }
        }
        
    }
}
