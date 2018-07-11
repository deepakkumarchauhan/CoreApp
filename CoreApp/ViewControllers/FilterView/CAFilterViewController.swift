//
//  CAFilterViewController.swift
//  CoreApp
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
protocol FilterProtocol {
    func filterList(strValue: String)
}

class CAFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var delegate: FilterProtocol?
    
    var titleArray = [String]()
    var checkBoxArray = [CALibraryInfo]()
    var fromWhere = String()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: CustomTextField!
    @IBOutlet weak var viewVerticalConstraint: NSLayoutConstraint!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        //Register Cell
        self.tableView.register(UINib(nibName: "CAFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "CAFilterTableViewCellID")
        titleArray = ["Show All", "Show only this week", "Show only this month", "Show only this year", "Show only downloaded", "Show only undownloaded"]
        
        //Add modal objects in Array
        for index in 0...5 {
            let tempInfo = CALibraryInfo()
            if fromWhere == "news" {
                
//                if index == 0 {
//                    tempInfo.isSelect =  "\(NSUSERDEFAULT.value(forKey: "newsShowAllFilter") ?? "0")" == "0" ? false : true
//                } else if index == 1 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "newsThisWeekFilter") ?? "0")" == "0" ? false : true
//                } else if index == 2 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "newsThisMonthsFilter") ?? "0")" == "0" ? false : true
//                } else if index == 3 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "newsThisYearsFilter") ?? "0")" == "0" ? false : true
//                } else if index == 4 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "newsDownloadFilter") ?? "0")" == "0" ? false : true
//                } else {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "newsunDownloadFilter") ?? "0")" == "0" ? false : true
//                }
//
                tempInfo.isSelect = (NSUSERDEFAULT.integer(forKey: "newsFilter") == index) ? true : false
            } else if fromWhere == "presentation" {
                
//                if index == 0 {
//                    tempInfo.isSelect =  "\(NSUSERDEFAULT.value(forKey: "presentationShowAllFilter") ?? "0")" == "0" ? false : true
//                } else if index == 1 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "presentationThisWeekFilter") ?? "0")" == "0" ? false : true
//                } else if index == 2 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "presentationThisMonthsFilter") ?? "0")" == "0" ? false : true
//                } else if index == 3 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "presentationThisYearsFilter") ?? "0")" == "0" ? false : true
//                } else if index == 4 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "presentationDownloadFilter") ?? "0")" == "0" ? false : true
//                } else {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "presentationUndownloadFilter") ?? "0")" == "0" ? false : true
//                }
                
                tempInfo.isSelect = (NSUSERDEFAULT.integer(forKey: "presentationFilter") == index) ? true : false
            } else {
                
//                if index == 0 {
//                    tempInfo.isSelect =  "\(NSUSERDEFAULT.value(forKey: "documentsShowAllFilter") ?? "0")" == "0" ? false : true
//                } else if index == 1 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "documentsThisWeekFilter") ?? "0")" == "0" ? false : true
//                } else if index == 2 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "documentsThisMonthsFilter") ?? "0")" == "0" ? false : true
//                } else if index == 3 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "documentsThisYearsFilter") ?? "0")" == "0" ? false : true
//                } else if index == 4 {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "documentsDownloadFilter") ?? "0")" == "0" ? false : true
//                } else {
//                    tempInfo.isSelect = "\(NSUSERDEFAULT.value(forKey: "documentsUndownloadFilter") ?? "0")" == "0" ? false : true
//                }

                tempInfo.isSelect = (NSUSERDEFAULT.integer(forKey: "documentsFilter") == index) ? true : false
            }
            checkBoxArray.append(tempInfo)
        }
    }
    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    //MARK: UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.viewVerticalConstraint.constant = -80.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.viewVerticalConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
       // let string = textField.text?.trimWhiteSpace()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder {
            if textField.textInputMode?.primaryLanguage == nil || textField.textInputMode?.primaryLanguage == "emoji" {
                return false
            }
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if str.length > 60 {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    
    //MARK: UIButton Action
    @IBAction func cancleButtonAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func applyButtonAction(_ sender: UIButton) {
        var isSelect: Bool = false
        for index in 0..<checkBoxArray.count {
            let obj = checkBoxArray[index]
            if obj.isSelect == true {
                isSelect = true
                break
            }
        }

        
//        for index in 0..<checkBoxArray.count {
//            let obj = checkBoxArray[index]
//            if obj.isSelect == true {
//                isSelect = true
//                if index == 0 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("1", forKey: "newsShowAllFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("1", forKey: "documentsShowAllFilter")
//                    } else {
//                        NSUSERDEFAULT.set("1", forKey: "presentationShowAllFilter")
//                    }
//                } else if index == 1 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("1", forKey: "newsThisWeekFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("1", forKey: "documentsThisWeekFilter")
//                    } else {
//                        NSUSERDEFAULT.set("1", forKey: "presentationThisWeekFilter")
//                    }
//                } else if index == 2 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("1", forKey: "newsThisMonthsFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("1", forKey: "documentsThisMonthsFilter")
//                    } else {
//                        NSUSERDEFAULT.set("1", forKey: "presentationThisMonthsFilter")
//                    }
//                } else if index == 3 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("1", forKey: "newsThisYearsFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("1", forKey: "documentsThisYearsFilter")
//                    } else {
//                        NSUSERDEFAULT.set("1", forKey: "presentationThisYearsFilter")
//                    }
//                } else if index == 4 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("1", forKey: "newsDownloadFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("1", forKey: "documentsDownloadFilter")
//                    } else {
//                        NSUSERDEFAULT.set("1", forKey: "presentationDownloadFilter")
//                    }
//                } else if index == 5 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("1", forKey: "newsunDownloadFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("1", forKey: "documentsUndownloadFilter")
//                    } else {
//                        NSUSERDEFAULT.set("1", forKey: "presentationUndownloadFilter")
//                    }
//                }
//            } else {
//                if index == 0 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("0", forKey: "newsShowAllFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("0", forKey: "documentsShowAllFilter")
//                    } else {
//                        NSUSERDEFAULT.set("0", forKey: "presentationShowAllFilter")
//                    }
//                } else if index == 1 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("0", forKey: "newsThisWeekFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("0", forKey: "documentsThisWeekFilter")
//                    } else {
//                        NSUSERDEFAULT.set("0", forKey: "presentationThisWeekFilter")
//                    }
//                } else if index == 2 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("0", forKey: "newsThisMonthsFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("0", forKey: "documentsThisMonthsFilter")
//                    } else {
//                        NSUSERDEFAULT.set("0", forKey: "presentationThisMonthsFilter")
//                    }
//                } else if index == 3 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("0", forKey: "newsThisYearsFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("0", forKey: "documentsThisYearsFilter")
//                    } else {
//                        NSUSERDEFAULT.set("0", forKey: "presentationThisYearsFilter")
//                    }
//                } else if index == 4 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("0", forKey: "newsDownloadFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("0", forKey: "documentsDownloadFilter")
//                    } else {
//                        NSUSERDEFAULT.set("0", forKey: "presentationDownloadFilter")
//                    }
//                } else if index == 5 {
//                    if fromWhere == "news" {
//                        NSUSERDEFAULT.set("0", forKey: "newsunDownloadFilter")
//                    } else if fromWhere == "documents" {
//                        NSUSERDEFAULT.set("0", forKey: "documentsUndownloadFilter")
//                    } else {
//                        NSUSERDEFAULT.set("0", forKey: "presentationUndownloadFilter")
//                    }
//                }
//            }
//        }
        
        if isSelect {
            //let dict = ["searchValue": self.searchTextField.text ?? ""] as [String : Any]

            self.dismiss(animated: true) {
                
                self.delegate?.filterList(strValue: self.searchTextField.text!)
//
//                if self.fromWhere == "news" {
//                    self.delegate?.filterList(strValue: self.searchTextField.text!)
//                   //NotificationCenter.default.post(name: NSNotification.Name("newsApiCall"), object: dict)
//                } else if self.fromWhere == "documents" {
//                    NotificationCenter.default.post(name: NSNotification.Name("documentsApiCall"), object: dict)
//                } else {
//                    NotificationCenter.default.post(name: NSNotification.Name("presentationApiCall"), object: dict)
//
//                }
            }
        } else {
            _ = AlertController.alert(select_AnyFilter)
        }
    }
    
    //MARK:- Selector Method
    @objc func checkBoxAction(sender: UIButton) {
        for obj in checkBoxArray {
            obj.isSelect = false
        }
        
        if fromWhere == "news" {
            NSUSERDEFAULT.set(sender.tag-100, forKey: "newsFilter")
        } else if fromWhere == "documents" {
            NSUSERDEFAULT.set(sender.tag-100, forKey: "documentsFilter")
        } else {
            NSUSERDEFAULT.set(sender.tag-100, forKey: "presentationFilter")
        }
        
        let obj = checkBoxArray[sender.tag-100]
        obj.isSelect = !obj.isSelect
        self.tableView.reloadData()
        
    }

    //MARK:- Touch Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
