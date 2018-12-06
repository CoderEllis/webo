//
//  textViewViewController.swift
//  wobo
//
//  Created by Soul Ai on 5/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import UIKit

class textViewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func jump(_ sender: Any) {
        let ui = UIViewController()
        ui.hidesBottomBarWhenPushed = true
        ui.view.backgroundColor = UIColor.cyan
        navigationController?.pushViewController(ui, animated: true)
        
    }
}
