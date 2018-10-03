//
//  AppDelegate.swift
//  ShahrVand
//
//  Created by Mohammad Gharary on 5/15/17.
//  Copyright © 2017 Mohammad Gharary. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    let defaults = UserDefaults.standard
    struct defaultsKeys {
        static let username = "firstStringKey"
        static let password = "secondStringKey"
        static let isLoggedIn = false
        static let deviceToken = ""
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification :\(notification!.payload.notificationID)")
        }
        
        let notificationOpenedBlock : OSHandleNotificationActionBlock = { result in
            //This Block gets called when user reacts to a notification received
            
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body
            print("Message = \(String(describing: fullMessage))")
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title  = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    //process the action button clicked!
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(String(describing: additionalData!["actionSelected"]))"
                }
                
            }
        }
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "d5a0da8b-94b8-4b15-ad30-5c9cc3adfe9d",
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        //OneSignal.initWithLaunchOptions(launchOptions, appId: "0122abce-f68d-4020-aff3-518c694b58ad", handleNotificationReceived: notificationReceivedBlock ,handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User Accepted notifications: \(accepted)")
        })
        UINavigationBar.appearance().barTintColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1)
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 20.0)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 9.0)!], for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "IRANSANSMOBILE", size: 14.0)!], for: .normal)
        
        
        
        
        
        let attr = NSDictionary(object: UIFont(name: "IRANSANSMOBILE", size: 16.0)!, forKey: NSAttributedStringKey.font as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        UISegmentedControl.appearance().tintColor = UIColor(red: 29.0/255.0, green: 146.0/255.0, blue: 122.0/255.0, alpha: 1)
        //UISegmentedControl.appearance().tintColor = UIColor.red
        


        
        
        if self.window!.rootViewController as? UITabBarController != nil {
            let tabbarController = self.window!.rootViewController as! UITabBarController
            tabbarController.selectedIndex = 3
        }
        else{
            print("couldn't reach rootViewController named UITabBarController")
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        defaults.set(token, forKey: "deviceToken")
        print("Device Token: \(token)")
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

