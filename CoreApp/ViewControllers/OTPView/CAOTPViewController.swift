//
//  CAOTPViewController.swift
//  CoreApp
//
//  Created by apple on 4/26/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAOTPViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var otpTextField: CustomTextField!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Custom Method
    func validateField()-> Bool  {
        if self.otpTextField.text?.trimWhiteSpace() == "" {
            _ = AlertController.alert(blank_OTP)
        } else if (self.otpTextField.text?.trimWhiteSpace().length)! <= 4 {
            _ = AlertController.alert(valid_OTP)
        } else {
            return true
        }
        return false
    }

    
    //MARK: UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        
        textField.inputAccessoryView = BTAppUtility.addToolBarOnView(self)

        if SCREENWIDTH <= 320 {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.logoTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if SCREENWIDTH <= 320 {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.logoTopConstraint.constant = 36
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        let string = textField.text?.trimWhiteSpace()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isFirstResponder {
            if textField.textInputMode?.primaryLanguage == nil || textField.textInputMode?.primaryLanguage == "emoji" {
                return false
            }
        }
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        
        if str.length > 8 {
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


    //MARK: UIButton Action Method
    @IBAction func submitButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if validateField() {
            self.view.endEditing(true)
            let resetVC = CAResetPasswordViewController()
            self.navigationController?.pushViewController(resetVC, animated: true)
        }
    }
    
    
    @IBAction func resendOtpButtonAction(_ sender: Any) {
    }
    
    
    //MARK: Selector Method
    @objc func doneButtonAction() {
        self.view .endEditing(true)
    }
    
    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
