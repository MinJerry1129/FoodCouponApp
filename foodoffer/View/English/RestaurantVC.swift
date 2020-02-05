//
//  RestaurantVC.swift
//  foodoffer
//
//  Created by Admin on 7/15/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Toaster
import Alamofire
import SDWebImage
import JTMaterialSpinner
class RestaurantVC: UIViewController, CLLocationManagerDelegate   {
    var restaurantoneVC: RestaurantOneVC!
    @IBOutlet weak var btnpostion1: UIButton!
    @IBOutlet weak var btnsort1: UIButton!
    @IBOutlet weak var btnsort: UIButton!
    @IBOutlet weak var btnpostion: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var spinnerView = JTMaterialSpinner()
    var i = 0
    var filteredRestaurant = [Restaurant]()
    var sortrestaurant = [Restaurant]()
    var position_latitude = ""
    var position_longitude = ""
    let searchController = UISearchController(searchResultsController: nil)
    let locationManager = CLLocationManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        i = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
      
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.init(red: 121/255, green: 190/255, blue: 72/255, alpha: 1)
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
   
    func getdata(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        filteredRestaurant = []
        let parameters: Parameters = ["userid": Defaults.getNameAndValue(Defaults.USERID_KEY)]
        Alamofire.request(Global.baseUrl + "igetrestaurant.php", method: .post, parameters: parameters).responseJSON{ returnValue in
            print(returnValue)
            if let value = returnValue.value as? [String: AnyObject] {
                let status = value["status"] as! String
                if status == "ok" {
                    let restaurants = value["restaurant"] as? [[String: Any]]
                    for i in 0 ... (restaurants?.count)!-1 {
                        let res_id = restaurants?[i]["id"] as! String
                        print (res_id)
                        let res_name = restaurants?[i]["name"] as! String
                        let res_pin = restaurants?[i]["pin"] as! String
                        let res_image = restaurants?[i]["image"] as! String
                        let res_logo = restaurants?[i]["logo"] as! String
                        let res_address = restaurants?[i]["address"] as! String
                        let res_position = restaurants?[i]["position"] as! String
                        let res_mobile = restaurants?[i]["mobile"] as! String
                        let res_opentime = restaurants?[i]["opentime"] as! String
                        let res_description = restaurants?[i]["description"] as! String
                        let res_coupon = restaurants?[i]["coupon"] as! String
                        let position = restaurants?[i]["position"] as! String
                        let check = position.components(separatedBy: ",")
                        let position2_lat = Double(check[0])
                        let position2_lon = Double(check[1])
                        let position1_lat = Double(self.position_latitude)
                        let position1_lon = Double(self.position_longitude)
                        let res_disweight = self.distance(lat1: Double(position1_lat!), lon1: Double(position1_lon!), lat2: Double(position2_lat!), lon2: Double(position2_lon!), unit: "K")
                        let restaurant_cell = Restaurant(id: res_id, name: res_name, pin: res_pin, image: res_image, logo: res_logo, address: res_address, position: res_position, disweight: Int(res_disweight), mobile: res_mobile, opentime: res_opentime, description: res_description, coupon: res_coupon )
                        self.filteredRestaurant.append(restaurant_cell)
                    }
                    print("aaaaa")
                    self.sortrestaurant = self.filteredRestaurant
                    self.sortrestaurant.sort() {$0.disweight < $1.disweight }
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                    self.spinnerView.endRefreshing()
                }else{
                    Toast(text: "No Restaurant").show()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else
        {
            return
            
        }
        position_latitude = "\(locValue.latitude)"
        position_longitude = "\(locValue.longitude)"        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        if(i == 0){
            getdata()
            i = i + 1
        }
        
    }
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been denied access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to submit offline report you need to enable your location services.",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    func deg2rad(deg:Double) -> Double {
        return deg * M_PI / 180
    }

    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / M_PI
    }

    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
    
    private func filterFootballers(for searchText: String) {
        filteredRestaurant = sortrestaurant.filter { player in
            return player.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }

    @IBAction func btnSort(_ sender: Any) {
        btnsort1.isHidden = false
        btnsort.isHidden = true
        btnpostion.isHidden = true
        btnpostion1.isHidden = false
        filterList_name()
    }
    
    @IBAction func btnPosition(_ sender: Any) {
        btnsort1.isHidden = true
        btnsort.isHidden = false
        btnpostion.isHidden = false
        btnpostion1.isHidden = true
        filterList_distance()
        
        
        
    }
    func filterList_distance() { // should probably be called sort and not filter
        sortrestaurant.sort() { $0.disweight < $1.disweight } // sort the fruit by name
        tableView.reloadData()
    }
    func filterList_name() { // should probably be called sort and not filter
        sortrestaurant.sort() { $0.name < $1.name } // sort the fruit by name
        tableView.reloadData()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension RestaurantVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredRestaurant.count
        }
        return sortrestaurant.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "cell"), for: indexPath) as! RestaurantViewCell
        let footballer: Restaurant
        if searchController.isActive && searchController.searchBar.text != "" {
            footballer = filteredRestaurant[indexPath.row]
        } else {
            footballer = sortrestaurant[indexPath.row]
        }
        
        cell.resImg.layer.borderWidth = 1
        cell.resImg.layer.masksToBounds = false
        cell.resImg.layer.borderColor = UIColor.gray.cgColor
        cell.resImg.layer.cornerRadius = 50*0.85
        cell.resImg.clipsToBounds = true
        print(footballer.logo)
        let imgUrl = Global.imageUrl + footballer.logo
        cell.resImg.sd_setImage(with: URL(string: imgUrl), completed: nil)
        cell.resName.text = footballer.name
        cell.resPosition.text = footballer.address
        cell.resDistance.text = "\(footballer.disweight)" + " km"
        cell.resCoupon.text = footballer.coupon
        
        
//        cell.textLabel?.text = footballer.name
//        cell.detailTextLabel?.text = footballer.league
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        let OneRes: Restaurant
        if searchController.isActive && searchController.searchBar.text != "" {
            OneRes = filteredRestaurant[indexPath.row]
        } else {
            OneRes = sortrestaurant[indexPath.row]
        }
        searchController.isActive = false
        let disweight_str = "\(OneRes.disweight)"
        let user_position = position_latitude + "," + position_longitude
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
        Defaults.save(user_position, with: Defaults.USERPOSITION_KEY)
        print(disweight_str)
        restaurantoneVC = self.storyboard?.instantiateViewController(withIdentifier: "restaurantoneVC") as? RestaurantOneVC
        self.present(restaurantoneVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension RestaurantVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterFootballers(for: searchController.searchBar.text ?? "")
    }
}
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
