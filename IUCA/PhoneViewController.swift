//
//  PhoneViewController.swift
//  IUCA
//
//  Created by User on 9/4/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit
import Firebase

struct Verify {
    var userID: String
    var otp: String
}

class PhoneViewController: UIViewController {
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    
    var userId: String = ""
    var verify: Verify!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        verify = Verify(userID: userId ?? "", otp: otpTextField.text ?? "")
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        guard let phoneNumber = phoneTextField.text else {
            return
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
            if error == nil {
                guard let ver = verificationId else {
                    return
                }
                self.userId = ver
                self.otpTextField.isHidden = false
                self.submitButton.isHidden = true
                self.verifyButton.isHidden = false
                
            } else {
                print("ERROR WITH REG \(error?.localizedDescription)")
            }
        }
    } 
}
