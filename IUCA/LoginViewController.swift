//
//  ViewController.swift
//  IUCA
//
//  Created by User on 8/26/20.
//  Copyright © 2020 Aidin. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseAuth
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FirebaseCore
import FBSDKCoreKit
import FBSDKLoginKit


class LoginViewController: UIViewController, GIDSignInDelegate {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!

    
    var authUI: FUIAuth!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginManager().logOut()
        
        if let accessToker = AccessToken.current?.tokenString {
            firebaseFacebook(accessToken: accessToker)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }


    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            return
        }
        
        guard let authentification = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentification.idToken, accessToken: authentification.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                print("ERROR IN GOOGLE \(error.localizedDescription)")
            } else {
                self.performSegue(withIdentifier: "FirstShowSegue", sender: nil)
            }
        }
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
    
    func showCreateAccount(email: String, password: String) {
        let alert = UIAlertController(title: "Wrong login or password", message: "Check one more time password or Create new account to sign in, click create and continue", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (_) in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                print("REGISTERED")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        present(alert, animated: true)
    }
    
    func firebaseFacebook(accessToken: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        Auth.auth().signIn(with: credential) { (resul, error) in
            if let error = error {
                print(error)
            }
        }
    }

    
    func signOut() {
        do {
            try authUI!.signOut()
        } catch {
            print("😡 ERROR: couldn't sign out")
            performSegue(withIdentifier: "FirstShowSegue", sender: nil)
        }
    }
    
    @IBAction func signInFacebookButton(_ sender: Any) {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (resulr, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let accessToken = AccessToken.current else {
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("ERROR IS HERE\(error)")
                    return
                } else {
                    if let currentUser = Auth.auth().currentUser {
                        self.performSegue(withIdentifier: "FirstShowSegue", sender: nil)
                    } else {
                        
                    }
                    
                }
            }
        }
    }
    
    @IBAction func googleSingInButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    
    @IBAction func unwindSignOutPressed(segue: UIStoryboardSegue) {
        if segue.identifier == "SignOutUnwind" {
            signOut()
        }
    }

    @IBAction func continueButton(_ sender: Any) {
        
        if GIDSignIn.sharedInstance()?.currentUser == nil && authUI.auth?.currentUser == nil { // user has not signed in
            guard let email = emailTextField.text, !email.isEmpty,
                let password = passwordTextField.text, !password.isEmpty else {
                    return
            }
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self](result, error) in
                guard let strongSelf = self else {
                    return
                }
                guard error == nil else {
                    strongSelf.showCreateAccount(email: email, password: password)
                    return
                }
            }
            print("SUCCESS")
            
        } else { // user is already logged in
            performSegue(withIdentifier: "FirstShowSegue", sender: nil)
        }
    }
    
    @IBAction func unwindFromPhoneVerification(segue: UIStoryboardSegue) {
        let source = segue.source as! PhoneViewController
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: source.verify.userID, verificationCode: source.verify.otp)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("SUCCESS")
                self.performSegue(withIdentifier: "FirstShowSegue", sender: nil)
            }
        }
    }
    
}


