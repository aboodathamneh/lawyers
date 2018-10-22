//
//  ViewController.swift
//  lawyers
//
//  Created by Abood_ath on 10/21/18.
//  Copyright © 2018 Abood_ath. All rights reserved.
//

import UIKit
import FBSDKLoginKit
class ViewController: UIViewController, FBSDKLoginButtonDelegate {
   
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
let LogInButton = FBSDKLoginButton()
        view.addSubview(LogInButton)
        LogInButton.frame = CGRect(x: 250, y: 250, width: 250, height: 250)
    LogInButton.delegate = self
    }

func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    if error != nil{
        print(error)
        return
    }
    print("succesful")
}

func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    print("you loged out facebook ")
    FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id","name":"email"])?.start(completionHandler: { (connection, result, err) in
        print(123)
    })
}
}
