//
//  CAChangeEmailViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAChangeEmailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var changePassInfoInfo = CAUserInfo()

    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        //Register Cell
        self.tableView.register(UINib(nibName: "CASignupTableViewCell", bundle: nil), forCellReuseIdentifier: "CASignupTableViewCell")
        //Add header view
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableView.alwaysBounceVertical = false
    }
    
    func validateField()-> Bool  {
//        if changePassInfoInfo.oldEmailID == "" {
//            _ = AlertController.alert(blank_OldEmail)
//        } else if !changePassInfoInfo.oldEmailID.isEmail() {
//            _ = AlertController.alert(valid_OldEmail)
//        } else if changePassInfoInfo.emailID == "" {
//            _ = AlertController.alert(blank_newEmail)
//        } else if !changePassInfoInfo.emailID.isEmail() {
//            _ = AlertController.alert(valid_newEmail)
//        } else {
//            return true
//        }
        if changePassInfoInfo.oldPassword == "" {
            _ = AlertController.alert(blank_OldPass)
        } else if changePassInfoInfo.oldPassword.length < 8 || !changePassInfoInfo.oldPassword.containsFourLettersAndTwoDigits() {
            _ = AlertController.alert(valid_OldPass)
        } else if changePassInfoInfo.password == "" {
            _ = AlertController.alert(blank_NewPassword)
        } else if changePassInfoInfo.password.length < 8 || !changePassInfoInfo.password.containsFourLettersAndTwoDigits() {
            _ = AlertController.alert(valid_NewPassword)
        }
//        else if !changePassInfoInfo.password.containsFourLettersAndTwoDigits() {
//            _ = AlertController.alert(valid_PasswordMatch)
//        }
        else if changePassInfoInfo.confirmPassword == "" {
            _ = AlertController.alert(blank_ConfirmPassword)
        } else if changePassInfoInfo.password != changePassInfoInfo.confirmPassword {
            _ = AlertController.alert(password_Match)
        } else {
            return true
        }
        
        return false
    }
    
    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CASignupTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CASignupTableViewCell") as! CASignupTableViewCell
        cell.signupTextField.tag = indexPath.row + 100
        cell.signupButton.isHidden = true
        cell.dropDownImageView.isHidden = true
        cell.signupTextField.delegate = self
        
        cell.signupTextField.isSecureTextEntry = true
        cell.iconImageView.image = UIImage(named: "password")
        cell.signupTextField.returnKeyType = .next

//        cell.signupTextField.keyboardType = .emailAddress
        cell.iconImageView.image = UIImage(named: "password")

        if indexPath.row == 0 {
          //  cell.signupTextField.placeholder = "Old Email ID"
            cell.signupTextField.placeholder = "Old Password"
        } else if indexPath.row == 1 {
            cell.signupTextField.placeholder = "New Password"
        } else {
            cell.iconImageView.image = UIImage(named: "confirmPass")
            cell.signupTextField.returnKeyType = .done
            cell.signupTextField.placeholder = "Confirm New Password"
        }
        return cell
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    
    //MARK: UITextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let string = textField.text?.trimWhiteSpace()
        
        if textField.tag == 100 {
            changePassInfoInfo.oldPassword = string!
        } else if textField.tag == 101 {
            changePassInfoInfo.password = string!
        } else {
            changePassInfoInfo.confirmPassword = string!
        }
        
//        if textField.tag == 100 {
//            changePassInfoInfo.oldEmailID = string!
//        } else {
//            changePassInfoInfo.emailID = string!
//        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder {
            if textField.textInputMode?.primaryLanguage == nil || textField.textInputMode?.primaryLanguage == "emoji" {
                return false
            }
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if str.length > 12 {
            return false
        }
//        else if textField.tag == 1 && str.length > 16 {
//            return false
//        }
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

    
    //MARK: UIButton Action Method
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeEmailButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if validateField() {
            callApiForChangePassword()
        }
    }
    
    //MARK: Call API
    func callApiForChangePassword()
    {
        let dict = NSMutableDictionary()
        dict[pCurrentPassword] = changePassInfoInfo.oldPassword
        dict[pNewUpdatePassword] = changePassInfoInfo.password
        dict[pConfirmPassword] = changePassInfoInfo.password

        CAServiceHelper.request(dict as! Dictionary<String, AnyObject>, method: .post, apiName: pChangePass, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    if(status == 201 || status == 200){
                        _ = AlertController.alert("", message: response.validatedValue("message", expected: "" as AnyObject) as! String, controller: self, buttons: ["OK"], tapBlock: { (Action, index) in
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

    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
