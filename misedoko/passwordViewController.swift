//
//  passwordViewController.swift
//  misedoko
//
//  Created by saki on 2023/06/21.
//

import UIKit
import FirebaseAuth

class passwordViewController: UIViewController {
    @IBOutlet var mailtextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        // 送信先のメールアドレスを取得
        let email = mailtextfield.text!
        // 取得したメールアドレスを引数に渡す
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                // エラーが無ければ、パスワード再設定用のメールが指定したメールアドレスまで送信されます。
                // 届いたメールからパスワード再設定後、新しいパスワードでログインする事が出来る様になっています。
                self.performSegue(withIdentifier: "tologin", sender: nil)
            }else{
                print("エラー：\(String(describing: error?.localizedDescription))")
            }
        }
    }
}
