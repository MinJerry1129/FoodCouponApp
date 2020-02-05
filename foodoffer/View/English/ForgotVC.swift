//
//  ForgotVC.swift
//  foodoffer
//
//  Created by Admin on 7/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import FlagPhoneNumber
import JTMaterialSpinner
class ForgotVC: UIViewController {

    @IBOutlet weak var txtMobile: FPNTextField!
    @IBOutlet weak var txtEmail: UITextField!
    var spinnerView = JTMaterialSpinner()
    var check_mobile = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        txtMobile.delegate = self
        txtMobile.setFlag(for: FPNCountryCode.EG)
        toastenvironment()
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
    
    @IBAction func resetBtn(_ sender: Any) {
        if (check_mobile == 1) {
            let strMobile = txtMobile.getFormattedPhoneNumber(format: .E164)!
            let email: String = txtEmail.text!
            
            if (email != ""){
                self.view.addSubview(spinnerView)
                spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                spinnerView.circleLayer.lineWidth = 2.0
                spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                spinnerView.beginRefreshing()
                let parameters: Parameters = ["mobile": strMobile ,"email": email]
                
                Alamofire.request(Global.baseUrl + "iresetpassword.php", method: .post, parameters: parameters).responseJSON{ returnValue in
                    print(returnValue)
                    if let value = returnValue.value as? [String: AnyObject] {
                        print(value)
                        let status = value["status"] as! String
                        if status == "ok" {
                             self.spinnerView.endRefreshing()
                             Toast(text: "Check your mail").show()
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
                Toast(text: "Enter the Email").show()
            }
            
        }else{
            Toast(text: "Check Phone Number").show()
        }
    }
}
extension ForgotVC:FPNTextFieldDelegate{
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
