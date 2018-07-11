//
//  CAHomeInfo.swift
//  CoreApp
//
//  Created by apple on 4/24/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class CAHomeInfo: NSObject {
    var isSelect = Bool()
    var isExpand = Bool()
    var isDownload = Bool()
    var isPlayMedia = Bool()
    var currentDate = Date()
    var isPlay = Bool()
    var homeId = ""
    var name = ""
    var slug = ""
    var titleDescription = ""
    var mediaId = ""
    var dataType = ""
    var userId = ""
    var parentId = ""
    var dailyPicId = ""
    var categoryId = ""
    var active = Bool()
    var createdAt = ""
    var updatedAt = ""
    var deletedAt = ""
    var mediaURL = ""
    var thumbnail = ""
    var mediaType = ""
    var title = ""
    var presentationData = Data()

    
    
    var newsArray = [CAHomeInfo]()
    var dailyPicArray = [CAHomeInfo]()
    var documentArray = [CAHomeInfo]()
    var presentationArray = [CAHomeInfo]()
    var categoryArray = [CAHomeInfo]()

    
    class func modelFromHomeDict(_ infoDict:Dictionary<String, AnyObject>?) -> CAHomeInfo {
        
        let mainObj = CAHomeInfo()
        let dailyPicks = infoDict?.validatedValue("dailypicks", expected: [] as AnyObject) as! [Dictionary<String, Any>]
        let presentationsArray = infoDict?.validatedValue("presentations", expected: [] as AnyObject) as! [Dictionary<String, Any>]
        let documentsArray = infoDict?.validatedValue("documents", expected: [] as AnyObject) as! [Dictionary<String, Any>]
        let newsArray = infoDict?.validatedValue("news", expected: [] as AnyObject) as! [Dictionary<String, Any>]

        var index:Int = 0
        
        for _ in 0...3 {
            var tempArr = [Dictionary<String, Any>]()
            if index == 0 {
                tempArr = dailyPicks
            } else if index == 1 {
                tempArr = newsArray
            } else if index == 2 {
                tempArr = documentsArray
            } else if index == 3 {
                tempArr = presentationsArray
            }
            
            for dict in tempArr {
                let obj = CAHomeInfo()
                obj.homeId = "\(dict.validatedValue(pID, expected: "" as AnyObject))"
                obj.name = "\(dict.validatedValue(pName, expected: "" as AnyObject))"
                obj.slug = "\(dict.validatedValue(pSlug, expected: "" as AnyObject))"
                obj.dataType = "\(dict.validatedValue(pType, expected: "" as AnyObject))"
                let descStr = "\(dict.validatedValue(pDescription, expected: "" as AnyObject))".html2String
                let filterStr = String(descStr.filter { !"\n\t\r".contains($0) })
                
                obj.titleDescription = filterStr
                obj.isSelect = false
                obj.isExpand = false
                obj.isPlay = false
                obj.title = "\(dict.validatedValue(pTitle, expected: "" as AnyObject))"
                obj.mediaId = "\(dict.validatedValue(pMediaId, expected: "" as AnyObject))"
                obj.userId = "\(dict.validatedValue(pUserId, expected: "" as AnyObject))"
                obj.active = ("\(dict.validatedValue(pActive, expected: "" as AnyObject))" == "0") ? false : true
                obj.createdAt = "\(dict.validatedValue(pCreatedAt, expected: "" as AnyObject))"
                obj.updatedAt = "\(dict.validatedValue(pUpdatedAt, expected: "" as AnyObject))"
                obj.mediaURL = "\(dict.validatedValue(pMediaUrl, expected: "" as AnyObject))"
                obj.thumbnail = "\(dict.validatedValue(pThumbnail, expected: "" as AnyObject))"
                obj.mediaType = "\(dict.validatedValue(pMediaType, expected: "" as AnyObject))"
                
                let categoryArray = dict.validatedValue("category_data", expected: [] as AnyObject) as! [Dictionary<String, Any>]
                
                for dict in categoryArray {
                    let tempObj = CAHomeInfo()
                    tempObj.homeId = "\(dict.validatedValue(pID, expected: "" as AnyObject))"
                    tempObj.title = "\(dict.validatedValue(pTitle, expected: "" as AnyObject))"
                    tempObj.slug = "\(dict.validatedValue(pSlug, expected: "" as AnyObject))"
                    tempObj.titleDescription = "\(dict.validatedValue(pDescription, expected: "" as AnyObject))"
                    tempObj.mediaId = "\(dict.validatedValue(pMediaId, expected: "" as AnyObject))"
                    tempObj.createdAt = "\(dict.validatedValue(pCreatedAt, expected: "" as AnyObject))"
                    tempObj.updatedAt = "\(dict.validatedValue(pUpdatedAt, expected: "" as AnyObject))"
                    tempObj.mediaURL = "\(dict.validatedValue(pMediaUrl, expected: "" as AnyObject))"
                    tempObj.thumbnail = "\(dict.validatedValue(pThumbnail, expected: "" as AnyObject))"
                    tempObj.mediaType = "\(dict.validatedValue(pMediaType, expected: "" as AnyObject))"
                    tempObj.parentId = "\(dict.validatedValue(pParentId, expected: "" as AnyObject))"
                    
                    let pivotDict = dict.validatedValue("pivot", expected: Dictionary<String, Any>() as AnyObject) as! Dictionary<String, Any>
                    tempObj.dailyPicId = "\((pivotDict.validatedValue(pDailyPicId, expected: "" as AnyObject)))"
                    tempObj.categoryId = "\((pivotDict.validatedValue(pCategoryId, expected: "" as AnyObject)))"
                    obj.categoryArray.append(tempObj)
                }
                if index == 0 {
                    mainObj.dailyPicArray.append(obj)
                } else if index == 1 {
                    mainObj.newsArray.append(obj)
                } else if index == 2 {
                    mainObj.documentArray.append(obj)
                } else if index == 3 {
                    mainObj.presentationArray.append(obj)
                }
            }
            index = index+1
        }
        return mainObj
    }
    
    
    class func modelFromLibraryDict(_ infoDict:Dictionary<String, AnyObject>) -> CAHomeInfo {
        
        let obj = CAHomeInfo()
        obj.homeId = "\(infoDict.validatedValue(pID, expected: "" as AnyObject))"
        obj.isSelect = false
        obj.name = "\(infoDict.validatedValue(pName, expected: "" as AnyObject))"
        obj.slug = "\(infoDict.validatedValue(pSlug, expected: "" as AnyObject))"
        obj.dataType = "\(infoDict.validatedValue(pType, expected: "" as AnyObject))"

        let descStr = "\(infoDict.validatedValue(pDescription, expected: "" as AnyObject))".html2String
        let filterStr = String(descStr.filter { !"\n\t\r".contains($0) })
        
        obj.titleDescription = filterStr
        obj.title = "\(infoDict.validatedValue(pTitle, expected: "" as AnyObject))"
        obj.mediaId = "\(infoDict.validatedValue(pMediaId, expected: "" as AnyObject))"
        obj.userId = "\(infoDict.validatedValue(pUserId, expected: "" as AnyObject))"
        obj.active = ("\(infoDict.validatedValue(pActive, expected: "" as AnyObject))" == "0") ? false : true
        obj.createdAt = "\(infoDict.validatedValue(pCreatedAt, expected: "" as AnyObject))"
        obj.updatedAt = "\(infoDict.validatedValue(pUpdatedAt, expected: "" as AnyObject))"
        obj.mediaURL = "\(infoDict.validatedValue(pMediaUrl, expected: "" as AnyObject))"
        obj.thumbnail = "\(infoDict.validatedValue(pThumbnail, expected: "" as AnyObject))"
        obj.mediaType = "\(infoDict.validatedValue(pMediaType, expected: "" as AnyObject))"
        
        let categoryArray = infoDict.validatedValue("category_data", expected: [] as AnyObject) as! [Dictionary<String, Any>]
        
        for dict in categoryArray {
            let tempObj = CAHomeInfo()
            tempObj.homeId = "\(dict.validatedValue(pID, expected: "" as AnyObject))"
            tempObj.title = "\(dict.validatedValue(pTitle, expected: "" as AnyObject))"
            tempObj.slug = "\(dict.validatedValue(pSlug, expected: "" as AnyObject))"
            tempObj.titleDescription = "\(dict.validatedValue(pDescription, expected: "" as AnyObject))"
            tempObj.mediaId = "\(dict.validatedValue(pMediaId, expected: "" as AnyObject))"
            tempObj.createdAt = "\(dict.validatedValue(pCreatedAt, expected: "" as AnyObject))"
            tempObj.updatedAt = "\(dict.validatedValue(pUpdatedAt, expected: "" as AnyObject))"
            tempObj.mediaURL = "\(dict.validatedValue(pMediaUrl, expected: "" as AnyObject))"
            tempObj.thumbnail = "\(dict.validatedValue(pThumbnail, expected: "" as AnyObject))"
            tempObj.mediaType = "\(dict.validatedValue(pMediaType, expected: "" as AnyObject))"
            tempObj.parentId = "\(dict.validatedValue(pParentId, expected: "" as AnyObject))"
            
            let pivotDict = dict.validatedValue("pivot", expected: Dictionary<String, Any>() as AnyObject) as! Dictionary<String, Any>
            tempObj.dailyPicId = "\((pivotDict.validatedValue(pDailyPicId, expected: "" as AnyObject)))"
            tempObj.categoryId = "\((pivotDict.validatedValue(pCategoryId, expected: "" as AnyObject)))"
            obj.categoryArray.append(tempObj)
        }
        return obj
    }
    
    class func modelFromCoreMonthlyDict(_ infoDict:Dictionary<String, AnyObject>) -> CAHomeInfo {
        let obj = CAHomeInfo()
        obj.createdAt = "\(infoDict.validatedValue(pCreatedAt, expected: "" as AnyObject))"
        obj.homeId = "\(infoDict.validatedValue(pID, expected: "" as AnyObject))"
        obj.isSelect = false
        obj.isDownload = "\(infoDict.validatedValue(pDownload, expected: "" as AnyObject))" == "0" ? false : true
        obj.title = "\(infoDict.validatedValue(pTitle, expected: "" as AnyObject))"
        obj.mediaURL = "\(infoDict.validatedValue(pMediaUrl, expected: "" as AnyObject))"
        obj.dataType = "\(infoDict.validatedValue(pType, expected: "" as AnyObject))"
        obj.mediaId = "\(infoDict.validatedValue(pMediaId, expected: "" as AnyObject))"

        let descStr = "\(infoDict.validatedValue(pDescription, expected: "" as AnyObject))".html2String
        let filterStr = String(descStr.filter { !"\n\t\r".contains($0) })

        obj.titleDescription = filterStr
        obj.thumbnail = "\(infoDict.validatedValue(pThumbnail, expected: "" as AnyObject))"

        return obj
    }
    
    class func modelFromPlaylistDict(_ infoDict:Dictionary<String, AnyObject>) -> CAHomeInfo {
        let obj = CAHomeInfo()
        obj.createdAt = "\(infoDict.validatedValue(pCreatedAt, expected: "" as AnyObject))"
        obj.homeId = "\(infoDict.validatedValue(pID, expected: "" as AnyObject))"
        obj.isSelect = false
        obj.title = "\(infoDict.validatedValue(pTitle, expected: "" as AnyObject))"
        obj.mediaURL = "\(infoDict.validatedValue(pMediaUrl, expected: "" as AnyObject))"
        obj.dataType = "\(infoDict.validatedValue(pType, expected: "" as AnyObject))"
        obj.mediaId = "\(infoDict.validatedValue(pMediaId, expected: "" as AnyObject))"
        obj.isDownload = "\(infoDict.validatedValue(pDownload, expected: "" as AnyObject))" == "0" ? false : true

        let descStr = "\(infoDict.validatedValue(pDescription, expected: "" as AnyObject))".html2String
        let filterStr = String(descStr.filter { !"\n\t\r".contains($0) })
        
        obj.titleDescription = filterStr
        obj.thumbnail = "\(infoDict.validatedValue(pThumbnail, expected: "" as AnyObject))"
        
        return obj
    }
    
    class func modelFromPlaylistDataBase(_ infoDict:DownloadedClass) -> CAHomeInfo {
        let obj = CAHomeInfo()
        obj.createdAt = infoDict.createdAt
        obj.homeId = infoDict.homeId
        obj.isSelect = infoDict.isSelect
        obj.title = infoDict.title
        obj.mediaURL = infoDict.mediaURL
        obj.dataType = infoDict.dataType
        obj.presentationData = infoDict.presentationData

        obj.mediaId = pMediaId
        obj.isDownload = infoDict.isDownload
        obj.isPlayMedia = infoDict.isPlayMedia
        obj.currentDate = infoDict.currentDate

        let descStr = infoDict.titleDescription.html2String
        let filterStr = String(descStr.filter { !"\n\t\r".contains($0) })

        obj.titleDescription = filterStr
        obj.thumbnail = infoDict.thumbnail

        return obj
    }

}
