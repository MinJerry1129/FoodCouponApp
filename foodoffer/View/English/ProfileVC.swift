//
//  ProfileVC.swift
//  foodoffer
//
//  Created by Admin on 7/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import SDWebImage
import Alamofire
import iOSDropDown
import JTMaterialSpinner
class ProfileVC: UIViewController {
    var couponpayVC : CouponPayVC!
    var changeVC : ChangePasswordMVC!
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var desUV: UIView!    
    @IBOutlet weak var sidebarBtn: UIButton!
    @IBOutlet weak var proUV: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    
    @IBOutlet weak var txtMobile: UILabel!
    @IBOutlet weak var txtRole: UILabel!
    @IBOutlet weak var txtExpireDate: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtLang: DropDown!
    @IBOutlet weak var upgrade: UIButton!
    
    @IBOutlet weak var txtUserName: UITextField!
    var spinnerView = JTMaterialSpinner()
    var langArray: [String] = ["English","عربى"]
    var selLang = ""
    var userid = ""
    var username = ""
    var usermobile = ""
    var userRole = ""
    var userexpiredate = ""
    var useremail = ""
    var userpassword = ""
    var userlang = ""
    var avatarurl = ""
    var imgUrl = ""
    var avatarImage : UIImage!
    var avatarSel = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        SetReady()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)        
        toastenvironment()
        initNotificationCenter()
        SetDropDown()
    }
    
    override func viewDidLayoutSubviews() {
        imageroundReady()
    }
    func SetReady() {
        avatarurl = Defaults.getNameAndValue(Defaults.AVATAR_KEY)
        imgUrl = Global.imageUrl + avatarurl
        userid = Defaults.getNameAndValue(Defaults.USERID_KEY)
        username = Defaults.getNameAndValue(Defaults.USERNAME_KEY)
        usermobile = Defaults.getNameAndValue(Defaults.MOBILE_KEY)
        userexpiredate = Defaults.getNameAndValue(Defaults.EXPIREDATE_KEY)
        useremail = Defaults.getNameAndValue(Defaults.EMAIL_KEY)
        userlang = Defaults.getNameAndValue(Defaults.LANGUAGE_KEY)
        userpassword = Defaults.getNameAndValue(Defaults.PASSWORD_KEY)
        print(userexpiredate)
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let nowDate = format.string(from: date)
        print(nowDate)
        if(nowDate>userexpiredate)
        {
            userRole = "Free Account"
            userexpiredate = ""
            upgrade.isHidden = false
        }
        else{
            userRole = "Premium Account"
            upgrade.isHidden = true
        }
        txtUserName.text = username
        txtMobile.text = usermobile
        txtRole.text = userRole
        txtExpireDate.text = userexpiredate
        txtEmail.text = useremail
        txtLang.text = userlang
        avatarImg.sd_setImage(with: URL(string: imgUrl), completed: nil)
    }
    func SetDropDown(){
        txtLang.optionArray = langArray
        txtLang.didSelect{(selectedText , index , id) in
            print(self.langArray[index])
            self.userlang = self.langArray[index]
        }
    }
    
    
    func imageroundReady(){
//        desUV.frame = CGRect(x: 0, y: 0, width: screenSize.height * 0.18, height: screenSize.height * 0.18)
        desUV.layer.borderWidth = 1
        desUV.layer.masksToBounds = false
        desUV.layer.borderColor = UIColor.white.cgColor
        desUV.layer.borderWidth = 2
        desUV.layer.cornerRadius = desUV.bounds.size.height*0.05
        desUV.clipsToBounds = true
        
//        proUV.frame = CGRect(x: 0, y: 0, width: screenSize.height * 0.18, height: screenSize.height * 0.18)
        proUV.layer.borderWidth = 1
        proUV.layer.masksToBounds = false
        proUV.layer.borderColor = UIColor.white.cgColor
        proUV.layer.borderWidth = 5
        proUV.layer.cornerRadius = proUV.bounds.size.height*0.05
        proUV.clipsToBounds = true
        
//        avatarImg.frame = CGRect(x: 0, y: 0, width: screenSize.height * 0.18, height: screenSize.height * 0.18)
        avatarImg.layer.borderWidth = 1
        avatarImg.layer.masksToBounds = false
        avatarImg.layer.borderColor = UIColor.white.cgColor
        avatarImg.layer.borderWidth = 3
        avatarImg.layer.cornerRadius = avatarImg.bounds.size.height/2
        avatarImg.clipsToBounds = true
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

    @IBAction func upgradeBtn(_ sender: UIButton) {
        couponpayVC = self.storyboard?.instantiateViewController(withIdentifier: "couponpayVC") as! CouponPayVC
        couponpayVC.profileVC = self
        self.present(couponpayVC, animated: true, completion: nil)
        
    }

    
    
    @IBAction func saveBtn(_ sender: Any) {
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        if avatarSel == 1{
            
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.avatarSel = 1
            let data = avatarImage.jpegData(compressionQuality: 0.6)
            let strBase64 = data!.base64EncodedString(options: .lineLength64Characters)
            let user_avatar : String = username + usermobile
            let avatar_url = "image/profile/IMG" + user_avatar + ".jpg"
            print(strBase64)
            
            let parameters: Parameters = ["mobile" : usermobile,"username": txtUserName.text!, "email" : txtEmail.text!, "password": userpassword, "language": userlang, "uploadfile" : strBase64 , "avatarsel":avatarSel]
            Alamofire.request(Global.baseUrl + "iupdateuser.php", method: .post, parameters: parameters).responseJSON{ response in
                print(response)
                if let value = response.value as? [String: AnyObject] {
                    let status = value["status"] as! String
                    if status == "ok" {
                        Defaults.save(self.txtUserName.text!, with: Defaults.USERNAME_KEY)
                        Defaults.save(self.txtEmail.text!, with: Defaults.EMAIL_KEY)
                        Defaults.save(self.userpassword, with: Defaults.PASSWORD_KEY)
                        Defaults.save(self.selLang, with: Defaults.LANGUAGE_KEY)
                        self.spinnerView.endRefreshing()
                        Defaults.save(avatar_url, with: Defaults.AVATAR_KEY)
                        print(avatar_url)
                        print(Defaults.getNameAndValue(Defaults.AVATAR_KEY))
                        Toast(text: "Success Updated").show()
                    }
                    else{
                        self.spinnerView.endRefreshing()
                        Toast(text: "Error").show()
                    }
                }
            }
            avatarSel = 0
        }
        else{
            let parameters: Parameters = ["mobile" : usermobile, "username": txtUserName.text!, "email" : txtEmail.text!, "password": userpassword, "language": userlang, "avatarsel":avatarSel]
            Alamofire.request(Global.baseUrl + "iupdateuser.php", method: .post, parameters: parameters).responseJSON{ response in
                print(response)
                if let value = response.value as? [String: AnyObject] {
                    let status = value["status"] as! String
                    if status == "ok" {
                        Defaults.save(self.txtUserName.text!, with: Defaults.USERNAME_KEY)
                        Defaults.save(self.txtEmail.text!, with: Defaults.EMAIL_KEY)
                        Defaults.save(self.userpassword, with: Defaults.PASSWORD_KEY)
                        Defaults.save(self.selLang, with: Defaults.LANGUAGE_KEY)
                        self.spinnerView.endRefreshing()
                        Toast(text: "Success Updated").show()
                    }
                    else{
                        self.spinnerView.endRefreshing()
                        Toast(text: "Error").show()
                    }
                }
            }
        }
        //Toast(text: "Change profile success.").show()
    }
    @IBAction func menuBrnClciked(_ sender: UIButton) {
        sideMenuController?.revealMenu()
    }
    
    @IBAction func selectAvatar(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Choose image from camera roll
    
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func changepassword(_ sender: UIButton) {
       changeVC = self.storyboard?.instantiateViewController(withIdentifier: "changeVC") as! ChangePasswordMVC
        changeVC.modalPresentationStyle = .overCurrentContext
        changeVC.profileVC = self
        self.present(changeVC, animated: true, completion: nil)
    }
}
extension ProfileVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(editedImage)
            avatarImage = editedImage
            avatarSel = 1
            self.avatarImg.image = editedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        avatarSel = 0
        self.dismiss(animated: true, completion: nil)
    }
}
