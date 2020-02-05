//
//  LoginVC.swift
//  foodoffer
//
//  Created by Admin on 7/19/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import FlagPhoneNumber
import Alamofire
import JTMaterialSpinner
class LoginVC: UIViewController {
    
    @IBOutlet weak var txtMobile:FPNTextField!
    @IBOutlet weak var txtPassword: UITextField!
    var str = ""
    var spinnerView = JTMaterialSpinner()
    var check_mobile = 0
    
    override func viewDidLoad() {
        txtMobile.setFlag(for: FPNCountryCode.EG)
        toastenvironment()
        txtMobile.delegate = self
//        txtMobile.setFlag(for: .EG)
//        txtMobile.set(phoneNumber: "+201234567890")
        //txtMobile.setFlag(for: .EG)
        //txtMobile.set(phoneNumber: "+8615840528308")
//        txtMobile.setCountries(excluding: [.EG])
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        str = Defaults.getNameAndValue(Defaults.MOBILE_KEY)
        if(str != ""){
            let parameters: Parameters = ["mobile": str]
            
            Alamofire.request(Global.baseUrl + "icheckmobile.php", method: .post, parameters: parameters).responseJSON{ response in
                print(response)
                if let value = response.value as? [String: AnyObject] {
                    print(value)
                    let status = value["status"] as! String
                    if status == "ok" {
                        self.spinnerView.endRefreshing()
                        self.performSegue(withIdentifier: "login", sender: self)
                    }
                }
            }
        }
        
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
    
    @IBAction func btnLogin(_ sender: Any) {
        if (check_mobile == 1) {
            let strMobile = txtMobile.getFormattedPhoneNumber(format: .E164)!
            let password: String = txtPassword.text!
            
            if (password != ""){
                self.view.addSubview(spinnerView)
                spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                spinnerView.circleLayer.lineWidth = 2.0
                spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                spinnerView.beginRefreshing()
                let parameters: Parameters = ["mobile": strMobile ,"password": password]
                
                Alamofire.request(Global.baseUrl + "iverifyuser.php", method: .post, parameters: parameters).responseJSON{ response in
                    print(response)
                    if let value = response.value as? [String: AnyObject] {
                        print(value)
                        let status = value["status"] as! String
                        if status == "ok" {
                            let user_id = value["id"] as! String
                            let user_name = value["username"] as! String
                            let user_mobile = value["mobile"] as! String
                            let user_role = value["role"] as! String
                            let user_email = value["email"] as! String
                            let user_avator = value["avatar"] as! String
                            let user_expiredate = value["expiredate"] as! String
                            let user_language = value["language"] as! String
                            let user_wallet = value["wallet"] as! String
                            Defaults.save(user_id, with: Defaults.USERID_KEY)
                            Defaults.save(user_name, with: Defaults.USERNAME_KEY)
                            Defaults.save(user_mobile, with: Defaults.MOBILE_KEY)
                            Defaults.save(user_role, with: Defaults.ROLE_KEY)
                            Defaults.save(user_email, with: Defaults.EMAIL_KEY)
                            Defaults.save(user_avator, with: Defaults.AVATAR_KEY)
                            Defaults.save(user_expiredate, with: Defaults.EXPIREDATE_KEY)
                            Defaults.save(user_language, with: Defaults.LANGUAGE_KEY)
                            Defaults.save(password, with: Defaults.PASSWORD_KEY)
                            Defaults.save(user_wallet, with: Defaults.WALLET_KEY)
                            
                            self.spinnerView.endRefreshing()
                            self.performSegue(withIdentifier: "login", sender: self)
                        } else if status == "wrongpassword" {
                            self.spinnerView.endRefreshing()
                            Toast(text: "Password is Wrong").show()
                        }else if status == "nouser" {
                            self.spinnerView.endRefreshing()
                            Toast(text: "You are not registered. Please signup").show()
                        } else{
                            self.spinnerView.endRefreshing()
                            Toast(text: "Unexpected error").show()
                        }
                    }
                    else{
                        print("aa")
                    }
                }
            } else{
                Toast(text: "Enter the Password").show()
            }
            
        }else{
            Toast(text: "Check Phone Number").show()
        }
        
    }
    
}
extension LoginVC:FPNTextFieldDelegate{
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if(isValid){
            check_mobile = 1
        }
        else{
            check_mobile = 0
        }
    }
    
    
}
