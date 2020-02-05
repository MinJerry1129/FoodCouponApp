//
//  ReviewVC.swift
//  foodoffer
//
//  Created by Admin on 7/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import JTMaterialSpinner
class ReviewVC: UIViewController {
    var allcouponwork = [CouponWork]()
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var sidebarBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationCenter()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        allcouponwork = []
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetcouponhistory.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                     self.spinnerView.endRefreshing()
                    let coupon_work = value["coupon"] as? [[String: Any]]
                    for i in 0 ... (coupon_work?.count)!-1 {
                        let c_date = coupon_work?[i]["usedate"] as! String
                        let c_couponid = coupon_work?[i]["couponid"] as! String
                        let c_foodname = coupon_work?[i]["foodname"] as! String
                        
                        let couponwork_cell = CouponWork(date: c_date, foodname: c_foodname, couponid: c_couponid)
                        self.allcouponwork.append(couponwork_cell)
                    }
                    print("aaaaa")
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                    //self.spinnerView.endRefreshing()
                }
                else{
                    self.spinnerView.endRefreshing()
                }
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
    
    
    @IBAction func menuBtnClicked(_ sender: Any) {
        sideMenuController?.revealMenu()
    }
    
}
extension ReviewVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allcouponwork.count
//        return allRestaurant.count + 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "headerCell")) as! TableHeaderCell
        cell.backgroundColor = UIColor.init(red: 103/255, green: 172/255, blue: 102/255, alpha: 1)
        cell.number.textColor = UIColor.white
        cell.tbdate.textColor = UIColor.white
        cell.couponnum.textColor = UIColor.white
        cell.foodname.textColor = UIColor.white
        
        cell.number.font=UIFont.init(name: "system", size: 18)
        cell.tbdate.font=UIFont.init(name: "system", size: 18)
        cell.couponnum.font=UIFont.init(name: "system", size: 18)
        cell.foodname.font=UIFont.init(name: "system", size: 18)
        
        cell.number.text = "#"
        cell.tbdate.text = "Date"
        cell.couponnum.text = "Coupon"
        cell.foodname.text = "FoodName"
        return cell
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "cell"), for: indexPath) as! ReviewCell
        let OneCouponWork : CouponWork
        OneCouponWork = allcouponwork[indexPath.row]
        let row = indexPath.row
        if row % 2 == 0{
            cell.backgroundColor = UIColor.init(red: 133/255, green: 224/255, blue: 133/255, alpha: 0)            
        }else{
            cell.backgroundColor = UIColor.init(red: 133/255, green: 224/255, blue: 133/255, alpha: 0.1)
        }
        cell.number.text = "\(indexPath.row + 1)"
        cell.dateLB.text = OneCouponWork.date
        cell.couponnum.text = OneCouponWork.couponid
        cell.foodname.text = OneCouponWork.foodname
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

