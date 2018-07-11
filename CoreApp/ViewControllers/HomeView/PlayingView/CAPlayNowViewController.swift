//
//  CAPlayNowViewController.swift
//  CoreApp
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import LongPressReorder
import AVFoundation
import RealmSwift

class CAPlayNowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    var mainArray = List<DownloadedClass>()
    var deletedArray = List<DownloadedClass>()
    var homeArray = [CAHomeInfo]()
    var filterHomeArray = [CAHomeInfo]()

    var stringData = Data()
    var reorderTableView: LongPressReorderTableView!
    var isShowLogo = Bool()
    var playingIndex = Int()
    var avAudioPlayer: AVAudioPlayer?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var backSkipButton: UIButton!
    @IBOutlet weak var privButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var musicBackgroundView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var noDataFoundLabel: UILabel!

    //MARK: UIView Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    //MARK: Custom Method
    func initialSetup()  {
        //Register Cell
        self.tableView.register(UINib(nibName: "CAPlayListTableViewCell", bundle: nil), forCellReuseIdentifier: "PlayListCellID")

        //Add Blur Effect on Music Image
        self.musicImageView.addBlurEffect(isBlur: true)
        self.playButton.isSelected = true
        self.musicBackgroundView.isUserInteractionEnabled = false
        playingIndex = -1
        
        //Add Reorder tableView
        reorderTableView = LongPressReorderTableView(tableView)
        reorderTableView.delegate = self
        reorderTableView.enableLongPressReorder()

        self.tableView.estimatedRowHeight = 100.0

        //Add Observer
        NotificationCenter.default.addObserver(self, selector: #selector(searchApi(notfication:)), name: NSNotification.Name("playingNotification"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(stopPlay), name: NSNotification.Name("stopPlaying"), object: nil)

        getDataFromDataBase()
    }


    func convertIntoData(realmObj: CAHomeInfo, index: Int) {

        let speechSynthesizer = SpeechSynthesizer(accessToken: "pk.eyJ1Ijoid29uZGVycGlsbGFycyIsImEiOiJjamdscnU0Z20xeW9kMzNwanlkcHp6MG5xIn0.7OxVz8nUxhLArKFhQVDWIA")
        var splitStrArr = realmObj.titleDescription.splitByLength(490)

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
            self.addDataToDataBase(obj: realmObj, index: index)
        }
    }

    func addDataToDataBase(obj: CAHomeInfo, index: Int) {

        self.filterHomeArray.remove(at: index)
        self.homeArray.remove(at: index)

        obj.presentationData = self.stringData
        obj.isDownload = true
        self.filterHomeArray.insert(obj, at: index)
        self.homeArray.insert(obj, at: index)

        if obj.homeId != "" {
            let realm = try! Realm()
            try! realm.write({
                obj.presentationData = self.stringData
                obj.isDownload = true
                self.view.isUserInteractionEnabled = true
                // self.downloadActivityController.stopAnimating()
                _ = AlertController.alert("", message:"Downloaded successfully.")
            })
            self.tableView.reloadData()
        }
    }


    func getDataFromDataBase() {
        let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)

        if userObj != nil {

            let appDel = UIApplication.shared.delegate as! AppDelegate
            if appDel.checkReachablility() {
                self.mainArray = (userObj?.downloadData)!

                // self.filterArray = self.mainArray

                for dict in self.mainArray {
                    self.homeArray.append(CAHomeInfo.modelFromPlaylistDataBase(dict))
                }
                self.filterHomeArray = self.homeArray
                let deletevalue = NSUSERDEFAULT.integer(forKey: "deletePreference")

                if deletevalue != 3 {
                    for obj in self.mainArray {
                        if (deletevalue == 1 && obj.isPlayMedia) || (deletevalue == 2 && !obj.isPlayMedia) {
                            let diffInMin = Calendar.current.dateComponents([.minute], from: obj.currentDate, to: Date()).minute

                            let prreferenceTime =  NSUSERDEFAULT.integer(forKey: "delete_prefrence_time")

                            if diffInMin! > prreferenceTime {
                                deletedArray.append(obj)
                            }
                        } else if (deletevalue == 0 && obj.isPlayMedia) {
                            let diffInMin = Calendar.current.dateComponents([.minute], from: obj.heardDate, to: Date()).minute

                            if diffInMin! > 10080 {
                                deletedArray.append(obj)
                            }
                        }
                    }
                    if deletedArray.count > 0 {
                        callApiForAutoDelete(indexPath: IndexPath(), isAutoDelete: true)
                    }
                }
            } else {
                for obj in (userObj?.downloadData)! {
                    if obj.isDownload {
                        self.mainArray.append(obj)
                    }

                    for dict in self.mainArray {
                        self.homeArray.append(CAHomeInfo.modelFromPlaylistDataBase(dict))
                    }
                    self.filterHomeArray = self.homeArray

                }
            }
            if self.filterHomeArray.count == 0 {
                self.tableView.isHidden = true
                self.musicBackgroundView.isHidden = true
                self.noDataFoundLabel.isHidden = false
            }
        }
    }

    func playNow() {
        //Play Method
        if self.filterHomeArray.count > 0 {
            playAudio()
        } else {
            self.tableView.isHidden = true
            self.musicBackgroundView.isHidden = true
            self.noDataFoundLabel.isHidden = false
        }
    }


    func playAudio() {
        self.indicatorView.startAnimating()
        self.musicBackgroundView.isUserInteractionEnabled = false
        var stringData = Data()

        let playObj = filterHomeArray[playingIndex]
        playObj.isPlayMedia = true

        let obj = mainArray[playingIndex]

        let realm = try! Realm()
        try! realm.write {
            obj.isPlayMedia = true
            obj.heardDate = "\(obj.heardDate)" == "" ? Date() : obj.heardDate
        }

        if playObj.isDownload {
            stringData = playObj.presentationData
            startPlay(obj: playObj, stringData: stringData)
        } else {
            let speechSynthesizer = SpeechSynthesizer(accessToken: "pk.eyJ1Ijoid29uZGVycGlsbGFycyIsImEiOiJjamdscnU0Z20xeW9kMzNwanlkcHp6MG5xIn0.7OxVz8nUxhLArKFhQVDWIA")

            let splitStrArr = playObj.titleDescription.splitByLength(450)

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
                            stringData.append(dataArr[index])
                        }
                    }
                }
            }

            myGroup.notify(queue: .main) {
                self.startPlay(obj: playObj, stringData: stringData)
            }
        }
    }

    func startPlay(obj: CAHomeInfo, stringData: Data) {
        do {
            self.avAudioPlayer = try AVAudioPlayer(data: stringData)

            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            self.avAudioPlayer?.delegate = self
            self.avAudioPlayer?.prepareToPlay()
            self.avAudioPlayer?.volume = 0.7
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
            self.musicBackgroundView.isUserInteractionEnabled = true
            self.textView.text = obj.titleDescription
        } catch {
            print(error)
        }
    }

    func stop() {
        self.avAudioPlayer?.stop()
        self.avAudioPlayer?.currentTime = 0
        self.slider.value = 0.0
    }

    //MARK: Deinit Method
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    //MARK: Notification Method
    @objc func searchApi(notfication: NSNotification) {
        let dict = notfication.object as! NSDictionary
        let str = "\(dict["searchValue"] as! String)".trimmingCharacters(in: .whitespaces).lowercased()

        if str == "" {
            filterHomeArray = homeArray
        } else {
            let filteredItems = homeArray.filter{ $0.title.lowercased().contains(str) }
            filterHomeArray = filteredItems
        }
        stop()
        playingIndex = -1

        if filterHomeArray.count == 0 {
            self.noDataFoundLabel.isHidden = false
            self.tableView.isHidden = true
            self.musicBackgroundView.isHidden = true

        } else {
            self.playButton.isSelected = true
            self.tableView.isHidden = false
            self.musicBackgroundView.isHidden = false
            self.noDataFoundLabel.isHidden = true
        }
        self.tableView.reloadData()
    }

    @objc func stopPlay() {
        stop()
    }

    //MARK: UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterHomeArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expandCell: CAPlayListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayListCellID") as! CAPlayListTableViewCell
        let obj = filterHomeArray[indexPath.row]

        expandCell.cellTitleLabel.text = obj.title
        if playingIndex == indexPath.row {
            expandCell.playingImageView.isHidden = false
            expandCell.playingImageView.image = UIImage.gifImageWithName("playingImage")
        } else {
            expandCell.playingImageView.isHidden = true
        }

        if obj.isDownload {
            expandCell.downloadLabel.text = "Downloaded"
        } else {
            expandCell.downloadLabel.text = "Download"
        }

        expandCell.cellBottomView.isHidden = !obj.isExpand
        expandCell.playNowButton.tag = indexPath.row+100
        expandCell.shareButton.tag = indexPath.row+100
        expandCell.readTextbutton.tag = indexPath.row+100
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

        return expandCell
    }


    //MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = filterHomeArray[indexPath.row]
        //Add data to realm
        let realm = try! Realm()
        try! realm.write({
            obj.isExpand = !obj.isExpand
        })
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = filterHomeArray[indexPath.row]
        if obj.isExpand {
            return 180.0
        }
        return 89.0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDel = UIApplication.shared.delegate as! AppDelegate
            if appDel.checkReachablility() {
                let objRealm = mainArray[indexPath.row]

                deletedArray.append(objRealm)
                callApiForAutoDelete(indexPath: indexPath, isAutoDelete: false)
            } else {
                _ = AlertController.alert("", message: "Please connect to internet connection to delete it.")
            }
        }
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

        let obj = filterHomeArray[sender.tag-100]

        if obj.isDownload {
            _ = AlertController.alert("", message: "Already Downloaded.")
        } else {
            _ = AlertController.alert("", message: "Are you sure you want to download?", controller: self, buttons: ["Yes", "No"], tapBlock: { (Action, index) in
                if index == 0 {
                    let obj = self.filterHomeArray[sender.tag-100]
                    self.callApiForDownloadData(obj: obj, index: sender.tag-100)
                }
            })
        }
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
        let obj = filterHomeArray[sender.tag-100]
        let readVC = CAReadTextViewController()
        readVC.readObj = obj
        readVC.isFromPlayList = false
        self.present(readVC, animated: true, completion: nil)
    }

    @objc func shareAction(sender: UIButton) {
        let obj = filterHomeArray[sender.tag-100]
        let shareText = "Core App shared you a \(obj.dataType):- \(obj.title)"
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        self.present(vc, animated: true, completion: nil)
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
        if playingIndex < filterHomeArray.count-1 {
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
        time -= 15.0 // Go backward by 15 seconds
        if time < 0
        {
            stop()
            playButton.isSelected = true
        } else
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
        time += 15.0 // Go forward by 10 seconds

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


    //MARK: AVAudioPlayer Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if playingIndex < filterHomeArray.count-1 {
            playButton.isSelected = false
            stop()
            playingIndex = playingIndex+1
            playAudio()
        } else {
            playButton.isSelected = true
        }
    }


    func callApiForAutoDelete(indexPath: IndexPath, isAutoDelete: Bool)
    {
        var deleteDict = Dictionary<String, Any>()
        var deleteArray = [Dictionary<String, Any>]()
        for obj in deletedArray {
            let dict = ["id": obj.homeId, "type": obj.dataType]
            deleteArray.append(dict)
        }
        deleteDict["data"] = deleteArray

        CAServiceHelper.request(deleteDict, method: .post, apiName: pAutoDelete, hudType: .simple) { (result, error, status) in

            if (error == nil) {

                if let response = result as? Dictionary<String, AnyObject> {

                    if(status == 201 || status == 200) {

                        if isAutoDelete {
                            let realm = try! Realm()
                            try! realm.write {
                                realm.delete(self.deletedArray)
                                let userObj = DBDataBaseManager.getInfoByEmail(email: NSUSERDEFAULT.value(forKey: "loginUserEmail") as! String)
                                self.mainArray = (userObj?.downloadData)!
                            }
                            self.deletedArray.removeAll()
                            self.tableView.reloadData()
                            self.playNow()
                        } else {
                            self.filterHomeArray.remove(at: indexPath.row)
                            self.homeArray.remove(at: indexPath.row)

                            let realm = try! Realm()
                            try! realm.write {
                                self.mainArray.remove(at: indexPath.row)
                                //                                    realm.delete(self.filterArray[indexPath.row])
                                self.tableView.deleteRows(at: [indexPath], with: .fade)
                                self.playingIndex = -1
                                self.tableView.reloadData()
                            }
                        }

                        if self.filterHomeArray.count == 0 {
                            self.tableView.isHidden = true
                            self.musicBackgroundView.isHidden = true
                            self.noDataFoundLabel.isHidden = false
                            self.stop()
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


    func callApiForDownloadData(obj: CAHomeInfo, index: Int)
    {
        var dict = Dictionary<String, AnyObject>()

        dict[pID] = obj.homeId as AnyObject
        dict[pType] = obj.dataType as AnyObject
        dict[pDownload] = "1" as AnyObject

        CAServiceHelper.request(dict, method: .get, apiName: pDownload, hudType: .simple) { (result, error, status) in

            if (error == nil) {
                if let response = result as? Dictionary<String, AnyObject> {
                    if(status == 201 || status == 200) {
                        self.convertIntoData(realmObj: obj, index: index)
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
extension CAPlayNowViewController {
    override func startReorderingRow(atIndex indexPath: IndexPath) -> Bool {
        return true
    }

    override func allowChangingRow(atIndex indexPath: IndexPath) -> Bool {
        return true
    }

    override func reorderFinished(initialIndex: IndexPath, finalIndex: IndexPath) {
        let realm = try! Realm()
        
        try! realm.write {
            swap(&self.filterHomeArray[initialIndex.row], &self.filterHomeArray[finalIndex.row])
        }
        if playingIndex == initialIndex.row {
            playingIndex = finalIndex.row
        } else if playingIndex == finalIndex.row  {
            playingIndex = initialIndex.row
        }
        self.tableView.reloadData()
    }
}


