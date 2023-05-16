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
    
    //firestoreのやつ
    let db = Firestore.firestore()
    
    let uid = Auth.auth().currentUser?.uid
    var documentid = [String]()
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("もらう方",hozonArray)
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
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    // 2-2. セル数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(hozonArray.count)
        return hozonArray.count
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let route = routes[indexPath.row]
        cell.shopnamelabel?.text = misetitle[indexPath.row]
        cell.adresslabel?.text = misesubtitle[indexPath.row]
        cell.timelabel.text = "\(round(route.expectedTravelTime / 60)) 分"
        
        
        
        
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
}




