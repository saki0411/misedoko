//
//  friendViewController.swift
//  misedoko
//
//  Created by saki on 2023/06/13.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class friendViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet var collectionview: UICollectionView!
    @IBOutlet var friendbutton: UIButton!
    @IBOutlet var kensakulabel: UILabel!
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.delegate = self
        collectionview.delegate = self
        collectionview.dataSource = self
        friendbutton.isEnabled = false
        
        //collectionview長押しのやつ
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.size.width / 4, height: view.bounds.size.width / 4)
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.headerReferenceSize = CGSize(width:0,height:0)
        
        
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // キーボードを閉じる
        view.endEditing(true)
        word = ""
        kensakulabel.text = ""
        // 入力された値がnilでなければif文のブロック内の処理を実行
        word = searchBar.text ?? ""
        if let word = searchBar.text {
            print(word,"a")
            DispatchQueue.global().async {
                
                self.misetitle = []
                self.misesubtitle = []
                
                let collectionRef = self.db.collection("users").document(word).collection("public")
                
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
                        collectionRef.getDocuments() { (querySnapshot, err) in
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
                                    
                                    
                                    
                                    self.commentArray.append(comment)
                                    
                                    
                                    self.selectedChoices.append(genre)
                                    self.documentid.append(document.documentID)
                                    
                                    
                                    self.colorArray.append(color)
                                    
                                    self.misetitle.append(title)
                                    self.misesubtitle.append(subtitle)
                                    
                                    print(self.misetitle)
                                }
                                self.choicecount  = []
                                for choice in self.selectedChoices {
                                    self.choicecount.append(self.zyanru.firstIndex(of: choice) ?? 2)
                                    
                                }
                                
                                print(self.misetitle,"e")
                                self.collectionview.register(self.nib, forCellWithReuseIdentifier: "cell")
                                self.collectionview.reloadData()
                                
                            }
                        }
                        
                    }else {
                        // コレクションが存在しないかドキュメントが存在しない場合の処理
                        print("コレクションがないよ")
                        self.kensakulabel.text = "検索結果がありません"
                        
                        
                    }
                    
                    
                    
                    
                    
                }
                
            }
            
        }
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        misetitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.commentButton.isHidden = true
        
        cell.pickerView.isHidden = true
        
        cell.URLtextfield.isHidden = true
        cell.URLbutton.isHidden = true
        
        
        
        
        cell.zyanruTextField.isUserInteractionEnabled = false
        
        
        let initialRow = choicecount[indexPath.row]
        cell.pickerView.selectRow(initialRow, inComponent: 0, animated: false)
        cell.zyanruTextField.text = zyanru[initialRow]
        
        cell.shopnamelabel?.text = misetitle[indexPath.row]
        cell.adresslabel?.text = misesubtitle[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSizeWidth:CGFloat = 350
        let cellSizeHeight:CGFloat = 280
        
        
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
            
            let addlist = UIAction(title: "マイリストに追加", image: UIImage(systemName: "rectangle.stack.fill.badge.plus")) { action in
                let collectionRef = self.db.collection("users").document(self.word).collection("public")
                
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
                        collectionRef.getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    
                                    if document.documentID == self.documentid[indexPath.row]{
                                        // 取得したドキュメントごとに実行する
                                        let data = document.data()
                                        let idokeido = data["idokeido"] as? GeoPoint
                                        let title = data["title"] as? String ?? "title:Error"
                                        let subtitle = data["subtitle"] as? String ?? "subtitle:Error"
                                        
                                        let genre = data["genre"] as? String ?? "カフェ"
                                        let color = data["color"] as? String ?? "pink"
                                        
                                        self.db.collection("users").document(self.uid ?? "").collection("shop").whereField("title", isEqualTo: title).getDocuments { (querySnapshot, error) in
                                            if let error = error {
                                                print(error.localizedDescription)
                                            } else {
                                                if querySnapshot!.isEmpty {
                                                    print("No matching documents")
                                                    var ref: DocumentReference? = nil
                                                    ref = self.db.collection("users").document(self.uid ?? "").collection("shop").addDocument(data: [
                                                        
                                                        "idokeido": idokeido!,
                                                        "title":   title,
                                                        "subtitle":subtitle,
                                                        "timestamp": FieldValue.serverTimestamp(),
                                                        "genre": genre,
                                                        "kyouyu": false,
                                                        "color": "pink"
                                                    ]) { err in
                                                        if let err = err {
                                                            print("Error writing document: \(err)")
                                                        } else {
                                                            self.documentid.append(ref!.documentID)
                                                            print("Document added with ID: \(ref!.documentID)")
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    } else {
                                        // コードを実行する
                                    }
                                }
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                
            }
            
            return UIMenu(title: "Menu", children: [addlist])
            
            
        }
        )
        
    }
    
    
    
}
