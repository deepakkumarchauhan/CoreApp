//
//  CAAccountViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var titleArray = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    //MARK: Custom Method
    func initialSetup()  {
        //Register Cell
        self.tableView.register(UINib(nibName: "CAAccountTableViewCell", bundle: nil), forCellReuseIdentifier: "CAAccountTableViewCellID")
        self.tableView.estimatedRowHeight = 58.0
        
        //Add Data to array
        titleArray = ["Subscription Preferences", "Download Content Preferences", "Auto Delete Preferences", "Change Password", "About the CORE Application"]
    }
    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CAAccountTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CAAccountTableViewCellID") as! CAAccountTableViewCell
        cell.arrowImageView.isHidden = false
        cell.cellSwitch.isHidden = true
        cell.cellSwitch.isOn = NSUSERDEFAULT.bool(forKey: "autoDownloadPrefrence")
        
        cell.cellSwitch.addTarget(self, action: #selector(toggleAction), for: .valueChanged)

        cell.cellTitleLabel.text = titleArray[indexPath.row]
        if indexPath.row == 1 {
            cell.cellSwitch.isHidden = false
            cell.arrowImageView.isHidden = true
        }
        return cell
    }
    
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let subscriptionVC = CASubscriptionPreferenceViewController()
            self.navigationController?.pushViewController(subscriptionVC, animated: true)
        case 2:
            let deleteSubVC = CAAutoDeleteViewController()
            self.navigationController?.pushViewController(deleteSubVC, animated: true)
        case 3:
            let changeEmailVC = CAChangeEmailViewController()
            self.navigationController?.pushViewController(changeEmailVC, animated: true)
        case 4:
            let aboutVC = CAAboutViewController()
            self.navigationController?.pushViewController(aboutVC, animated: true)

        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: UIButton Action Method
    @IBAction func disconnectButtonAction(_ sender: Any) {
        _ = AlertController.alert("", message: "Are you sure you want to disconnect?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
            if index == 0 {
                self.callApiForDisconnect()
            //    self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    //MARK: Selector Method
    @objc func toggleAction(sender: UISwitch) {
        NSUSERDEFAULT.set(sender.isOn, forKey: "autoDownloadPrefrence")
        self.tableView.reloadData()
    }
    
    
    //MARK: Call API
    func callApiForDisconnect()
    {
        CAServiceHelper.request(Dictionary<String, AnyObject>(), method: .post, apiName: pDisconnect, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        NSUSERDEFAULT.set(nil, forKey: "token")
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    else {
                        _ = AlertController.alert("", message: response.validatedValue("message", expected: "" as AnyObject) as! String)
                    }
                }
            }
            else {
                _ = AlertController.alert("", message: "\(error!.localizedDescription)")
            }
        }
    }

    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
