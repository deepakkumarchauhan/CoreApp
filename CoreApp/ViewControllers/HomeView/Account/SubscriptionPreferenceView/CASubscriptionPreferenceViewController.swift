//
//  CASubscriptionPreferenceViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CASubscriptionPreferenceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var titleArray = [String]()
    var checkBoxArray = [CALibraryInfo]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        //Register Cell
        self.tableView.register(UINib(nibName: "CAFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "CAFilterTableViewCellID")
        titleArray = ["I would like to see in the app updates about Supply Chain Security.", "I would like to see in the app updates about Trade Facilitation.", "I would like to receive the Weekly Digest by email.", "I would like to receive the CORE Monthly by email.", "I would like the app to automatically download the weekly information in my device and delete the old one."]
        self.tableView.estimatedRowHeight = 45.0
        
        callApiToGetSubscription()
        
    }
    
    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkBoxArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CAFilterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CAFilterTableViewCellID") as! CAFilterTableViewCell
        let obj = checkBoxArray[indexPath.row]
        cell.checkBoxButton.isSelected = obj.isSelect
        if obj.isSelect {
            cell.checkBoxButton.setImage(UIImage(named: "checkBox"), for: .selected)
        } else {
            cell.checkBoxButton.setImage(UIImage(named: "emptyCheckBox"), for: .normal)
        }
        cell.checkBoxButton.tag = indexPath.row+100
        cell.cellTitleLabel.text = titleArray[indexPath.row]
        cell.checkBoxButton.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)
        return cell
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    //MARK: UIButton Action Method
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        var isSelect: Bool = false
        for index in 0..<2 {
            let obj = checkBoxArray[index]
            if obj.isSelect == true {
                isSelect = true
                break
            }
        }

        if isSelect {
            callApiForUpdate()
        } else {
            _ = AlertController.alert(select_AnyFromTwo)
        }
    }
    
//autoDownloadPrefrence
    //MARK: Call API
    func callApiToGetSubscription()
    {
        CAServiceHelper.request(Dictionary<String, Any>(), method: .get, apiName: pGetSubscription, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200) {
                        let dataDict = response.validatedValue("data", expected: NSDictionary())as! Dictionary<String,AnyObject>

                        //Add modal objects in Array
                         let tempInfo = CALibraryInfo()
                        tempInfo.isSelect = "\(dataDict[pSupplyChain] as! NSNumber)" == "1" ? true : false
                        self.checkBoxArray.append(tempInfo)
                        
                        let tempInfo1 = CALibraryInfo()
                        tempInfo1.isSelect = "\(dataDict[pTradeFaci] as! NSNumber)" == "1" ? true : false
                        self.checkBoxArray.append(tempInfo1)
                        
                        let tempInfo2 = CALibraryInfo()
                        tempInfo2.isSelect = "\(dataDict[pWeeklyDigest] as! NSNumber)" == "1" ? true : false
                        self.checkBoxArray.append(tempInfo2)
                        
                        let tempInfo3 = CALibraryInfo()
                        tempInfo3.isSelect = "\(dataDict[pCoreMonthly] as! NSNumber)" == "1" ? true : false
                        self.checkBoxArray.append(tempInfo3)
                        
                        let tempInfo4 = CALibraryInfo()
                        let isSel = NSUSERDEFAULT.bool(forKey: "autoDownloadPrefrence")
                        tempInfo4.isSelect = isSel
                        self.checkBoxArray.append(tempInfo4)
                        
                        self.submitButton.isHidden = false

                        self.tableView.reloadData()
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

    
    func callApiForUpdate()
    {
        let dict = NSMutableDictionary()
        for index in 0..<checkBoxArray.count {
            let obj = checkBoxArray[index]
            switch index {
            case 0:
                dict[pSupplyChain] = obj.isSelect ? "1" : "0"
            case 1:
                dict[pTradeFaci] = obj.isSelect ? "1" : "0"
            case 2:
                dict[pWeeklyDigest] = obj.isSelect ? "1" : "0"
            case 3:
                dict[pCoreMonthly] = obj.isSelect ? "1" : "0"
            case 4:
                dict[pAutomaticDownload] = obj.isSelect ? "1" : "0"
            default:
                break
            }
        }

        CAServiceHelper.request(dict as! [String : Any], method: .get, apiName: pSubscription, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        _ = AlertController.alert("", message: response.validatedValue("message", expected: "" as AnyObject) as! String, controller: self, buttons: ["OK"], tapBlock: { (Action, index) in
                            let obj = self.checkBoxArray[self.checkBoxArray.count-1]
                            NSUSERDEFAULT.set(obj.isSelect ? true : false, forKey: "autoDownloadPrefrence")

                            self.navigationController?.popViewController(animated: true)
                        })
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

    
    //MARK:- Selector Method
    @objc func checkBoxAction(sender: UIButton) {
        let obj = checkBoxArray[sender.tag-100]
        obj.isSelect = !obj.isSelect
        self.tableView.reloadData()
    }
    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
