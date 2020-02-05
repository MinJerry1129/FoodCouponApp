import UIKit
import SideMenuSwift
import ImageSlideshow
import Alamofire
import SDWebImage
import JTMaterialSpinner
class MainPageVC : UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionview1: UICollectionView!
    @IBOutlet weak var restaurantImg: ImageSlideshow!    
    @IBOutlet weak var sidebarBtn: UIButton!
    @IBOutlet weak var goRestaurant: UIImageView!
    @IBOutlet weak var allresBtn: UIButton!
    var inputSource: [InputSource] = []
    var spinnerView = JTMaterialSpinner()
    var restaurantVC : RestaurantVC! = nil
    var foodVC: FoodVC!
    var allfoods = [Food]()
    var specialfoods = [Food]()
    var allres = [Restaurant]()
    override func viewDidLoad() {
        super.viewDidLoad()
        inputSource.append(ImageSource(image: UIImage(named: "ads3")!))
        getdata()
        collectionView.register(UINib(nibName: "OptionViewCell", bundle: nil), forCellWithReuseIdentifier: "OptionViewCell")
        collectionview1.register(UINib(nibName: "OptionViewCell", bundle: nil), forCellWithReuseIdentifier: "OptionViewCell")
        initNotificationCenter()
        
//        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
//        restaurantImg.addGestureRecognizer(gesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
        collectionviewReady()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        allresBtn.layer.borderWidth = 1
        allresBtn.layer.masksToBounds = false
        allresBtn.layer.borderColor = UIColor.gray.cgColor
        allresBtn.layer.cornerRadius = allresBtn.frame.height * 0.5
        allresBtn.clipsToBounds = true
        
    }
    func getdata(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetfoodmain.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    let foods = value["foods"] as? [[String: Any]]
                    let admobs = value["admobs"] as? [[String: Any]]
                    for j in 0 ... 8{
                        let admoburl = admobs?[j]["admobimage"] as! String
                        let ImgUrl = Global.imageUrl + admoburl
                        self.inputSource.append(SDWebImageSource(urlString: ImgUrl)!)
                    }
                    for i in 0 ... (foods?.count)!-1 {
                        let food_id = foods?[i]["foodid"] as! String
                        let food_resid = foods?[i]["resid"] as! String
                        let food_name = foods?[i]["foodname"] as! String
                        let food_image = foods?[i]["foodimage"] as! String
                        let food_description = foods?[i]["fooddescription"] as! String
                        let food_needdes = foods?[i]["foodneeddes"] as! String
                        let food_status = foods?[i]["foodstatus"] as! String
                        let aaaaa = foods?[i]["count"]
                        print(aaaaa!)
                        let food_favorite = "\(aaaaa!)"
                        
                        let res_name = foods?[i]["resname"] as! String
                        let res_pin = foods?[i]["respin"] as! String
                        let res_image = foods?[i]["resimage"] as! String
                        let res_logo = foods?[i]["reslogo"] as! String
                        let res_mobile = foods?[i]["resmobile"] as! String
                        let res_address = foods?[i]["resaddress"] as! String
                        let res_position = foods?[i]["resposition"] as! String
                        let res_opentime = foods?[i]["resopentime"] as! String
                        let res_description = foods?[i]["resdescription"] as! String
                        
                        if food_status == "set"{
                            let specialcell = Food(id: food_id, resid: food_resid, name: food_name, image: food_image, description: food_description, needdescription: food_needdes, favorite: food_favorite, coupon: "0")
                            self.specialfoods.append(specialcell)
                        }
                        let foodcell = Food(id: food_id, resid: food_resid, name: food_name, image: food_image, description: food_description, needdescription: food_needdes, favorite: food_favorite, coupon: "0")
                        self.allfoods.append(foodcell)
                        
                        let restaurant_cell = Restaurant(id: food_resid, name: res_name, pin: res_pin, image: res_image, logo: res_logo, address: res_address, position: res_position, disweight: 0, mobile: res_mobile, opentime: res_opentime, description: res_description, coupon: "0" )
                        self.allres.append(restaurant_cell)
                        self.collectionView.delegate = self
                        self.collectionView.dataSource = self
                        self.collectionview1.delegate = self
                        self.collectionview1.dataSource = self
                    }
                    self.slideshowready()
                    self.collectionView.reloadData()
                    self.collectionview1.reloadData()
                    
                    self.spinnerView.endRefreshing()
                    
                }
            }
        }
    }
    
    func slideshowready(){
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        restaurantImg.pageIndicator = pageControl
        restaurantImg.activityIndicator = DefaultActivityIndicator()
        restaurantImg.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .customBottom(padding: 40))
        
        
//        inputSource.append(AlamofireSource(urlString: "https://h4x11elir13k9pit7gbc4sic-wpengine.netdna-ssl.com/wp-content/uploads/2018/09/Like-Ad-Example-min.jpg")!)
        restaurantImg.contentScaleMode = UIViewContentMode.scaleAspectFill
//        restaurantImg.contentScaleMode = UIViewContentMode.scaleToFill
        restaurantImg.setImageInputs(inputSource)
    }
    func collectionviewReady(){
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
       
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.reloadData()
        
        collectionview1.decelerationRate = UIScrollView.DecelerationRate.fast
        if let layout1 = collectionview1.collectionViewLayout as? UICollectionViewFlowLayout {
            layout1.scrollDirection = .horizontal
        }
        collectionview1.reloadData()
    }
    
    func initNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(showMenuButton(notification:)), name: .showMenuButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMenuButton(notification:)), name: .hideMenuButton, object: nil)
    }
    
    @IBAction func goRestaurantBtn(_ sender: Any) {
        restaurantVC = self.storyboard?.instantiateViewController(withIdentifier: "restaurantVC") as? RestaurantVC
        self.present(restaurantVC, animated: true, completion: nil)
    }
//    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
//        restaurantVC = self.storyboard?.instantiateViewController(withIdentifier: "restaurantVC") as? RestaurantVC
//        self.present(restaurantVC, animated: true, completion: nil)
//    }
//
    @IBAction func menuBtnClick(_ sender: UIButton) {
        sideMenuController?.revealMenu()
    }
    
    // Notification Center
    @objc func showMenuButton(notification: NSNotification) {
        sidebarBtn.isHidden = false
    }

    @objc func hideMenuButton(notification: NSNotification) {
        sidebarBtn.isHidden = true
    }

}

extension MainPageVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Cell #\(indexPath.row)")
        let  OneRes: Restaurant
        OneRes = allres[indexPath.row]
        let OneFood: Food
        OneFood = allfoods[indexPath.row]
        
        if (collectionView.tag == 100){
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
            Defaults.save(OneFood.favorite, with: Defaults.FOODFAV_KEY)
            
            foodVC = self.storyboard?.instantiateViewController(withIdentifier: "foodVC") as? FoodVC
            self.present(foodVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(foodVC, animated: true)
        }else{
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
            Defaults.save(OneFood.favorite, with: Defaults.FOODFAV_KEY)
            
            foodVC = self.storyboard?.instantiateViewController(withIdentifier: "foodVC") as? FoodVC
            self.present(foodVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(foodVC, animated: true)
        }
    }
}

extension MainPageVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 100) {
            let count = allfoods.count
            if count>5{
                return 5
            }
            else{
                return count
            }
        }else {
            let count = specialfoods.count
            if count>5{
                return 5
            }
            else{
                return count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "OptionViewCell"), for: indexPath) as! OptionViewCell
        let food : Food
       
        if (collectionView.tag == 100){
            food = allfoods[indexPath.row]
            cell.foodImg.layer.borderWidth = 1
            cell.foodImg.layer.masksToBounds = false
            cell.foodImg.layer.borderColor = UIColor.white.cgColor
            cell.foodImg.layer.cornerRadius = cell.foodImg.frame.height * 0.03
            cell.foodImg.clipsToBounds = true
            let ImgUrl = Global.imageUrl + food.image
            cell.foodImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
            cell.foodTitle.text = food.name
        }
        else {
            food = specialfoods[indexPath.row]
            cell.foodImg.layer.borderWidth = 1
            cell.foodImg.layer.masksToBounds = false
            cell.foodImg.layer.borderColor = UIColor.white.cgColor
            cell.foodImg.layer.cornerRadius = cell.foodImg.frame.height * 0.03
            cell.foodImg.clipsToBounds = true
            let ImgUrl = Global.imageUrl + food.image
            cell.foodImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
            cell.foodTitle.text = food.name
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height * 0.9, height: collectionView.bounds.height * 0.9)
    }
}
