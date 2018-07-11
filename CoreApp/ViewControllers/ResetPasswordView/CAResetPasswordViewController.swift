//
//  CAResetPasswordViewController.swift
//  CoreApp
//
//  Created by apple on 4/26/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAResetPasswordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var resetPassInfoInfo = CAUserInfo()
    
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
        self.tableView.alwaysBounceVertical = false
    }
    
    func validateField()-> Bool  {
        if resetPassInfoInfo.password == "" {
            _ = AlertController.alert(blank_NewPassword)
        } else if resetPassInfoInfo.password.length < 8 || !resetPassInfoInfo.password.containsFourLettersAndTwoDigits() {
            _ = AlertController.alert(valid_NewPassword)
        } else if resetPassInfoInfo.confirmPassword == "" {
            _ = AlertController.alert(blank_ConfirmPassword)
        } else if resetPassInfoInfo.confirmPassword != resetPassInfoInfo.password {
            _ = AlertController.alert(password_Match)
        } else if resetPassInfoInfo.otp == "" {
            _ = AlertController.alert(blank_OTP)
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
        cell.signupTextField.keyboardType = .emailAddress

        if indexPath.row == 0 {
            cell.signupTextField.placeholder = "New Password"
        } else if indexPath.row == 1 {
            cell.signupTextField.placeholder = "Confirm New Password"
        } else {
            cell.signupTextField.isSecureTextEntry = false
            cell.signupTextField.keyboardType = .numberPad
            cell.iconImageView.image = UIImage(named: "otp")
            cell.signupTextField.placeholder = "OTP"
        }
        return cell
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    
    //MARK: UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 102 {
            textField.inputAccessoryView = BTAppUtility.addToolBarOnView(self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let string = textField.text?.trimWhiteSpace()
        
        if textField.tag == 100 {
            resetPassInfoInfo.password = string!
        } else if textField.tag == 101 {
            resetPassInfoInfo.confirmPassword = string!
        } else {
            resetPassInfoInfo.otp = string!
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
        if str.length > 16 {
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
    
    
    //MARK: UIButton Action Method
    @IBAction func resetButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if validateField() {
            callApiForUpdatePassword()
        }
    }
    
    //MARK: Selector Method
    @objc func doneButtonAction() {
        self.view .endEditing(true)
    }
    
    @IBAction func backToForgotButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Call API
    func callApiForUpdatePassword()
    {
        let dict = NSMutableDictionary()
        dict[pPassword] = resetPassInfoInfo.password
        dict[pOTP] = resetPassInfoInfo.otp

        CAServiceHelper.request(dict as! Dictionary<String, AnyObject>, method: .post, apiName: pVarifyOtpForgotPass, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        _ = AlertController.alert("", message: response.validatedValue("message", expected: "" as AnyObject) as! String, controller: self, buttons: ["OK"], tapBlock: { (Action, index) in
                            self.navigationController?.popToRootViewController(animated: true)
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
