//
//  CollectionViewCell.swift
//  misedoko
//
//  Created by saki on 2023/05/07.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CollectionViewCell: UICollectionViewCell,UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet var shopnamelabel: UILabel!
    @IBOutlet var adresslabel: UILabel!
    @IBOutlet var timelabel: UILabel!
    @IBOutlet  var zyanruTextField: UITextField!
    @IBOutlet var commentlabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    
    
    var zyanru = [String]()
    var pickerView: UIPickerView = UIPickerView()
    let userDefaults = UserDefaults.standard
    var indexPath: IndexPath?
    var selectedChoice: String = ""
    var savedata: UserDefaults = UserDefaults.standard
    var hozondic = [[String]]()
    var documentid = [String]()
    var genres: [(genre: String, documentID: String)] = []
    var selectedChoices = [String]()
    var choicecount = [Int]()
    
    var cellSizeWidth:CGFloat = 350
    var cellSizeHeight:CGFloat = 300
    
    
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
  
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }else{
            zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
            
        }
        
        
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
       
        
        
        createPickerView()
        for string in zyanru {
            var index = 0
            index =  zyanru.firstIndex(of: string) ?? 0
            pickerView.reloadComponent(index)
        }
        
        
        
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return zyanru.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        return zyanru[row]
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedChoice = zyanru[row]
        
        zyanruTextField.text = selectedChoice
        print(self.choicecount,"b")
        
        print("あああ",documentid)
        
        db.collection(self.uid ?? "hozoncollection").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.selectedChoices = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let genre = document.data()["genre"] as? String ?? "カフェ"
                    
                    self.selectedChoices.append(genre)
                    print(self.selectedChoices,"choicesだよ！")
                    
                    self.documentid.append(document.documentID)
                    
                }
            }
        }
        choicecount = []
        for choice in selectedChoices {
            choicecount.append(zyanru.firstIndex(of: choice) ?? 0)
            print(zyanru.firstIndex(of: choice) ?? 0)
            
            
        }
        
        db.collection(self.uid ?? "hozoncollection").document(documentid[indexPath?.row ?? 0]).updateData(["genre": selectedChoice ]) { error in
            
            if let error = error {
                
                print("エラーが発生しました: \(error)")
                
            } else {
                
                print("ジャンルを更新しました")
                
                
            }
            
        }
    }
    
    func createPickerView() {
        pickerView.delegate = self
        zyanruTextField.inputView = pickerView
        // toolbar
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.pickerView.frame.width, height: 44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CollectionViewCell.donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        zyanruTextField.inputAccessoryView = toolbar
    }
    
    @objc func donePicker() {
        zyanruTextField.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        zyanruTextField.endEditing(true)
    }
      
      // MARK: - Action
      @objc    func testAction(){
          print(commentButton.tag)
      }
    
    @IBAction func comment(){
        let num: Int = Int("\(commentButton.tag)")!
        if let topViewController: colectionviewViewController = getTopViewController() as? colectionviewViewController {
            topViewController.selectedd(gotselectedcell: num)
        }
    }
    func getTopViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            var topViewController: UIViewController = rootViewController

            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }

            return topViewController
        } else {
            return nil
        }
    }
    
    
    
}
