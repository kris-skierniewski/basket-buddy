//
//  AppDelegate.swift
//  price tracker
//
//  Created by Kris Skierniewski on 28/08/2024.
//

import UIKit
import FirebaseCore
import AppIntents
import WidgetKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //only for debugging
//        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator?.start()
        
        ShoppingListAppShortcuts.updateAppShortcutParameters()
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        
        // Parse the URL
        if url.path.contains("/basketbuddy/invite") {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let queryItems = components.queryItems,
               let inviteCode = queryItems.first(where: { $0.name == "code" })?.value {
                
                // Handle the invite code
                appCoordinator?.handleDeepLink(deeplink: Deeplink.invite(code: inviteCode))
                return true
            }
        }
        
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.path.contains("shoppinglist") {
            appCoordinator?.handleDeepLink(deeplink: Deeplink.shoppingList)
            return true
            
        } else if url.path.contains("invite") {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let queryItems = components.queryItems,
               let inviteCode = queryItems.first(where: { $0.name == "code"})?.value {
                
                appCoordinator?.handleDeepLink(deeplink: Deeplink.invite(code: inviteCode))
                return true
            }
        }
        return false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    
}

