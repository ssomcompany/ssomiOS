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
import FirebaseMessaging
import KeychainAccess
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SSDrawerViewControllerDelegate {

    var window: UIWindow?
    var drawerController: SSDrawerViewController?
    var isDrawable: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Fabric
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true

        // Firebase
        FIRApp.configure()

        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                                         name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)

        // Google Maps
        GMSServices.provideAPIKey(PreDefine.GoogleMapKey);

        // OneSignal
        OneSignal.initWithLaunchOptions(launchOptions, appId: PreDefine.OneSignalKey, handleNotificationReceived: { (notification) in
            print("notification: \(notification), payload data: \(notification?.payload.additionalData)")

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let keyWindow = appDelegate.window else { return }
            guard let rootViewController = keyWindow.rootViewController else { return }
            if rootViewController is SSDrawerViewController {
                guard let mainViewController = (rootViewController as! SSDrawerViewController).mainViewController else { return }
                if mainViewController is UINavigationController {
                    print("Now MainViewController is : NavigationController")

                    guard let topViewController = (mainViewController as! UINavigationController).topViewController else { return }
                    print("Now TopViewController is : \(topViewController)")
                    if topViewController is SSChatViewController {
                        // add the received message to the bottom fo the message lists
                        (topViewController as! SSChatViewController).reload(with: notification?.payload.additionalData as! [String: AnyObject])
                    } else if topViewController is SSChatListViewController {
                        // move up the chat room of the received message & add +1 to unread count
                        (topViewController as! SSChatListViewController).reload(with: notification?.payload.additionalData as! [String: AnyObject])
                    } else if topViewController is SSMasterViewController {
                        // add +1 to unread count
                        (topViewController as! SSMasterViewController).reload(with: notification?.payload.additionalData as! [String: AnyObject])
                    }
                } else {
                    print("Now MainViewController is : \(mainViewController)")
                }
            } else {
                print("Now view controller is : \(rootViewController)")
            }

        }, handleNotificationAction: { (openedResult) in
            print("openedResult : \(openedResult)")

            guard let notification = openedResult?.notification else { return }

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            guard let keyWindow = appDelegate.window else { return }
            guard let rootViewController = keyWindow.rootViewController else { return }
            if rootViewController is SSDrawerViewController {
                guard let mainViewController = (rootViewController as! SSDrawerViewController).mainViewController else { return }
                if mainViewController is UINavigationController {
                    print("Now MainViewController is : NavigationController")

                    guard let topViewController = (mainViewController as! UINavigationController).topViewController else { return }
                    print("Now TopViewController is : \(topViewController)")
                    if topViewController is SSChatViewController {
                        // add the received message to the bottom fo the message lists
                        (topViewController as! SSChatViewController).reload(with: notification.payload.additionalData as! [String: AnyObject])
                    } else if topViewController is SSChatListViewController {
                        // move up the chat room of the received message
                        (topViewController as! SSChatListViewController).reload(with: notification.payload.additionalData as! [String: AnyObject], needRecount: false)
                    } else if topViewController is SSMasterViewController {
                        // add +1 to unread count
                        (topViewController as! SSMasterViewController).reload(with: notification.payload.additionalData as! [String: AnyObject])
                    }
                } else {
                    print("Now MainViewController is : \(mainViewController)")
                }
            } else {
                print("Now view controller is : \(rootViewController)")
            }
        }, settings: [kOSSettingsKeyInFocusDisplayOption : "None"])

        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // DrawerViewController
        self.drawerController = self.window!.rootViewController as? SSDrawerViewController
        self.drawerController?.delegate = self
        self.drawerController?.addStylerFromArray([SSDrawerScaleStyler.styler(), SSDrawerFadeStyler.styler(), SSDrawerShadowStyler.styler()], forDirection: SSDrawerDirection.Left)

        let menuViewController: SSMenuViewController = (self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? SSMenuViewController)!
        menuViewController.drawerViewController = self.drawerController
        self.drawerController?.setDrawerViewController(menuViewController, forDirection: SSDrawerDirection.Left)

        // Transition to the first view controller
        menuViewController.transitionToViewController()

        self.window?.rootViewController = self.drawerController
        self.window?.makeKeyAndVisible()

        // Version Check
        SSNetworkAPIClient.getVersion { (version, error) in
            if let err = error {
                print(err.localizedDescription)

                SSAlertController.showAlertConfirm(title: "Error", message: "버전 체크에 실패하였습니다!", completion: nil)
            } else {
                if let bundleVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String, let currentVersion = version {
                    print("Current App Version is : ", bundleVersion)

                    if Double(bundleVersion.replacingOccurrences(of: ".", with: ""))! < Double(currentVersion.replacingOccurrences(of: ".", with: ""))! {
                        SSAlertController.showAlertTwoButton(title: "알림",
                            message: "새로운 업데이트가 있습니다.\n 업데이트 후 이용하실 수 있습니다 =)",
                            button1Title: "업데이트",
                            button2Title: "종료",
                            button1Completion: { (action) in
                                UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/bars/id1083356262")!)
                                exit(0)
                            },
                            button2Completion: { (action) in
                                exit(0)
                        })
                    }
                }
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connectToFcm()

        FBSDKAppEvents.activateApp()

        self.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO: UUID 관리 관련해서 수정해야됨..
        print("deviceToken : \(deviceToken)")
        let keyChain = Keychain(service: "com.ssom")
        keyChain[data: "pushDeviceToken"] = deviceToken

        OneSignal.idsAvailable { (oneSignalPlayerID, pushToken) in
            print("playerId : \(oneSignalPlayerID), pushToken : \(pushToken)")
            keyChain[string: "oneSignalPlayerID"] = oneSignalPlayerID
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let gcmMessageId = userInfo["gcm.message_id"] {
            print("Message ID : \(gcmMessageId)")
        }

        print("%@", userInfo)
    }

// MARK: - private
    fileprivate func activateApp() {
        if let token = SSAccountManager.sharedInstance.sessionToken, let email = SSAccountManager.sharedInstance.email {
            SSNetworkAPIClient.getUser(token, email: email, completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                }

                if let model = user {
                    print("user is : \(model)")

                    if let imageUrl = model.profileImageUrl {
                        SSNetworkContext.sharedInstance.saveSharedAttribute(imageUrl, forKey: "profileImageUrl")
                    } else {
                        SSNetworkContext.sharedInstance.deleteSharedAttribute("profileImageUrl")
                    }
                }
            })
        }

        SSNetworkAPIClient.postLoginWithoutId { (error) in
            if let err = error {
                print(err.localizedDescription)

                SSAlertController.showAlertConfirm(title: "Error", message: "유저 세션 갱신에 실패하였습니다!", completion: nil)
            }
        }
    }

// MARK: - FirebaseMessage
    func tokenRefreshNotification(_ notification: Notification) {
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }

    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }

// MARK: - SSDrawerViewControllerDelegate

    func drawerViewController(_ drawerViewController: SSDrawerViewController, mayUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection) {
        print("Drawer view controller may update to state `\(paneState)` for direction `\(direction)`")

        if paneState == .open {
            if let menuViewController = drawerViewController.drawerViewController as? SSMenuViewController {
                if let headerView = menuViewController.menuTableView.headerView(forSection: 0) as? SSMenuHeadView {
                    headerView.configView()
                }
            }
        }
    }

    func drawerViewController(_ drawerViewController: SSDrawerViewController, didUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection) {
        print("Drawer view controller did update to state `\(paneState)` for direction `\(direction)`")
    }

    func drawerViewController(_ drawerViewController: SSDrawerViewController, shouldBeginPanePan panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return self.isDrawable
    }
}

