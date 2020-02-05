//
//  CheckPinVC.swift
//  foodoffer
//
//  Created by Admin on 7/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import PinCodeTextField
import Alamofire
import SDWebImage
import JTMaterialSpinner
class CheckPinVC: UIViewController {

    @IBOutlet weak var reslogo: UIImageView!
    @IBOutlet weak var PinCode: PinCodeTextField!
    var spinnerView = JTMaterialSpinner()
    override func viewDidLoad() {
        toastenvironment()
        super.viewDidLoad()
        PinCode.keyboardType = .asciiCapableNumberPad
        PinCode.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let ImgUrl = Global.imageUrl + Defaults.getNameAndValue(Defaults.RESLOGO_KEY)
        reslogo.sd_setImage(with: URL(string: ImgUrl), completed: nil)
    }
    override func viewDidLayoutSubviews() {
        imageroundReady()
    }
    func imageroundReady(){
        
        reslogo.layer.borderWidth = 1
        reslogo.layer.masksToBounds = false
        reslogo.layer.borderColor = UIColor.lightGray.cgColor
        reslogo.layer.borderWidth = 2
        reslogo.layer.cornerRadius = reslogo.bounds.size.height*0.5
        reslogo.clipsToBounds = true
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
    
    @IBAction func signBtn(_ sender: Any) {
        if(PinCode.text != Defaults.getNameAndValue(Defaults.RESPIN_KEY))
        {
            Toast(text: "Wrong Restaurant Pin.").show()
        }
        else{
            self.view.addSubview(spinnerView)
            spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
            spinnerView.circleLayer.lineWidth = 2.0
            spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
            spinnerView.beginRefreshing()
            let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY) ,"foodid": Defaults.getNameAndValue(Defaults.FOODID_KEY)]
            
            Alamofire.request(Global.baseUrl + "icouponwork.php", method: .post, parameters: parameters).responseJSON{ response in
                print(response)
                if let value = response.value as? [String: AnyObject] {
                    print(value)
                    let status = value["status"] as! String
                    if status == "ok" {
                         self.spinnerView.endRefreshing()
                        let couponid = value["couponid"] as! String
                        Toast(text: "Coupon(" + couponid + ") select successfully .").show()
                    } else{
                         self.spinnerView.endRefreshing()
                        Toast(text: "Unexpected error").show()
                    }
                }
                else{
                    print("aa")
                }
            }
        }
        
//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
