//
//  ViewController.swift
//  Attendy IOS
//
//  Created by Jaiveer Singh on 9/21/18.
//  Copyright © 2018 Full Stack. All rights reserved.
//

import UIKit
import GoogleSignIn
import Alamofire

class ViewController: UIViewController, GIDSignInUIDelegate {
    //MARK: Properties
    @IBOutlet weak var nameInstructions: UILabel!
    @IBOutlet weak var nameSignInButton: GIDSignInButton!
    @IBOutlet weak var nameHereButton: UIButton!
    @IBOutlet weak var nameLoadingBar: UIProgressView!
    @IBOutlet weak var nameRecheckButton: UIButton!
    var timer:Timer?
    var duration = 10
    var indexProgressBar = 0
    var email = ""
    var fullName = ""
    let key = "AIzaSyBFycG6-zNadEpeKDYysG2dU06R5OGK0kg"
    let urlString = "http://40.114.119.189"
    
    
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
        let parameters = [
            "fullName": fullName,
            "email": email
        ]
        
        Alamofire.request(urlString + "/login", method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseString { response in
            print(response)
        }
        nameHereButton.isEnabled = false
        nameInstructions.text = "Please wait while we confirm"
        nameLoadingBar.isHidden = false
        indexProgressBar = 0
        if(timer == nil) {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(setProgressBar), userInfo: nil, repeats: true)
        }
    }
    // [START toggle_auth]
    func toggleAuthUI() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Signed in
            nameSignInButton.isHidden = true
            nameInstructions.text = "Are you in class today?"
            nameHereButton.isHidden = false
            nameHereButton.isEnabled = true
        }
    }
    // [END toggle_auth]
    
    @objc func setProgressBar()
    {
        if(nameLoadingBar.isHidden == false)
        {
        // update the display
        // use poseDuration - 1 so that you display 20 steps of the the progress bar, from 0...19
        nameLoadingBar.progress = Float(indexProgressBar) / Float(duration - 1)
        
        // increment the counter
        indexProgressBar += 1
        if indexProgressBar >= duration {
            nameLoadingBar.isHidden = true
            nameHereButton.isHidden = true
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            nameInstructions.text = "All set - bye for now!"
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                self.nameRecheckButton.isHidden = false
            })
            
        }
        }
    }
    
    @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
        if notification.name.rawValue == "ToggleAuthUINotification" {
            fullName = notification.userInfo!["fullName"] as! String
            email = notification.userInfo!["email"] as! String
            self.toggleAuthUI()
        }
    }
    
    @IBAction func recheckClicked(_ sender: Any) {
        nameRecheckButton.isHidden = true
        nameLoadingBar.isHidden = true
        toggleAuthUI()
    }
}

