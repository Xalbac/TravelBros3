//
//  StartViewController.swift
//  TravelBros
//
//  Created by Peter on 2019-02-11.
//  Copyright © 2019 Edvard Hedlund. All rights reserved.
//

import UIKit
import CommonCrypto
import LocalAuthentication

class LoginController: UIViewController{
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: "password") == nil {
            createUser()
        } else {
            logIn()
        }
    }
    
    func createUser() {
        let alertController = UIAlertController(title:"Create user", message: "Please complete this form", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "User ID"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        let loginAction = UIAlertAction(title: "Accpet", style: .default, handler: { action in
            if let id = alertController.textFields?[0].text , let pw = alertController.textFields?[1].text {
                let pw256 = self.hash256(pw)
                print(pw256!)
                UserDefaults.standard.set(pw256, forKey: "password")
                UserDefaults.standard.set(id, forKey: "userid")
            }
        })
        alertController.addAction(loginAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func logIn() {
        let alertController = UIAlertController(title:"Login", message: "You must log in to use the app", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "User ID"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        let loginAction = UIAlertAction(title: "Accept", style: .default, handler: { action in
            if let pw = alertController.textFields?[1].text {
                let pw256 = self.hash256(pw)
                let pass = UserDefaults.standard.string(forKey: "password")
                if pw256 == pass {
                    //Login action
                   self.performSegue(withIdentifier: "segToList", sender: self)
                } else {
                    print("fail")
                }
            }
        })
        alertController.addAction(loginAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func hash256(_ string: String) -> String? {
        let length = Int(CC_SHA256_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let dataString = string.data(using: String.Encoding.utf8) {
            _ = dataString.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_SHA256(body, CC_LONG(dataString.count), &digest)
            }
        }
        
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    
}
