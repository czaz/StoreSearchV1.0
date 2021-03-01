//
//  AppDelegate.swift
//  StoreSearch
//
//  Created by Wm. Zazeckie on 2/19/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        customizeAppearance() // implementing color change for search bars
        detailVC.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem // Puts a button into the navigation item for switching between the split view display modes.
        searchVC.splitViewDetail = detailVC 
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    // MARK:- Helper Methods
    
    // all search bars are changed to the color specified by the UICOlor method
    func customizeAppearance() {
        let barTintColor = UIColor(red: 20/255, green: 160/225,
                                   blue: 160/225, alpha: 1)
        UISearchBar.appearance().barTintColor = barTintColor
    }
    

    // MARK:- Properties
    
    // top level view controller
    var splitVC: UISplitViewController {
      return window!.rootViewController as! UISplitViewController
    }
    
    // The search screen in the master pane of the split view
    var searchVC: SearchViewController {
      return splitVC.viewControllers.first as! SearchViewController
    }
    
    // The UINavigationController in the detail pane of the split view.
    var detailNavController: UINavigationController {
      return splitVC.viewControllers.last as! UINavigationController
    }
    
    // The detail screen inside the UINavigationController
    var detailVC: DetailViewController {
      return detailNavController.topViewController as! DetailViewController
    }
  

    
    
    
}

