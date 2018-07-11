//
//  CASearchViewController.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class CASearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var mainArray = [CAHomeInfo]()
    var searchInfo = CAHomeInfo()
    var filterArray = [CAHomeInfo]()
    var playingIndex = Int()
    var stringData = Data()
    var isFrom = String()
    let groupDispatch = DispatchGroup()

    @IBOutlet weak var noSearchFoundLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var downloadActivityController: UIActivityIndicatorView!
    @IBOutlet weak var searchTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navTitleLabel: UILabel!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        //Register Cell
        self.tableView.register(UINib(nibName: "CALibraryTableViewCell", bundle: nil), forCellReuseIdentifier: "CALibraryTableViewCellID")
        
        //Call API
        if isFrom == "core" {
            self.searchTopConstraint.constant = 105.0
            self.navTitleLabel.text = "Core Monthly"
            callApiForCoreMonthlyData()
        } else if isFrom == "supply" {
            self.navTitleLabel.text = "Supply Chain Security"
            callApiForSupplyData(supply: "1", trade: "0")
        } else if isFrom == "trade" {
            self.navTitleLabel.text = "Trade Facilitation"
            callApiForSupplyData(supply: "0", trade: "1")
        } else {
            callApiForHomeData(searchText: "")
            self.searchTopConstraint.constant = 0.0
        }
        
        //Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(searchApi(notification:)), name: NSNotification.Name("searchNotification"), object: nil)
    }
    
    
    func addDataToDatabase() {
        let isDownload = NSUSERDEFAULT.bool(forKey: "autoDownloadPrefrence")
        if isDownload {
            let filteredItems = filterArray.filter { $0.isDownload == false }
            if filteredItems.count > 0 {
                callApiForMultipleDownloadData(deletedArray: filteredItems)
            }
        }
    }
    
    
    func convertIntoData(homeObj: CAHomeInfo, realmObj: DownloadedClass, isMultiDownload: Bool) {
        
        let speechSynthesizer = SpeechSynthesizer(accessToken: "pk.eyJ1Ijoid29uZGVycGlsbGFycyIsImEiOiJjamdscnU0Z20xeW9kMzNwanlkcHp6MG5xIn0.7OxVz8nUxhLArKFhQVDWIA")
        
        var splitStrArr = [String]()
        if realmObj.homeId != "" {
            splitStrArr = realmObj.titleDescription.splitByLength(490)
        } else {
            splitStrArr = homeObj.titleDescription.splitByLength(490)
        }
        
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
            if realmObj.homeId != "" {
                self.addDataToDataBase(listObj: homeObj, isDownload: true, obj: realmObj, isMultiDownload: isMultiDownload)
            } else {
                self.addDataToDataBase(listObj: homeObj, isDownload: true, obj: DownloadedClass(), isMultiDownload: isMultiDownload)
            }
        }
    }

    
    func addDataToDataBase(listObj: CAHomeInfo, isDownload: Bool, obj: DownloadedClass, isMultiDownload: Bool) {
        let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
        let downloadObj = DownloadedClass()
        
        if obj.homeId != "" {
            let realm = try! Realm()
            try! realm.write({
                obj.presentationData = self.stringData
                obj.isDownload = true
                self.view.isUserInteractionEnabled = true
                self.downloadActivityController.stopAnimating()
                _ = AlertController.alert("", message: isDownload ? "Downloaded successfully." : "Added to playlist successfully.")
            })

        } else {
            downloadObj.homeId = listObj.homeId
            downloadObj.isExpand = false
            downloadObj.isSelect = false
            downloadObj.isPlay = false
            downloadObj.name = listObj.name
            downloadObj.mediaId = listObj.mediaId
            downloadObj.dataType = listObj.dataType
            downloadObj.slug = listObj.slug
            downloadObj.currentDate = Date()
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
                self.view.isUserInteractionEnabled = true
                self.downloadActivityController.stopAnimating()
                if isMultiDownload {
                    self.groupDispatch.leave()
                } else {
                    _ = AlertController.alert("", message: isDownload ? "Downloaded successfully." : "Added to playlist successfully.")
                }
            })
        }
    }

    
    //MARK: Deinit Method
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    //MARK: Notification Method
    @objc func searchApi(notification: NSNotification) {
        let dict = notification.object as! NSDictionary
        let str = "\(dict["searchValue"] as! String)".trimmingCharacters(in: .whitespaces).lowercased()
        
        if isFrom == "core" || isFrom == "supply" || isFrom == "trade" {
            if str == "" {
                filterArray = mainArray
            } else {
                let filteredItems = mainArray.filter { $0.title.lowercased().contains(str) }
                filterArray = filteredItems
            }
            
            if filterArray.count == 0 {
                self.noSearchFoundLabel.isHidden = false
            } else {
                self.noSearchFoundLabel.isHidden = true
            }
            self.tableView.reloadData()

        } else {
            callApiForHomeData(searchText: str)
        }
    }

    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expandCell: CALibraryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CALibraryTableViewCellID") as! CALibraryTableViewCell
        
        let obj = filterArray[indexPath.row]
        expandCell.cellTitleLabel.text = obj.title
        expandCell.cellBottomView.isHidden = !obj.isSelect
        expandCell.playNowButton.tag = indexPath.row+100
        expandCell.shareButton.tag = indexPath.row+100
        expandCell.readTextbutton.tag = indexPath.row+100
        expandCell.addToPlaylistButton.tag = indexPath.row+100
        expandCell.downloadButton.tag = indexPath.row+100
        expandCell.typeImageView.isHidden = false
        
        if isFrom == "" {
            if obj.dataType == "presentations" {
                expandCell.typeImageView.image = UIImage(named:"todays-doc")
            } else if obj.dataType == "news" {
                expandCell.typeImageView.image = UIImage(named:"today-news")
            } else {
                expandCell.typeImageView.image = UIImage(named:"today-document")
            }
        } else {
            expandCell.typeImageView.isHidden = true
        }
        
        expandCell.cellImageView.sd_setImage(with: URL(string: obj.mediaURL), placeholderImage: UIImage(named: "Placeholder"))
        if obj.createdAt != "" {
            expandCell.dateLabel.text = BTAppUtility.convertDateString(dateString: obj.createdAt, fromFormat: "YYYY-MM-dd", toFormat: "dd MMM, YYYY")
        }
        
        //Rotate Image
        if obj.isSelect {
            UIView.animate(withDuration: 0.2, animations: {
                expandCell.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                expandCell.arrowImageView.transform = CGAffineTransform.identity
            })
        }
        
        expandCell.downloadButton.addTarget(self, action: #selector(downloadAction), for: .touchUpInside)
        expandCell.playNowButton.addTarget(self, action: #selector(playNowAction), for: .touchUpInside)
        expandCell.readTextbutton.addTarget(self, action: #selector(readTextAction), for: .touchUpInside)
        expandCell.shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        expandCell.addToPlaylistButton.addTarget(self, action: #selector(addPlaylistAction), for: .touchUpInside)
        
        return expandCell
    }
    
    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = filterArray[indexPath.row]
        obj.isSelect = !obj.isSelect
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = filterArray[indexPath.row]
        if obj.isSelect {
            return 180.0
        }
        return 89.0
    }
    
    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        let str = textField.text?.trimmingCharacters(in: .whitespaces).lowercased()
        if str == "" {
            filterArray = mainArray
        } else {
            let filteredItems = mainArray.filter { $0.title.lowercased().contains(str!) }
            filterArray = filteredItems
        }
        
        if filterArray.count == 0 {
            self.noSearchFoundLabel.isHidden = false
        } else {
            self.noSearchFoundLabel.isHidden = true
        }
        self.tableView.reloadData()
        return true
    }
    

    //MARK: UIButton Action Method
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Selector Method
    @objc func downloadAction(sender: UIButton) {
        _ = AlertController.alert("", message: "Are you sure you want to download?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
            if index == 0 {
                let listObj = self.filterArray[sender.tag-100]
                self.callApiForDownloadData(obj: listObj, isDownload: "1")
            }
        })
    }
    
    @objc func playNowAction(sender: UIButton) {
        let playVC = CAPlayViewController()
        playVC.playArray = filterArray
        playVC.playingIndex = sender.tag-100
        self.navigationController?.pushViewController(playVC, animated: true)
    }
    
    @objc func readTextAction(sender: UIButton) {
        let obj = filterArray[sender.tag-100]
        let readVC = CAReadTextViewController()
        readVC.readObj = obj
        self.present(readVC, animated: true, completion: nil)
    }
    
    @objc func shareAction(sender: UIButton) {
        let obj = filterArray[sender.tag-100]
        let shareText = "Core App shared a \(obj.dataType):- \(obj.title)"
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func addPlaylistAction(sender: UIButton) {
        _ = AlertController.alert("", message: "Are you sure you want to add to playlist?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
            if index == 0 {
                let listObj = self.filterArray[sender.tag-100]
                self.callApiForDownloadData(obj: listObj, isDownload: "0")
            }
        })
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
                        self.mainArray.removeAll()
                        
                        self.searchInfo = CAHomeInfo.modelFromHomeDict(dataDict)
                        self.mainArray = self.searchInfo.documentArray + self.searchInfo.newsArray + self.searchInfo.presentationArray
                        self.filterArray = self.mainArray
                        
                        if self.filterArray.count == 0 {
                            self.noSearchFoundLabel.isHidden = false
                        } else {
                            self.noSearchFoundLabel.isHidden = true
                        }
                        self.tableView.reloadData()
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
    
    
    
    func callApiForCoreMonthlyData()
    {
        CAServiceHelper.request(Dictionary<String, AnyObject>(), method: .get, apiName: pCorMonthly, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        let dataArray = response.validatedValue("data", expected: Array<Any>() as AnyObject) as! [Dictionary<String,AnyObject>]
                        self.mainArray.removeAll()

                        for dict in dataArray {
                            self.mainArray.append(CAHomeInfo.modelFromCoreMonthlyDict(dict))
                        }
                        
                        self.filterArray = self.mainArray
                        if self.filterArray.count == 0 {
                            self.noSearchFoundLabel.isHidden = false
                        } else {
                            self.noSearchFoundLabel.isHidden = true
                        }
                        self.tableView.reloadData()
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
    
    func callApiForSupplyData(supply: String, trade: String)
    {
        var dict = Dictionary<String, AnyObject>()
        dict[pSupplyChain] = supply as AnyObject
        dict[pTradeFaci] = trade as AnyObject

        CAServiceHelper.request(dict, method: .get, apiName: pTrade, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200) {
                        let dataArray = response.validatedValue("data", expected: Array<Any>() as AnyObject) as! [Dictionary<String,AnyObject>]
                        self.mainArray.removeAll()
                        for dict in dataArray {
                            self.mainArray.append(CAHomeInfo.modelFromCoreMonthlyDict(dict))
                        }
                        
                        self.filterArray = self.mainArray
                        self.addDataToDatabase()
                        
                        if self.filterArray.count == 0 {
                            self.noSearchFoundLabel.isHidden = false
                        } else {
                            self.noSearchFoundLabel.isHidden = true
                        }
                        self.tableView.reloadData()
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
    
    func callApiForDownloadData(obj: CAHomeInfo, isDownload: String)
    {
        var dict = Dictionary<String, AnyObject>()
        
        dict[pID] = obj.homeId as AnyObject
        dict[pType] = obj.dataType as AnyObject
        dict[pDownload] = isDownload as AnyObject
        
        CAServiceHelper.request(dict, method: .get, apiName: pDownload, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                if let response = result as? Dictionary<String, AnyObject> {
                    if(status == 201 || status == 200) {
                        
                        if isDownload == "0" {
                            self.addDataToDataBase(listObj: obj, isDownload: false, obj: DownloadedClass(), isMultiDownload: false)
                        } else {
                            self.view.isUserInteractionEnabled = false
                            self.downloadActivityController.startAnimating()
                            
                            let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
                            let filteredArray = userObj?.downloadData.filter() { $0.homeId == obj.homeId && $0.dataType == obj.dataType }
                            if (filteredArray?.count)! > 0 {
                                self.convertIntoData(homeObj: obj, realmObj: (filteredArray?.first)!, isMultiDownload: false)
                            } else {
                                self.convertIntoData(homeObj: obj, realmObj: DownloadedClass(), isMultiDownload: false)
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

    
    func callApiForMultipleDownloadData(deletedArray: [CAHomeInfo])
    {
        var dict = Dictionary<String, AnyObject>()
        var deleteArray = [Dictionary<String, Any>]()
        for obj in deletedArray {
            let tempDict = [pID: obj.homeId, pType: obj.dataType, pDownload: "1"]
            deleteArray.append(tempDict)
        }
        dict["data"] = deleteArray as AnyObject

        CAServiceHelper.request(dict, method: .post, apiName: pMultipleDownload, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                if let response = result as? Dictionary<String, AnyObject> {
                    if(status == 201 || status == 200) {
                        
                        self.view.isUserInteractionEnabled = false
                        self.downloadActivityController.startAnimating()

                        for obj in deletedArray {
                            self.groupDispatch.enter()
                            self.convertIntoData(homeObj: obj, realmObj: DownloadedClass(), isMultiDownload: true)
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

    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }


    //MARK: Memory Management Method
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
