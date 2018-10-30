//
//  ViewController.swift
//  lawyers
//
//  Created by Abood_ath on 10/21/18.
//  Copyright © 2018 Abood_ath. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
class ViewController: UIViewController, FBSDKLoginButtonDelegate,GIDSignInUIDelegate {
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var user_name: UITextField!
    @IBOutlet weak var password: UITextField!
    var Email:String?
    var db:Firestore?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loading.isHidden = true
        db = Firestore.firestore()
        if let user = Auth.auth().currentUser{
    self.performSegue(withIdentifier: "Country1", sender: self)
        }
        //sign in buuton check password and email
        
        let infoViewController = storyboard?.instantiateViewController(withIdentifier: "country") as! Country
        self.present(infoViewController, animated: true)
        //end
        let LogInButton = FBSDKLoginButton()
    LogInButton.delegate = self
    LogInButton.readPermissions=["email","public_profile"]
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
        }
            // User is signed in
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
        customFBButton.frame = CGRect(x: 247, y: 436, width: 90, height: 31)
        customFBButton.setTitle("Facebook", for: .normal)
      //  customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBButton.tintColor = UIColor.blue
        view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
   // google custom button
        let customGSIButton = UIButton(type: .system)
        customGSIButton.backgroundColor = .white
        customGSIButton.frame = CGRect(x: 247, y: 476, width: 90, height: 31)
        customGSIButton.setTitle("Gmail", for: .normal)
     //   customGSIButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customGSIButton.tintColor = UIColor.blue
        view.addSubview(customGSIButton)
        customGSIButton.addTarget(self, action:#selector(handleCustomGooglesignin), for: .touchUpInside)
       
        //end
//google sign in
GIDSignIn.sharedInstance()?.uiDelegate = self
//add google sign in button
//let googlebutton = GIDSignInButton()
     //   googlebutton.frame = CGRect(x: 247, y: 456 , width: 90, height: 31)
      //  view.addSubview(googlebutton)
    }
  //google
    @objc func handleCustomGooglesignin (){
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
// sign in using user name and password
    @IBAction func signinbu(_ sender: Any) {
        if (user_name==nil || (user_name.text?.isEmpty)!){
         ActionSheet(Msg: "Email or Password are invalid")
        }else {
        
        db!.collection("Users").whereField("Username", isEqualTo: user_name.text)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.Email = (document.data()["Email"]) as! String
                    }
                    self.signIn()
                }
        }
        }
   
    }
    func signIn(){
        if (Email==nil || (Email?.isEmpty)!){
            
        }else {
        Auth.auth().signIn(withEmail: Email!, password: password.text!) { (user, error) in
            if (error != nil){
                print(error.debugDescription)
            }else {
                let infoViewController = self.storyboard?.instantiateViewController(withIdentifier: "country") as! Country
                self.present(infoViewController, animated: true)
                self.loading.stopAnimating()
                self.loading.isHidden = true
            }
        }
    }
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
}
