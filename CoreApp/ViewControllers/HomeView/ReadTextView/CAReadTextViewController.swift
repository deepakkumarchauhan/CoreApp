//
//  CAReadTextViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class CAReadTextViewController: UIViewController {

    var readObj = CAHomeInfo()
    var realmObj = DownloadedClass()
    var isFromPlayList = Bool()

    @IBOutlet weak var labelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.isScrollEnabled = false
        initialSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textView.isScrollEnabled = true
    }
    
    //MARK: Custom Method
    func initialSetup() {
        if isFromPlayList {
            self.textView.text = realmObj.titleDescription
            self.titleLabel.text = realmObj.title
            if realmObj.createdAt != ""  {
                self.dateLabel.text = BTAppUtility.convertDateString(dateString: realmObj.createdAt, fromFormat: "YYYY-MM-dd", toFormat: "dd MMM, YYYY")
            }
            let realm = try! Realm()
            try! realm.write {
               realmObj.isPlayMedia = true
            }
        } else {
            self.textView.text = readObj.titleDescription
            self.titleLabel.text = readObj.title
            if readObj.createdAt != ""  {
                self.dateLabel.text = BTAppUtility.convertDateString(dateString: readObj.createdAt, fromFormat: "YYYY-MM-dd", toFormat: "dd MMM, YYYY")
            }
        }
    }

    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
    //MARKS: UIButton Action Method
    @IBAction func normalZoomButtonAction(_ sender: Any) {
        self.textView.originalFontSize()
    }
    
    @IBAction func crossButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func zoomInButtonAction(_ sender: Any) {
        self.textView.increaseFontSize()
    }
    
    @IBAction func zoomOutButtonAction(_ sender: Any) {
        self.textView.decreaseFontSize()
    }
    
    @IBAction func shareButtonAction(_ sender: Any) {
        let shareText = readObj.title
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UITextView {
    func increaseFontSize () {
        self.font =  UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize == 26) ? (self.font?.pointSize)! : (self.font?.pointSize)!+1)!

//        UIView.animate(withDuration: 1.0) {
//        }
    }
    func decreaseFontSize () {
        self.font =  UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize == 5) ? (self.font?.pointSize)! : (self.font?.pointSize)!-1)!
    }
    func originalFontSize () {
        self.font =  UIFont(name: (self.font?.fontName)!, size: 16)
    }
}
