//
//  CASuccessViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CASuccessViewController: UIViewController {

    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: UIButton Action
    @IBAction func loginButtonAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
