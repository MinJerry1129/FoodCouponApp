//
//  ViewController.swift
//  foodoffer
//
//  Created by Admin on 7/13/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Toaster
import JTMaterialSpinner
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
         let sel_segu = Defaults.getNameAndValue(Defaults.SETLANGUAGE_KEY)
        if(sel_segu == "english"){
            self.performSegue(withIdentifier: "english", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "arabic", sender: self)
        }
    }
    
}

