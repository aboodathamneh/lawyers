//
//  ViewController.swift
//  lawyers
//
//  Created by Abood_ath on 10/21/18.
//  Copyright © 2018 Abood_ath. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AuthenticationServices
import GoogleSignIn
import Firebase

class signup: UIViewController, FBSDKLoginButtonDelegate,GIDSignInUIDelegate {
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    let db = Firestore.firestore()
    var flag = 0
    @IBAction func btnSignUp(_ sender: Any) {
        self.loading.isHidden = false
        self.loading.startAnimating()
        
        SignUp()
        let infoViewController = storyboard?.instantiateViewController(withIdentifier: "sign in") as! ViewController
        self.present(infoViewController, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.isHidden = true
      let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        // Do any additional setup after loading the view, typically from a nib.
        // facebook auth
        func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        // facebook
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
        }
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        //auth facebook done
        // Add custom Facebook Button
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = .white
        customFBButton.frame = CGRect(x: 263, y: 483, width: 70, height: 30)
        customFBButton.setTitle("Facebook", for: .normal)
        //  customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.tintColor = UIColor.blue
        view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        // google custom button
        let customGSIButton = UIButton(type: .system)
        customGSIButton.backgroundColor = .white
        customGSIButton.frame = CGRect(x: 263, y: 521, width: 46, height: 30)
        customGSIButton.setTitle("Gmail", for: .normal)
       // customGSIButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customGSIButton.tintColor = UIColor.blue
        view.addSubview(customGSIButton)
        customGSIButton.addTarget(self, action:#selector(handleCustomGooglesignin), for: .touchUpInside)
        //end
          //sign up
            func SaveDoc(Email:String, Username:String)  {
                let email = Email
                
                let username = Username
                db.collection("Users").document(Email).setData([
                    "Username": username,
                    "Email": email ,
                  //  "fromDevice" :AppDelegate.DEVICEID
                ]) { err  in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        self.ActionSheet(Msg:"Register Successfully , Login now !!")
                        
                    }
                }
                Clear()
                
            }
            //sign up end
            //google sign in
        GIDSignIn.sharedInstance()?.uiDelegate = self
        //add google sign in button
        //let googlebutton = GIDSignInButton()
        //   googlebutton.frame = CGRect(x: 247, y: 456 , width: 90, height: 31)
        //  view.addSubview(googlebutton)
    }
    //google
      @objc  func handleCustomGooglesignin (){
        GIDSignIn.sharedInstance()?.signIn()
    }
    //facebook
        @objc func handleCustomFBLogin(){
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err as Any)
                return
            }
            print(result?.token.tokenString as Any)
        }
    }
    // tha log in button facebook
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id,name,email"]).start{
            (connection, result, err) in
            if err != nil {
                print("Faild to Start Graph Request:", err as Any )
                return
            }
            print(result as Any)
        }
    }
    // log out button facebook
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("you loged out facebook ")
        return
    }
        func Clear() {
            txtConfirmPassword.text=""
            txtEmail.text=""
            txtPassword.text=""
            txtUsername.text=""
            
        }
        func ActionSheet(Msg:String) {
            let alertController = UIAlertController(title: nil, message: Msg, preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Done", style: .default) { action in
                // perhaps use action.title here
            })
            self.present(alertController, animated: true, completion: {() -> Void in
                
                
                alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
            })
        }

 //sign up validation for password confirmation
func Validation() -> Bool {
    
    let email = txtEmail.text!
    let password = txtPassword.text!
    let Confierm = txtConfirmPassword.text!
    let username = txtUsername.text!
    var vaild :Bool = true
    
    if (email.isEmpty==true){
        vaild = false
    }
    if (password.isEmpty==true){
        vaild = false
    }
    if (Confierm.isEmpty==true){
        vaild = false
    }
    if (username.isEmpty==true){
        vaild = false
    }
    return vaild
    
}
// for signup using email and password
    func SignUp() {
    if (Validation()==false)
    {
        self.loading.stopAnimating()
        self.loading.isHidden = true
        ActionSheet(Msg:"password or email are invalid")
        Clear()
        return
    }
    else if ((txtPassword.text==txtConfirmPassword.text)==false){
        self.loading.stopAnimating()
        self.loading.isHidden = true
         ActionSheet(Msg:"Password And Confirm Password must be equale")
        Clear()
        
    } else {
        
        
        db.collection("Users").document(txtEmail.text!)
            .addSnapshotListener { documentSnapshot, error in
                guard documentSnapshot == nil else {
                    self.flag = 1
                    self.loading.stopAnimating()
                    self.loading.isHidden = true
                    return
                }
                
        }
        if (flag == 1) {
            self.loading.stopAnimating()
            self.loading.isHidden = true
            ActionSheet(Msg:"This User is alerdy registerd ")
            Clear()
            
        } else {
            Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { (authResult, error) in
                
                guard (authResult?.user) != nil else {
                    print(error.debugDescription)
                    self.loading.stopAnimating()
                    self.loading.isHidden = true
                    return
                }
                
                self.SaveDoc(Email: self.txtEmail.text!, Username: self.txtUsername.text!)
                // prepare(for: "", sender: nil)
                
            }
        }
    }
  
    //
    let LogInButton = FBSDKLoginButton()
    LogInButton.delegate = self
    LogInButton.readPermissions=["email","public_profile"]

}
    func SaveDoc(Email:String, Username:String)  {
        let email = Email
        
        let username = Username
        db.collection("Users").document(Email).setData([
            "Username": username,
            "Email": email ,
         //   "fromDevice" :AppDelegate.DEVICEID
        ]) { err  in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.ActionSheet(Msg:"Register Successfully , Login now !!")
                
            }
        }
        Clear()
        
    }

}
