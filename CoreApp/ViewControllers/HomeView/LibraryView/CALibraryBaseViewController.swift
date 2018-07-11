//
//  CALibraryBaseViewController.swift
//  CoreApplication
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CALibraryBaseViewController: UIViewController, CAPSPageMenuDelegate {
    
    var pageMenu = CAPSPageMenu()
    var currentPageNumber = Int()
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: Custom Method
    func initialSetup() {
        // Alloc Controllers
        let VC1 = CANewsViewController()
        VC1.title = "News"
        let VC2 = CADocumentsViewController()
        VC2.title = "Documents"
        let VC3 = CAPresentationsViewController()
        VC3.title = "Presentations"
        
        var controllerArray = [UIViewController]()
        controllerArray = [VC1, VC2, VC3]
        self.view.frame = CGRect.init(x: 0, y: 0, width: Window_Width, height: Window_Height)
        
        let parameterdict = [CAPSPageMenuOptionScrollMenuBackgroundColor: UIColor.black, CAPSPageMenuOptionSelectionIndicatorColor: UIColor.init(red: 132.0/255.0, green:154.0/255.0, blue:61.0/255.0, alpha:1.0), CAPSPageMenuOptionMenuItemFont: UIFont.boldSystemFont(ofSize: (Window_Width<=320) ? 16 : 18), CAPSPageMenuOptionUnselectedMenuItemLabelColor:  UIColor.white, CAPSPageMenuOptionSelectedMenuItemLabelColor: UIColor.init(red: 132.0/255.0, green:154.0/255.0, blue:61.0/255.0, alpha:1.0), CAPSPageMenuOptionMenuHeight: (45), CAPSPageMenuOptionMenuItemWidth: (Window_Width)] as [String : Any]
        
        pageMenu.menuItemSeparatorWidth = 0
        pageMenu.menuItemWidthBasedOnTitleTextWidth = true
        pageMenu = CAPSPageMenu.init(viewControllers: controllerArray, frame: CGRect.init(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height), options: parameterdict)
        pageMenu.delegate = self
        self.view.addSubview(pageMenu.view)
        pageMenu.move(toPage: currentPageNumber)
        
        //Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(searchApi(notification:)), name: NSNotification.Name("libraryNotification"), object: nil)
    }
    
    //MARK: Deinit Method
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Notification Method
    @objc func searchApi(notification: NSNotification) {
        let dict = notification.object as! NSDictionary

        if currentPageNumber == 0 {
            NotificationCenter.default.post(name: NSNotification.Name("newsNotification"), object: dict)
        } else if currentPageNumber == 1 {
            NotificationCenter.default.post(name: NSNotification.Name("documentsNotification"), object: dict)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("presentationsNotification"), object: dict)
        }
    }

    
    //MARK: Page Menu Delegate
    func willMove(toPage controller: UIViewController!, index: Int) {
        currentPageNumber = index
    }
    
    func didMove(toPage controller: UIViewController!, index: Int) {
        currentPageNumber = index
    }
    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

