//
//  SignUpVC.swift
//  foodoffer
//
//  Created by Admin on 7/22/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import Toaster
import Alamofire
import JTMaterialSpinner
import Firebase
class SignUpVC: UIViewController {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtMobile: FPNTextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtpromocode: UITextField!
    var verifyVC : VerifyVC!
    var loginVC : LoginVC!
    var check_Mobile = 0
    var spinnerView = JTMaterialSpinner()
    var verifycode = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        txtMobile.delegate = self
        txtMobile.setFlag(for: FPNCountryCode.EG)
        let random_verify = Int.random(in: 123456...999999)
        verifycode = "\(random_verify)"
        toastenvironment()
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
    
    @IBAction func goLoginBtn(_ sender: Any) {
        loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
        self.present(loginVC, animated: true, completion: nil)
    }
    @IBAction func btnSignUp(_ sender: UIButton) {
        if(check_Mobile == 1)
        {
            let name: String = txtName.text!
            let email: String = txtEmail.text!
            let mobile: String = txtMobile.getFormattedPhoneNumber(format: .E164)!
            let password: String = txtPassword.text!
            let confirmpassword : String = txtConfirmPassword.text!
            let promocode : String =  txtpromocode.text!
            if name != "" && email != "" && mobile != "" && password != "" && confirmpassword != ""{
                if password == confirmpassword {
                    
                    Defaults.save(name, with: Defaults.SIGNNAME_KEY)
                    Defaults.save(email, with: Defaults.SIGNEMAIL_KEY)
                    Defaults.save(mobile, with: Defaults.SIGNMOBILE_KEY)
                    Defaults.save(password, with: Defaults.SIGNPASSWORD_KEY)
                    Defaults.save(promocode, with: Defaults.SIGNPROMOCODE_KEY)
                    Defaults.save(verifycode, with: Defaults.SIGNVCODE_KEY)
                    
                    self.view.addSubview(spinnerView)
                    spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                    spinnerView.circleLayer.lineWidth = 2.0
                    spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                    spinnerView.beginRefreshing()
                    let parameters: Parameters = ["verifycode": verifycode, "mobile": mobile ]
                    print(parameters)
                    print(Global.baseUrl + "iverifycode.php")
                    Alamofire.request(Global.baseUrl + "iverifycode.php", method: .post, parameters: parameters).responseJSON{ response in
                        print(response)
                        if let value = response.value as? [String: AnyObject] {
                            print(value)
                            let status = value["status"] as! String
                            if status == "ok" {
                                self.spinnerView.endRefreshing()
                                
//                                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                                Auth.auth().languageCode = "ar";                                
                                PhoneAuthProvider.provider().verifyPhoneNumber(mobile, uiDelegate: nil) { (verificationID, error) in
                                    if let error = error {
                                        print("adadfaf")
                                        return
                                    }
                                    Toast(text: "SMS of verify code was sent.").show()
                                    self.verifyVC = self.storyboard?.instantiateViewController(withIdentifier: "verifyVC") as! VerifyVC
                                    self.verifyVC.verificationID = verificationID
                                    self.present(self.verifyVC, animated: true, completion: nil)
                                }                             
                                
                            } else if status == "existuser" {
                                 self.spinnerView.endRefreshing()
                                Toast(text: "This user already registered").show()
                            }else{
                                 self.spinnerView.endRefreshing()
                                Toast(text: "Unexpected error").show()
                            }
                        }
                        else{
                            print("aa")
                        }
                    }
                } else{
                    Toast(text: "Passwords not equal!").show()
                }
//
            } else{
                Toast(text: "Fields can not be empty").show()
            }
        }
        else{
            Toast(text: "Check Phone Number").show()
        }        
    }
}

extension SignUpVC: FPNTextFieldDelegate {
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid {
            check_Mobile = 1
        } else {
            check_Mobile = 0
        }
    }
    
}


