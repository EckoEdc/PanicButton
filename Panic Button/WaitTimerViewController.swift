//
//  WaitTimerViewController.swift
//  Panic Button
//
//  Created by Edric MILARET on 17-08-08.
//  Copyright © 2017 Edric MILARET. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Reachability

class WaitTimerViewController: UIViewController {

    //MARK: - Properties
    let reachability = Reachability()!
    
    //MARK: Outlets
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    @IBOutlet weak var presenterView: UIView!
    
    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenterView.layer.cornerRadius = 30
        presenterView.layer.masksToBounds = true
        
        indicatorView.type = .pacman
        indicatorView.startAnimating()
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                if reachability.isReachableViaWiFi {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    //MARK: - Start Reachability
    func startWatcher() {
        /* MagicNumber: 20 sec should be enough for the iphone to realise it doesnt have wifi anymore and for the router to have shut it off */
        Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { (_) in
            do {
                try self.reachability.startNotifier()
            } catch {
                let alert = UIAlertController(title: "Error", message: "Unable to start connection watcher", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
