//
//  SceneDelegate.swift
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



class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let backgroundTaskIdentifier = "com.hosonuma.sakki.misedoko.backgroundTask2"
    let notificationCenter = UNUserNotificationCenter.current()
    
    var db: Firestore! = nil
    var uid: String? = nil
    var nearbyAnnotations = [MKAnnotation]()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
            
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // アプリがバックグラウンドに入ったら呼ばれる
        scheduleAppRefresh()
    }
        
        func sceneDidBecomeActive(_ scene: UIScene) {
            // Called when the scene has moved from an inactive state to an active state.
            // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        }
        
        func sceneWillResignActive(_ scene: UIScene) {
            // Called when the scene will move from an active state to an inactive state.
            // This may occur due to temporary interruptions (ex. an incoming phone call).
        }
        
        func sceneWillEnterForeground(_ scene: UIScene) {
            // Called as the scene transitions from the background to the foreground.
            // Use this method to undo the changes made on entering the background.
        }
        
        func sceneDidEnterBackground(_ scene: UIScene) {
          
           
        }
        func scheduleAppRefresh() {
            // バックグラウンドタスクの予約 (スケジュール) をする
            let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
            // 最も早い実行時刻を設定する (15分後)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
            // ネットワーク接続が必要かどうかを設定する (true)
            request.requiresNetworkConnectivity = true
            // タスクを予約する
            do {
                try BGTaskScheduler.shared.submit(request)
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
        
        func handleAppRefresh(task: BGAppRefreshTask) {
            // バックグラウンドタスクを実行する
            // タイムアウト時に呼ばれる処理を設定する
            task.expirationHandler = {
                // タスクをキャンセルする
                task.setTaskCompleted(success: false)
            }
            db = Firestore.firestore()
            uid = Auth.auth().currentUser?.uid
            
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
                    self.db.collection("users").document(self.uid ?? "").collection("shop").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
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
                    
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
                    let request = UNNotificationRequest(identifier: "immediately", content: content, trigger:trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                }
                
                // バックグラウンドタスクの処理が終了したら、タスクの完了を通知する
                
                
                
                // タスクが完了したことを通知する
                task.setTaskCompleted(success: true)
                // 次のタスクを予約する
                self.scheduleAppRefresh()
            }
        }
        
        
        
    
}
