//
//  CAHomeInnerViewController.swift
//  CoreApplication
//
//  Created by apple on 4/20/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class CAHomeInnerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var homeInfo = CAHomeInfo()
    var playArray = [CAHomeInfo]()

    var stringData = Data()
    var isRestoredataBase = Bool()
    var imageIndex: NSInteger = 0

    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var documentsCollectionView: UICollectionView!
    @IBOutlet weak var presentationCollectionView: UICollectionView!
    @IBOutlet weak var dailyTitleLabel: UILabel!
    @IBOutlet weak var blurImageView: UIImageView!
    
    @IBOutlet weak var newsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newsCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var documentationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var documentCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var presentationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var presentationCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var downloadActivityController: UIActivityIndicatorView!
    
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var updatingLabel: UILabel!
    
    @IBOutlet weak var newsSeeAllButton: UIButton!
    @IBOutlet weak var documentSeeAllButton: UIButton!
    @IBOutlet weak var presentationSeeAllButton: UIButton!
    
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        // Register CollectionView
        self.newsCollectionView.register(UINib.init(nibName: "CAHomeInnerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CAHomeInnerCollectionViewCell")
        self.documentsCollectionView.register(UINib.init(nibName: "CAHomeInnerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CAHomeInnerCollectionViewCell")
        self.presentationCollectionView.register(UINib.init(nibName: "CAHomeInnerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CAHomeInnerCollectionViewCell")
        
        //Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(searchApi(notfication:)), name: NSNotification.Name("homeNotification"), object: nil)

        //Add Blur Effect on Music Image
        self.blurImageView.addBlurEffect(isBlur: true)
        
        //Call API
        callApiForHomeData(searchText: "")
    }
    
    
    func manageSeeAllButton() {
        
        if  self.homeInfo.newsArray.count > 4 {
            self.newsSeeAllButton.isHidden = false
        }
        if self.homeInfo.presentationArray.count > 4 {
            self.newsSeeAllButton.isHidden = false
        }
        if self.homeInfo.documentArray.count > 4 {
            self.newsSeeAllButton.isHidden = false
        }
    }
    
    func deleteFromDataBase() {
        let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
        let realm = try! Realm()
        try! realm.write({
            realm.delete((userObj?.downloadData.self)!)
            self.callApiForPlayListData()
        })
    }
    
    //MARK: Notification Method
    @objc func searchApi(notfication: NSNotification) {
        //Call Search API
        let dict = notfication.object as! NSDictionary
        let str = "\(dict["searchValue"] as! String)".trimmingCharacters(in: .whitespaces).lowercased()
        callApiForHomeData(searchText: str)
    }
    
    func addDataToDataBase(listObj: CAHomeInfo, isDownload: Bool, isAutoDownload: Bool) {
        let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
        let filteredArray = userObj?.downloadData.filter() { $0.homeId == listObj.homeId && $0.dataType == listObj.dataType }

        if filteredArray?.count == 0 {
            let downloadObj = DownloadedClass()
            downloadObj.homeId = listObj.homeId
            downloadObj.isExpand = false
            downloadObj.isSelect = false
            downloadObj.isPlay = false
            downloadObj.name = listObj.name
            downloadObj.dataType = listObj.dataType
            downloadObj.mediaId = listObj.mediaId
            downloadObj.currentDate = Date()
            downloadObj.slug = listObj.slug
            downloadObj.titleDescription = listObj.titleDescription
            downloadObj.userId = listObj.userId
            downloadObj.parentId = listObj.parentId
            downloadObj.dailyPicId = listObj.dailyPicId
            downloadObj.categoryId = listObj.categoryId
            downloadObj.active = listObj.active
            downloadObj.createdAt = listObj.createdAt
            downloadObj.updatedAt = listObj.updatedAt
            downloadObj.deletedAt = listObj.deletedAt
            downloadObj.mediaURL = listObj.mediaURL
            downloadObj.thumbnail = listObj.thumbnail
            downloadObj.mediaType = listObj.mediaType
            downloadObj.title = listObj.title
            if isDownload {
                downloadObj.presentationData = self.stringData
                downloadObj.isDownload = true
            } else {
                downloadObj.isDownload = false
            }

            //Add data to realm
            let realm = try! Realm()
            try! realm.write({
                userObj?.downloadData.append(downloadObj)
                if !isAutoDownload {
                    _ = AlertController.alert("", message: isDownload ? "Downloaded successfully." : "Added to playlist successfully.")
                }
            })
        } else {
            if !isAutoDownload {
                _ = AlertController.alert("", message: "Already downloaded.")
            }
        }
        
        self.updatingLabel.isHidden = true
        self.view.isUserInteractionEnabled = true
        self.downloadActivityController.stopAnimating()
    }
    
    
    
    func convertIntoData(homeObj: CAHomeInfo, isAutoDownload: Bool) {
        
        let speechSynthesizer = SpeechSynthesizer(accessToken: "pk.eyJ1Ijoid29uZGVycGlsbGFycyIsImEiOiJjamdscnU0Z20xeW9kMzNwanlkcHp6MG5xIn0.7OxVz8nUxhLArKFhQVDWIA")
        
        let splitStrArr = homeObj.titleDescription.splitByLength(490)
        self.stringData.removeAll()
        
        let myGroup = DispatchGroup()
        var dataArr = [Data]()
        var currentIndex = Int()
        
        for _ in 0..<splitStrArr.count {
            dataArr.append(Data())
        }

        for index in 0..<splitStrArr.count {
            myGroup.enter()
            let options = SpeechOptions(text: splitStrArr[index])
            speechSynthesizer.audioData(with: options) { (data: Data?, error: NSError?) in
                guard error == nil else {
                    print("Error calculating directions: \(error!)")
                    return
                }
                dataArr.insert(data!, at: index)
                dataArr.remove(at: index+1)
                currentIndex = currentIndex + 1
                myGroup.leave()
                
                if currentIndex == splitStrArr.count {
                    self.stringData.removeAll()

                    for index in 0..<dataArr.count {
                        self.stringData.append(dataArr[index])
                    }
                }
            }
        }
        myGroup.notify(queue: .main) {
            self.addDataToDataBase(listObj: homeObj, isDownload: true, isAutoDownload: isAutoDownload)
        }
    }

    
    // MARK: UICollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 0 {
            return homeInfo.newsArray.count > 4 ? 4 : homeInfo.newsArray.count
        } else if collectionView.tag == 1 {
            return homeInfo.documentArray.count > 4 ? 4 : homeInfo.documentArray.count
        } else {
            return homeInfo.presentationArray.count > 4 ? 4 : homeInfo.presentationArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CAHomeInnerCollectionViewCell", for: indexPath) as! CAHomeInnerCollectionViewCell
        cell.downloadButton.isHidden = true
        cell.readTextButton.isHidden = true
        cell.cellMainView.isHidden = true
        cell.cellImageView.addBlurEffect(isBlur: false)

        if collectionView.tag == 0 {
            let obj = homeInfo.newsArray[indexPath.item]
            cell.cellMainView.isHidden = !obj.isSelect
            cell.downloadButton.isHidden = !obj.isSelect
            cell.readTextButton.isHidden = !obj.isSelect
            if obj.isSelect {
                cell.crossButton.setImage(UIImage(named: "close"), for: .normal)
            } else {
                cell.crossButton.setImage(UIImage(named: "infoIcon"), for: .normal)
            }
         //   cell.cellImageView.addBlurEffect(isBlur: !obj.isSelect)
            cell.crossButton.tag = indexPath.item+100
            cell.readTextButton.tag = indexPath.item+100
            cell.downloadButton.tag = indexPath.item+100
            cell.cellImageView.sd_setImage(with: URL(string: obj.mediaURL), placeholderImage: UIImage(named: "Placeholder"))
            cell.cellTitleLabel.text = obj.title
        } else if collectionView.tag == 1 {
            cell.crossButton.tag = indexPath.item+100
            let obj = homeInfo.documentArray[indexPath.item]
            cell.cellMainView.isHidden = !obj.isSelect
            cell.downloadButton.isHidden = !obj.isSelect
            cell.readTextButton.isHidden = !obj.isSelect
            cell.readTextButton.tag = indexPath.item+100
            cell.downloadButton.tag = indexPath.item+100
            if obj.isSelect {
                cell.crossButton.setImage(UIImage(named: "close"), for: .normal)
            } else {
                cell.crossButton.setImage(UIImage(named: "infoIcon"), for: .normal)
            }
         //   cell.cellImageView.addBlurEffect(isBlur: !obj.isSelect)
            cell.cellImageView.sd_setImage(with: URL(string: obj.mediaURL), placeholderImage: UIImage(named: "Placeholder"))
            cell.cellTitleLabel.text = obj.title
        } else {
            cell.crossButton.tag = indexPath.item+100
            let obj = homeInfo.presentationArray[indexPath.item]
            cell.cellMainView.isHidden = !obj.isSelect
            cell.downloadButton.isHidden = !obj.isSelect
            cell.readTextButton.isHidden = !obj.isSelect
            cell.readTextButton.tag = indexPath.item+100
            cell.downloadButton.tag = indexPath.item+100
            if obj.isSelect {
                cell.crossButton.setImage(UIImage(named: "close"), for: .normal)
            } else {
                cell.crossButton.setImage(UIImage(named: "infoIcon"), for: .normal)
            }
           // cell.cellImageView.addBlurEffect(isBlur: !obj.isSelect)
            cell.cellImageView.sd_setImage(with: URL(string: obj.mediaURL), placeholderImage: UIImage(named: "Placeholder"))
            cell.cellTitleLabel.text = obj.title
        }
        cell.downloadButton.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        cell.readTextButton.addTarget(self, action: #selector(readTextAction), for: .touchUpInside)
        cell.crossButton.addTarget(self, action: #selector(crossAction), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 105.0, height: 105.0)
    }
    
    // MARK: UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var objArr = [CAHomeInfo]()
        var obj = CAHomeInfo()
        if collectionView.tag == 0 {
            objArr = homeInfo.newsArray
        } else if collectionView.tag == 1 {
            objArr = homeInfo.documentArray
        } else {
            objArr = homeInfo.presentationArray
        }
        obj = objArr[indexPath.item]
        obj.isPlay = true

        let playNowVC = CAPlayViewController()
        playNowVC.playArray = objArr
        playNowVC.playingIndex = indexPath.item
        self.navigationController?.pushViewController(playNowVC, animated: true)
    }
    
    //MARK: UIButton Action Method
    @IBAction func downloadButtonAction(_ sender: Any) {
        if homeInfo.dailyPicArray.count > 0 {
            _ = AlertController.alert("", message: "Are you sure you want to download?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
                if index == 0 {
                    self.callApiForDownloadData(obj: self.homeInfo.dailyPicArray[self.imageIndex], isUpdateDB: false)
                }
            })
        } else {
            _ = AlertController.alert("", message: "No data found.")
        }
    }
    
    @IBAction func playNowButtonAction(_ sender: Any) {
        if homeInfo.dailyPicArray.count > 0 {
            let playVC = CAPlayViewController()
            playVC.playArray = homeInfo.dailyPicArray
            self.navigationController?.pushViewController(playVC, animated: true)
        } else {
            _ = AlertController.alert("", message: "No data found.")
        }
    }
    
    @IBAction func readTextButtonAction(_ sender: UIButton) {
        if homeInfo.dailyPicArray.count > 0 {
            let readVC = CAReadTextViewController()
            readVC.readObj = homeInfo.dailyPicArray[self.imageIndex]
            self.present(readVC, animated: true, completion: nil)
        } else {
            _ = AlertController.alert("", message: "No data found.")
        }
    }
    
    @IBAction func supplyChainButtonAction(_ sender: Any) {
        let searchVC = CASearchViewController()
        searchVC.isFrom = "supply"
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func tradeFacilitationButtonAction(_ sender: Any) {
        let searchVC = CASearchViewController()
        searchVC.isFrom = "trade"
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func coreMonthlyButtonAction(_ sender: Any) {
        let searchVC = CASearchViewController()
        searchVC.isFrom = "core"
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func playTodayNewsButtonAction(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let result = formatter.string(from: date)

        let filteredArray = homeInfo.newsArray.filter() { $0.createdAt == result }
        if filteredArray.count > 0 {
            let playVC = CAPlayViewController()
            playVC.playArray = filteredArray
            self.navigationController?.pushViewController(playVC, animated: true)
        } else {
            _ = AlertController.alert("", message: "No news found.")
        }
    }
    
    @IBAction func playTodayDocumentButtonAction(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let result = formatter.string(from: date)
        
        let filteredArray = homeInfo.documentArray.filter() { $0.createdAt == result }
        if filteredArray.count > 0 {
            let playVC = CAPlayViewController()
            playVC.playArray = filteredArray
            self.navigationController?.pushViewController(playVC, animated: true)
        } else {
            _ = AlertController.alert("", message: "No document found.")
        }
    }
    
    @IBAction func playTodayPresentationButtonAction(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let result = formatter.string(from: date)
        
        let filteredArray = homeInfo.presentationArray.filter() { $0.createdAt == result }
        if filteredArray.count > 0 {
            let playVC = CAPlayViewController()
            playVC.playArray = filteredArray
            self.navigationController?.pushViewController(playVC, animated: true)
        } else {
            _ = AlertController.alert("", message: "No presentation found.")
        }
    }
    
    @IBAction func newsSeeAllButtonAction(_ sender: Any) {
        let dict = ["seeAllValue": "0"]
        NotificationCenter.default.post(name: NSNotification.Name("seeAllNotification"), object: dict)
    }
    
    
    @IBAction func documentsSeeAllButtonAction(_ sender: Any) {
        let dict = ["seeAllValue": "1"]
        NotificationCenter.default.post(name: NSNotification.Name("seeAllNotification"), object: dict)
    }
    
    
    @IBAction func presentationSeeAllButtonAction(_ sender: Any) {
        let dict = ["seeAllValue": "2"]
        NotificationCenter.default.post(name: NSNotification.Name("seeAllNotification"), object: dict)
    }
    
    
    //MARK: Selector Methods
    @objc func downloadAction(sender: UIButton) {
        _ = AlertController.alert("", message: "Are you sure you want to download?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
            if index == 0 {
                if let collectionView = sender.superview?.superview?.superview?.superview?.superview {
                    var obj = CAHomeInfo()
                    if collectionView.tag == 0 {
                        obj = self.homeInfo.newsArray[sender.tag-100]
                    } else if collectionView.tag == 1 {
                        obj = self.homeInfo.documentArray[sender.tag-100]
                    } else {
                        obj = self.homeInfo.presentationArray[sender.tag-100]
                    }
                    self.callApiForDownloadData(obj: obj, isUpdateDB: false)

                }
            }
        })
    }
    
    @objc func readTextAction(sender: UIButton) {
        if let collectionView = sender.superview?.superview?.superview?.superview?.superview {
            var obj = CAHomeInfo()
            if collectionView.tag == 0 {
                obj = homeInfo.newsArray[sender.tag-100]
                obj.isSelect = !obj.isSelect
            } else if collectionView.tag == 1 {
                obj = homeInfo.documentArray[sender.tag-100]
                obj.isSelect = !obj.isSelect
            } else {
                obj = homeInfo.presentationArray[sender.tag-100]
                obj.isSelect = !obj.isSelect
            }
            let readVC = CAReadTextViewController()
            readVC.readObj = obj
            self.present(readVC, animated: true, completion: nil)
        }
    }
    
    @objc func crossAction(sender: UIButton) {
        if let collectionView = sender.superview?.superview?.superview?.superview {
            if collectionView.tag == 0 {
                let obj = homeInfo.newsArray[sender.tag-100]
                obj.isSelect = !obj.isSelect
                self.newsCollectionView.reloadData()
            } else if collectionView.tag == 1 {
                let obj = homeInfo.documentArray[sender.tag-100]
                obj.isSelect = !obj.isSelect
                self.documentsCollectionView.reloadData()
            } else {
                let obj = homeInfo.presentationArray[sender.tag-100]
                obj.isSelect = !obj.isSelect
                self.presentationCollectionView.reloadData()
            }
        }
    }
    
    @objc func swiped(gesture: UIGestureRecognizer) {
        
        if self.homeInfo.dailyPicArray.count > 0 {
            
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                
                switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.right :
                    imageIndex = imageIndex - 1
                    if imageIndex < 0 {
                        imageIndex = homeInfo.dailyPicArray.count-1
                    }
                    self.blurImageView.slideInFromLeft()
                    let obj = self.homeInfo.dailyPicArray[imageIndex]
                    self.blurImageView.sd_setImage(with: URL(string: (obj.mediaURL)), placeholderImage: UIImage(named: "Placeholder"))
                    self.dailyTitleLabel.text = obj.titleDescription
                    
                case UISwipeGestureRecognizerDirection.left:
                    imageIndex = imageIndex + 1
                    if imageIndex > homeInfo.dailyPicArray.count-1 {
                        imageIndex = 0
                    }
                    self.blurImageView.slideInFromRight()
                    let obj = self.homeInfo.dailyPicArray[imageIndex]
                    self.blurImageView.sd_setImage(with: URL(string: (obj.mediaURL)), placeholderImage: UIImage(named: "Placeholder"))
                    self.dailyTitleLabel.text = obj.titleDescription
                    
                default:
                    break
                }
                self.pageController.currentPage = imageIndex
            }

        }
    }

    
    //MARK: Call API
    func callApiForHomeData(searchText: String)
    {
        var dict = Dictionary<String, AnyObject>()
        dict[pSearch] = searchText as AnyObject
        
        CAServiceHelper.request(dict, method: .get, apiName: pHome, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        let dataDict = response.validatedValue("data", expected: NSDictionary())as! Dictionary<String,AnyObject>
                        self.homeInfo = CAHomeInfo.modelFromHomeDict(dataDict)
                        
                        //Manage CollectionView
                        if  self.homeInfo.newsArray.count == 0 {
                            self.newsHeightConstraint.constant = 0.0
                            self.newsCollectionHeightConstraint.constant = 0
                        } else {
                            self.newsHeightConstraint.constant = 21.0
                            self.newsCollectionHeightConstraint.constant = 105.0
                        }
                        
                        if self.homeInfo.presentationArray.count == 0 {
                            self.presentationHeightConstraint.constant = 0.0
                            self.presentationCollectionHeightConstraint.constant = 0
                        } else {
                            self.presentationHeightConstraint.constant = 21.0
                            self.presentationCollectionHeightConstraint.constant = 105.0
                        }
                        
                        if self.homeInfo.documentArray.count == 0 {
                            self.documentationHeightConstraint.constant = 0.0
                            self.documentCollectionHeightConstraint.constant = 0
                        } else {
                            self.documentationHeightConstraint.constant = 21.0
                            self.documentCollectionHeightConstraint.constant = 105.0
                        }
                        
                        self.manageSeeAllButton()
                        
                        //Set DailyData
                        if self.homeInfo.dailyPicArray.count != 0 {
                            let obj = self.homeInfo.dailyPicArray.first
                            self.blurImageView.sd_setImage(with: URL(string: (obj?.mediaURL)!), placeholderImage: UIImage(named: "Placeholder"))
                            self.dailyTitleLabel.text = obj?.titleDescription
                            self.pageController.numberOfPages = self.homeInfo.dailyPicArray.count > 1 ? self.homeInfo.dailyPicArray.count : 0
                            self.pageController.currentPage = 0
                            
                            //Add swipe oh daily
                            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
                            swipeRight.direction = UISwipeGestureRecognizerDirection.right
                            self.blurImageView.addGestureRecognizer(swipeRight)
                            
                            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped))
                            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                            self.blurImageView.addGestureRecognizer(swipeLeft)

                        } else {
                            self.pageController.numberOfPages = 0
                            self.blurImageView.image = UIImage(named: "Placeholder")
                            self.dailyTitleLabel.text = "No Data Found."
                        }
                        if self.isRestoredataBase {
                            self.deleteFromDataBase()
                        }
                        self.newsCollectionView.reloadData()
                        self.presentationCollectionView.reloadData()
                        self.documentsCollectionView.reloadData()
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
    
    func callApiForDownloadData(obj: CAHomeInfo, isUpdateDB: Bool)
    {
        var dict = Dictionary<String, AnyObject>()

        dict[pID] = obj.homeId as AnyObject
        dict[pDownload] = "1" as AnyObject
        dict[pType] = obj.dataType as AnyObject

        CAServiceHelper.request(dict, method: .get, apiName: pDownload, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                if let response = result as? Dictionary<String, AnyObject> {
                    if(status == 201 || status == 200) {
                        self.view.isUserInteractionEnabled = false
                        self.downloadActivityController.startAnimating()
                        self.convertIntoData(homeObj: obj, isAutoDownload: false)
                    }
                    else {
                        _ = AlertController.alert("", message: response.validatedValue("message", expected: "" as AnyObject) as! String)
                    }
                }
            }
            else {
                self.view.isUserInteractionEnabled = true
                self.downloadActivityController.stopAnimating()

                _ = AlertController.alert("", message: "\(error!.localizedDescription)")
            }
        }
    }
    
    func callApiForPlayListData()
    {
        CAServiceHelper.request(Dictionary<String, AnyObject>(), method: .get, apiName: pPlayList, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200) {
                        let dataArray = response.validatedValue("data", expected: Array<Any>() as AnyObject) as! [Dictionary<String,AnyObject>]
                        
                        for dict in dataArray {
                            self.playArray.append(CAHomeInfo.modelFromPlaylistDict(dict))
                        }
                        
                        if self.playArray.count > 0 {
                            self.downloadActivityController.startAnimating()
                            self.view.isUserInteractionEnabled = false
                            self.updatingLabel.isHidden = false
                        }
                        
                        for obj in self.playArray {
                            if obj.isDownload {
                                self.convertIntoData(homeObj: obj, isAutoDownload: true)
                            } else {
                                self.addDataToDataBase(listObj: obj, isDownload: false, isAutoDownload: true)
                            }
                        }
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
