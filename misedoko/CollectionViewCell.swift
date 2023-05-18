//
//  CollectionViewCell.swift
//  misedoko
//
//  Created by saki on 2023/05/07.
//

import UIKit

class CollectionViewCell: UICollectionViewCell,UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    @IBOutlet var shopnamelabel: UILabel!
    @IBOutlet var adresslabel: UILabel!
    @IBOutlet var timelabel: UILabel!
    @IBOutlet  var zyanruTextField: UITextField!
    
    
    var zyanru = [String]()
    var pickerView: UIPickerView = UIPickerView()
    let userDefaults = UserDefaults.standard
    var indexPath: IndexPath?
    var selectedChoice: String?
    var savedata: UserDefaults = UserDefaults.standard
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
      
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }else{
            zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店"]
            
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        
       
        
     //   zyanruTextField.inputView = pickerView
        createPickerView()
        for string in zyanru {
            var index = 0
            index =  zyanru.firstIndex(of: string) ?? 0
            pickerView.reloadComponent(index)
        }
       
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let indexPath = indexPath {
            let key = "pickerviewSelectRow\(indexPath.item)" // キーはインデックスパスの番号を含める
            let row = userDefaults.integer(forKey: key) // 保存された行番号を取得する
            pickerView.selectRow(row, inComponent: 0, animated: false) // pickerviewに反映する
            if zyanru.isEmpty { // zyanruが空の配列だったら
              print("zyanruに要素がありません")
                selectedChoice = ""
            } else if row < 0 || row >= zyanru.count { // rowがzyanruの範囲外だったら
              print("rowが不正な値です")
                selectedChoice = ""
            } else {
              // zyanru[row]が存在する場合の処理
                selectedChoice = zyanru[row] // 選択されたジャンルを更新する

            }
           
           
            zyanruTextField.text = selectedChoice // text fieldに反映する
            print("ジャンル表示できてるみたい")
        }else{
            print("ジャンル保存できてないみたい",selectedChoice as Any)
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return zyanru.count
    }
    
    //最初に表示される数字
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return zyanru[row]
    }
    
    //選択された時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedChoice = zyanru[row]
        self.zyanruTextField.text =  selectedChoice // text fieldに反映する
        if let indexPath = indexPath {
            let key = "pickerviewSelectRow\(indexPath.item)" // キーはインデックスパスの番号を含める
            userDefaults.set(row, forKey: key) // 行番号を保存する
            userDefaults.synchronize() // 同期する
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
    
    
}
