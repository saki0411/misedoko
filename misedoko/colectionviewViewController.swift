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
                                   UICollectionViewDelegateFlowLayout {
    
    
    
    var hozonArray = [MKAnnotation]()
    var routes: [MKRoute] = []
    
    var misetitle = [String]()
    var misesubtitle = [String]()
   
    
    var colorArray = [String]()
    
    
    var zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
    var savedata: UserDefaults = UserDefaults.standard
    
    var genres: [(genre: String, documentID: String)] = []
    var selectedChoices = [String]()
    var selectedChoice: String = ""
    var choicecount = [Int]()
  
    var selectedCell: Int  = -1
    
    //firestoreのやつ
    let db = Firestore.firestore()
    
    let uid = Auth.auth().currentUser?.uid
    var documentid = [String]()
    
    @IBOutlet  weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
      
     
        
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
        selectedChoices = []
        
        
        let collectionRef = db.collection(uid ?? "hozoncollection")
        
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
                            let genre = document.data()["genre"] as? String ?? "カフェ"
                            let color = document.data()["color"] as? String ?? "pink"
                            
                            self.selectedChoices.append(genre)
                           self.colorArray.append(color)
                            print(self.selectedChoices,"choicesだよ！")
                            self.documentid.append(document.documentID)
                            
                            
                            
                            
                            
                            
                        }
                        self.choicecount  = []
                        for choice in self.selectedChoices {
                            self.choicecount.append(self.zyanru.firstIndex(of: choice) ?? 2)
                            
                        }
                     
                            print(self.choicecount,"c")
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
        print(colorArray)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hozonArray.count
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }else{
            zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
            
        }
        
        cell.documentid = documentid
        
        cell.genres = genres
        
        cell.commentButton.tag = indexPath.row
        
        cell.commentlabel.isHidden = true
      
        
        let initialRow = choicecount[indexPath.row]
        cell.pickerView.selectRow(initialRow, inComponent: 0, animated: false)
        cell.zyanruTextField.text = zyanru[initialRow] 
        
        
        
        cell.indexPath = indexPath
        print(colorArray)
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

        let cellSizeWidth:CGFloat = 350
        var cellSizeHeight:CGFloat = 300
        // タップされたセルのインデックスと一致する場合は高さを変更する
        if indexPath.row == selectedCell {
            print("できた")
            cellSizeHeight = 600
            cell.commentlabel.isHidden = false
        }

        print("cell",cellSizeHeight)
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
            let delete = UIAction(title: "DELETE", image: UIImage(systemName: "trash.fill")) { action in
                
                guard let itemToDelete = self.hozonArray[indexPath.item] as? MKAnnotation else {
                    return
                }
                if let indexToDelete = self.hozonArray.firstIndex(where: { $0 === itemToDelete }) {
                    self.db.collection(self.uid ?? "hozoncollection").document(self.documentid[indexPath.row]).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                            
                        }
                    }
                    self.documentid.remove(at: indexPath.row)
                    
                    self.hozonArray.remove(at: indexToDelete)
                    self.misetitle.remove(at: indexPath.row)
                    self.misesubtitle.remove(at: indexPath.row)
                    
                    self.selectedChoices.remove(at: indexPath.row)
                    self.choicecount.remove(at: indexPath.row)
                   
                    self.colorArray.remove(at: indexPath.row)
                    
                    collectionView.reloadData()
                    
                }
            }
            
            return UIMenu(title: "Menu", children: [delete])
            
            
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
            db.collection(self.uid ?? "hozoncollection").document(documentid[indexPath.row ]).updateData(["color": "blue" ]) { error in
                
                if let error = error {
                    
                    print("エラーが発生しました: \(error)")
                    
                } else {
                    
                    print("ジャンルを更新しました")
                    print("dekita",[indexPath])
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
            db.collection(self.uid ?? "hozoncollection").document(documentid[indexPath.row ]).updateData(["color": "pink" ]) { error in
                
                if let error = error {
                    
                    print("エラーが発生しました: \(error)")
                    
                } else {
                    
                    print("ジャンルを更新しました")
                    self.collectionView.reloadData()
                    
                    
                }
                
            }
          
                    
                 
        }
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
    }
    
    
    func selectedd(gotselectedcell: Int){
        selectedCell = gotselectedcell
      
        collectionView.reloadData()
    }
    
  
    
}




