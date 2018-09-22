//
//  ViewController.swift
//  Attendy IOS
//
//  Created by Jaiveer Singh on 9/21/18.
//  Copyright © 2018 Full Stack. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
    //MARK: Properties
    @IBOutlet weak var nameInstructions: UILabel!
    @IBOutlet weak var nameSignInButton: GIDSignInButton!
    @IBOutlet weak var nameHereButton: UIButton!
    @IBOutlet weak var nameLoadingBar: UIProgressView!
    var timer:Timer!
    var duration = 10
    var indexProgressBar = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user.
        GIDSignIn.sharedInstance().signInSilently()
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(ViewController.receiveToggleAuthUINotification(_:)),
            name: Notification.Name(rawValue: "ToggleAuthUINotification"),
            object: nil)
    }
    
    @IBAction func hereClick(_ sender: Any) {
        nameHereButton.isEnabled = false
        nameInstructions.text = "Please wait while we confirm"
        nameLoadingBar.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgressBar), userInfo: nil, repeats: true)
    }
    // [START toggle_auth]
    func toggleAuthUI() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Signed in
            nameSignInButton.isHidden = true
            nameInstructions.text = "Are you in class today?"
            nameHereButton.isHidden = false
        }
    }
    // [END toggle_auth]
    
    @objc func setProgressBar()
    {
        // update the display
        // use poseDuration - 1 so that you display 20 steps of the the progress bar, from 0...19
        nameLoadingBar.progress = Float(indexProgressBar) / Float(duration - 1)
        
        // increment the counter
        indexProgressBar += 1
        if indexProgressBar >= duration {
            nameLoadingBar.isHidden = true
            nameHereButton.isHidden = true
            timer.invalidate()
            nameInstructions.text = "All done! Thanks :)"
        }
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            self.toggleAuthUI()
        }
    }
    
}

