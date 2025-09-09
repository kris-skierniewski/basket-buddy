////
////  Navigator.swift
////  price tracker
////
////  Created by Kris Skierniewski on 28/08/2024.
////
//
//import UIKit
//
//class Navigator {
//    private var window: UIWindow?
//    
//    private var masterViewController: UIViewController!
//    
//    private var context: ViewControllerContext!
//    
//    private var leftTabNavigationController: UINavigationController!
//    private var middleTabNavigationController: UINavigationController!
//    private var rightTabNavigationController: UINavigationController!
//    
//    var tabBarController: UITabBarController?
//    
//    func initialiseApp(onWindow window: UIWindow, context: ViewControllerContext) {
//        self.context = context
//        self.masterViewController = MasterViewController(withContext: context)
//        
//        let leftTabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
//        leftTabNavigationController = UINavigationController(rootViewController: masterViewController)
//        leftTabNavigationController.tabBarItem = leftTabBarItem
//        
//        let middleTabBarItem = UITabBarItem(title: "Shopping List", image: UIImage(systemName: "cart"), tag: 2)
//        middleTabNavigationController = UINavigationController(rootViewController: ComposeShoppingListViewController(withContext: context))
//        middleTabNavigationController.tabBarItem = middleTabBarItem
//        
////        let rightTabBarItem = UITabBarItem(title: "Account", image: UIImage(systemName: "person.crop.circle"), tag: 1)
////        let accountViewController = AccountViewController()
////        rightTabNavigationController = UINavigationController(rootViewController: accountViewController)
////        rightTabNavigationController.tabBarItem = rightTabBarItem
//        
//        tabBarController = UITabBarController()
//        tabBarController?.viewControllers = [leftTabNavigationController, middleTabNavigationController]
//        
//        self.window = window
//        window.rootViewController = tabBarController
//        window.makeKeyAndVisible()
//    }
//    
//    func add(_ childViewController: UIViewController,
//             parentViewController: UIViewController,
//             containerView: UIView? = nil) {
//        parentViewController.addChild(childViewController)
//        let viewControllerContainerView = containerView ?? parentViewController.view
//        viewControllerContainerView?.addExpandingSubview(childViewController.view)
//        childViewController.didMove(toParent: parentViewController)
//    }
//    
//    func presentAlertController(withErrorDescription errorDescription: String) {
//        let alertController = UIAlertController(title: "Sorry, something went wrong", message: errorDescription, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "Got it", style: .default)
//        alertController.addAction(okAction)
//        tabBarController?.present(alertController, animated: true)
//    }
//    
//}
