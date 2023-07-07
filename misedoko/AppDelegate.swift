//
//  AppDelegate.swift
//  misedoko
//
//  Created by saki on 2023/04/23.
//

import UIKit
import FirebaseCore
import BackgroundTasks
import CoreLocation
import MapKit
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import IQKeyboardManagerSwift
import FirebaseDynamicLinks

@main

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // Dynamic Linksのハンドリングを追加する
        if let userActivity = launchOptions?[.userActivityDictionary] as? [AnyHashable : Any],
           let activity = userActivity[UIApplication.LaunchOptionsKey.userActivityType] as? NSUserActivity {
            return handleDynamicLink(activity)
        }
        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted{
                    UNUserNotificationCenter.current().delegate = self
                } else {
                    print("通知が許可されていないよ")
                }
            }
        
        
        
        
     
        
        return true
        
    }
    

}

func applicationWillEnterForeground(_ application: UIApplication) {
    
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
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // アプリ起動中でもアラートと音で通知
    completionHandler([.alert, .sound])
    
}

func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
    
}
func applicationDidEnterBackground(_ application: UIApplication) {
    
}
// Dynamic Linksのハンドリングを追加する
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return handleDynamicLink(url)
}
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return handleDynamicLink(userActivity)
}

func handleDynamicLink(_ url: URL) -> Bool {
    guard let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) else { return false }
    handleDynamicLink(dynamicLink)
    
    return true
}

func handleDynamicLink(_ userActivity:NSUserActivity) -> Bool {
    guard let incomingURL = userActivity.webpageURL else { return false }
    guard let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: incomingURL) else { return false }
    handleDynamicLink(dynamicLink)
    return true
}

func handleDynamicLink(_ dynamicLink: DynamicLink) {
    // チームIDを取得する
    if let teamId = dynamicLink.url?.lastPathComponent {
        // チームIDをUserDefaultsに保存する
        UserDefaults.standard.set(teamId, forKey: "teamId")
        print(teamId,"te-muID")
    }
}






