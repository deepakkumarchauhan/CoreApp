//
//  CAPaginationInfo.swift
//  CoreApp
//
//  Created by apple on 5/14/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAPaginationInfo: NSObject {
    var pageNumber = String()
    var totalPages = String()

    class func getPaginationData(_ infoDict:Dictionary<String, AnyObject>?) -> CAPaginationInfo {
        let obj = CAPaginationInfo()
        
        obj.pageNumber = "\((infoDict?.validatedValue(pPageNumber, expected: "" as AnyObject))!)"
        obj.totalPages = "\((infoDict?.validatedValue(pTotalPages, expected: "" as AnyObject))!)"
        return obj
    }
}
