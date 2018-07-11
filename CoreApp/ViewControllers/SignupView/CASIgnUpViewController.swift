//
//  CASIgnUpViewController.swift
//  CoreApplication
//
//  Created by apple on 4/19/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class CASIgnUpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var signUpInfo = CAUserInfo()
    var titleArray = [String]()
    var checkBoxArray = [CAUserInfo]()
    var isFromSocial = Bool()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var footerView: UIView!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        
        //print(UIDevice.current.identifierForVendor!.uuidString)

        //Register Cell
        self.tableView.register(UINib(nibName: "CASignupTableViewCell", bundle: nil), forCellReuseIdentifier: "CASignupTableViewCell")
        self.tableView.register(UINib(nibName: "CACheckBoxTableViewCell", bundle: nil), forCellReuseIdentifier: "CACheckBoxTableViewCell")
        
        self.tableView.estimatedRowHeight = 55.0
        self.tableView.tableFooterView = self.footerView

        titleArray = ["I would like to see in the app updates about Supply Chain Security.", "I would like to see in the app updates about Trade Facilitation.", "I would like to receive the Weekly Digest by email.", "I would like to receive the CORE Monthly by email.", "I would like the app to automatically download the weekly information in my device and delete the old one.", "I have read and accept the terms and conditions for the usage of this APP."]
        
        //Add modal objects in Array
        for _ in 0...5 {
            let tempInfo = CAUserInfo()
            tempInfo.isSelect = false
            checkBoxArray.append(tempInfo)
        }
    }
    
    func validateField()-> Bool  {
        let obj = checkBoxArray.last
        
        var isSelect: Bool = false
        for index in 0..<2 {
            let obj = checkBoxArray[index]
            if obj.isSelect == true {
                isSelect = true
                break
            }
        }
        
        if signUpInfo.userName == "" {
            _ = AlertController.alert(blank_Email)
        } else if !signUpInfo.userName.isEmail() {
            _ = AlertController.alert(valid_Email)
        } else if signUpInfo.password == "" {
            _ = AlertController.alert(blank_Password)
        } else if signUpInfo.password.length < 8 || !signUpInfo.password.containsFourLettersAndTwoDigits() {
            _ = AlertController.alert(valid_PasswordMatch)
        }
//        else if !signUpInfo.password.containsFourLettersAndTwoDigits() {
//            _ = AlertController.alert(valid_PasswordMatch)
//        }
        else if signUpInfo.country == "" {
            _ = AlertController.alert(blank_Country)
        } else if !(isSelect) {
            _ = AlertController.alert(select_AnyFromTwo)
        } else if !(obj?.isSelect)! {
            _ = AlertController.alert(terms_Alert)
        } else {
            return true
        }
        return false
    }
    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CASignupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CASignupTableViewCell") as! CASignupTableViewCell
        let checkBoxCell: CACheckBoxTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CACheckBoxTableViewCell") as! CACheckBoxTableViewCell

        if indexPath.row < 3 {
            cell.signupTextField.delegate = self
            cell.dropDownImageView.isHidden = true
            cell.signupButton.isHidden = true
            cell.signupTextField.isUserInteractionEnabled = true
            cell.signupTextField.tag = indexPath.row+100
            switch indexPath.row {
            case 0:
                cell.signupTextField.text = signUpInfo.userName
                cell.iconImageView.image = UIImage(named: "emailBlue")
                cell.signupTextField.placeholder = "Email ID"
                cell.signupTextField.returnKeyType = .next
                cell.signupTextField.keyboardType = .emailAddress
                cell.signupTextField.isSecureTextEntry = false
            case 1:
                cell.signupTextField.text = signUpInfo.password
                cell.iconImageView.image = UIImage(named: "password")
                cell.signupTextField.placeholder = "Password"
                cell.signupTextField.returnKeyType = .done
                cell.signupTextField.keyboardType = .default
                cell.signupTextField.isSecureTextEntry = true
            case 2:
                cell.signupTextField.text = signUpInfo.country
                cell.iconImageView.image = UIImage(named: "country")
                cell.dropDownImageView.isHidden = false
                cell.signupButton.isHidden = false
                cell.signupTextField.placeholder = "Select Country"
                cell.signupTextField.isUserInteractionEnabled = true
            default:
                break
            }
            cell.signupButton.addTarget(self, action: #selector(selectCountryAction), for: .touchUpInside)

            return cell
        } else {
            if indexPath.row == 8 {
                checkBoxCell.termsButton.isHidden = false
            } else {
                checkBoxCell.termsButton.isHidden = true
            }
            let obj = checkBoxArray[indexPath.row-3]
            checkBoxCell.checkButton.tag = indexPath.row+100
            checkBoxCell.checkButton.isSelected = obj.isSelect
            checkBoxCell.cellTitleLabel.text = titleArray[indexPath.row-3]
            checkBoxCell.termsButton.addTarget(self, action: #selector(termsButtonAction), for: .touchUpInside)
            checkBoxCell.checkButton.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)

            return checkBoxCell
        }
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row > 2 {
//            let obj = checkBoxArray[indexPath.row-3]
//            obj.isSelect = !obj.isSelect
//            self.tableView.reloadData()
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < 3 {
            return 65.0
        }
        return UITableViewAutomaticDimension
    }
    
    
    //MARK: UITextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let string = textField.text?.trimWhiteSpace()
        
        if textField.tag == 100 {
            signUpInfo.userName = string!
        } else {
            signUpInfo.password = string!
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder {
            if textField.textInputMode?.primaryLanguage == nil || textField.textInputMode?.primaryLanguage == "emoji" {
                return false
            }
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if textField.tag == 100 && str.length > 60 {
            return false
        } else if textField.tag == 101 && str.length > 12 {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            let kTextField = self.view.viewWithTag(textField.tag+1) as? UITextField
            kTextField?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: Selector Method
    @objc func selectCountryAction() {
        self.view.endEditing(true)
        
        let values = ["Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia (Hrvatska)", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "France Metropolitan", "French Guiana", "French Polynesia", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard and Mc Donald Islands", "Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran (Islamic Republic of)", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan", "Lao, People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia, The Former Yugoslav Republic of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of", "Monaco", "Mongolia", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Seychelles", "Sierra Leone", "Singapore", "Slovakia (Slovak Republic)", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "St. Helena", "St. Pierre and Miquelon", "Sudan", "Suriname", "Svalbard and Jan Mayen Islands", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Virgin Islands (British)", "Virgin Islands (U.S.)", "Wallis and Futuna Islands", "Western Sahara", "Yemen", "Yugoslavia", "Zambia", "Zimbabwe"]
        DPPickerManager.shared.showPicker(title: "Select Country", selected: (signUpInfo.country == "") ? "Switzerland" : signUpInfo.country, strings: values) { (value, index, cancel) in
            if !cancel {
                // TODO: you code here
                debugPrint(value as Any)
                self.signUpInfo.country = value!
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func termsButtonAction() {
        self.view.endEditing(true)
        let aboutVC = CAAboutViewController()
        aboutVC.isFromTerms = true
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @objc func checkBoxAction(sender: UIButton) {
        let obj = checkBoxArray[sender.tag-103]
        obj.isSelect = !obj.isSelect
        self.tableView.reloadData()
    }
    
    //MARK: UIButton Action Method
    @IBAction func signinButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if validateField() {
            callApiForSignUp()
        }
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        self.signUpInfo = CAUserInfo()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Call API
    func callApiForSignUp()
    {
        let dict = NSMutableDictionary()
        dict[pEmail] = signUpInfo.userName
        dict[pPassword] = signUpInfo.password
        dict[pCountry] = signUpInfo.country
        dict[pDeviceId] = "\(UIDevice.current.identifierForVendor!.uuidString)"
        dict[pConfirmed] = isFromSocial ? "1" : "0"

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
            case 5:
                dict[pTerms] = obj.isSelect ? "1" : "0"

            default:
                break
            }
        }

        CAServiceHelper.request(dict as! Dictionary<String, AnyObject>, method: .post, apiName: pSignUp, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200) {
                        
                        let dataDict = response.validatedValue("data", expected: NSDictionary())as! Dictionary<String,AnyObject>
                        
                        //Add Data into database
                        let realm = try! Realm()

                        let user = UserClass()
                        user.userEmail = self.signUpInfo.userName
                        user.userToken = dataDict.validatedValue("token", expected: ""as AnyObject)as! String
                        
                        let obj = self.checkBoxArray[self.checkBoxArray.count-1]
                        NSUSERDEFAULT.set(obj.isSelect ? true : false, forKey: "autoDownloadPrefrence")

                        try! realm.write {
                            realm.add(user)
                            
                            if self.isFromSocial {
                                NSUSERDEFAULT.set(dataDict.validatedValue("token", expected: ""as AnyObject)as! String,  forKey: "token")
                                NSUSERDEFAULT.set(self.signUpInfo.userName, forKey: "loginUserEmail")
                                NSUSERDEFAULT.set(dataDict.validatedValue("delete_prefrence_time", expected: ""as AnyObject)as! String,  forKey: "delete_prefrence_time")


                                NSUSERDEFAULT.set("", forKey: "emailId")
                                NSUSERDEFAULT.set("", forKey: "password")
                                NSUSERDEFAULT.set(false, forKey: "isRemember")
                                
                                
                                let homeVC = CAHomeBaseViewController()
                                homeVC.isRestoredataBase = (dataDict.validatedValue("device_status", expected: ""as AnyObject)as! String) == "0" ? false : true
                                self.navigationController?.pushViewController(homeVC, animated: false)
                            } else {
                                let successVC = CASuccessViewController()
                                self.navigationController?.pushViewController(successVC, animated: true)
                            }
                            self.signUpInfo = CAUserInfo()
                        }
                        NSUSERDEFAULT.synchronize()
                    }
                    else {
                     let str = (response.validatedValue("message", expected: Dictionary<String, Any>() as AnyObject) as! Dictionary<String, Any>).validatedValue("email", expected: [] as AnyObject) as! [String]
                        _ = AlertController.alert("", message: str.first!)
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
