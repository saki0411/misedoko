//
//  friendViewController.swift
//  misedoko
//
//  Created by saki on 2023/06/13.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDynamicLinks
import Firebase

class addteamViewController: UIViewController, UISearchBarDelegate {
 
  

    @IBOutlet var kensakulabel: UILabel!
    @IBOutlet var teamlabel: UILabel!
    @IBOutlet var teamnamelabel: UILabel!
    var documentNames = [String]()
    var result = String()
    
    var selectedChoices = [String]()
    var commentArray = [String]()
    var documentid = [String] ()
    var colorArray = [String]()
    var misetitle  = [String]()
    var misesubtitle = [String]()
    var choicecount = [Int]()
    var zyanru = [String]()
    let uid = Auth.auth().currentUser?.uid
    let db = Firestore.firestore()
    let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
    
    var word = String()
    
    
    
    
    // ユーザーのメールアドレスと名前を保持する変数
        var userEmail = ""
        var userName = ""
    var name = ""
        
        // チームのIDと名前を保持する変数
        var teamId = ""
        var teamName = ""
    
        
        // チームのメンバーとお店のリストを保持する変数
        var teamMembers = [String]()
        var teamShops = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getteam()
   getname()
        
   
    }
    func getname(){
        let docRef = db.collection("users").document(uid ?? "").collection("personal").document("info")
        docRef.getDocument { (document, error) in
           if let document = document, document.exists {
             let data = document.data()
             let name2 = data?["name"] as? String ?? "Name:Error"
               self.name = name2
               print("Success! Name:\(self.name)")
 
           } else {
             print("Document does not exist")
           }
    
             }
    }
   
    
  
    @IBAction func createTeam(_ sender: Any){
            // チーム名を入力するアラートを表示する
            let alert = UIAlertController(title: "チーム作成", message: "チーム名を入力してください", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "チーム名"
            }
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "作成", style: .default) { action in
                // 入力されたチーム名を取得する
                if let teamName = alert.textFields?.first?.text, !teamName.isEmpty {
                    // Firestoreにチーム情報を保存する
                    let db = Firestore.firestore()
                    db.collection("teams").addDocument(data:[
                        "name": teamName,
                        "members": [self.name],
                        "uids": self.uid as Any,
                        "shops": []
                    ]) { error in
                        if let e = error {
                            // エラーがあればアラートを表示する
                            let alert = UIAlertController(title: "作成失敗", message: e.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                            self.present(alert, animated:true, completion:nil)
                        } else {
                            // エラーがなければFirestoreからチーム情報を取得する
                            db.collection("teams").whereField("name", isEqualTo: teamName).getDocuments { querySnapshot, error in
                                if let e = error {
                                    // エラーがあればアラートを表示する
                                    let alert = UIAlertController(title: "取得失敗", message: e.localizedDescription, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                                    self.present(alert, animated:true, completion:nil)
                                } else {
                                    // エラーがなければチームIDと名前を取得する
                                    if let documents = querySnapshot?.documents, let document = documents.first {
                                        self.teamId = document.documentID
                                        self.teamName = teamName
                                        // ユーザー情報にチームIDを追加する
                                        db.collection("users").document(self.uid ?? "").collection("personal").document("info").updateData([
                                            "teams": FieldValue.arrayUnion([self.teamId])
                                        ]) { error in
                                            if let e = error {
                                                // エラーがあればアラートを表示する
                                                let alert = UIAlertController(title: "更新失敗", message: e.localizedDescription, preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                                                self.present(alert, animated:true, completion:nil)
                                            } else {
                                                // エラーがなければナビゲーションバーのタイトルを変更する
                                                self.title = "\(self.userName)さん (\(self.teamName))"
                                                // チームメンバーとお店のリストを更新する
                                                self.updateTeamInfo()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
            self.present(alert, animated: true, completion: nil)
        }
        
        @IBAction func joinTeam() {
            // チームIDを入力するアラートを表示する
            let alert = UIAlertController(title: "チーム参加", message: "チームIDを入力してください", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "チームID"
            }
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "参加", style: .default) { action in
                // 入力されたチームIDを取得する
                if let teamId = alert.textFields?.first?.text, !teamId.isEmpty {
                    // Firestoreからチーム情報を取得する
                    let db = Firestore.firestore()
                    db.collection("teams").document(teamId).getDocument { document, error in
                        if let e = error {
                            // エラーがあればアラートを表示する
                            let alert = UIAlertController(title: "参加が失敗", message: e.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                            self.present(alert, animated:true, completion:nil)
                        } else {
                            // エラーがなければチーム名を取得する
                            if let document = document, document.exists {
                                if let data = document.data(), let teamName = data["name"] as? String {
                                    self.teamId = teamId
                                    self.teamName = teamName
                                    // チーム情報にユーザーのメールアドレスを追加する
                                    db.collection("teams").document(teamId).updateData([
                                        "members": FieldValue.arrayUnion([self.name]),
                                        "uids": FieldValue.arrayUnion([self.uid ?? ""])
                                    ]) { error in
                                        if let e = error {
                                            // エラーがあればアラートを表示する
                                            let alert = UIAlertController(title: "参加失敗", message: e.localizedDescription, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                                            self.present(alert, animated:true, completion:nil)
                                        } else {
                                            // エラーがなければユーザー情報にチームIDを追加する
                                            db.collection("users").document(self.uid ?? "").collection("personal").document("info").updateData([
                                                "teams": teamId
                                            ]) { error in
                                                if let e = error {
                                                    // エラーがあればアラートを表示する
                                                    let alert = UIAlertController(title: "参加失敗", message: e.localizedDescription, preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                                                    self.present(alert, animated:true, completion:nil)
                                                } else {
                                                    // エラーがなければナビゲーションバーのタイトルを変更する
                                                    self.navigationItem.title = "\(self.userName)さん (\(self.teamName))"
                                                    // チームメンバーとお店のリストを更新する
                                                    self.updateTeamInfo()
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                // ドキュメントが存在しなければアラートを表示する
                                let alert = UIAlertController(title: "参加失敗", message: "チームIDが正しくありません", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                                self.present(alert, animated:true, completion:nil)
                            }
                        }
                    }
                }
            })
            self.present(alert, animated: true, completion: nil)
        }
        
        func updateTeamInfo() {
            // Firestoreからチームメンバーとお店のリストを取得する
            let db = Firestore.firestore()
            db.collection("teams").document(teamId).getDocument { document, error in
                if let document = document, document.exists {
                    if let data = document.data(), let members = data["members"] as? [String], let shops = data["shops"] as? [String] {
                        // チームメンバーとお店のリストを更新する
                        self.teamMembers = members
                        self.teamlabel.text = self.teamName
                        for teamMember in self.teamMembers {
                            self.teamnamelabel.text! += teamMember
                        }
                        
                        self.teamShops = shops
//                        // テーブルビューをリロードする
//                        self.tableView.reloadData()
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    func createDynamicLink() {
           // Dynamic Linksのコンポーネントを作成する
           guard let link = URL(string: "https://\(FirebaseApp.app()?.options.projectID ?? "").page.link/\(teamId)") else { return }
           let dynamicLinksDomainURIPrefix = "https://\(FirebaseApp.app()?.options.projectID ?? "").page.link"
           let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
           linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier ?? "")
           linkBuilder?.iOSParameters?.appStoreID = "1234567890" // App Store IDを入力する
           
           // Dynamic LinksのURLを生成する
           linkBuilder?.shorten { url, warnings, error in
               if let error = error {
                   // エラーがあればアラートを表示する
                   let alert = UIAlertController(title: "生成失敗", message: error.localizedDescription, preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                   self.present(alert, animated:true, completion:nil)
               } else {
                   // エラーがなければ共有機能を呼び出す
                   if let url = url {
                       let items = [url]
                       let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                       self.present(activityVC, animated: true, completion: nil)
                   }
               }
           }
       }
    func getteam(){
        db.collection("users").document(self.uid ?? "").collection("personal").document("info").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let team = data?["teams"] as? String ?? "team:Error"
                print(data?["teams"] as Any)
                self.teamId = team
                print(self.teamId)
            } else {
                print("Document does not exist")
            }
        }
        if !teamId.isEmpty{
            
            // あるドキュメントをリッスンする
            db.collection("teams").document(teamId)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    if let data = document.data(), let members = data["members"] as? [String], let shops = data["shops"] as? [String] {
                        // チームメンバーとお店のリストを更新する
                        self.teamMembers = members
                        self.teamlabel.text = self.teamName
                        for teamMember in self.teamMembers {
                            self.teamnamelabel.text! += teamMember
                        }
                        
                        self.teamShops = shops
                    }
                }
            
        }
        }
    }

    

