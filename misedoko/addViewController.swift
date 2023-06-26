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
       zyanrusyutoku()
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zyanru.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
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
        savedata.set(zyanru, forKey: "zyanru")
        tableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tomain2" {
            let nextView = segue.destination as! mainViewController
            nextView.zyanru = zyanru
        }
    }
    func zyanrusyutoku(){
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
                self.db.collection("users").document(self.uid ?? "").collection("zyanru").order(by: "timestamp").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let zyanrulist = data["zyanrulist"]
                            self.zyanru.append(zyanrulist as! String)
                        }
                    }
                }
            }
        }
    
    }
    
}
