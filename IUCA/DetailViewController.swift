//
//  DetailViewController.swift
//  IUCA
//
//  Created by User on 8/27/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var textFieldForEvent: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var textVIewForDescription: UITextView!
    

    var spot: Spot!
    var photo: Photo!
    var reviews: Reviews!
    var photos: Photos!
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePickerController.delegate = self
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if spot == nil {
            spot = Spot()
        } else {
            disableTextEditing()
            cancelBarButton.hide()
            saveBarButton.hide()
            navigationController?.setToolbarHidden(true, animated: true)
            
        }
        reviews = Reviews()
        photos = Photos()
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if spot.documentId != "" {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        reviews.loadData(spot: spot) {
            self.tableView.reloadData()
        }
        photos.loadData(spot: spot) {
            self.collectionView.reloadData()
        }
    }
    
    func updateUserInterface() {
        textFieldForEvent.text = spot.name
        textVIewForDescription.text = spot.description
    }
    
    func updateFromInterface() {
        spot.name = textFieldForEvent.text!
        spot.description = textVIewForDescription.text
    }
    
    func disableTextEditing() {
        textFieldForEvent.isEnabled = false
        textVIewForDescription.isEditable = false
        textFieldForEvent.backgroundColor = .clear
        textVIewForDescription.backgroundColor = .clear
        textFieldForEvent.borderStyle = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromInterface()
        switch segue.identifier ?? "" {
        case "AddReview":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ReviewTableViewController
            destination.spot = spot
        case "ShowReview":
            let destination = segue.destination as! ReviewTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.review = reviews.reviewArray[selectedIndexPath.row]
            destination.spot = spot
        case "AddPhoto":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! PhotoViewController
            destination.spot = spot
            destination.photo = photo
        case "ShowPhoto":
            let destination = segue.destination as! PhotoViewController
            guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
                return
            }
            destination.photo = photos.photosArray[selectedIndexPath.row]
            destination.spot = spot
        default:
            print("ERROR")
        }
    }
    
    func leaveViewController() {
        let isPresentingMode = presentingViewController is UINavigationController
        if isPresentingMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    @IBAction func nameOfEvent(_ sender: UITextField) {
        let noSpaces = textFieldForEvent.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.spot.saveData { (success) in
                self.saveBarButton.title = "Done"
                self.cancelBarButton.hide()
                self.disableTextEditing()
                if segueIdentifier == "AddReview" {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                } else {
                    self.cameraLibraryAlert()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func cameraLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.accessCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addReviewButton(_ sender: Any) {
        if spot.documentId == "" {
            saveCancelAlert(title: "This event hasn't been saved", message: "You must save it before you add reviews", segueIdentifier: "AddReview")
        } else {
            performSegue(withIdentifier: "AddReview", sender: nil)
        }
        
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        spot.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR IN SAVE BUTTON")
            }
        }
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        leaveViewController()
    }
    
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if spot.documentId == "" {
            saveCancelAlert(title: "This event hasn't been saved", message: "You must save it before you add reviews", segueIdentifier: "AddPhoto")
        } else {
            cameraLibraryAlert()
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! SpotReviewTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! SpotPhotoCollectionViewCell
        photoCell.spot = spot
        photoCell.photo = photos.photosArray[indexPath.row]
        return photoCell
    }
}

extension DetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        photo = Photo()
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photo.image = originalImage
        }
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "AddPhoto", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "There is no access to camera", message: "It's recommended you allow camera in settings", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
}
