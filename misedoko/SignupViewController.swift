//
//  loginViewController.swift
//  misedoko
//
//  Created by saki on 2023/05/12.
//

import UIKit
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore



class SignupViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    
    
    
    // 新規登録用のUITextFieldです
    @IBOutlet var signUpMailTextField: UITextField!
    @IBOutlet var signUpPassowordTextField: UITextField!
    @IBOutlet var signUpnameTextField: UITextField!
    @IBOutlet var signUpPasswordConfirmationTextField: UITextField!
    @IBOutlet  private weak var buttonView: UIView!
    private var signInWithAppleObject = SignInWithAppleObject()
    
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    
    
    // SetUp
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(   authorizationButtonType: .default,
                                                                  authorizationButtonStyle: .whiteOutline)
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        authorizationButton.frame = CGRect(x: 0, y: 0, width: 230, height: 44)
        authorizationButton.cornerRadius = 0
        authorizationButton.center = CGPoint(x: buttonView.bounds.midX, y: buttonView.bounds.midY + 80)
        
        
        buttonView.addSubview(authorizationButton)
    }
    
    // Action
    @objc    func handleAuthorizationAppleIDButtonPress() {
        
        
        signInWithApple()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        signUpMailTextField.text = ""
        signUpPassowordTextField.text = ""
        signUpPasswordConfirmationTextField.text = ""
        signUpnameTextField.text = ""
        setupProviderLoginView()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // ログイン状態の確認
        if Auth.auth().currentUser != nil {
            // ログイン済みの場合、メインページに遷移
            navigateToMainPage()
        } else {
            
        }
    }
    
    func navigateToMainPage() {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "tabbar") as! UITabBarController
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func registerButton() {
        let email = signUpMailTextField.text ?? ""
        let password = signUpPassowordTextField.text ?? ""
        let passwordConfirmation = signUpPasswordConfirmationTextField.text ?? ""
        let name = signUpnameTextField.text ?? ""
        if (password == passwordConfirmation) {
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if (result?.user) != nil {
                    self.saveUserData(email: email, name: name)
                    print("新規登録成功！")
                    self.navigateToMainPage()
                    
                } else {
                    print(error!)
                }
            }
        }
    }
    
    
    func saveUserData(email: String?, name: String?) {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        db.collection("users").document(uid ?? "").collection("personal").document("info").setData([
            "uid": uid ?? "uid:Error",
            "email": email ?? "email:Error",
            "name": name ?? "name:Error",
        ])
    }
    
    //appleログイン
    func authorizationController(controller: ASAuthorizationController,didCompleteWithAuthorization authorization: ASAuthorization ) {
        // Sign in With Firebase app
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                self.navigateToMainPage()
                
            }
        }
    }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    private var currentNonce: String?
    
    public func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    //  https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    private func auth() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                // ...
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                
                // At this point, our user is signed in
                self.navigateToMainPage()
            }
            
        }
        
    }
    
    @IBAction func didTappSignInButton(_ sender: Any) {
        auth()
    }
}


