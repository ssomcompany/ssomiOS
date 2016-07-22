//
//  AppDelegate.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 1..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import GoogleMaps
import Fabric
import Crashlytics
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SSDrawerViewControllerDelegate {

    var window: UIWindow?
    var drawerController: SSDrawerViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true

        FIRApp.configure()

        GMSServices.provideAPIKey(PreDefine.GoogleMapKey);

        self.drawerController = self.window!.rootViewController as? SSDrawerViewController
        self.drawerController?.delegate = self
        self.drawerController?.addStylerFromArray([SSDrawerScaleStyler.styler(), SSDrawerFadeStyler.styler()], forDirection: SSDrawerDirection.Left)

        let menuViewController: SSMenuViewController = (self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as? SSMenuViewController)!
        menuViewController.drawerViewController = self.drawerController
        self.drawerController?.setDrawerViewController(menuViewController, forDirection: SSDrawerDirection.Left)

        // Transition to the first view controller
        menuViewController.transitionToViewController()

        self.window?.rootViewController = self.drawerController
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

// MARK: - SSDrawerViewControllerDelegate

    func drawerViewController(drawerViewController: SSDrawerViewController, mayUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection) {
        print("Drawer view controller may update to state `\(paneState)` for direction `\(direction)`")
    }

    func drawerViewController(drawerViewController: SSDrawerViewController, didUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection) {
        print("Drawer view controller did update to state `\(paneState)` for direction `\(direction)`")
    }

}

