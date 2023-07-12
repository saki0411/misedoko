//
//  SettingViewController.swift
//  misedoko
//
//  Created by saki on 2023/07/12.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class SettingViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var nameTectField: UITextField!
    @IBOutlet weak var IconImageView: UIImageView!
    
    var imageData: Data! = nil
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        getDataButtonAction()
    }
    

    @IBAction func Iconedit(_ sender: Any) {
        let picker = UIImagePickerController()
              picker.sourceType = .photoLibrary
              picker.delegate = self
              present(picker, animated: true)
              self.present(picker, animated: true)
    }
   
    @IBAction func nameedit(_ sender: Any) {
        
        // ストレージサービスへの参照を取得
              let storage = Storage.storage()

              // ストレージへの参照を取得
              let storageRef = storage.reference()

              // データをアップロードしたい参照を作成
        let imageRef = storageRef.child("images/\(String(describing: uid)).jpg")

              //アップロードを実行
              let uploadTask = imageRef.putData(imageData!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                  // Uh-oh, an error occurred!
                    print("Error occurred! : \(error)")
                  return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                imageRef.downloadURL { (url, error) in
                  guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                      print("Error occurred! : \(error)")
                    return
                  }
                    // アップロードが成功したらここが実行される
                    print("Upload success! URL: \(downloadURL)")
                }
              }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let selectedImage = info[.originalImage] as? UIImage {
               // ライブラリから選択された画像をレイアウト上のimageViewに表示
               IconImageView.image = selectedImage
               // 画像をData型に変換してimageDataに代入
               imageData = selectedImage.jpegData(compressionQuality: 1)
           }
           self.dismiss(animated: true)
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           self.dismiss(animated: true)
       }
    
    // データをFirebase Storageから受信するコード
   func getDataButtonAction(){
        // ストレージサービスへの参照を取得
        let storage = Storage.storage()

        // ストレージへの参照を取得
        let storageRef = storage.reference()

        // ダウンロードしたいデータの参照を作成
        let imageRef = storageRef.child("images/\(String(describing: uid)).jpg")

        // 100MB (100 * 1024 * 1024 bytes)以下のデータをダウンロードする
        imageRef.getData(maxSize: 100 * 1024 * 1024) { data, error in
          if let error = error {
              // Uh-oh, an error occurred!
              print("Error occurred! : \(error)")
          } else {
              // ダウンロードが成功したらここが実行される
              // Data型をUIImage型に変換する
              let image = UIImage(data: data!)
              // 変換された画像をレイアウト上のimageViewに表示
              self.IconImageView.image = image
          }
        }
    }
    @IBAction func back(){
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "tabbar") as! UITabBarController
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
}
