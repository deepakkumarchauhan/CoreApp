//
//  CAHomeBaseViewController.swift
//  CoreApplication
//
//  Created by apple on 4/20/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class CAHomeBaseViewController: UIViewController, UITextFieldDelegate {

    var isRestoredataBase = Bool()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextField: CustomTextField!
    
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var libraryImageView: UIImageView!
    @IBOutlet weak var playingImageView: UIImageView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var accountImageView: UIImageView!

    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var playingLabel: UILabel!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var libraryLabel: UILabel!
    
    @IBOutlet weak var searchViewHeightConstrant: NSLayoutConstraint!
    @IBOutlet weak var topSearchImageView: UIImageView!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Default Home Select
        changeButtonImage(imageView: self.homeImageView, titleLabel: self.homeLabel, image: UIImage(named: "homeBlue")!)
        let homeVC = CAHomeInnerViewController()
        homeVC.isRestoredataBase = isRestoredataBase
        addViewController(homeVC)
        
        NotificationCenter.default.addObserver(self, selector: #selector(seeAlldata(notification:)), name: NSNotification.Name("seeAllNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    //MARK: Notification Method
    @objc func seeAlldata(notification: NSNotification) {
        let dict = notification.object as! NSDictionary
        let seeAllValue = "\(dict["seeAllValue"] as! String)"
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.homeSelectedTab = 1
        removeViewController()
        changeButtonImage(imageView: self.libraryImageView, titleLabel: self.libraryLabel, image: UIImage(named: "libraryBlue")!)
        let libraryVC = CALibraryBaseViewController()
        libraryVC.currentPageNumber = Int(seeAllValue)!
        addViewController(libraryVC)
    }

    
    //MARK: Custom Method
    func addViewController(_ childController: UIViewController) {
        
        if  childController is CAAccountViewController {
            self.searchViewHeightConstrant.constant = 0
            self.topSearchImageView.isHidden = true
            self.searchTextField.isHidden = true
        } else {
            showSearchView()
        }
        
        NSUSERDEFAULT.set(0, forKey: "newsFilter")
        NSUSERDEFAULT.set(0, forKey: "documentsFilter")
        NSUSERDEFAULT.set(0, forKey: "presentationFilter")

        self.searchTextField.text = ""
        childController.view.frame = self.containerView.bounds;
        self.addChildViewController(childController)
        self.containerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
        let appDel = UIApplication.shared.delegate as! AppDelegate
        if appDel.homeSelectedTab != 2 {
            NotificationCenter.default.post(name: NSNotification.Name("stopPlaying"), object: nil)
        }
        
        //addDataToDataBAse()
    }
    
    
    func removeViewController() {
        for viewController in self.containerView.subviews {
            viewController.removeFromSuperview()
        }
    }
    
    func changeButtonImage(imageView: UIImageView, titleLabel: UILabel, image: UIImage) {
        self.homeLabel.textColor = UIColor.black
        self.libraryLabel.textColor = UIColor.black
        self.playingLabel.textColor = UIColor.black
        self.searchLabel.textColor = UIColor.black
        self.accountLabel.textColor = UIColor.black
        
        self.homeImageView.image = UIImage(named: "homeGray")
        self.libraryImageView.image = UIImage(named: "libraryGray")
        self.playingImageView.image = UIImage(named: "playingGray")
        self.accountImageView.image = UIImage(named: "setting")
        self.searchImageView.image = UIImage(named: "searchGray")
        
        UIView.animate(withDuration: 0.2,
                       animations: {
                        imageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                        titleLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            imageView.transform = CGAffineTransform.identity
                            titleLabel.transform = CGAffineTransform.identity
                        }
        })


        titleLabel.textColor = UIColor.init(red: 0.0/255.0, green: 127.0/255, blue: 242.0/255.0, alpha: 1.0)
        imageView.image = image
    }
    
    func showSearchView() {
        self.searchViewHeightConstrant.constant = 40.0
        self.topSearchImageView.isHidden = false
        self.searchTextField.isHidden = false
    }

    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        let dict = ["searchValue": textField.text]
        let appDel = UIApplication.shared.delegate as! AppDelegate
        if (appDel.homeSelectedTab == 0) {
            NotificationCenter.default.post(name: NSNotification.Name("homeNotification"), object: dict)
        } else if (appDel.homeSelectedTab == 1) {
            NotificationCenter.default.post(name: NSNotification.Name("libraryNotification"), object: dict)
        } else if (appDel.homeSelectedTab == 2) {
            NotificationCenter.default.post(name: NSNotification.Name("playingNotification"), object: dict)
        } else if (appDel.homeSelectedTab == 3) {
            NotificationCenter.default.post(name: NSNotification.Name("searchNotification"), object: dict)
        }
        return true
    }
    
    //MARK: UIButton Action
    @IBAction func homeButtonAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.homeSelectedTab = 0
        removeViewController()
        changeButtonImage(imageView: self.homeImageView, titleLabel: self.homeLabel, image: UIImage(named: "homeBlue")!)
        let homeVC = CAHomeInnerViewController()
        addViewController(homeVC)
    }
    
    @IBAction func libraryButtonAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.homeSelectedTab = 1
        removeViewController()
        changeButtonImage(imageView: self.libraryImageView, titleLabel: self.libraryLabel, image: UIImage(named: "libraryBlue")!)
        let libraryVC = CALibraryBaseViewController()
        addViewController(libraryVC)
    }
    
    @IBAction func playingButtonAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        if appDel.homeSelectedTab != 2 {
            appDel.homeSelectedTab = 2
            removeViewController()
            changeButtonImage(imageView: self.playingImageView, titleLabel: self.playingLabel, image: UIImage(named: "playingBlue")!)
            let playVC = CAPlayNowViewController()
            addViewController(playVC)
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.homeSelectedTab = 3
        removeViewController()
        changeButtonImage(imageView: self.searchImageView, titleLabel: self.searchLabel, image: UIImage(named: "searchBlue")!)
        let searchVC = CASearchViewController()
        addViewController(searchVC)
    }
    
    @IBAction func accountButtonAction(_ sender: Any) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.homeSelectedTab = 4
        removeViewController()
        changeButtonImage(imageView: self.accountImageView, titleLabel: self.accountLabel, image: UIImage(named: "settingBlue")!)
        let accountVC = CAAccountViewController()
        addViewController(accountVC)
    }
    
    
    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
