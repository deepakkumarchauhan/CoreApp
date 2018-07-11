//
//  CALogInViewController.swift
//  CoreApplication
//
//  Created by apple on 4/19/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookLogin
import FacebookCore
import TwitterKit
import RealmSwift

class CALogInViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var loginInfo = CAUserInfo()
    var email = String()
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    @IBOutlet weak var rememberMeButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let token = NSUSERDEFAULT.value(forKey: "token")
        if token != nil {
            let homeVC = CAHomeBaseViewController()
            homeVC.isRestoredataBase = false
            self.navigationController?.pushViewController(homeVC, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup()  {
        //Set Values in Model Class
        if let _ = UserDefaults.standard.value(forKey: "emailId") {
            loginInfo.userName = UserDefaults.standard.value(forKey: "emailId") as! String
            loginInfo.password = UserDefaults.standard.value(forKey: "password") as! String
            self.rememberMeButton.isSelected = UserDefaults.standard.bool(forKey: "isRemember")
        }
        self.usernameTextField.text = loginInfo.userName
        self.passwordTextField.text = loginInfo.password
        
        //Google Signin
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "396094934795-sii77nu6jcjgkmkt59oh63h5b5mrbnf8.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.login")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
    }
    
    func checkUserInDatabase(isRestore: Bool) {
        let realm = try! Realm()
        
        let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
        if userObj == nil {
            let user = UserClass()
            user.userEmail = NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String
            user.userToken = NSUSERDEFAULT.value(forKey: "token") as! String
            try! realm.write {
                realm.add(user)
            }
        }
        //else {
            let homeVC = CAHomeBaseViewController()
            homeVC.isRestoredataBase = isRestore
            self.navigationController?.pushViewController(homeVC, animated: true)
       // }
    }
    
    func validateField()-> Bool  {
        if loginInfo.userName == "" {
            _ = AlertController.alert(blank_Email)
        } else if !loginInfo.userName.isEmail() {
            _ = AlertController.alert(valid_Email)
        } else if loginInfo.password == "" {
            _ = AlertController.alert(blank_Password)
        } else if loginInfo.password.length < 8 || !loginInfo.password.containsFourLettersAndTwoDigits() {
            _ = AlertController.alert(valid_PasswordMatch)
        }
//        else if !loginInfo.password.containsFourLettersAndTwoDigits() {
//            _ = AlertController.alert(valid_PasswordMatch)
//        }
        else {
            return true
        }
        return false
    }
    
    //MARK: UIButton Action Method
    @IBAction func remembermeButtonAction(_ sender: Any) {
        self.rememberMeButton.isSelected = !self.rememberMeButton.isSelected
    }
    
    @IBAction func signUpButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        if validateField() {
            callApiForlogin()
        }
    }
    
    @IBAction func forgotButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        let forgotVC = CAForgotViewController()
        self.navigationController?.pushViewController(forgotVC, animated: true)
    }
    
    @IBAction func facebookButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        facebookIntegrationWithHelperClass()
    }
    
    @IBAction func twitterButtonAction(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                let userName = session!.userName
                self.email = "\(userName)@twitter.com"
                self.callApiForSociallogin()
            } else {
                print("error: \(error?.localizedDescription)");
            }
        })
    }
    
    @IBAction func googleButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func registerNowButtonAction(_ sender: Any) {
        self.view.endEditing(true)
        let signupVC = CASIgnUpViewController()
        self.navigationController?.pushViewController(signupVC, animated: true)
    }
    
    //MARK: UITextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let string = textField.text?.trimWhiteSpace()
        
        if textField.tag == 0 {
            loginInfo.userName = string!
        } else {
            loginInfo.password = string!
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
        
        if textField.tag == 0 && str.length > 60 {
            return false
        } else if textField.tag == 1 && str.length > 12 {
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
    
    //MARK: - google sign in delegates
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
            logInfo("\(String(describing: error?.localizedDescription))")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            self.loginInfo.userId = user.userID
            email = user.profile.email
            
            self.callApiForSociallogin()

//            if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
//                let countryName = BTAppUtility.countryName(countryCode: countryCode)
//                print("\(countryName)")
//            }
        }
    }
    
    //MARK: - Facebook Integration
    func facebookIntegrationWithHelperClass() {
        
        FacebookManager.sharedInstance.logoutFromFacebook()
        FacebookManager.sharedInstance.getFacebookInfoWithCompletionHandler(self) { (dataDictionary:Dictionary<String, AnyObject>?, error:NSError?) -> Void in
            if dataDictionary != nil {
                // save fetched values from facebook in userinfo modal class
                self.loginInfo.userId = dataDictionary?["id"] as! String
                self.email = dataDictionary?["email"] as! String
                
                if self.email.count == 0 {
                    self.email = self.loginInfo.userId + "@facebook.com"
                }
                self.callApiForSociallogin()
            }
        }
    }

    
    //MARK: Call API
    func callApiForlogin()
    {
        let dict = NSMutableDictionary()

        dict[pEmail] = loginInfo.userName
        dict[pPassword] = loginInfo.password
        dict[pDeviceId] = "\(UIDevice.current.identifierForVendor!.uuidString)"

        CAServiceHelper.request(dict as! Dictionary<String, AnyObject>, method: .post, apiName: pLogin, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        
                        let dataDict = response.validatedValue("data", expected: NSDictionary())as! Dictionary<String,AnyObject>
                        NSUSERDEFAULT.set(dataDict.validatedValue("token", expected: ""as AnyObject)as! String,  forKey: "token")
                        NSUSERDEFAULT.set(self.loginInfo.userName, forKey: "loginUserEmail")
                        NSUSERDEFAULT.set(dataDict.validatedValue("delete_prefrence_time", expected: ""as AnyObject)as! String,  forKey: "delete_prefrence_time")
                        
                        if self.rememberMeButton.isSelected  {
                            NSUSERDEFAULT.set(self.loginInfo.userName, forKey: "emailId")
                            NSUSERDEFAULT.set(self.loginInfo.password, forKey: "password")
                        } else {
                            NSUSERDEFAULT.set("", forKey: "emailId")
                            NSUSERDEFAULT.set("", forKey: "password")
                        }
                        NSUSERDEFAULT.set(self.rememberMeButton.isSelected, forKey: "isRemember")
                        
                        self.checkUserInDatabase(isRestore: (dataDict.validatedValue("device_status", expected: ""as AnyObject)as! String) == "0" ? false : true)
                        NSUSERDEFAULT.synchronize()
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
    
    func callApiForSociallogin()
    {
        let dict = NSMutableDictionary()
        dict[pEmail] = email
        dict[pDeviceId] = "\(UIDevice.current.identifierForVendor!.uuidString)"

        CAServiceHelper.request(dict as! Dictionary<String, AnyObject>, method: .get, apiName: pSocialLogin, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200) {
                        let dataDict = response.validatedValue("data", expected: NSDictionary())as! Dictionary<String,AnyObject>
                        
                        NSUSERDEFAULT.set(dataDict.validatedValue("token", expected: ""as AnyObject)as! String,  forKey: "token")
                        
                        NSUSERDEFAULT.set(dataDict.validatedValue("delete_prefrence_time", expected: ""as AnyObject)as! String,  forKey: "delete_prefrence_time")

                        NSUSERDEFAULT.set(self.loginInfo.userName, forKey: "loginUserEmail")
                        self.checkUserInDatabase(isRestore: (dataDict.validatedValue("device_status", expected: ""as AnyObject)as! String) == "0" ? false : true)
                        self.loginInfo = CAUserInfo()
                        
                    } else if status == 404 {
                        let signupVC = CASIgnUpViewController()
                        signupVC.isFromSocial = true
                        signupVC.signUpInfo.userName = self.email
                        self.navigationController?.pushViewController(signupVC, animated: true)
                        self.loginInfo = CAUserInfo()
                    } else {
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
