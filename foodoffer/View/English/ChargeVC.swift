//
//  ChargeVC.swift
//  foodoffer
//
//  Created by Admin on 7/26/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import JTMaterialSpinner
class ChargeVC: UIViewController , PayPalPaymentDelegate{
    
    //    PayPalEnvironmentSandbox  , PayPalEnvironmentNoNetwork
    var environment:String =  PayPalEnvironmentSandbox{
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    var payPalConfig = PayPalConfiguration()
    var spinnerView = JTMaterialSpinner()
    var exchange_rate : Double = 0.0
    @IBOutlet weak var middleUV: UIView!
    @IBOutlet weak var txtwallet: UILabel!
    var billingVC : BillingVC! = nil
    var couponpayVC :CouponPayVC! = nil
    var amountofpay = ""
    @IBOutlet weak var txtmoney: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        toastenvironment()
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetsetting.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let rate = value["rate"] as! String
                self.exchange_rate = Double(rate)!
            }
            
        }
       
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
         setpayenvironment()
         txtwallet.text = Defaults.getNameAndValue(Defaults.WALLET_KEY)
    }
    override func viewDidLayoutSubviews() {
        imageroundReady()
    }
    
    func imageroundReady(){
        middleUV.layer.borderWidth = 1
        middleUV.layer.masksToBounds = false
        middleUV.layer.borderColor = UIColor.gray.cgColor
        middleUV.layer.cornerRadius = middleUV.frame.height * 0.05
        middleUV.clipsToBounds = true
        
    }
    func setpayenvironment(){
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "BREWIT 9"  //Give your company name here.
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full") //Give your company's privacy policy url here.
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full") //Give UserAgreement URL here.
        
        //This is the language in which your paypal sdk will be shown to users.
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        //Here you can set the shipping address. You can choose either the address associated with PayPal account or different address. We'll use .both here.
        
        payPalConfig.payPalShippingAddressOption = .both;
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
    
    @IBAction func payBtn(_ sender: Any) {
        amountofpay = txtmoney.text!
        if(amountofpay != "" ){
            let amountusd = Double(amountofpay)! * exchange_rate
//
//            let item1 = PayPalItem(name: "Add to Foodoffer Wallet", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(amountusd)"), withCurrency: "USD", withSku: "BREWIT-0011")
            let item1 = PayPalItem(name: "Add to Foodoffer Wallet", withQuantity: 1, withPrice: NSDecimalNumber(string: "\(amountusd)"), withCurrency: "USD", withSku: "BREWIT-0011")
            let items = [item1]
            let subtotal = PayPalItem.totalPrice(forItems: items) //This is the total price of all the items
            
            // Optional: include payment details
            let shipping = NSDecimalNumber(string: "0")
            let tax = NSDecimalNumber(string: "0")
            let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
            
            let total = subtotal.adding(shipping).adding(tax) //This is the total price including shipping and tax
            
            let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Pay to Hoster", intent: .sale)
            
            payment.items = items
            payment.paymentDetails = paymentDetails
            
            if (payment.processable) {
                let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
                present(paymentViewController!, animated: true, completion: nil)
            }
            else {
                Toast(text: "Payment not processalbe: \(payment)").show()
            }
            
        }
        else{
           Toast(text: "Enter the charge amount.").show()
        }
        if(billingVC != nil)
        {
            billingVC.getdata()
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if(billingVC != nil){
            billingVC.getdata()
        }
        if(couponpayVC != nil){
            couponpayVC.setready()
        }
    }
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        let mywallet = Defaults.getNameAndValue(Defaults.WALLET_KEY)
        let add_wallet :Double = Double(mywallet)! + Double(amountofpay)!
        let wallet = "\(add_wallet)"
        
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
        })
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY) , "addvalue": amountofpay ,"wallet" : wallet]
        Alamofire.request(Global.baseUrl + "iupdatewallet.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    self.txtwallet.text = wallet
                    Defaults.save(wallet, with: Defaults.WALLET_KEY)
                     self.spinnerView.endRefreshing()
                    Toast(text: "Success Payment").show()
                }
                else{
                    self.spinnerView.endRefreshing()
                    Toast(text: "Error").show()
                }
            }
        }
        
        
    }
}
