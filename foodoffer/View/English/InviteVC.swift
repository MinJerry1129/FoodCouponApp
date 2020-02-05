//
//  InviteVC.swift
//  foodoffer
//
//  Created by Admin on 7/25/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import JTMaterialSpinner
class InviteVC: UIViewController {

    @IBOutlet weak var sidebarBtn: UIButton!
    @IBOutlet weak var txtpromocode: UILabel!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtContent: UILabel!
    
    var spinnerView = JTMaterialSpinner()
    override func viewDidLoad() {
        super.viewDidLoad()
         initNotificationCenter()
   
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sideBtn(_ sender: UIButton) {
        sideMenuController?.revealMenu()
    }
    @IBAction func copyBtn(_ sender: Any) {
        UIPasteboard.general.string = txtpromocode.text
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
                    let promocode = value["promo"] as! String
                    let uinvite = value["uinvite"] as! String
                    let cinvite = value["cinvite"] as! String
                    self.txtTitle.text = "At exactly " + cinvite+"E£"
                    self.txtContent.text = "Refer your friends to us, and they'll each get " + cinvite + "E£. We'll give you " + uinvite + "E£ for each friend that register app with your promo code."
                    self.txtpromocode.text = promocode
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
