//
//  friendViewController.swift
//  misedoko
//
//  Created by saki on 2023/06/13.
//

import UIKit
import FirebaseFirestore

class friendViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate,UICollectionViewDataSource {
   
    
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet var collectiionview: UICollectionView!
    
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
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.delegate = self
        collectiionview.delegate = self
        collectiionview.dataSource = self
     
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        // 入力された値がnilでなければif文のブロック内の処理を実行
        if let word = searchBar.text {
            print(word,"a")
            
            db.collection("users").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    print("e")
                    for document in querySnapshot!.documents {
                        self.documentNames.append(document.documentID)
                        print(document.documentID)
                    }
                    print(self.documentNames,"w")
                    
                }
            }
            if (documentNames.first(where: {$0 == word}) != nil){
                let collectionRef = db.collection("users").document(word).collection("public")
                
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
                                }
                                self.choicecount  = []
                                for choice in self.selectedChoices {
                                    self.choicecount.append(self.zyanru.firstIndex(of: choice) ?? 2)
                                    
                                }
                            }
                        }
                    }else {
                        // コレクションが存在しないかドキュメントが存在しない場合の処理
                        print("コレクションがないよ")
                        
                        
                    }
                }
                
                
                
                
                
            }
            
           
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        misetitle.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.commentButton.isHidden = true
        cell.commentlabel.isHidden = true
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
    
    
    
    
}
