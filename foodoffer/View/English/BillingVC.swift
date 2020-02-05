//
//  BillingVC.swift
//  foodoffer
//
//  Created by Admin on 7/25/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import JTMaterialSpinner
class BillingVC: UIViewController {

    @IBOutlet weak var txtWallet: UILabel!
    @IBOutlet weak var txtIncome: UILabel!
    @IBOutlet weak var txtSpent: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sidebarBtn: UIButton!    
    @IBOutlet weak var transactionSegment: UISegmentedControl!
    var spinnerView = JTMaterialSpinner()
    var chargeVC : ChargeVC! = nil
    var allBillings = [Wallet]()
    var sortBillings = [Wallet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationCenter()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        getdata()
    }
    func getdata(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        allBillings = []
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        print(parameters)
        Alamofire.request(Global.baseUrl + "igetbillinghistory.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                let t_Ballance = value["wallet"] as! String
                let t_earn = value["totalincome"] as! String
                let t_spent = value["totalspent"] as! String
                if(t_Ballance == "no")
                {
                    self.txtWallet.text = "\(0)"
                }
                else{
                    self.txtWallet.text = t_Ballance
                }
                if(t_earn == "no")
                { self.txtIncome.text = "\(0)"
                }
                else{
                    self.txtIncome.text = t_earn
                }
                if(t_spent == "no")
                {
                    self.txtSpent.text = "\(0)"
                }
                else{
                    self.txtSpent.text = t_spent
                }
                if status == "ok" {
                    let billings = value["billings"] as? [[String: Any]]
                    if(billings?.count == 0){
                        self.spinnerView.endRefreshing()
                    }else{
                        for i in 0 ... (billings?.count)!-1 {
                            let w_date = billings?[i]["paydate"] as! String
                            let w_transaction = billings?[i]["transaction"] as! String
                            let w_amount = billings?[i]["amount"] as! String
                            let w_type = billings?[i]["type"] as! String
                            
                            let billing_cell = Wallet(date: w_date, transaction: w_transaction, amount: w_amount, type: w_type)
                            self.allBillings.append(billing_cell)
                        }
                        print("aaaaa")
                        self.sortBillings = self.allBillings
                        self.tableView.dataSource = self
                        self.tableView.delegate = self
                        self.tableView.reloadData()
                        self.spinnerView.endRefreshing()
                    }
                    
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
    
    @IBAction func ChargeBtn(_ sender: UIButton) {
        chargeVC = self.storyboard?.instantiateViewController(withIdentifier: "chargeVC") as! ChargeVC
        chargeVC.modalPresentationStyle = .overCurrentContext
        chargeVC.billingVC = self
        self.present(chargeVC, animated: true, completion: nil)
    }
    
    @IBAction func transactionSeg(_ sender: UISegmentedControl) {
        switch transactionSegment.selectedSegmentIndex
        {
        case 0:
           self.sortBillings = self.allBillings
           self.tableView.reloadData()
        case 1:
            self.sortBillings = self.allBillings.filter { billing in
                return billing.type.lowercased().contains("income")
            }
            self.tableView.reloadData()
        case 2:
            self.sortBillings = self.allBillings.filter { billing in
                return billing.type.lowercased().contains("spent")
            }
            self.tableView.reloadData()
        default:
            break
        }
    }
    
    @objc func hideMenuButton(notification: NSNotification) {
        sidebarBtn.isHidden = true
    }
    
    @IBAction func sidebarBtn(_ sender: Any) {
          sideMenuController?.revealMenu()
    }
}
extension BillingVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortBillings.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "cell"), for: indexPath) as! TransactionCell
        let OneBilling :Wallet
            OneBilling = sortBillings[indexPath.row]
        let row = indexPath.row
        if row % 2 == 0{
            cell.backgroundColor = UIColor.init(red: 133/255, green: 224/255, blue: 133/255, alpha: 0.1)
        }else{
            cell.backgroundColor = UIColor.init(red: 133/255, green: 224/255, blue: 133/255, alpha: 0)
        }
        cell.txtNum.text = "\(indexPath.row+1)"
        cell.txtDate.text = OneBilling.date
        cell.txtTransaction.text = OneBilling.transaction
        if(OneBilling.type == "spent")
        {
            cell.txtAmount.textColor = UIColor.red
            cell.txtAmount.text = "-" + OneBilling.amount
        }
        else{
            cell.txtAmount.textColor = UIColor.init(red: 8/255, green: 115/255, blue: 28/255, alpha: 1)
            cell.txtAmount.text = OneBilling.amount
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "headerCell")) as! TransactionTableHeaderCell
        cell.backgroundColor = UIColor.init(red: 103/255, green: 172/255, blue: 102/255, alpha: 1)
        cell.txtnum.textColor = UIColor.white
        cell.txtDate.textColor = UIColor.white
        cell.txtTransaction.textColor = UIColor.white
        cell.txtAmount.textColor = UIColor.white
        
        cell.txtnum.font=UIFont.init(name: "system", size: 13)
        cell.txtDate.font=UIFont.init(name: "system", size: 13)
        cell.txtTransaction.font=UIFont.init(name: "system", size: 13)
        cell.txtAmount.font=UIFont.init(name: "system", size: 13)
        
        cell.txtnum.text = "#"
        cell.txtDate.text = "Date"
        cell.txtTransaction.text = "Transaction"
        cell.txtAmount.text = "Amount (E£)"
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
