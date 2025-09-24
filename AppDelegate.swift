//
//  AppDelegate.swift
//  BeReal
//
//  Created by shaun amoah on 9/23/25.
//

import UIKit
import ParseSwift



@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize ParseSwift
        ParseSwift.initialize(applicationId: "4sg0SZNy1vt1k68WuKx5bIgZWvrNXOo4VbFsdvUH", // Replace with your Parse app ID
                             clientKey: "JEwyfjSEHaWGVcSNzCfG8EvZ4SW7GMAZptJM3n07", // Replace with your Parse client key
                             serverURL: URL(string: "https://parseapi.back4app.com")!) { _, _ in
            // Optional: Add any custom configuration here
        }
        
        // Set up window and initial view controller
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Check if user is already logged in
        if User.current != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let feedViewController = storyboard.instantiateViewController(withIdentifier: "FeedViewController")
            window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            window?.rootViewController = loginViewController
        }
        
        window?.makeKeyAndVisible()
        return true
    }
}
