//
//  CAAutoDeleteViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAAutoDeleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var titleArray = [String]()
    var checkBoxArray = [CALibraryInfo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        //Register Cell
        self.tableView.register(UINib(nibName: "CAFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "CAFilterTableViewCellID")
        titleArray = ["Auto weekly/monthly/yearly download for heard/read news, documents or presentations.", "Auto weekly/monthly/yearly download for unheard/unread news, documents or presentations.", "No auto-delete."]
        self.tableView.estimatedRowHeight = 45.0
        let prefValue = NSUSERDEFAULT.integer(forKey: "deletePreference")

        //Add modal objects in Array
        for index in 0...2 {
            let tempInfo = CALibraryInfo()
            tempInfo.isSelect = (prefValue == index+1) ? true : false
            checkBoxArray.append(tempInfo)
        }
    }
    
    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CAFilterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CAFilterTableViewCellID") as! CAFilterTableViewCell
        let obj = checkBoxArray[indexPath.row]
        cell.checkBoxButton.tag = indexPath.row+100
        cell.checkBoxButton.isSelected = obj.isSelect
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
        for obj in checkBoxArray {
            if obj.isSelect == true {
                isSelect = true
                break
            }
        }
        
        if isSelect {
            _ = AlertController.alert("", message: "Delete preferences updated successfully.", controller: self, buttons: ["OK"], tapBlock: { (Action, index) in
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            _ = AlertController.alert(select_AnyOption)
        }
    }
    
    //MARK:- Selector Method
    @objc func checkBoxAction(sender: UIButton) {
        for obj in checkBoxArray {
            obj.isSelect = false
        }
        let obj = checkBoxArray[sender.tag-100]
        obj.isSelect = !obj.isSelect
        
        NSUSERDEFAULT.set(sender.tag-99, forKey: "deletePreference")
        
        self.tableView.reloadData()
    }

    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
