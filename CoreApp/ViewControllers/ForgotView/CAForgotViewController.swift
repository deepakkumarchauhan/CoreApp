//
//  CAForgotViewController.swift
//  CoreApplication
//
//  Created by apple on 4/19/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAForgotViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: CustomTextField!
    
    var otpValue = String()
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: UIButton Action Method
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        
        self.view.endEditing(true)

        if otpValue == "" {
            _ = AlertController.alert(blank_Email)
        } else if !(otpValue.isEmail()) {
            _ = AlertController.alert(valid_Email)
        } else {
            callApiForForgotPassword()
        }
    }
    
    //MARK: UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        
        if SCREENWIDTH <= 320 {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.viewTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if SCREENWIDTH <= 320 {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.viewTopConstraint.constant = 36
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        otpValue = (textField.text?.trimWhiteSpace())!
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
    
    //MARK:- Touch Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK: Call API
    func callApiForForgotPassword()
    {
        let dict = NSMutableDictionary()
        dict[pEmail] = otpValue
        
        CAServiceHelper.request(dict as! Dictionary<String, AnyObject>, method: .post, apiName: pForgotPassword, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        
                        _ = AlertController.alert("", message: response.validatedValue("message", expected: "" as AnyObject) as! String, controller: self, buttons: ["OK"], tapBlock: { (Action, index) in
                            let resetVC = CAResetPasswordViewController()
                            self.navigationController?.pushViewController(resetVC, animated: true)
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
