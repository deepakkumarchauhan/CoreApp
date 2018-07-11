//
//  FacebookManager.swift
//  Template
//
//  Created by Raj Kumar Sharma on 20/01/16.
//  Copyright © 2016 Innology. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookManager: NSObject {

    typealias LoginCompletionBlock = (Dictionary<String, AnyObject>?, NSError?) -> Void
    static let sharedInstance = FacebookManager()
    var isReachable: Bool = false
    //MARK:- Public functions

    func getFacebookInfoWithCompletionHandler(_ fromViewController:AnyObject, onCompletion: @escaping LoginCompletionBlock) -> Void {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if !appDel.checkReachablility() {
            DispatchQueue.main.async(execute: {
               _ = AlertController.alert("No internet connection.")
            })
            return
        }

        self.getFBInfoWithCompletionHandler(fromViewController) { (dataDictionary:Dictionary<String, AnyObject>?, error: NSError?) -> Void in
            onCompletion(dataDictionary, error)
        }
    }
    
    func logoutFromFacebook() {
        FBSDKLoginManager().logOut()
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
    }
    
    //MARK:- Private functions

    fileprivate func getFBInfoWithCompletionHandler(_ fromViewController:AnyObject, onCompletion: @escaping LoginCompletionBlock) -> Void {
        
        let permissionDictionary = [
            "fields" : "id,name,first_name,last_name,gender,email,birthday,picture.type(large)",
            //"locale" : "en_US"
        ]
        
        if FBSDKAccessToken.current() != nil {

            FBSDKGraphRequest(graphPath: "/me", parameters: permissionDictionary)
                .start(completionHandler:  { (connection, result, error) in
                    
//                    guard let result = result as? NSDictionary, let email = result["email"] as? String,
//                        let user_name = result["name"] as? String,
//                        let user_gender = result["gender"] as? String,
//                        let user_id_fb = result["id"]  as? String else {
//                            return
//                    }
                    
                    if error == nil {
                        onCompletion(result as? Dictionary<String, AnyObject>, nil)
                    } else {
                        onCompletion(nil, error as NSError?)
                    }
                    
                })
        
        } else {
            
            FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_photos"], from: fromViewController as! UIViewController, handler: { (result, error) -> Void in
                
                
                if error != nil {
                    FBSDKLoginManager().logOut()
                    
                    if let error = error as NSError? {
                        let errorDetails = [NSLocalizedDescriptionKey : "Processing Error. Please try again!"]
                        let customError = NSError(domain: "Error!", code: error.code, userInfo: errorDetails)
                        
                        onCompletion(nil, customError)
                    } else {
                        onCompletion(nil, error as NSError?)
                    }
                    
                } else if (result?.isCancelled)! {
                    FBSDKLoginManager().logOut()
                    let errorDetails = [NSLocalizedDescriptionKey : "Request cancelled!"]
                    let customError = NSError(domain: "Request cancelled!", code: 1001, userInfo: errorDetails)
                    
                    onCompletion(nil, customError)
                } else {
                    let pictureRequest = FBSDKGraphRequest(graphPath: "me", parameters: permissionDictionary)
                    let _ = pictureRequest?.start(completionHandler: {
                        (connection, result, error) -> Void in
                        
                        if error == nil {
                            onCompletion(result as? Dictionary<String, AnyObject>, nil)
                        } else {
                            onCompletion(nil, error as NSError?)
                        }
                    })
                }
            })
        }
    }
    
}
