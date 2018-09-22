//
//  AppDelegate.swift
//  Attendy IOS
//
//  Created by Jaiveer Singh on 9/21/18.
//  Copyright © 2018 Full Stack. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var key = "AIzaSyBFycG6-zNadEpeKDYysG2dU06R5OGK0kg"
    var urlString = "http://40.114.119.189"
    var publication : GNSPublication?
    var subscription : GNSSubscription?
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let email = user.profile.email
            let fullName = user.profile.name
            GNSMessageManager.setDebugLoggingEnabled(true)
            let messageManager = GNSMessageManager(apiKey: key)
            publication =
                messageManager!.publication(
                    with: GNSMessage(content: email!.data(using: .utf8)),
                    paramsBlock: { (params: GNSPublicationParams?) in
                        guard let params = params else { return }
                        params.strategy = GNSStrategy(paramsBlock: { (params: GNSStrategyParams?) in
                            guard let params = params else { return }
                            params.discoveryMediums = .audio
                            params.discoveryMode = .default
                        })
                })
            subscription =
                messageManager!.subscription(
                    messageFoundHandler: { (message: GNSMessage?) in
                    // Add the name to a list for display
                        let other_email = String(data: (message?.content)!, encoding: .utf8)
                        let json: [String: Any] = ["": "ABC",
                                                   "dict": ["1":"First", "2":"Second"]]
                        
                        let jsonData = try? JSONSerialization.data(withJSONObject: json)
                    print("Found a message!!!! " + other_email!)
                        let serverURL = URL(string: self.urlString + "/reportStatus")!
                        var request = URLRequest(url: serverURL)
                        request.httpMethod = "POST"
                        request.httpBody = jsonData
                        
                        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data, error == nil else {
                                print("SERVER BOBOBB")
                                print(error?.localizedDescription ?? "No data")
                                return
                            }
                            print("SERVER BOBOBOBOB")
                            print(String(data: data, encoding: .utf8)!)
                            print(response!)
                            print("END SERVERER BOBOBO")
                        }
                        
                        task.resume()
                },
                                            messageLostHandler: { (message: GNSMessage?) in
                                                // Remove the name from the list
                },
                                            paramsBlock: { (params: GNSSubscriptionParams?) in
                                                guard let params = params else { return }
                                                params.strategy = GNSStrategy(paramsBlock: { (params: GNSStrategyParams?) in
                                                    guard let params = params else { return }
                                                    params.discoveryMediums = .audio
                                                    params.discoveryMode = .default
                                                })
                })
            
            print("Hey your email is " + email!)
            let json: [String: Any] = ["fullName": fullName!,
                                       "email": email!]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            let serverURL = URL(string: urlString + "/login")!
            var request = URLRequest(url: serverURL)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("SERVER BOBOBB")
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                print("SERVER BOBOBOBOB")
                print(String(data: data, encoding: .utf8)!)
                print(response!)
                print("END SERVERER BOBOBO")
            }
            
            task.resume()
            
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "ToggleAuthUINotification"),
                object: self,
                userInfo: ["statusText": "BOBERT: " + email!])
        }
    }
    

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = "1029510740323-iqf3dp5vocbl37b9fo4p50l9e55v1dlf.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

