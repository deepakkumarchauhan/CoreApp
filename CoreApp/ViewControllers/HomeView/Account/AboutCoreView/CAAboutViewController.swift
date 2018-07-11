//
//  CAAboutViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAAboutViewController: UIViewController, UIWebViewDelegate {
    
    var isFromTerms = Bool()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        if isFromTerms {
            self.titleLabel.text = "Terms and Conditions"
            callApiForAboutData()
        } else {
            self.titleLabel.text = "About CORE Application"
            callApiForAboutData()
        }
    }
    
    //MARK: WebView Delegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK: UIButton Action Method
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Call API
    func callApiForAboutData()
    {
        CAServiceHelper.request(Dictionary<String, AnyObject>(), method: .get, apiName: isFromTerms ? pTermsAndConditions : pAbout, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        let dataDict = response.validatedValue("data", expected: NSDictionary())as! Dictionary<String,AnyObject>
                        self.webView.loadHTMLString(dataDict.validatedValue("description", expected: "" as AnyObject) as! String, baseURL: nil)
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
