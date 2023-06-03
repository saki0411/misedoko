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


@main

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    let backgroundTaskIdentifier = "com.hosonuma.sakki.misedoko.backgroundTask"
    let notificationCenter = UNUserNotificationCenter.current()
    
    var db: Firestore! = nil
    var uid: String? = nil
    var nearbyAnnotations = [MKAnnotation]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        db = Firestore.firestore()
        uid = Auth.auth().currentUser?.uid
        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted{
                    UNUserNotificationCenter.current().delegate = self
                } else {
                    print("通知が許可されていない")
                }
            }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.hosonuma.sakki.misedoko.backgroundTask", using: nil) { task in
            // バックグラウンド処理したい内容 ※後述します
            
            
            // バックグラウンドタスクが実行されたら、このクロージャーが呼ばれる
            var annotations: [MKAnnotation] = []
            let collectionRef = self.db.collection(self.uid ?? "hozoncollection")
            
            collectionRef.getDocuments { (snapshot, error) in
                if let error = error {
                    // エラーが発生した場合の処理
                    print("Error fetching documents: \(error)")
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    // コレクションにドキュメントが存在する場合の処理
                    print("Collection exists and contains documents")
                    // 全てのドキュメントを取得する
                    self.db.collection(self.uid ?? "hozoncollection").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                // 取得したドキュメントごとに実行する
                                let data = document.data()
                                let idokeido = data["idokeido"] as? GeoPoint
                                
                                
                                let latitude = idokeido?.latitude
                                let longitude = idokeido?.longitude
                                let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = coordinate
                                annotations.append(annotation)
                                
                                
                                
                                
                                
                                let locationManager = CLLocationManager()
                                locationManager.requestWhenInUseAuthorization()
                                guard let currentLocation = locationManager.location else {
                                    // 現在地が取得できなかったら、タスクを完了する
                                    task.setTaskCompleted(success: false)
                                    return
                                }
                                
                                
                                
                                // annotationのCLLocationCoordinate2DをCLLocationに変換する
                                let annotationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                
                                // 現在地とannotationの距離を計算する
                                let distance = currentLocation.distance(from: annotationLocation)
                                
                                
                                
                                // 距離が1000m以下なら、nearbyAnnotationsに追加する
                                if distance <= 1000 {
                                    
                                    
                                    self.nearbyAnnotations.append(annotation)
                                    
                                }
                                
                                
                                else {
                                    // コレクションが存在しないかドキュメントが存在しない場合の処理
                                    print("Collection does not exist or is emptyコレクションがないよ")
                                    
                                }
                            }
                            
                            
                        }
                    }
                    
                    
                }
                // arrayに情報が入っている場合は、ローカル通知を表示する
                if !self.nearbyAnnotations.isEmpty {
                    let content = UNMutableNotificationContent()
                          content.title = "お知らせ"
                          content.body = "近くにあります"
                          content.sound = UNNotificationSound.default

                         
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
                          let request = UNNotificationRequest(identifier: "immediately", content: content, trigger:trigger)
                          UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                }
                
                // バックグラウンドタスクの処理が終了したら、タスクの完了を通知する
                task.setTaskCompleted(success: true)
            }
        }
        
        
        return true
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
    
    
    
}
    
 
