//
//  CredentialViewController.swift
//  Panic Button
//
//  Created by Edric MILARET on 17-08-08.
//  Copyright © 2017 Edric MILARET. All rights reserved.
//

import UIKit
import Locksmith

class CredentialViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var presenterView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenterView.layer.cornerRadius = 30
        self.presenterView.layer.masksToBounds = true
        
        if let dic = Locksmith.loadDataForUserAccount(userAccount: "RouterAccount") {
            let account = dic as! [String : String]
            usernameTextField.text = account["username"]
            passwordTextField.text = account["password"]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameTextField.becomeFirstResponder()
    }
    
    //MARK: - Actions
    @IBAction func doneTapped(_ sender: Any) {
        guard !usernameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty else {
            return
        }
        
        do {
            try Locksmith.updateData(data: ["username": usernameTextField.text!, "password": passwordTextField.text!], forUserAccount: "RouterAccount")
            self.dismiss(animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
}
