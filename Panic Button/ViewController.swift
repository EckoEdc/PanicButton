//
//  ViewController.swift
//  Panic Button
//
//  Created by Edric MILARET on 17-08-08.
//  Copyright © 2017 Edric MILARET. All rights reserved.
//

import UIKit
import Alamofire
import WebKit
import Reachability
import Locksmith

class ViewController: UIViewController {
    
    //MARK: - Properties
    let reachability = Reachability()!
    var account: Dictionary<String, String>!
    
    //MARK: - Outlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    
    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.tintColor = UIColor.white
        settingsButton.imageView?.tintColor = UIColor.black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let dic = Locksmith.loadDataForUserAccount(userAccount: "RouterAccount") {
            account = dic as! [String : String]
        } else {
            self.performSegue(withIdentifier: "credentialSegue", sender: self)
        }
    }
    
    //MARK: - Actions
    @IBAction func onRestartTapped(_ sender: Any) {
        
        guard reachability.isReachableViaWiFi else {
            let alert = UIAlertController(title: "Error",
                                          message: "You're not connected to a WiFi network",
                                          preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        let parameters: Parameters = [
            "username": account["username"]!,
            "password": account["password"]!,
            ]
        
        self.performSegue(withIdentifier: "waitTimerSegue", sender: nil)
        
        Alamofire.request("http://192.168.0.1/cgi-bin/luci/easy/passWarning",
                          method: .post,
                          parameters: parameters)
            .response { response in
                
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: (response.response?.allHeaderFields as! [String: String]),
                                                 for: response.request!.url!)
                
                let path = (response.response?.allHeaderFields["Set-Cookie"] as! String)
                    .split(separator: " ")[1]
                    .replacingOccurrences(of: "path=", with: "")
                
                Alamofire.SessionManager.default.session.configuration
                    .httpCookieStorage?.setCookies(cookies,
                                                   for: response.request!.url!,
                                                   mainDocumentURL: nil)
                
                Alamofire.upload(multipartFormData:{ multipartFormData in
                    multipartFormData.append("Redémarrer".data(using: .utf8)!,
                                             withName: "restartsystem")
                },
                                 to:"http://192.168.0.1\(path)/expert/maintenance/Systemrebooting",
                    method:.post,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(_, _, _):
                            (self.presentedViewController as! WaitTimerViewController).startWatcher()
                        case .failure(let encodingError):
                            print(encodingError)
                        }
                })
        }
    }
    
    @IBAction func onSettingsTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "credentialSegue", sender: self)
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

