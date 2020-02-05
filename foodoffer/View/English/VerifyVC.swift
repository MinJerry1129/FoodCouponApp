//
//  VerifyVC.swift
//  foodoffer
//
//  Created by Admin on 8/1/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import JTMaterialSpinner
import Firebase
class VerifyVC: UIViewController {
    
    @IBOutlet weak var txtVerifyCode: UITextField!
    var loginVC : LoginVC!
    var spinnerView = JTMaterialSpinner()
    var verificationID: String!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func verifyBtn(_ sender: UIButton) {
        
        let name = Defaults.getNameAndValue(Defaults.SIGNNAME_KEY)
        let email = Defaults.getNameAndValue(Defaults.SIGNEMAIL_KEY)
        let password = Defaults.getNameAndValue(Defaults.SIGNPASSWORD_KEY)
        let promocode = Defaults.getNameAndValue(Defaults.SIGNPROMOCODE_KEY)
        let mobile = Defaults.getNameAndValue(Defaults.SIGNMOBILE_KEY)
        let vcode = Defaults.getNameAndValue(Defaults.SIGNVCODE_KEY)
        print(vcode)
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: txtVerifyCode.text!)
        self.view.addSubview(self.spinnerView)
        self.spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        self.spinnerView.circleLayer.lineWidth = 2.0
        self.spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        self.spinnerView.beginRefreshing()
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                self.spinnerView.endRefreshing()
                print("Wrong Code")
                return
            }
            let parameters: Parameters = ["username": name, "email": email, "mobile": mobile ,"password": password, "promocode": promocode]
            print(parameters)
            print(Global.baseUrl + "iuserregister.php")
            Alamofire.request(Global.baseUrl + "iuserregister.php", method: .post, parameters: parameters).responseJSON{ response in
                print(response)
                if let value = response.value as? [String: AnyObject] {
                    print(value)
                    let status = value["status"] as! String
                    if status == "ok" {
                        self.spinnerView.endRefreshing()
                        Toast(text: "SignUP Success").show()
                        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginVC
                        self.present(self.loginVC, animated: true, completion: nil)
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
