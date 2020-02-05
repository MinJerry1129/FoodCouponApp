//
//  RestaurantOneVC.swift
//  foodoffer
//
//  Created by Admin on 7/16/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import CenteredCollectionView
import Toaster
import Alamofire
import SDWebImage
import JTMaterialSpinner
class RestaurantOneVC: UIViewController {
    var foodVC : FoodVC!
    var allFoods = [Food]()
    @IBOutlet weak var middleUV: UIView!
    @IBOutlet weak var foodList: UICollectionView!    
    @IBOutlet weak var ResName: UILabel!
    @IBOutlet weak var ResImage: UIImageView!
    @IBOutlet weak var ResLogo: UIImageView!
    @IBOutlet weak var ResFullName: UILabel!
    @IBOutlet weak var ResOpenTime: UILabel!
    @IBOutlet weak var ResMobile: UILabel!    
    @IBOutlet weak var ResAddress: UILabel!
    @IBOutlet weak var ResDescription: UITextView!
    @IBOutlet weak var countCoupon: UILabel!
    
    var spinnerView = JTMaterialSpinner()
    
    let cellPercentWidth: CGFloat = 0.3
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        centeredCollectionViewFlowLayout = (foodList.collectionViewLayout as! CenteredCollectionViewFlowLayout)
        
        // Modify the collectionView's decelerationRate (REQURED)
        foodList.decelerationRate = UIScrollView.DecelerationRate.fast
        // Make the example pretty ✨
        
        // Assign delegate and data source
        foodList.delegate = self
        foodList.dataSource = self
        
        ResName.text = Defaults.getNameAndValue(Defaults.RESNAME_KEY)
        let ImgUrl = Global.imageUrl + Defaults.getNameAndValue(Defaults.RESIMAGE_KEY)
        ResImage.sd_setImage(with: URL(string: ImgUrl), completed: nil)
        let LogoUrl = Global.imageUrl + Defaults.getNameAndValue(Defaults.RESLOGO_KEY)
        ResLogo.sd_setImage(with: URL(string: LogoUrl), completed: nil)
        ResFullName.text = Defaults.getNameAndValue(Defaults.RESNAME_KEY)
        ResOpenTime.text = Defaults.getNameAndValue(Defaults.RESOPENTIME_KEY)
        ResMobile.text = Defaults.getNameAndValue(Defaults.RESMOBILE_KEY)
        ResAddress.text = Defaults.getNameAndValue(Defaults.RESADDRESS_KEY)
        ResDescription.text = Defaults.getNameAndValue(Defaults.RESDESCRIPTION_KEY)
        
        
        // Configure the required item size (REQURED)
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.height * cellPercentWidth,
            height: view.bounds.height * cellPercentWidth * 223 / 175
            //            height: view.bounds.height * cellPercentWidth * cellPercentWidth
        )
        
        // Configure the optional inter item spacing (OPTIONAL)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        allFoods = []
        let resid = "\(Defaults.getNameAndValue(Defaults.RESID_KEY))"
        let parameters: Parameters = ["resid": resid, "userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetfoods.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    let foods = value["foods"] as? [[String: Any]]
                    var count_coupon = 0
                    for i in 0 ... (foods?.count)!-1 {
                        let food_id = foods?[i]["id"] as! String
                        let food_resid = foods?[i]["resid"] as! String
                        let food_name = foods?[i]["name"] as! String
                        let food_image = foods?[i]["image"] as! String
                        let food_description = foods?[i]["description"] as! String
                        let food_needdes = foods?[i]["needdes"] as! String
                        let food_coupon = foods?[i]["coupon"] as! String
                        count_coupon = count_coupon + Int(food_coupon)!
                        let aaaaa = foods?[i]["count"]
                        print(aaaaa!)
                        let food_favorite = "\(aaaaa!)"
                        let foodcell = Food(id: food_id, resid: food_resid, name: food_name, image: food_image, description: food_description, needdescription: food_needdes, favorite: food_favorite, coupon : food_coupon )
                        
                        self.allFoods.append(foodcell)
                    }
                    self.countCoupon.text = "\(count_coupon)"
                    self.foodList.reloadData()
                    self.spinnerView.endRefreshing()
                    
                }else{
                    Toast(text: "No Foods").show()
                    self.dismiss(animated: true, completion: nil)
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
        
        
        ResLogo.layer.borderWidth = 1
        ResLogo.layer.masksToBounds = false
        ResLogo.layer.borderColor = UIColor.white.cgColor
        ResLogo.layer.borderWidth = 2
        ResLogo.layer.cornerRadius = ResLogo.bounds.size.height*0.5
        ResLogo.clipsToBounds = true
    }

    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func openBrowserBtn(_ sender: UIButton) {
//        http://maps.google.com/?saddr=34.052222,-118.243611&daddr=37.322778,-122.031944
//        if let url = URL(string: "https://www.google.com/maps/@25.258145,51.535955,18z"), UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        }
        let mapstr = "http://maps.google.com/?saddr=" + Defaults.getNameAndValue(Defaults.USERPOSITION_KEY) + "&daddr=" + Defaults.getNameAndValue(Defaults.RESPOSITION_KEY)
        print (mapstr)
        if let url = URL(string: mapstr), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func callBtn(_ sender: Any) {
        let moblestr = "tel://" + Defaults.getNameAndValue(Defaults.RESMOBILE_KEY)
        print (moblestr)
        guard let number = URL(string: moblestr) else { return }
        UIApplication.shared.open(number)
    }
}
extension RestaurantOneVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let OneFood: Food
        OneFood = allFoods[indexPath.row]
        
        Defaults.save(OneFood.id, with: Defaults.FOODID_KEY)
        Defaults.save(OneFood.resid, with: Defaults.FOODRESID_KEY)
        Defaults.save(OneFood.name, with: Defaults.FOODNAME_KEY)
        Defaults.save(OneFood.image, with: Defaults.FOODIMAGE_KEY)
        Defaults.save(OneFood.description, with: Defaults.FOODDES_KEY)
        Defaults.save(OneFood.needdescription, with: Defaults.FOODNEEDDES_KEY)
        Defaults.save(OneFood.favorite, with: Defaults.FOODFAV_KEY)
        
        foodVC = self.storyboard?.instantiateViewController(withIdentifier: "foodVC") as? FoodVC
        self.present(foodVC, animated: true, completion: nil)
        print("Selected Cell #\(indexPath.row)")
    }
}

extension RestaurantOneVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "CollectionViewCell"), for: indexPath) as! RestaurantOneCell
        let food : Food
        food = allFoods[indexPath.row]
        
        cell.foodImg.layer.borderWidth = 1
        cell.foodImg.layer.masksToBounds = false
        cell.foodImg.layer.borderColor = UIColor.white.cgColor
        cell.foodImg.layer.cornerRadius = cell.foodImg.frame.height * 0.05
        cell.foodImg.clipsToBounds = true
        cell.foodcoupon.text = food.coupon
        let ImgUrl = Global.imageUrl + food.image
        
        cell.foodImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
        cell.foodName.text = food.name
        cell.foodDescription.text = food.description
        if(Int(food.favorite) != 0){
            cell.foodfavImg.isHidden = false
        }
        else{
            cell.foodfavImg.isHidden = true
        }
       
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }
}

