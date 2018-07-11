//
//  BTAppUtility.swift
//  BeanThere
//
//  Created by Neha Chhabra on 11/11/16.
//  Copyright © 2016 Neha Chhabra. All rights reserved.
//

import UIKit

// MARK: - Short Terms
let kAppBlueColor = RGBA(73, g: 173, b: 197, a: 1)
let KAppWhiteColor = UIColor.white

let KAppDarkGrayColor = UIColor.darkGray

let KAppPlaceholderColor = UIColor.lightGray
let KAppTextColor = UIColor.darkGray
let KAppMediumFont = UIFont(name:"San Francisco Text Medium", size:20)!
//let KAppRegularFont = UIFont(name:"San Francisco Text Regular", size: 18)!
let kAppDarkGrayColor = RGBA(29, g: 35, b: 34, a: 0.2)
let KAppTintColor = RGBA(255, g: 220, b: 65, a: 1)
let kAppDelegate = UIApplication.shared.delegate as! AppDelegate

let showLog = true

let Window_Width = UIScreen.main.bounds.size.width
let Window_Height = UIScreen.main.bounds.size.height

let NSUSERDEFAULT = UserDefaults.standard


// MARK: - Helper functions


//func showHudOnView(headerText: String , footerText: String , inView: UIView){
//    
//    let hud = MBProgressHUD.showAdded(to: inView, animated: true)
//    hud.backgroundView.style = MBProgressHUDBackgroundStyle.solidColor
//    hud.bezelView.style = MBProgressHUDBackgroundStyle.solidColor
//    hud.bezelView.color = UIColor.white
//    hud.bezelView.alpha = 1.0
//    hud.label.text = headerText
//    hud.detailsLabel.text = footerText
//}


func dropShadow(objView: UIView) {
    
    objView.layer.masksToBounds = false
    objView.layer.shadowColor = UIColor.lightGray.cgColor
    objView.layer.shadowOpacity = 0.5
    objView.layer.shadowOffset = CGSize(width: 1, height: 1)
    objView.layer.shadowRadius = 1
    
    objView.layer.shadowPath = UIBezierPath(rect: objView.bounds).cgPath
    objView.layer.shouldRasterize = true
}


func dropShadowOnTop(objView: UIView) {
    
    objView.layer.masksToBounds = false
    objView.layer.shadowColor = UIColor.lightGray.cgColor
    objView.layer.shadowOpacity = 0.5
    objView.layer.shadowOffset = CGSize.zero
    objView.layer.shadowRadius = 2
    objView.layer.shadowPath = UIBezierPath(rect: objView.bounds).cgPath
    objView.layer.shouldRasterize = true
}


func dropShadowForAllCorners(objView: UIView) {
    
    objView.layer.masksToBounds = false
    objView.layer.shadowColor = UIColor.darkGray.cgColor
    objView.layer.shadowOpacity = 0.5
    objView.layer.shadowOffset = CGSize.zero
    objView.layer.shadowRadius = 1
    
    objView.layer.shadowPath = UIBezierPath(rect: objView.bounds).cgPath
    objView.layer.shouldRasterize = true
}


func RGBA(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
}

func getRoundRect(_ obj : UIButton){
    obj.layer.cornerRadius = obj.frame.size.height/2
    obj.layer.borderColor = KAppWhiteColor.cgColor
    obj.layer.borderWidth = obj.frame.size.width/2
    obj.clipsToBounds = true
}

func getRoundImage(_ obj : UIImageView){
    obj.layer.cornerRadius = obj.frame.size.height/2
    obj.layer.borderColor = KAppWhiteColor.cgColor
    obj.layer.borderWidth = 5
    obj.layer.masksToBounds = true
}

func getViewWithTag(_ tag:NSInteger, view:UIView) -> UIView {
    return view.viewWithTag(tag)!
}

// custom log
func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    if (showLog) {
        print("\(function): \(line): \(message)")
    }
}

func trimWhiteSpace (_ str: String) -> String {
    let trimmedString = str.trimmingCharacters(in: CharacterSet.whitespaces)
    return trimmedString
}


func presentAlert(_ titleStr : String?,msgStr : String?,controller : AnyObject?){
    DispatchQueue.main.async(execute: {
        let alert=UIAlertController(title: titleStr, message: msgStr, preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        
        //event handler with closure
        controller!.present(alert, animated: true, completion: nil);
        //alert.view.tintColor = UserDefaults.standard.colorForKey("color")! as UIColor
    })
}

 func presentAlertWithOptions(_ title: String, message: String,controller : AnyObject, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert, buttons: buttons, tapBlock: tapBlock)
    controller.present(alert, animated: true, completion: nil)
   // alert.view.tintColor = UserDefaults.standard.colorForKey("color")! as UIColor

    //        instance.topMostController()?.presentViewController(alert, animated: true, completion: nil)
    return alert
}

private extension UIAlertController {
    
    convenience init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) {
        self.init(title: title, message: message, preferredStyle:preferredStyle)
        var buttonIndex = 0
        for buttonTitle in buttons {
            let action = UIAlertAction(title: buttonTitle, preferredStyle: .default, buttonIndex: buttonIndex, tapBlock: tapBlock)
            buttonIndex += 1
            self.addAction(action)
        }
    }
}

private extension UIAlertAction {
    convenience init(title: String?, preferredStyle: UIAlertActionStyle, buttonIndex:Int, tapBlock:((UIAlertAction,Int) -> Void)?) {
       
        
        self.init(title: title, style: preferredStyle) {
            (action:UIAlertAction) in
            if let block = tapBlock {
                block(action,buttonIndex)
            }
        }
    }
}

class BTAppUtility: NSObject {
   class func convertDateString(dateString : String!, fromFormat sourceFormat : String!, toFormat desFormat : String!) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = sourceFormat
        let date = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = desFormat
        return dateFormatter.string(from: date!)
    }
    
   class func countryName(countryCode: String) -> String? {
        let current = Locale(identifier: Locale.current.identifier)
        return current.localizedString(forRegionCode: countryCode) ?? nil
    }

    class  func leftBarButton(_ imageName : NSString,controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: imageName as String), for: UIControlState())
        button.addTarget(controller, action: #selector(leftBarButtonAction(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    class  func rightBarButton(_ imageName : NSString,controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: imageName as String), for: UIControlState())
        button.addTarget(controller, action: #selector(rightBarButtonAction(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    
    @objc   func leftBarButtonAction(_ button : UIButton) {
        
    }
    
    @objc   func rightBarButtonAction(_ button : UIButton) {
        
    }
    
    class func addToolBarOnView(_ controller: UIViewController)->UIToolbar {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: controller, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        return doneToolbar
    }
    
    @objc func doneButtonAction() {
        
    }


}



