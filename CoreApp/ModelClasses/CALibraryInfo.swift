//
//  CALibraryInfo.swift
//  CoreApp
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CALibraryInfo: NSObject {
    var isSelect = Bool()
    var homeId = ""
    var name = ""
    var slug = ""
    var titleDescription = ""
    var mediaId = ""
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
    var categoryArray = [CAHomeInfo]()

    class func modelFromLibraryDict(_ infoDict:Dictionary<String, AnyObject>) -> CALibraryInfo {
        
        let obj = CALibraryInfo()
        obj.homeId = "\(infoDict.validatedValue(pID, expected: "" as AnyObject))"
        obj.isSelect = false
        obj.name = "\(infoDict.validatedValue(pName, expected: "" as AnyObject))"
        obj.slug = "\(infoDict.validatedValue(pSlug, expected: "" as AnyObject))"
        obj.titleDescription = "\(infoDict.validatedValue(pDescription, expected: "" as AnyObject))"
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
}
