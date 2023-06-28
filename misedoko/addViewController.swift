//
//  addViewController.swift
//  misedoko
//
//  Created by saki on 2023/05/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class addViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var zyanru = [String]()
    var selectedChoice: String?
    var commentArray = [String]()
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
    
    var savedata: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
       
        DispatchQueue.main.async {
            self.zyanrukakuninn()
         
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
            print(self.zyanru)
          
        }
       
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zyanru.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        print(zyanru)
        cell.textLabel!.text = zyanru[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            zyanru.remove(at: indexPath.row)
            savedata.set(zyanru, forKey: "zyanru")
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @IBAction func hozon(){
        zyanru.append(textField.text ?? "")
        textField.text = ""
        addzyanru()
        tableView.reloadData()
    }
    
    
    
    
    func zyanrukakuninn(){
        zyanru = []
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
    
    
    
    func addzyanru(){
        // ドキュメントを消去する
        self.db.collection("users").document(self.uid ?? "").collection("zyanru").document("list").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        self.db.collection("users").document(self.uid ?? "").collection("zyanru").document("list").setData([
            "zyanrulist": self.zyanru
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                
            }
        }
      
      
      
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
