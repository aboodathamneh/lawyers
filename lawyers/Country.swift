//
//  Country.swift
//  lawyers
//
//  Created by Abood_ath on 10/28/18.
//  Copyright © 2018 Abood_ath. All rights reserved.
//

import UIKit
import CoreData
import Firebase
class Country: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var listCountry = Array<String>()
    var Country:String?
    var db:Firestore?
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return listCountry.count
    }
    

    @IBOutlet weak var pickerview: UIPickerView!
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func loadData()  {
            
            loading.isHidden = false
            loading.startAnimating()
            listCountry.append("--- Select Country ---")
            let docRef = db!.collection("Country")
            docRef.getDocuments { (querySnapshot, error) in
                if (error != nil) {
                    self.loading.stopAnimating()
                    self.loading.isHidden = true
                    return
                }else {
                    for document in (querySnapshot?.documents)! {
                        let Country:String = document.data()["c-name"] as! String
                        self.listCountry.append(Country)
                        print(Country)
                    }
                    self.loading.isHidden = true
                    self.loading.stopAnimating()
                    self.pickerview.reloadAllComponents()
                    
                }
            }
        // Do any additional setup after loading the view.
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listCountry[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row==0) {
            ActionSheet(Msg: "Please Choose Country , then try again ")
        } else {
            Country = listCountry[row]
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
    
}
