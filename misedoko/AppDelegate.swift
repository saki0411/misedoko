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
class AppDelegate: UIResponder, UIApplicationDelegate {
    

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
        // バックグラウンドタスクの登録
        registerBackgroundTask()
        
        // 通知の許可と内容を設定する
        setupNotification()
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
    
    
    func registerBackgroundTask() {
        // BGTaskSchedulerにバックグラウンドタスクの識別子と実行内容を登録する
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
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
                                let title = data["title"] as? String ?? "title:Error"
                                let subtitle = data["subtitle"] as? String ?? "subtitle:Error"
                                
                                let genre = data["genre"] as? String ?? "カフェ"
                                let color = data["color"] as? String ?? "pink"
                                let comment = data["comment"] as? String ?? ""
                                
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
                    self.showNotification(message: "近くに\(self.nearbyAnnotations.count)件のお店があります")
                }
                
                // バックグラウンドタスクの処理が終了したら、タスクの完了を通知する
                task.setTaskCompleted(success: true)
            }
        }
        
    }
    
    // 通知の許可と内容を設定するメソッド
     func setupNotification() {
         // 通知の種類を指定
         let options: UNAuthorizationOptions = [.alert, .sound]
         
         // 通知の許可をユーザーに求める
         notificationCenter.requestAuthorization(options: options) { (granted, error) in
             if let error = error {
                 print("Error: \(error.localizedDescription)")
             }
         }
         
         // 通知の内容を作成
         let content = UNMutableNotificationContent()
         content.title = "お店の情報"
         content.sound = .default
         
         // 通知の内容を登録
         notificationCenter.setNotificationCategories([UNNotificationCategory(identifier: "backgroundTask", actions: [], intentIdentifiers: [], options: [])])
     }
     
     // 通知を表示するメソッド
     func showNotification(message: String) {
         // 通知の内容を取得
         let content = UNMutableNotificationContent()
         content.title = "お店の情報"
         content.body = message
         content.sound = .default
         
         // 通知のトリガーを作成（即時発火）
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
         
         // 通知のリクエストを作成
         let request = UNNotificationRequest(identifier: "backgroundTask", content: content, trigger: trigger)
         
         // 通知を登録
         notificationCenter.add(request) { (error) in
             if let error = error {
                 print("Error: \(error.localizedDescription)")
             }
         }
     }
     
     // タスクリクエストを送信するメソッド
     func submitTaskRequest() {
         // BGAppRefreshTaskRequestクラスのインスタンスを作成
         let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
         
         // 最小間隔を1時間に設定
         request.earliestBeginDate = Date(timeIntervalSinceNow: 100)
         
         // タスクリクエストを送信
         do {
             try BGTaskScheduler.shared.submit(request)
         } catch {
             print("Error: \(error.localizedDescription)")
         }
     }

}

