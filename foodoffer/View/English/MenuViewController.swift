//
//  MenuViewController.swift
//  SideMenuExample
//
//  Created by kukushi on 11/02/2018.
//  Copyright © 2018 kukushi. All rights reserved.
//

import UIKit
import SideMenuSwift
import SDWebImage
import Alamofire
import JTMaterialSpinner
class Preferences {
    static let shared = Preferences()
    var enableTransitionAnimation = false
}

class MenuViewController: UIViewController{
    var mainVC : MainPageVC!
    var profileVC: ProfileVC!
    var spinnerView = JTMaterialSpinner()
  
    @IBOutlet weak var txtmoney: UILabel!
    @IBOutlet weak var avatarUV: UIView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var username = ""
    var avatarurl = ""
    var imgUrl = ""
    var isDarkModeEnabled = false
    @IBOutlet weak var walletbtn: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
        }
    }
    
    
    private var themeColor = UIColor.init(red: 243/255, green: 243/255, blue: 243/255, alpha: 0.95)
    private var themeColor1 = UIColor.init(red: 106/255, green: 203/255, blue: 111/255, alpha: 0.95)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isDarkModeEnabled = SideMenuController.preferences.basic.position == .under
        configureView()
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "profileVC")
        }, with: "1")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "favouriteVC")
        }, with: "2")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "inviteVC")
        }, with: "3")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "billingVC")
        }, with: "4")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "reviewVC")
        }, with: "5")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "contactVC")
        }, with: "6")
        
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "loginVC")

        }, with: "7")
        
        sideMenuController?.delegate = self
        username = Defaults.getNameAndValue(Defaults.USERNAME_KEY)
        avatarurl = Defaults.getNameAndValue(Defaults.AVATAR_KEY)
        imgUrl = Global.imageUrl + avatarurl
        
        avatarImg.sd_setImage(with: URL(string: imgUrl), completed: nil)
        userName.text = username
    }
    override func viewDidLayoutSubviews() {
        imageroundReady()
    }
    func imageroundReady(){
        avatarImg.layer.borderWidth = 1
        avatarImg.layer.masksToBounds = false
        avatarImg.layer.borderColor = UIColor.white.cgColor
        avatarImg.layer.borderWidth = 5
        avatarImg.layer.cornerRadius = avatarImg.frame.height*0.5
        avatarImg.clipsToBounds = true
    }

    @IBAction func openWalleteBtn(_ sender: Any) {
        let row = 4
        sideMenuController?.setContentViewController(with: "\(row)", animated: Preferences.shared.enableTransitionAnimation)
        sideMenuController?.hideMenu()
        
        if let identifier = sideMenuController?.currentCacheIdentifier() {
            print("[Example] View Controller Cache Identifier: \(identifier)")
        }
    }
    
    private func configureView() {
        view.backgroundColor = UIColor.clear
        avatarUV.backgroundColor = themeColor
        tableView.backgroundColor = themeColor1
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        view.layoutIfNeeded()
    }
}

extension MenuViewController: SideMenuControllerDelegate {
    func sideMenuController(_ sideMenuController: SideMenuController,
                            animationControllerFrom fromVC: UIViewController,
                            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BasicTransitionAnimator(options: .transitionFlipFromLeft, duration: 1)
    }
    func sideMenuController(_ sideMenuController: SideMenuController, willShow viewController: UIViewController, animated: Bool) {
        print("[Example] View controller will show [\(viewController)]")
    }
    
    func sideMenuController(_ sideMenuController: SideMenuController, didShow viewController: UIViewController, animated: Bool) {
        print("[Example] View controller did show [\(viewController)]")
    }
    
    func sideMenuControllerWillHideMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu will hide")
         NotificationCenter.default.post(name: .showMenuButton, object: nil)
    }
    
    func sideMenuControllerDidHideMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu did hide.")
    }
    
    func sideMenuControllerWillRevealMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu will reveal.")
        avatarurl = Defaults.getNameAndValue(Defaults.AVATAR_KEY)
        imgUrl = Global.imageUrl + avatarurl
        print(imgUrl)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        if appDelegate?.avatarSel == 1{
            appDelegate?.avatarSel = 0
            SDImageCache.shared.clearMemory()
            SDImageCache.shared.clearDisk()
            avatarImg.sd_setImage(with: URL(string: imgUrl), completed: nil)
        }
        let strMobile = Defaults.getNameAndValue(Defaults.MOBILE_KEY)
        let parameters: Parameters = ["mobile": strMobile]
        
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()        
        Alamofire.request(Global.baseUrl + "igetpromocode.php", method: .post, parameters: parameters).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                if status == "ok" {
                     self.spinnerView.endRefreshing()
                    let wallet = value["wallet"] as! String
                    Defaults.save(wallet, with: Defaults.WALLET_KEY)
                    self.txtmoney.text = wallet + "E£"
                    self.walletbtn.setTitle(wallet + "E£", for: .normal)
                }
            }
            else{
                print("aa")
            }
        }
        
        
        NotificationCenter.default.post(name: .hideMenuButton, object: nil)
    }
    
    func sideMenuControllerDidRevealMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu did reveal.")        
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    // swiftlint:disable force_cast
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuVCCell
        let row = indexPath.row       
        if row == 0 {
            cell.menuImg.image = UIImage(named: "menuImg_home")
            cell.menuTitle.text = "H o m e"
            
        } else if row == 1 {
            cell.menuImg.image = UIImage(named: "menuImg_profile")
            cell.menuTitle.text = "Profile"
        } else if row == 2 {
            cell.menuImg.image = UIImage(named: "menuImg_favo")
            cell.menuTitle.text = "My Favourite"
        }else if row == 3 {
            cell.menuImg.image = UIImage(named: "invite_friend")
            cell.menuTitle.text = "Invite Friends"
        }else if row == 4 {
            cell.menuImg.image = UIImage(named: "wallet_white")
            cell.menuTitle.text = "My Wallet"
        }
        else if row == 5 {
            cell.menuImg.image = UIImage(named: "menuImg_review")
            cell.menuTitle.text = "My History"
        }
        else if row == 6 {
            cell.menuImg.image = UIImage(named: "menuImg_contact")
            cell.menuTitle.text = "Contact Us"
        }
        else if row == 7 {
            cell.menuImg.image = UIImage(named: "menuImg_logout")
            cell.menuTitle.text = "Log Out"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        if(row == 7){
            Defaults.save("", with: Defaults.MOBILE_KEY)
        }
            sideMenuController?.setContentViewController(with: "\(row)", animated: Preferences.shared.enableTransitionAnimation)
            sideMenuController?.hideMenu()
            
            if let identifier = sideMenuController?.currentCacheIdentifier() {
                print("[Example] View Controller Cache Identifier: \(identifier)")
            }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.backgroundColor = UIColor.init(red: 4/255, green: 45/255, blue: 4/255, alpha: 0.8)
            })
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.backgroundColor = UIColor.clear
            })
        }
        
    }
}
