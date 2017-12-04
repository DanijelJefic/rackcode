//
//  NotificationModel.swift
//  Rack
//
//  Created by hyperlink on 14/07/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class  NotificationModel : NSObject{
    
    var displayName : String!
    var followersCount : String!
    var followingCount : String!
    var id : String!
    var insertdate : String!
    var isFollowing : String!
    var isRead : String!
    var message : String!
    var notificationId : String!
    var notificationType : String!
    var profile : String!
    
    var rackCell : String!
    var rackCount : String!
    var tagType : String!
    var userId : String!
    var userName : String!
    var viewCount : String!
    var wardrobesImage : String!
    var itemName : String!
    var itemData : ItemModel!
    var isPublic : String!
    var createdDuration : String!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        displayName = json["display_name"].stringValue
        followersCount = json["followers_count"].stringValue
        followingCount = json["following_count"].stringValue
        id = json["id"].stringValue
        insertdate = json["insertdate"].stringValue
        isFollowing = json["is_following"].stringValue
        isRead = json["notification_read"].stringValue
        message = json["message"].stringValue
        notificationId = json["notification_id"].stringValue
        notificationType = json["notification_type"].stringValue
        profile = json["profile"].stringValue
        
        rackCell = json["rackCell"].stringValue
        rackCount = json["rack_count"].stringValue
        tagType = json["tag_type"].stringValue
        userId = json["user_id"].stringValue
        userName = json["user_name"].stringValue
        viewCount = json["view_count"].stringValue
        wardrobesImage = json["wardrobes_image"].stringValue
        itemName = json["item_name"].stringValue
        let itemDataJson = json["item_data"]
        if !itemDataJson.isEmpty{
            itemData = ItemModel(fromJson: itemDataJson)
        }
        isPublic = json["is_public"].stringValue
        createdDuration = json["created_duration"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if displayName != nil{
            dictionary["display_name"] = displayName
        }
        if followersCount != nil{
            dictionary["followers_count"] = followersCount
        }
        if followingCount != nil{
            dictionary["following_count"] = followingCount
        }
        if id != nil{
            dictionary["id"] = id
        }
        if insertdate != nil{
            dictionary["insertdate"] = insertdate
        }
        if isFollowing != nil{
            dictionary["is_following"] = isFollowing
        }
        if isRead != nil{
            dictionary["notification_read"] = isRead
        }
        if message != nil{
            dictionary["message"] = message
        }
        if notificationId != nil{
            dictionary["notification_id"] = notificationId
        }
        if notificationType != nil{
            dictionary["notification_type"] = notificationType
        }
        if profile != nil{
            dictionary["profile"] = profile
        }
        
        if rackCell != nil{
            dictionary["rackCell"] = rackCell
        }
        if rackCount != nil{
            dictionary["rack_count"] = rackCount
        }
        if tagType != nil{
            dictionary["tag_type"] = tagType
        }
        if userId != nil{
            dictionary["user_id"] = userId
        }
        if userName != nil{
            dictionary["user_name"] = userName
        }
        if viewCount != nil{
            dictionary["view_count"] = viewCount
        }
        if wardrobesImage != nil{
            dictionary["wardrobes_image"] = wardrobesImage
        }
        if itemName != nil{
            dictionary["item_name"] = itemName
        }
        if itemData != nil{
            dictionary["item_data"] = itemData.toDictionary()
        }
        if isPublic != nil{
            dictionary["is_public"] = isPublic
        }
        if createdDuration != nil{
            dictionary["created_duration"] = createdDuration
        }
        return dictionary
    }
    
    internal class func modelsFromDictionaryArray(array:[JSON]) -> [NotificationModel] {
        var models:[NotificationModel] = []
        for item in array
        {
            models.append(NotificationModel(fromJson: item))
        }
        return models
    }
    
    //MARK: - Helper Method
    func getInsertDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self.insertdate) {
            return date
        }
        return nil
    }
    
    func calculatePostTime() -> String {
        guard let insertDate = self.getInsertDate() else {
            return ""
        }
        
//        if let _ = createdDuration {
//
//            let seconds = createdDuration
//            return GFunction.shared.conversionSecondsToPostDuration(Int(seconds!))
//
//        } else {
        
            let localDate = insertDate.convertToLocal(sourceDate: insertDate)
            let seconds = Date().timeIntervalSince(localDate)
            return GFunction.shared.conversionSecondsToPostDuration(Int(seconds))
//        }
    }
    
    func getUserName() -> String {
        var uName : String = ""
        
        if self.userId == UserModel.currentUser.userId {
            uName = UserModel.currentUser.userName
        } else {
            uName = userName
        }
        
        return uName.replacingOccurrences(of: "@", with: "")
    }
    
    
    
    func getUserProfile() -> String {
        var img : String = ""
        if id == UserModel.currentUser.userId {
            img = UserModel.currentUser.profile
        } else {
            img = profile
        }
        return img
    }
    
    func isPrivateProfile() -> Bool {
        
        if self.isPublic == profileType.kPrivate.rawValue {
            return true
        } else {
            return false
        }
    }
}
