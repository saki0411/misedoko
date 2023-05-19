//
//  addViewController.swift
//  misedoko
//
//  Created by saki on 2023/05/17.
//

import UIKit

class addViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var zyanru = ["カフェ","レストラン","食べ放題","持ち帰り","チェーン店","スタバ"]
    
    var savedata: UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        if  savedata.object(forKey: "zyanru") as? [String] != nil{
            zyanru = savedata.object(forKey: "zyanru") as! [String]
        }
        
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
}
