//
//  FoodVC.swift
//  foodoffer
//
//  Created by Admin on 7/16/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import JTMaterialSpinner
class FoodVC: UIViewController {
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var middleUV: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var resLogo: UIImageView!
    @IBOutlet weak var foodFullName: UILabel!
    @IBOutlet weak var resName: UILabel!
    @IBOutlet weak var resMobile: UILabel!
    @IBOutlet weak var resAddress: UILabel!
    @IBOutlet weak var foodNeedDes: UITextView!
    @IBOutlet weak var foodDes: UITextView!
    @IBOutlet weak var resOpenTime: UILabel!
    @IBOutlet weak var favImg: UIButton!
    @IBOutlet weak var txtcoupon: UILabel!
    @IBOutlet weak var useCoupon: UIButton!
    @IBOutlet weak var btnRole: UIButton!
    var couponpayVC: CouponPayVC!
    var spinnerView = JTMaterialSpinner()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodName.text = Defaults.getNameAndValue(Defaults.FOODNAME_KEY)
        let ImgUrl = Global.imageUrl + Defaults.getNameAndValue(Defaults.FOODIMAGE_KEY)
        foodImage.sd_setImage(with: URL(string: ImgUrl), completed: nil)
        let LogoUrl = Global.imageUrl + Defaults.getNameAndValue(Defaults.RESLOGO_KEY)
        resLogo.sd_setImage(with: URL(string: LogoUrl), completed: nil)
        foodFullName.text = Defaults.getNameAndValue(Defaults.FOODNAME_KEY)
        resName.text = Defaults.getNameAndValue(Defaults.RESNAME_KEY)
        resMobile.text = Defaults.getNameAndValue(Defaults.RESMOBILE_KEY)
        resAddress.text = Defaults.getNameAndValue(Defaults.RESADDRESS_KEY)
        foodDes.text = Defaults.getNameAndValue(Defaults.FOODDES_KEY)
        foodNeedDes.text = Defaults.getNameAndValue(Defaults.FOODNEEDDES_KEY)
        resOpenTime.text = Defaults.getNameAndValue(Defaults.RESOPENTIME_KEY)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {        
        super.viewWillAppear(true)
        getdata()
    }
    func getdata(){
        
        let expiredate = Defaults.getNameAndValue(Defaults.EXPIREDATE_KEY)
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let nowDate = format.string(from: date)
        print(expiredate)
        if(nowDate>expiredate)
        {
            btnRole.isHidden = false
        }
        else{
            btnRole.isHidden = true
        }
        
        
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["foodid": Defaults.getNameAndValue(Defaults.FOODID_KEY), "userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "icheckfavfood.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    self.spinnerView.endRefreshing()
                    let fav_str = value["count"] as! String
                    let coupon = value["coupon"] as! String
                    self.txtcoupon.text = coupon
                    if(Int(coupon) == 0 )
                    {
                        self.useCoupon.isEnabled = false
                    }
                    if(Int(fav_str) != 0){
                        self.favImg.isEnabled = false
                    }
                }
            }
        }
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
        
        resLogo.layer.borderWidth = 1
        resLogo.layer.masksToBounds = false
        resLogo.layer.borderColor = UIColor.white.cgColor
        resLogo.layer.borderWidth = 2
        resLogo.layer.cornerRadius = resLogo.bounds.size.height*0.5
        resLogo.clipsToBounds = true
    }
    
    @IBAction func callBtn(_ sender: Any) {
        let moblestr = "tel://" + Defaults.getNameAndValue(Defaults.RESMOBILE_KEY)
        print (moblestr)
        guard let number = URL(string: moblestr) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func btnRole(_ sender: UIButton) {
        couponpayVC = self.storyboard?.instantiateViewController(withIdentifier: "couponpayVC") as? CouponPayVC
        couponpayVC.foodVC = self
        self.present(couponpayVC, animated: true, completion: nil)
    }
    @IBAction func positionBtn(_ sender: Any) {
        let mapstr = "http://maps.google.com/?saddr=" + Defaults.getNameAndValue(Defaults.USERPOSITION_KEY) + "&daddr=" + Defaults.getNameAndValue(Defaults.RESPOSITION_KEY)
        print (mapstr)
        if let url = URL(string: mapstr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func selFav(_ sender: Any) {
        
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY), "foodid": Defaults.getNameAndValue(Defaults.FOODID_KEY)]
        print(Defaults.getNameAndValue(Defaults.FOODID_KEY))
        print(Global.baseUrl + "ifavfoodregister.php")
        Alamofire.request(Global.baseUrl + "ifavfoodregister.php", method: .post, parameters: parameters).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                if status == "ok" {
                    Toast(text: "Set Favorite Food Success").show()
                    self.favImg.isEnabled = false
                }else{
                    Toast(text: "Fail").show()
                }
            }
            else{
                print("aa")
            }
        }
        
        
    }
    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
//        if (favVC != nil) {
//            favVC?.getdata()
//        }
    }
    
    
}

