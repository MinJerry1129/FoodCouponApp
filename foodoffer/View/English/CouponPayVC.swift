//
//  CouponPayVC.swift
//  foodoffer
//
//  Created by Admin on 7/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import JTMaterialSpinner
class CouponPayVC: UIViewController {
    var profileVC: ProfileVC! = nil
    var chargeVC : ChargeVC! = nil
    var foodVC : FoodVC! = nil
    @IBOutlet weak var isYearly: UILabel!
    @IBOutlet weak var isMontly: UILabel!
    @IBOutlet weak var txtWallet: UILabel!
    @IBOutlet weak var monthlyBtn: UIButton!
    @IBOutlet weak var yearlyBtn: UIButton!
    var spinnerView = JTMaterialSpinner()
    var wallet = ""
    var yearly_pay : Double = 0.0
    var monthly_pay : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetsetting.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let monthly = value["monthly"] as! String
                let yearly = value["yearly"] as! String
                self.monthly_pay = Double(monthly)!
                self.yearly_pay = Double(yearly)!
                self.setready()
            }
        }
        
        let str = String(format: "%.16f", Double(Defaults.getNameAndValue(Defaults.WALLET_KEY))! - 4.99)
        print(Double(Defaults.getNameAndValue(Defaults.WALLET_KEY))! - 4.99)
        toastenvironment()
    }
    func setready(){
        print(Defaults.getNameAndValue(Defaults.WALLET_KEY))
        txtWallet.text = Defaults.getNameAndValue(Defaults.WALLET_KEY)
        let isValue = Defaults.getNameAndValue(Defaults.WALLET_KEY)
        if(Double(isValue)! < monthly_pay){
            monthlyBtn.isEnabled = false
            monthlyBtn.backgroundColor = UIColor.gray
            yearlyBtn.backgroundColor = UIColor.gray
            yearlyBtn.isEnabled = false
            isYearly.isHidden = false
            isMontly.isHidden = false
        }else if(Double(isValue)! < yearly_pay){
            yearlyBtn.backgroundColor = UIColor.gray
            monthlyBtn.isEnabled = true
            yearlyBtn.isEnabled = false
            isYearly.isHidden = false
            isMontly.isHidden = true
        }else{
            monthlyBtn.isEnabled = true
            yearlyBtn.isEnabled = true
            isYearly.isHidden = true
            isMontly.isHidden = true
            
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
    
    @IBAction func PayMonthlyBtn(_ sender: UIButton) {
        let wallet = Defaults.getNameAndValue(Defaults.WALLET_KEY)
        if(Double(wallet)! > monthly_pay){
            let alert = UIAlertController(title: "Do you pay for the Monthly", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Pay", style: .default, handler: { _ in
                self.monthlypay()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        else{
            Toast(text: "Lack of funds").show()
        }
    }
    func monthlypay()  {
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let wallet = Defaults.getNameAndValue(Defaults.WALLET_KEY)
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY), "paytype": "monthly", "wallet" : wallet, "payvalue" : monthly_pay]
        Alamofire.request(Global.baseUrl + "iupdatemembership.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    
                    let expiredate = value["expiredate"] as! String
                    let wallet_amount = value["wallet"] as! String
                    Defaults.save(wallet_amount, with: Defaults.WALLET_KEY)
                    Defaults.save(expiredate, with: Defaults.EXPIREDATE_KEY)
                    if(self.profileVC != nil){
                        self.profileVC.txtRole.text = "Premium Account"
                        self.profileVC.txtExpireDate.text = expiredate
                        self.profileVC.upgrade.isHidden = true
                    }
                    self.txtWallet.text = wallet_amount
                    self.spinnerView.endRefreshing()
                    self.monthlyBtn.isEnabled = false
                    self.monthlyBtn.backgroundColor = UIColor.gray
                    self.yearlyBtn.backgroundColor = UIColor.gray
                    self.yearlyBtn.isEnabled = false
                    Toast(text: "Success Updated").show()
                }
                else{
                  self.spinnerView.endRefreshing()
                    Toast(text: "Error").show()
                }
            }
        }
    }
    func yearlypay()  {
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        
        let wallet = Defaults.getNameAndValue(Defaults.WALLET_KEY)
        Defaults.save(wallet, with: Defaults.WALLET_KEY)
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY), "paytype": "yearly", "wallet" : wallet, "payvalue" : yearly_pay]
        Alamofire.request(Global.baseUrl + "iupdatemembership.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    
                    let expiredate = value["expiredate"] as! String
                    self.profileVC.txtRole.text = "Premium Account"
                    self.profileVC.txtExpireDate.text = expiredate
                    self.profileVC.upgrade.isHidden = true
                    let wallet_amount = value["wallet"] as! String
                    Defaults.save(wallet_amount, with: Defaults.WALLET_KEY)
                    Defaults.save(expiredate, with: Defaults.EXPIREDATE_KEY)
                    self.txtWallet.text = wallet_amount
                    self.spinnerView.endRefreshing()
                    self.monthlyBtn.isEnabled = false
                    self.monthlyBtn.backgroundColor = UIColor.gray
                    self.yearlyBtn.backgroundColor = UIColor.gray
                    self.yearlyBtn.isEnabled = false
                    Toast(text: "Success Updated").show()
                }
                else{
                    self.spinnerView.endRefreshing()
                    Toast(text: "Error").show()
                }
            }
        }
    }
    
    @IBAction func PayYearlyBtn(_ sender: UIButton) {
        let wallet = Defaults.getNameAndValue(Defaults.WALLET_KEY)
        if(Double(wallet)! > yearly_pay){
            let alert = UIAlertController(title: "Do you pay for the Yearly", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Pay", style: .default, handler: { _ in
                self.yearlypay()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        else{
            Toast(text: "Lack of funds").show()
        }
    }

    @IBAction func addCoinBtn(_ sender: UIButton) {
        chargeVC = self.storyboard?.instantiateViewController(withIdentifier: "chargeVC") as! ChargeVC
        chargeVC.modalPresentationStyle = .overCurrentContext
        chargeVC.couponpayVC = self
        self.present(chargeVC, animated: true, completion: nil)
    }
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if(foodVC != nil){
            foodVC.getdata()
        }
        
    }
}
