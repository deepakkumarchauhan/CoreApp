//
//  DBManager.swift
//  CoreApp
//
//  Created by apple on 5/5/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit
import RealmSwift

class UserClass: Object {
    @objc dynamic var userEmail = ""
   // @objc dynamic var userId = ""
    @objc dynamic var userToken = ""
    let downloadData = List<DownloadedClass>()
    let playListData = List<DocumentsClass>()
//    override static func primaryKey() -> String? {
//        return "userId"
//    }
}

class DownloadedClass: Object {
    @objc dynamic var isSelect = Bool()
    @objc dynamic var isExpand = Bool()
    @objc dynamic var isPlay = Bool()
    @objc dynamic var isPlayMedia = Bool()
    @objc dynamic var isDownload = Bool()
    @objc dynamic var homeId = ""
    @objc dynamic var name = ""
    @objc dynamic var dataType = ""
    @objc dynamic var timeStamp = ""
    @objc dynamic var slug = ""
    @objc dynamic var titleDescription = ""
    @objc dynamic var userId = ""
    @objc dynamic var parentId = ""
    @objc dynamic var dailyPicId = ""
    @objc dynamic var categoryId = ""
    @objc dynamic var active = Bool()
    @objc dynamic var createdAt = ""
    @objc dynamic var updatedAt = ""
    @objc dynamic var deletedAt = ""
    @objc dynamic var mediaURL = ""
    @objc dynamic var mediaId = ""
    @objc dynamic var thumbnail = ""
    @objc dynamic var mediaType = ""
    @objc dynamic var title = ""
    @objc dynamic var heardDate = Date()
    @objc dynamic var currentDate = Date()
    @objc dynamic var presentationData = Data()
}

class DocumentsClass: Object {
    @objc dynamic var isSelect = Bool()
    @objc dynamic var isExpand = Bool()
    @objc dynamic var isPlay = Bool()
    @objc dynamic var timeStamp = ""
    @objc dynamic var homeId = ""
    @objc dynamic var name = ""
    @objc dynamic var slug = ""
    @objc dynamic var titleDescription = ""
    @objc dynamic var userId = ""
    @objc dynamic var parentId = ""
    @objc dynamic var dailyPicId = ""
    @objc dynamic var categoryId = ""
    @objc dynamic var active = Bool()
    @objc dynamic var createdAt = ""
    @objc dynamic var updatedAt = ""
    @objc dynamic var deletedAt = ""
    @objc dynamic var mediaId = ""
    @objc dynamic var mediaURL = ""
    @objc dynamic var thumbnail = ""
    @objc dynamic var mediaType = ""
    @objc dynamic var title = ""
    @objc dynamic var currentDate = Date()
    @objc dynamic var documentData: Data? = nil // optionals supported
}

class PresentationClass: Object {
    @objc dynamic var isSelect = Bool()
    @objc dynamic var isExpand = Bool()
    @objc dynamic var isPlay = Bool()
    @objc dynamic var timeStamp = ""
    @objc dynamic var homeId = ""
    @objc dynamic var name = ""
    @objc dynamic var slug = ""
    @objc dynamic var titleDescription = ""
    @objc dynamic var userId = ""
    @objc dynamic var parentId = ""
    @objc dynamic var dailyPicId = ""
    @objc dynamic var categoryId = ""
    @objc dynamic var active = Bool()
    @objc dynamic var createdAt = ""
    @objc dynamic var updatedAt = ""
    @objc dynamic var deletedAt = ""
    @objc dynamic var mediaId = ""
    @objc dynamic var mediaURL = ""
    @objc dynamic var thumbnail = ""
    @objc dynamic var mediaType = ""
    @objc dynamic var title = ""
    @objc dynamic var currentDate = Date()
    @objc dynamic var documentData: Data? = nil // optionals supported
}



class DBDataBaseManager {
    class func getInfoByEmail(email: String) -> UserClass? {
        let realm = try! Realm()
        let scope = realm.objects(UserClass.self).filter("userEmail == %@", email)
        print(scope)
        return scope.first
    }
}
