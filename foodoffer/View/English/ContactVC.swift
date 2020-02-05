//
//  ContactVC.swift
//  foodoffer
//
//  Created by Admin on 7/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import JTMaterialSpinner
import Alamofire
class ContactVC: UIViewController {
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var sidebarBtn: UIButton!    
    @IBOutlet weak var contactEmail: UILabel!
    @IBOutlet weak var contactMobile: UILabel!
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtContent: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetsetting.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let mobile = value["cmobile"] as! String
                let email = value["cemail"] as! String
                self.contactEmail.text = email
                self.contactMobile.text = mobile
            }
        }
        toastenvironment()
        initNotificationCenter()
        // Do any additional setup after loading the view.
    }
    
    func toastenvironment(){
        let appearance = ToastView.appearance()
        appearance.backgroundColor = .black
        appearance.textColor = .white
        appearance.font = .boldSystemFont(ofSize: 16)
        appearance.textInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        appearance.bottomOffsetPortrait = 100
        appearance.cornerRadius = 20
    }
    func initNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(showMenuButton(notification:)), name: .showMenuButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMenuButton(notification:)), name: .hideMenuButton, object: nil)
    }
    
    @objc func showMenuButton(notification: NSNotification) {
        sidebarBtn.isHidden = false
    }
    
    @objc func hideMenuButton(notification: NSNotification) {
        sidebarBtn.isHidden = true
    }
    
    @IBAction func menubtnClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }
    
    @IBAction func sendBtn(_ sender: Any) {
        let title = txtTitle.text!
        let content = txtContent.text!
        if title != ""{
            if content != ""{
                let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY), "useremail" : Defaults.getNameAndValue(Defaults.EMAIL_KEY), "title": title, "content" : content, "toemail" : contactEmail.text!]
                Alamofire.request(Global.baseUrl + "icontactus.php", method: .post, parameters: parameters).responseJSON{ returnValue in
                    print(returnValue)
                    if let value = returnValue.value as? [String: AnyObject] {
                        let status = value["status"] as! String
                        if status == "ok"{
                            Toast(text: "Send message to administarator.").show()
                        }
                        else{
                            Toast(text: "Send message Fail").show()
                        }
                    }
                    else{
                        Toast(text: "Send message Fail").show()
                    }
                }
            }else{
                Toast(text: "Empty content field.").show()
            }
        }else{
            Toast(text: "Empty title field.").show()
        }
        
    }
}
