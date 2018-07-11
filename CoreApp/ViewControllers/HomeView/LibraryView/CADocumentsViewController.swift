//
//  CADocumentsViewController.swift
//  CoreApplication
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class CADocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FilterProtocol {
    var mainArray = [CAHomeInfo]()
    var filterArray = [CAHomeInfo]()
    var stringData = Data()

    @IBOutlet weak var noDataFoundLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var downloadActivityIndicator: UIActivityIndicatorView!
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup() {
        //Register Cell
        self.tableView.register(UINib(nibName: "CALibraryTableViewCell", bundle: nil), forCellReuseIdentifier: "CALibraryTableViewCellID")
        
        //Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(searchApi(notification:)), name: NSNotification.Name("documentsNotification"), object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(showAllData(notification:)), name: NSNotification.Name("showAllData"), object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(callDocumentsApi(notification:)), name: NSNotification.Name("documentsApiCall"), object: nil)


        callApiForDocumentsData(searchText: "", noFilter: false)
    }
    
    func addDataToDataBase(listObj: CAHomeInfo, isDownload: Bool, obj: DownloadedClass) {
        let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
        
        let downloadObj = DownloadedClass()
        if obj.homeId != "" {
            let realm = try! Realm()
            try! realm.write({
                obj.presentationData = self.stringData
                obj.isDownload = true
                self.view.isUserInteractionEnabled = true
                self.downloadActivityIndicator.stopAnimating()
                _ = AlertController.alert("", message: isDownload ? "Downloaded successfully." : "Added to playlist successfully.")
            })
            
        } else {
            downloadObj.homeId = listObj.homeId
            downloadObj.isExpand = false
            downloadObj.isSelect = false
            downloadObj.isPlay = false
            downloadObj.name = listObj.name
            downloadObj.dataType = listObj.dataType
            downloadObj.currentDate = Date()
            downloadObj.mediaId = listObj.mediaId
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
                self.view.isUserInteractionEnabled = true
                self.downloadActivityIndicator.stopAnimating()
                _ = AlertController.alert("", message: isDownload ? "Downloaded successfully." : "Added to playlist successfully.")
            })
        }
    }
    
    func convertIntoData(homeObj: CAHomeInfo, realmObj: DownloadedClass) {
        
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
                    for index in 0..<dataArr.count {
                        self.stringData.append(dataArr[index])
                    }
                }
            }
        }
        myGroup.notify(queue: .main) {
            if realmObj.homeId != "" {
                self.addDataToDataBase(listObj: homeObj, isDownload: true, obj: realmObj)
            } else {
                self.addDataToDataBase(listObj: homeObj, isDownload: true, obj: DownloadedClass())
            }
        }
    }

    
    //MARK: Deinit Method
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Notification Method
//    @objc func callDocumentsApi(notification: NSNotification) {
//        let dict = notification.object as! NSDictionary
//        let str = "\(dict["searchValue"] as! String)".trimmingCharacters(in: .whitespaces).lowercased()
//        callApiForDocumentsData(searchText: str, noFilter: false)
//
//    }

    @objc func searchApi(notification: NSNotification) {
        let dict = notification.object as! NSDictionary
        let str = "\(dict["searchValue"] as! String)".trimmingCharacters(in: .whitespaces).lowercased()
        //NSUSERDEFAULT.set(0, forKey: "documentsFilter")
        callApiForDocumentsData(searchText: str, noFilter: true)


//        if str == "" {
//            filterArray = mainArray
//        } else {
//            let filteredItems = mainArray.filter { $0.title.lowercased().contains(str) }
//            filterArray = filteredItems
//        }
//
//        if filterArray.count == 0 {
//            self.noDataFoundLabel.isHidden = false
//        } else {
//            self.noDataFoundLabel.isHidden = true
//        }
//        self.tableView.reloadData()
    }
    
    @objc func showAllData(notification: NSNotification) {
        filterArray = mainArray
        self.tableView.reloadData()
    }
    
    
    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
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
        
        expandCell.cellImageView.sd_setImage(with: URL(string: obj.mediaURL), placeholderImage: UIImage(named: "Placeholder"))
        if obj.createdAt != ""  {
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
    
    //MARK: Selector Method
    @objc func downloadAction(sender: UIButton) {
        _ = AlertController.alert("", message: "Are you sure you want to download?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
            if index == 0 {
                let listObj = self.filterArray[sender.tag-100]
                self.callApiForDownloadData(obj: listObj, isDownload: "1")

//                let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
//                let filteredArray = userObj?.downloadData.filter() { $0.homeId == listObj.homeId && $0.dataType == listObj.dataType}
//
//                if filteredArray?.count == 0 {
//                    self.callApiForDownloadData(obj: listObj, isDownload: "1")
//                } else {
//                    _ = AlertController.alert("", message: "Already downloaded.")
//                }
            }
        })
    }
    
    @objc func playNowAction(sender: UIButton) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let playVC = CAPlayViewController()
        playVC.playArray = filterArray
        playVC.playingIndex = sender.tag-100
        appdelegate.navController?.pushViewController(playVC, animated: true)
    }
    
    @objc func readTextAction(sender: UIButton) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let obj = filterArray[sender.tag-100]
        let readVC = CAReadTextViewController()
        readVC.readObj = obj
        appdelegate.navController?.present(readVC, animated: true, completion: nil)
    }
    
    @objc func shareAction(sender: UIButton) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let obj = filterArray[sender.tag-100]
        let shareText = "Core App shared a \(obj.dataType):- \(obj.title)"
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        appdelegate.navController?.present(vc, animated: false, completion: nil)
    }
    
    @objc func addPlaylistAction(sender: UIButton) {
        _ = AlertController.alert("", message: "Are you sure you want to add to playlist?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
            if index == 0 {
                let listObj = self.filterArray[sender.tag-100]
                self.callApiForDownloadData(obj: listObj, isDownload: "0")
            }
        })
    }

    
    //MARK: UIButton Action
    @IBAction func filterButtonAction(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let filterVC = CAFilterViewController()
        filterVC.delegate =  self
        filterVC.fromWhere = "documents"
        filterVC.modalPresentationStyle = .overCurrentContext
        appdelegate.navController?.present(filterVC, animated: false, completion: nil)
    }
    
    //MARK: Custom Delegate Method
    func filterList(strValue: String) {
        callApiForDocumentsData(searchText: strValue, noFilter: false)
    }

    
    //MARK: Call API
    func callApiForDocumentsData(searchText: String, noFilter: Bool)
    {
        var dict = Dictionary<String, AnyObject>()
        var val = Int()
        val = NSUSERDEFAULT.integer(forKey: "documentsFilter")
        if noFilter {
            val = 0
        }

        if val == 1 {
            dict[pThisMonth] = "0" as AnyObject
            dict[pThisWeek] = "1" as AnyObject
            dict[pThisYear] = "0" as AnyObject
        } else if val == 2 {
            dict[pThisMonth] = "1" as AnyObject
            dict[pThisWeek] = "0" as AnyObject
            dict[pThisYear] = "0" as AnyObject
        } else if val == 3 {
            dict[pThisMonth] = "0" as AnyObject
            dict[pThisWeek] = "0" as AnyObject
            dict[pThisYear] = "1" as AnyObject
        } else if val == 4 {
            dict[pThisMonth] = "0" as AnyObject
            dict[pThisWeek] = "0" as AnyObject
            dict[pThisYear] = "0" as AnyObject
            dict[pDownload] = "1" as AnyObject
        } else if val == 5 {
            dict[pThisMonth] = "0" as AnyObject
            dict[pThisWeek] = "0" as AnyObject
            dict[pThisYear] = "0" as AnyObject
            dict[pDownload] = "0" as AnyObject
        }

        dict[pSearch] = searchText as AnyObject

        CAServiceHelper.request(dict, method: .get, apiName: pDocuments, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                
                if let response = result as? Dictionary<String, AnyObject> {
                    
                    if(status == 201 || status == 200){
                        
                        self.mainArray.removeAll()
                        let dataArray = response.validatedValue("data", expected: [Dictionary<String,AnyObject>]() as AnyObject) as! [Dictionary<String,AnyObject>]
                        for dict in dataArray {
                            self.mainArray.append(CAHomeInfo.modelFromLibraryDict(dict))
                        }
                        self.filterArray = self.mainArray
                        if self.filterArray.count == 0 {
                            self.noDataFoundLabel.isHidden = false
                        } else {
                            self.noDataFoundLabel.isHidden = true
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
        dict[pDownload] = isDownload as AnyObject
        dict[pType] = obj.dataType as AnyObject

        CAServiceHelper.request(dict, method: .get, apiName: pDownload, hudType: .simple) { (result, error, status) in
            
            if (error == nil) {
                if let response = result as? Dictionary<String, AnyObject> {
                    if(status == 201 || status == 200) {
                        
                        if isDownload == "0" {
                            self.addDataToDataBase(listObj: obj, isDownload: false, obj: DownloadedClass())
                        } else {
                            self.view.isUserInteractionEnabled = false
                            self.downloadActivityIndicator.startAnimating()
                            
                            let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
                            let filteredArray = userObj?.downloadData.filter() { $0.homeId == obj.homeId && $0.dataType == obj.dataType }
                            if (filteredArray?.count)! > 0 {
                                self.convertIntoData(homeObj: obj, realmObj: (filteredArray?.first)!)
                            } else {
                                self.convertIntoData(homeObj: obj, realmObj: DownloadedClass())
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
