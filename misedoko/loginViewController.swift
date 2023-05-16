//
//  loginViewController.swift
//  misedoko
//
//  Created by saki on 2023/05/12.
//

import UIKit
import FirebaseAuth

class loginViewController: UIViewController {
    
    // ログイン用のUITextFieldです
    @IBOutlet var loginMailTextField: UITextField!
    @IBOutlet var loginPasswordTextField: UITextField!
    // 新規登録用のUITextFieldです
    @IBOutlet var signUpMailTextField: UITextField!
    @IBOutlet var signUpPassowordTextField: UITextField!
    @IBOutlet var signUpPasswordConfirmationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        loginMailTextField.text = ""
        loginPasswordTextField.text = ""
        signUpMailTextField.text = ""
        signUpPassowordTextField.text = ""
        signUpPasswordConfirmationTextField.text = ""
    }
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            // ログイン状態の確認
            if Auth.auth().currentUser != nil {
                // ログイン済みの場合、メインページに遷移
                navigateToMainPage()
            } else {
                // ログインされていない場合、ログインページを表示
                showLoginPage()
            }
        }
        
        func navigateToMainPage() {
            // メインページに遷移する処理を実装する
            // 例えば、Storyboardを使用してSegueを実行する場合は次のように書きます：
            performSegue(withIdentifier: "tomain", sender: self)
        }
        
        func showLoginPage() {
            // ログインページを表示する処理を実装する
            // 例えば、Storyboardを使用してSegueを実行する場合は次のように書きます：
         
        }
    
    @IBAction func registerButton() {
        let email = signUpMailTextField.text ?? ""
        let password = signUpPassowordTextField.text ?? ""
        let passwordConfirmation = signUpPasswordConfirmationTextField.text ?? ""
        
        if (password == passwordConfirmation) {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if (result?.user) != nil {
                    print("新規登録成功！")
                } else {
                    print(error!)
                }
            }
        }
    }
    @IBAction func loginButton() {
        let email = loginMailTextField.text ?? ""
        let password = loginPasswordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if (result?.user) != nil {
                self.performSegue(withIdentifier: "tomain", sender: nil)
            } else {
                print(error!)
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
