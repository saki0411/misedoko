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
    var cellColors = [IndexPath: UIColor]()
    
    
    var zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
    
    
    //firestoreのやつ
    let db = Firestore.firestore()
    
    let uid = Auth.auth().currentUser?.uid
    var documentid = [String]()
    var savedata: UserDefaults = UserDefaults.standard
    @IBOutlet  weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource  = self
        
        //collectionview長押しのやつ
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.size.width / 4, height: view.bounds.size.width / 4)
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.headerReferenceSize = CGSize(width:0,height:0)
        
        
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        
        
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hozonArray.count
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        
        
        
        cell.indexPath = indexPath
        
        cell.backgroundColor = cellColors[indexPath] ?? UIColor {_ in return #colorLiteral(red: 0.9568627451, green: 0.7019607843, blue: 0.7607843137, alpha: 1)}
        
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
     //   cell.timelabel.text = "\(round(route.expectedTravelTime / 60)) 分"
        
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSizeWidth:CGFloat = 350
        let cellSizeHeight:CGFloat = 300
        
        
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
                            collectionView.reloadData()
                        }
                    }
                    self.documentid.remove(at: indexPath.row)
                    
                    self.hozonArray.remove(at: indexToDelete)
                    self.misetitle.remove(at: indexPath.row)
                    self.misesubtitle.remove(at: indexPath.row)
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
            cellColors[indexPath] = UIColor {_ in return #colorLiteral(red: 0.6784313725, green: 0.7568627451, blue: 0.9176470588, alpha: 1)}
            collectionView.reloadItems(at: [indexPath])
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
            cellColors[indexPath] = UIColor {_ in return #colorLiteral(red: 0.9176470588, green: 0.7803921569, blue: 0.6784313725, alpha: 1)} 
            collectionView.reloadItems(at: [indexPath])
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
    
    
}



