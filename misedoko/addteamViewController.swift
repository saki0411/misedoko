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
import MapKit
class addteamViewController: UIViewController, UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,
                             UICollectionViewDelegateFlowLayout {
    
    
    
    
    
    @IBOutlet var kensakulabel: UILabel!
    @IBOutlet var teamlabel: UILabel!
    @IBOutlet var teamnamelabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
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
    var first = false
    var word = String()
    var URLArray = [String]()
    var hozonArray = [MKAnnotation]()
    
    var genres = [String]()
    var selectedCell: Int  = -1
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        print(first)
        if first == true{
            print(first)
            syutoku()
            collectionView.reloadData()
        }
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.dataSource = self
        collectionView.delegate = self
        getteam()
        getname()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.getgenre()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.syutoku()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.first = true
            self.collectionView.reloadData()
        }
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
                    "uids": self.uid as Any
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
    @IBAction func kyouyu(_ sender: Any) {
        
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
    //    func createDynamicLink() {
    //        print(teamId,"これだ！！！")
    //           // Dynamic Linksのコンポーネントを作成する
    //           guard let link = URL(string: "https://misedoko.page.link.\(teamId)") else { return }
    //           let dynamicLinksDomainURIPrefix = "https://misedoko.page.link"
    //           let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
    //           linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier ?? "")
    //           linkBuilder?.iOSParameters?.appStoreID = "1234567890" // App Store IDを入力する
    //
    //           // Dynamic LinksのURLを生成する
    //           linkBuilder?.shorten { url, warnings, error in
    //               if let error = error {
    //                   // エラーがあればアラートを表示する
    //                   let alert = UIAlertController(title: "生成失敗", message: error.localizedDescription, preferredStyle: .alert)
    //                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
    //                   self.present(alert, animated:true, completion:nil)
    //               } else {
    //                   // エラーがなければ共有機能を呼び出す
    //                   if let url = url {
    //                       let items = [url]
    //                       let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
    //                       self.present(activityVC, animated: true, completion: nil)
    //                   }
    //               }
    //           }
    //       }
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
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            print(self.teamId,"aa")
            if !self.teamId.isEmpty{
                self.db.collection("teams").document(self.teamId)
                    .getDocument { documentSnapshot, error in
                        guard let document = documentSnapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        
                        let data = document.data()
                        let members = data?["members"] as? [String]
                        let shops = data?["shops"] as? [String]
                        let teamneme = data?["name"]
                        
                        print(members as Any)
                        // チームメンバーとお店のリストを更新する
                        self.teamMembers = []
                        self.teamMembers = members ?? []
                        self.teamName = ""
                        self.teamName = teamneme as! String
                        
                        self.teamlabel.text = self.teamName
                        for teamMember in self.teamMembers {
                            self.teamnamelabel.text! += teamMember
                        }
                        
                      
                    }
                
                // あるドキュメントをリッスンする
                self.db.collection("teams").document(self.teamId)
                    .addSnapshotListener { documentSnapshot, error in
                        guard let document = documentSnapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        
                        let data = document.data()
                        let members = data?["members"] as? [String]
                        let shops = data?["shops"] as? [String]
                        let teamneme = data?["name"]
                        
                        print(members as Any)
                        // チームメンバーとお店のリストを更新する
                        self.teamMembers = []
                        self.teamMembers = members ?? []
                        self.teamName = ""
                        self.teamName = teamneme as! String
                        
                        self.teamlabel.text = self.teamName
                        for teamMember in self.teamMembers {
                            self.teamnamelabel.text! += teamMember
                        }
                        
                        
                    }
                
                
            }
        }
    }
    func syutoku(){
        selectedChoices = []
        misetitle = []
        misesubtitle = []
        colorArray = []
        documentid = []
        commentArray = []
        URLArray = []
        
        
        let collectionRef = db.collection("teams").document(teamId).collection("shops")
        
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
                self.db.collection("teams").document(self.teamId).collection("shops").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            // 取得したドキュメントごとに実行する
                            let data = document.data()
                            let idokeido = data["idokeido"] as? GeoPoint
                            let genre = data["genre"] as? String ?? "カフェ"
                            let color = data["color"] as? String ?? "pink"
                            let comment = data["comment"] as? String ?? ""
                            let URL = data["URL"] as? String ?? ""
                            let title = data["title"] as? String ?? "title:Error"
                            let subtitle = data["subtitle"] as? String ?? "subtitle:Error"
                            
                            
                            self.selectedChoices.append(genre)
                            self.colorArray.append(color)
                            self.misetitle.append(title)
                            self.misesubtitle.append(subtitle)
                            self.documentid.append(document.documentID)
                            
                            self.commentArray.append(comment)
                            
                            self.URLArray.append(URL)
                            
                            let latitude = idokeido?.latitude
                            let longitude = idokeido?.longitude
                            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            self.hozonArray.append(annotation)
                            
                            
                            
                            
                            
                            
                            
                        }
                        self.choicecount  = []
                        for choice in self.selectedChoices {
                            self.choicecount.append(self.zyanru.firstIndex(of: choice) ?? 2)
                            
                        }
                        
                        
                        
                        
                        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
                        self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                        self.collectionView.reloadData()
                        
                    }
                    
                    
                }
            }else {
                // コレクションが存在しないかドキュメントが存在しない場合の処理
                print("Collection does not exist or is emptyコレクションがないよ")
                self.collectionView.delegate = self
                self.collectionView.dataSource  = self
                
                let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
                
                self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                self.collectionView.reloadData()
            }
            
        }
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return misetitle.count
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        
        
        
        
        cell.documentid = documentid
        
        //   cell.genres = genres
        cell.URLArray = URLArray
        cell.commentButton.tag = indexPath.row
        
        
        
        
        let initialRow = choicecount[indexPath.row]
        print(choicecount,"これだ！")
        
        cell.pickerView.selectRow(initialRow, inComponent: 0, animated: false)
        cell.zyanruTextField.text = zyanru[initialRow]
        
        
        
        
        
        if !commentArray.isEmpty{
            cell.commenttextfield.text = commentArray[indexPath.row]
        }
        if !URLArray.isEmpty{
            cell.URLtextfield.text = URLArray[indexPath.row]
        }
        
        
        
        
        cell.indexPath = indexPath
        cell.zyanru = zyanru
        
        
        
        let color = colorArray[indexPath.row]
        
        if color == "pink"{
            cell.backgroundColor = UIColor {_ in return #colorLiteral(red: 0.9568627451, green: 0.7019607843, blue: 0.7607843137, alpha: 1)}
            
        }else{
            cell.backgroundColor = UIColor {_ in return #colorLiteral(red: 0.6784313725, green: 0.7568627451, blue: 0.9176470588, alpha: 1)}
            
        }
        // セルにスワイプジェスチャーレコグナイザーを追加
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = .left // スワイプの方向を指定（例: 左方向）
        cell.addGestureRecognizer(swipeGesture)
        let swipeGesture2 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture2(_:)))
        swipeGesture2.direction = .right // スワイプの方向を指定（例: 左方向）
        cell.addGestureRecognizer(swipeGesture2)
        
        
        
        
        
        
        // let route = routes[indexPath.row]
        
        cell.shopnamelabel?.text = misetitle[indexPath.row]
        cell.adresslabel?.text = misesubtitle[indexPath.row]
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let cellSizeWidth:CGFloat = 320
        var cellSizeHeight:CGFloat = 300
        // タップされたセルのインデックスと一致する場合は高さを変更する
        
        
        if indexPath.row == selectedCell  {
            print("BB")
            cellSizeHeight = 600
        }
        
        // widthとheightのサイズを返す
        return CGSize(width: cellSizeWidth, height: cellSizeHeight/2)
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0 // 行間
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        
        guard let cell = gesture.view as? UICollectionViewCell else {
            return
        }
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        if gesture.state == .ended {
            
            colorArray[indexPath.row] = "blue"
            db.collection("teams").document(teamId).collection("shops").document(documentid[indexPath.row]).updateData(["color": "blue" ]) { error in
                
                if let error = error {
                    
                    print("エラーが発生しました: \(error)")
                    
                } else {
                    
                    print("ジャンルを更新しました")
                    
                    self.collectionView.reloadData()
                    
                    
                }
                
            }
            
            
            
            
            
            
        }
    }
    
    
    @objc func handleSwipeGesture2(_ gesture: UISwipeGestureRecognizer) {
        
        guard let cell = gesture.view as? UICollectionViewCell else {
            return
        }
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        if gesture.state == .ended {
            colorArray[indexPath.row] = "pink"
            db.collection("teams").document(teamId).collection("shops").document(documentid[indexPath.row ]).updateData(["color": "pink" ]) { error in
                
                if let error = error {
                    
                    print("エラーが発生しました: \(error)")
                    
                } else {
                    
                    print("ジャンルを更新しました")
                    self.collectionView.reloadData()
                    
                    
                }
                
            }
            
            
            
        }
    }
    func getgenre(){
        self.db.collection("users").document(self.uid ?? "").collection("zyanru").document("list").getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let zyanrulist = data?["zyanrulist"] as! Array<Any>
                for string in zyanrulist {
                    self.zyanru.append(string as! String)
                    print("これだよ！",self.zyanru)
                }
            }else {
                print("Document does not exist")
            }
        }
    }
    
}



