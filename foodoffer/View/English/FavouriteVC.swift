//
//  FavouriteVC.swift
//  foodoffer
//
//  Created by Admin on 7/17/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import JTMaterialSpinner
class FavouriteVC: UIViewController {
    var foodVC: FoodVC!
    @IBOutlet weak var sidebarBtn: UIButton!
    @IBOutlet weak var bntSort1: UIButton!
    @IBOutlet weak var btnSort: UIButton!
    @IBOutlet weak var btnPosSort1: UIButton!
    @IBOutlet weak var btnPosSort: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var allfoods = [Food]()
    var spinnerView = JTMaterialSpinner()
    var allres = [Restaurant]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNotificationCenter()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getdata()
    }
    
    func getdata() {
        allfoods = []
        allres = []
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetfavfood.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    let foods = value["foods"] as? [[String: Any]]
                    if(foods?.count == 0){
                        self.spinnerView.endRefreshing()
                    }
                    else{
                        for i in 0 ... (foods?.count)!-1 {
                            let food_id = foods?[i]["foodid"] as! String
                            let food_resid = foods?[i]["resid"] as! String
                            let food_name = foods?[i]["foodname"] as! String
                            let food_image = foods?[i]["foodimage"] as! String
                            let food_description = foods?[i]["fooddescription"] as! String
                            let food_needdes = foods?[i]["foodneeddes"] as! String
                            let food_coupon = foods?[i]["coupon"]as! String
                            
                            let res_name = foods?[i]["resname"] as! String
                            let res_pin = foods?[i]["respin"] as! String
                            let res_image = foods?[i]["resimage"] as! String
                            let res_logo = foods?[i]["reslogo"] as! String
                            let res_mobile = foods?[i]["resmobile"] as! String
                            let res_address = foods?[i]["resaddress"] as! String
                            let res_position = foods?[i]["resposition"] as! String
                            let res_opentime = foods?[i]["resopentime"] as! String
                            let res_description = foods?[i]["resdescription"] as! String
                            
                            
                            let foodcell = Food(id: food_id, resid: food_resid, name: food_name, image: food_image, description: food_description, needdescription: food_needdes, favorite: "1", coupon: food_coupon)
                            self.allfoods.append(foodcell)
                            
                            let restaurant_cell = Restaurant(id: food_resid, name: res_name, pin: res_pin, image: res_image, logo: res_logo, address: res_address, position: res_position, disweight: 0, mobile: res_mobile, opentime: res_opentime, description: res_description, coupon: "0" )
                            self.allres.append(restaurant_cell)
                            self.tableView.delegate = self
                            self.tableView.dataSource = self
                            self.spinnerView.endRefreshing()
                            
                        }
                        self.tableView.reloadData()
                        
                        //                    self.spinnerView.endRefreshing()
                        
                    }
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
extension FavouriteVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allfoods.count
        //        return allRestaurant.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "cell"), for: indexPath) as! FavouriteCell
        let food: Food
        food = allfoods[indexPath.row]
        let restaurant : Restaurant
        restaurant = allres[indexPath.row]
        
        cell.foodImg.layer.borderWidth = 1
        cell.foodImg.layer.masksToBounds = false
        cell.foodImg.layer.borderColor = UIColor.gray.cgColor
        cell.foodImg.layer.cornerRadius = 50*0.85
        cell.foodImg.clipsToBounds = true
        let ImgUrl = Global.imageUrl + food.image
        cell.foodImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
        cell.foodName.text = food.name
        cell.restaurantName.text = restaurant.name
        cell.resAddress.text = restaurant.address
        cell.foodcoupon.text = food.coupon
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        let OneRes : Restaurant
        let OneFood: Food
        OneFood = allfoods[indexPath.row]
        
        OneRes = allres[indexPath.row]
        let disweight_str = "\(OneRes.disweight)"
        Defaults.save(OneRes.id, with: Defaults.RESID_KEY)
        Defaults.save(OneRes.name, with: Defaults.RESNAME_KEY)
        Defaults.save(OneRes.pin, with: Defaults.RESPIN_KEY)
        Defaults.save(OneRes.image, with: Defaults.RESIMAGE_KEY)
        Defaults.save(OneRes.logo, with: Defaults.RESLOGO_KEY)
        Defaults.save(OneRes.address, with: Defaults.RESADDRESS_KEY)
        Defaults.save(OneRes.position, with: Defaults.RESPOSITION_KEY)
        Defaults.save(disweight_str, with: Defaults.RESDISWEIGHT_KEY)
        Defaults.save(OneRes.mobile, with: Defaults.RESMOBILE_KEY)
        Defaults.save(OneRes.opentime, with: Defaults.RESOPENTIME_KEY)
        Defaults.save(OneRes.description, with: Defaults.RESDESCRIPTION_KEY)
        
        Defaults.save(OneFood.id, with: Defaults.FOODID_KEY)
        Defaults.save(OneFood.resid, with: Defaults.FOODRESID_KEY)
        Defaults.save(OneFood.name, with: Defaults.FOODNAME_KEY)
        Defaults.save(OneFood.image, with: Defaults.FOODIMAGE_KEY)
        Defaults.save(OneFood.description, with: Defaults.FOODDES_KEY)
        Defaults.save(OneFood.needdescription, with: Defaults.FOODNEEDDES_KEY)
        
        foodVC = self.storyboard?.instantiateViewController(withIdentifier: "foodVC") as? FoodVC
        
        self.present(foodVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY) ,"foodid": allfoods[indexPath.row].id]
            allfoods.remove(at: indexPath.row)
            Alamofire.request(Global.baseUrl + "ideletefavfood.php", method: .post, parameters: parameters).responseJSON{ returnValue in
                print(returnValue)
                if let value = returnValue.value as? [String: AnyObject] {
                    print(value)
                    let status = value["status"] as! String
                    if status == "ok" {
                        Toast(text: "Delete Success").show()
                    }else{
                        Toast(text: "Unexpected error").show()
                    }
                }
                else{
                    print("aa")
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

