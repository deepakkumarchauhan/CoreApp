//
//  CAPlayViewController.swift
//  CoreApp
//
//  Created by apple on 4/25/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import LongPressReorder
import AVFoundation
import RealmSwift

class CAPlayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AVAudioPlayerDelegate {
    var playArray = [CAHomeInfo]()
    var filterArray = [CAHomeInfo]()
    var isShowLogo = Bool()
    var playingIndex = Int()
    var avAudioPlayer: AVAudioPlayer?
    var stringData = Data()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backSkipButton: UIButton!
    @IBOutlet weak var privButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var searchTextField: CustomTextField!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playMainView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noDataFoundImageView: UILabel!
    @IBOutlet weak var downloadActivityIndicator: UIActivityIndicatorView!
    
    
    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    //MARK: Custom Method
    func initialSetup()  {
        //Register Cell
        self.tableView.register(UINib(nibName: "CALibraryTableViewCell", bundle: nil), forCellReuseIdentifier: "CALibraryTableViewCellID")
        
        //Add Blur Effect on Music Image
        self.musicImageView.addBlurEffect(isBlur: true)
        filterArray = playArray
        
        //Play Method
        playAudio()
    }
    
    func playAudio() {
        self.backButton.isUserInteractionEnabled = false
        self.indicatorView.startAnimating()
        self.playMainView.isUserInteractionEnabled = false
        print(playingIndex)
        
        let playObj = filterArray[playingIndex]
        let speechSynthesizer = SpeechSynthesizer(accessToken: "pk.eyJ1Ijoid29uZGVycGlsbGFycyIsImEiOiJjamdscnU0Z20xeW9kMzNwanlkcHp6MG5xIn0.7OxVz8nUxhLArKFhQVDWIA")

        let splitStrArr = playObj.titleDescription.splitByLength(490)
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
            do {
                self.avAudioPlayer = try AVAudioPlayer(data: self.stringData as Data)
                
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)

                self.avAudioPlayer?.delegate = self
                self.avAudioPlayer?.volume = 0.7
                self.avAudioPlayer?.prepareToPlay()
                self.slider.maximumValue = Float((self.avAudioPlayer?.duration)!)
                self.slider.value = 0.0
                self.startTimeLabel.text = String(format: "%.2f", self.slider.value)
                
                let sec = (self.slider.maximumValue).truncatingRemainder(dividingBy: 60)
                let min = (self.slider.maximumValue) / 60
                
                self.endTimeLabel.text = String(format: "%d:%.2d", Int(min),Int(sec))
                
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateAudioProgressView), userInfo: nil, repeats: true)
                self.avAudioPlayer?.play()
                self.tableView.reloadData()
                self.indicatorView.stopAnimating()
                self.playMainView.isUserInteractionEnabled = true
                self.backButton.isUserInteractionEnabled = true
                self.textView.text = playObj.titleDescription
                
            } catch {
                print(error)
            }
        }
    }
    
    func stop() {
        self.avAudioPlayer?.stop()
        self.avAudioPlayer?.currentTime = 0
        self.slider.value = 0.0
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
            downloadObj.mediaId = listObj.mediaId
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


    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expandCell: CALibraryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CALibraryTableViewCellID") as! CALibraryTableViewCell
        let obj = filterArray[indexPath.row]
        expandCell.cellTitleLabel.text = obj.title
        if playingIndex == indexPath.row {
            expandCell.playingImageView.isHidden = false
            expandCell.playingImageView.image = UIImage.gifImageWithName("playingImage")
        } else {
            expandCell.playingImageView.isHidden = true
        }
        
        expandCell.cellBottomView.isHidden = !obj.isExpand
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
        if obj.isExpand {
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
        obj.isExpand = !obj.isExpand
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = filterArray[indexPath.row]
        if obj.isExpand {
            return 180.0
        }
        return 89.0
    }
    
    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        let str = textField.text?.trimmingCharacters(in: .whitespaces).lowercased()
        if str == "" {
            filterArray = playArray
        } else {
            let filteredItems = playArray.filter { $0.title.lowercased().contains(str!) }
            filterArray = filteredItems
        }
        
        if filterArray.count == 0 {
            self.noDataFoundImageView.isHidden = false
        } else {
            self.noDataFoundImageView.isHidden = true
        }
        self.tableView.reloadData()
        return true
    }

    //MARK: Selector Method
    @objc func updateAudioProgressView()
    {
        self.slider.value = Float((self.avAudioPlayer?.currentTime)!)
        let sec = (self.slider.value).truncatingRemainder(dividingBy: 60)
        let min = (self.slider.value) / 60
        self.startTimeLabel.text = String(format: "%d:%.2d", Int(min),Int(sec))
    }

    @objc func downloadAction(sender: UIButton) {
        _ = AlertController.alert("", message: "Are you sure you want to download?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
            if index == 0 {
                
                let listObj = self.filterArray[sender.tag-100]
                self.callApiForDownloadData(obj: listObj, isDownload: "1")
            }
        })
    }
    
    @objc func playNowAction(sender: UIButton) {
        playButton.isSelected = false
        stop()
        playingIndex = sender.tag-100
        playAudio()
    }
    
    @objc func readTextAction(sender: UIButton) {
        stop()
        playButton.isSelected = true
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
    
    
    //MARK: UIButton Action Methods
    @IBAction func sliderAction(_ sender: Any) {
        self.avAudioPlayer?.currentTime = TimeInterval(self.slider.value)
        let sec = (self.avAudioPlayer?.currentTime)!.truncatingRemainder(dividingBy: 60)
        let min = (self.avAudioPlayer?.currentTime)! / 60
        self.startTimeLabel.text = String(format: "%d:%.2d", Int(min),Int(sec))
    }
    
    @IBAction func playButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (avAudioPlayer?.isPlaying)! {
            avAudioPlayer?.pause()
        } else {
            avAudioPlayer?.play()
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if playingIndex < filterArray.count-1 {
            playButton.isSelected = false
            stop()
            playingIndex = playingIndex+1
            playAudio()
        }
    }
    
    @IBAction func privButtonAction(_ sender: Any) {
        if playingIndex > 0 {
            playButton.isSelected = false
            stop()
            playingIndex = playingIndex-1
            playAudio()
        }
    }
    
    @IBAction func infoButtonAction(_ sender: Any) {
    }
    
    @IBAction func backwardButtonAction(_ sender: Any) {
        var time: TimeInterval = self.avAudioPlayer!.currentTime
        time -= 15.0 // Go backward by 10 seconds
        if time < 0
        {
            stop()
            playButton.isSelected = true
        }else
        {
            self.avAudioPlayer?.currentTime = time
            let sec = (time).truncatingRemainder(dividingBy: 60)
            let min = (time) / 60
            slider.value = Float((self.avAudioPlayer?.currentTime)!)
            print("Slider Value: \(slider.value)")
            self.startTimeLabel.text = "\(String(format: "%d:%.2d", Int(min),Int(sec)))"
        }
    }
    
    @IBAction func moveButtonAction(_ sender: Any) {
        var time: TimeInterval = self.avAudioPlayer!.currentTime
        time += 15.0 // Go forward by 15 seconds
        
        if time > (self.avAudioPlayer?.duration)!
        {
            stop()
            playButton.isSelected = true
        }else
        {
            self.avAudioPlayer?.currentTime = time
            let sec = time.truncatingRemainder(dividingBy: 60)
            let min = time / 60
            slider.value = Float((self.avAudioPlayer?.currentTime)!)
            print("Slider Value: \(slider.value)")
            self.startTimeLabel.text = "\(String(format: "%d:%.2d", Int(min),Int(sec)))"
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        stop()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: AVAudioPlayer Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if playingIndex < filterArray.count-1 {
            playButton.isSelected = false
            stop()
            playingIndex = playingIndex+1
            playAudio()
        } else {
            playButton.isSelected = true
        }
    }
    
    
    //MARK: Call API
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


// MARK: - Long press drag and drop reorder
extension CAPlayViewController {
    override func startReorderingRow(atIndex indexPath: IndexPath) -> Bool {
        if indexPath.row > 0 {
            return true
        }
        return false
    }
    
    override func allowChangingRow(atIndex indexPath: IndexPath) -> Bool {
        if indexPath.row > 0 {
            return true
        }
        return false
    }
}

