//
//  ELVisitorViewController.swift
//  wobo
//
//  Created by Soul Ai on 8/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class ELVisitorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //"http://app.u17.com/v3/appV3_3/ios/phone/rank/list"
        
        NetworkTools.shareInstance.getRequest(url: "http://httpbin.org/get", param: ["name": "el"], successBlock: { (response) in
            print("resopnse==========\(response)")
        }, failure: { (error) in
            print("error===========\(error)")
        }) { (neterror) in
            print("neterror==========\(neterror)")
        }
        
    }

}
