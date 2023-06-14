//
//  colectionviewViewController.swift
//  misedoko
//
//  Created by saki on 2023/05/15.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseFirestore

class colectionviewViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout, CustomCellDelegate {
    func showAlert(message: String) {
        let alert: UIAlertController = UIAlertController(title: "保存", message: "コメントの保存しました", preferredStyle: .alert)
        
        
        alert.addAction(
            UIAlertAction(title: "OK",
                          style: .default,
                          handler: { action in
                              
                              
                          })
            
        )
        self.present(alert,animated: true,completion: nil)
    }
    
    
    
    
    var hozonArray = [MKAnnotation]()
    var routes: [MKRoute] = []
    
    var misetitle = [String]()
    var misesubtitle = [String]()
    var publicmisetitle = [String]()
    var publicmisesubtitle = [String]()
    
    
    var colorArray = [String]()
    var publiccolorArray = [String]()
    var URLArray = [String]()
    
    var zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
    var savedata: UserDefaults = UserDefaults.standard
    
    var genres: [(genre: String, documentID: String)] = []
    var selectedChoices = [String]()
    var publicselectedChoices = [String]()
    var selectedChoice: String = ""
    var choicecount = [Int]()
    var publicchoicecount = [Int]()
    
    var commentArray = [String]()
    
    var selectedCell: Int  = -1
    
    //firestoreのやつ
    let db = Firestore.firestore()
    
    let uid = Auth.auth().currentUser?.uid
    var documentid = [String]()
    var publicdocumentid = [String]()
    
    @IBOutlet  weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = 0
        
        
        //collectionview長押しのやつ
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.size.width / 4, height: view.bounds.size.width / 4)
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.headerReferenceSize = CGSize(width:0,height:0)
        
        
        
        
        
        
        
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
            
            
        }
     syutoku()
      
        deletekyouyu()
        
     
        
    }
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
            print(sender.titleForSegment(at: sender.selectedSegmentIndex)!)
        if sender.selectedSegmentIndex == 0{
            syutoku()
            
        }else if sender.selectedSegmentIndex == 1{
        
            print("えええ")
            DispatchQueue.global().async {
              
                DispatchQueue.main.sync {
                    print(self.publicmisetitle)
                    self.collectionView.reloadData()
                }
                // 三番目に実行
            }
           
                           
            
        
                      
               
        }else{
         
        }
        }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if  segmentedControl.selectedSegmentIndex == 0{
            return misetitle.count
        }else if segmentedControl.selectedSegmentIndex == 1{
            return publicmisetitle.count
        }else{
            return misetitle.count
        }
       
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }else{
            zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
            
        }
        if segmentedControl.selectedSegmentIndex != 0{
            cell.commentButton.isHidden = true
          
        
            cell.pickerView.isHidden = true
            
            cell.URLtextfield.isHidden = true
            cell.URLbutton.isHidden = true
            cell.zyanruTextField.isUserInteractionEnabled = false
           
        }
        
      
        cell.delegate = self
        cell.documentid = documentid
        
        cell.genres = genres
        cell.URLArray = URLArray
        cell.commentButton.tag = indexPath.row
        
    
        if segmentedControl.selectedSegmentIndex == 0{
            let initialRow = choicecount[indexPath.row]
            cell.pickerView.selectRow(initialRow, inComponent: 0, animated: false)
            cell.zyanruTextField.text = zyanru[initialRow]
            
         
            print(publicchoicecount,"2")
        }else if segmentedControl.selectedSegmentIndex == 1{
            let initialRow = publicchoicecount[indexPath.row]
            cell.pickerView.selectRow(initialRow, inComponent: 0, animated: false)
            cell.zyanruTextField.text = zyanru[initialRow]
        }
       
      
        if !commentArray.isEmpty{
            cell.commenttextfield.text = commentArray[indexPath.row]
        }
        if !URLArray.isEmpty{
            cell.URLtextfield.text = URLArray[indexPath.row]
        }

        
        
        
        cell.indexPath = indexPath
      
        if segmentedControl.selectedSegmentIndex == 0{
            
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
        }else{
           
            let color = publiccolorArray[indexPath.row]
           
            if color == "pink"{
                cell.backgroundColor = UIColor {_ in return #colorLiteral(red: 0.9568627451, green: 0.7019607843, blue: 0.7607843137, alpha: 1)}
                
            }else{
                cell.backgroundColor = UIColor {_ in return #colorLiteral(red: 0.6784313725, green: 0.7568627451, blue: 0.9176470588, alpha: 1)}
                
            }
                
            
        }
            // let route = routes[indexPath.row]
            if  segmentedControl.selectedSegmentIndex == 0{
                cell.shopnamelabel?.text = misetitle[indexPath.row]
                cell.adresslabel?.text = misesubtitle[indexPath.row]
            }else if segmentedControl.selectedSegmentIndex == 1{
                cell.shopnamelabel?.text = publicmisetitle[indexPath.row]
                cell.adresslabel?.text = publicmisesubtitle[indexPath.row]
            }
            
            
       
        
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let cellSizeWidth:CGFloat = 350
        var cellSizeHeight:CGFloat = 300
        // タップされたセルのインデックスと一致する場合は高さを変更する
        if indexPath.row == selectedCell {
            cellSizeHeight = 600
           
        }
        
        
        // widthとheightのサイズを返す
        return CGSize(width: cellSizeWidth, height: cellSizeHeight/2)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0 // 行間
    }
    
    
    
    
    //長押しのやつ
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            //ボタン
            let delete = UIAction(title: "削除", image: UIImage(systemName: "trash.fill")) { action in
                if self.segmentedControl.selectedSegmentIndex == 0{
                    
                    
                    guard let itemToDelete = self.hozonArray[indexPath.item] as? MKAnnotation else {
                        return
                    }
                    if let indexToDelete = self.hozonArray.firstIndex(where: { $0 === itemToDelete }) {
                        self.db.collection("users").document(self.uid ?? "").collection("shop").document(self.documentid[indexPath.row]).delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                                self.deletekyouyu()
                                
                            }
                        }
                        self.documentid.remove(at: indexPath.row)
                        self.hozonArray.remove(at: indexToDelete)
                        self.misetitle.remove(at: indexPath.row)
                        self.misesubtitle.remove(at: indexPath.row)
                        self.URLArray.remove(at: indexPath.row)
                        self.selectedChoices.remove(at: indexPath.row)
                        self.choicecount.remove(at: indexPath.row)
                        self.commentArray.remove(at: indexPath.row)
                        self.colorArray.remove(at: indexPath.row)
                        
                        
                        collectionView.reloadData()
                        
                    }
                }else if self.segmentedControl.selectedSegmentIndex == 1{
                 
                    self.db.collection("users").document(self.uid ?? "").collection("public").document(self.publicdocumentid[indexPath.row]).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            self.deletekyouyu()
                            
                            
                        }
                    }
                    self.publicdocumentid.remove(at: indexPath.row)
                    self.publiccolorArray.remove(at: indexPath.row)
                }
            }
            let addlist = UIAction(title: "共有リストに追加", image: UIImage(systemName: "rectangle.stack.badge.person.crop.fill")) { action in
                self.db.collection("users").document(self.uid ?? "").collection("shop").document(self.documentid[indexPath.row ]).updateData(["kyouyu": true]) { error in
                    
                    if let error = error {
                        
                        print("エラーが発生しました: \(error)")
                        
                    } else {
                     
                        self.deletekyouyu()
                        
                       
                        print("共有リストを更新しました")
                        
                        
                        
                    }
                }
            }
            
            return UIMenu(title: "Menu", children: [addlist, delete])
            
            
        }
        )
        
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
            db.collection("users").document(uid ?? "").collection("shop").document(documentid[indexPath.row ]).updateData(["color": "blue" ]) { error in
                
                if let error = error {
                    
                    print("エラーが発生しました: \(error)")
                    
                } else {
                    
                    print("ジャンルを更新しました")
                    self.deletekyouyu()
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
            db.collection("users").document(uid ?? "").collection("shop").document(documentid[indexPath.row ]).updateData(["color": "pink" ]) { error in
                
                if let error = error {
                    
                    print("エラーが発生しました: \(error)")
                    
                } else {
                    self.deletekyouyu()
                    print("ジャンルを更新しました")
                    self.collectionView.reloadData()
                    
                    
                }
                
            }
            
            
            
        }
    }
    @IBAction func share(sender: UIButton) {

    let activityItems = ["私のミセドココードは",uid,"だよ"]

        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems as [Any], applicationActivities: nil)

        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.print
        ]

        activityVC.excludedActivityTypes = excludedActivityTypes

        // UIActivityViewControllerを表示
        self.present(activityVC, animated: true, completion: nil)
      }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toadd" {
            let nextView = segue.destination as! addViewController
            nextView.zyanru = zyanru
        }
        if segue.identifier == "tomain" {
            let nextView = segue.destination as! mainViewController
            nextView.zyanru = zyanru
        }
        if segue.identifier == "tofriend" {
            let nextView = segue.destination as! friendViewController
            nextView.zyanru = zyanru
        }
    }
    
    
    func selectedd(gotselectedcell: Int){
        selectedCell = gotselectedcell
        
        collectionView.reloadData()
    }
   
    func syutoku(){
        selectedChoices = []
        
        
        let collectionRef = db.collection("users").document(uid ?? "").collection("shop")
        
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
                            let genre = document.data()["genre"] as? String ?? "カフェ"
                            let color = document.data()["color"] as? String ?? "pink"
                            let comment = document.data()["comment"] as? String ?? ""
                            let URL = document.data()["URL"] as? String ?? ""
                            self.selectedChoices.append(genre)
                            self.colorArray.append(color)
                            
                            self.documentid.append(document.documentID)
                            
                            self.commentArray.append(comment)
                            
                            self.URLArray.append(URL)
                            
                            
                            
                        }
                        self.choicecount  = []
                        for choice in self.selectedChoices {
                            self.choicecount.append(self.zyanru.firstIndex(of: choice) ?? 2)
                            
                        }
                        
                        
                        
                        
                        self.collectionView.delegate = self
                        self.collectionView.dataSource  = self
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
    func deletekyouyu(){
        publicmisetitle = []
        publicmisesubtitle = []
        publicdocumentid = []
        publiccolorArray = []
        publicchoicecount = []
        publicselectedChoices = []
        db.collection("users").document(uid ?? "").collection("public").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.delete()
                    }
                }
            }
    
        db.collection("users").document(uid ?? "").collection("shop").whereField("kyouyu", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
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
                      let kyouyu = data["kyouyu"] as? Bool ?? false
                        let timestamp = data["timestamp"]
                        
                        var ref: DocumentReference? = nil
                    
                        
                        ref = self.db.collection("users").document(self.uid ?? "").collection("public").addDocument(data: [
                            
                            "idokeido": idokeido ?? "",
                            "title":   title,
                            "subtitle":subtitle,
                            "timestamp": timestamp ?? "",
                            "genre":genre,
                            "kyouyu": kyouyu,
                            "color": color
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                
                                self.publicmisetitle.append(title)
                                self.publicmisesubtitle.append(subtitle)
                                self.publicdocumentid.append(ref!.documentID)
                                self.publiccolorArray.append(color)
                                self.publicselectedChoices.append(genre)
                                print(self.selectedChoices)
                                for choice in self.publicselectedChoices {
                                     self.publicchoicecount.append(self.zyanru.firstIndex(of: choice) ?? 0)
                                 
                                 
                                 }
                                print("Document added with ID2: \(ref!.documentID)")
                            }
                        }
                    }
                }
             
              
        }
    
    }
}




