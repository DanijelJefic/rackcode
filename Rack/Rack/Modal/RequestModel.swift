//
//  RequestModel.swift
//  Rack
//
//  Created by hyperlink on 06/06/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit


class RequestModel: NSObject {

    var email                   : String!
    var password                : String!
    var device_type             : String!
    var device_token            : String!
    var login_type              : String!
    var fb_id                   : String!
    var usernm_email            : String!

    var user_id                 : String!
    var user_name               : String!
    var display_name            : String!
    var bio_txt                 : String!

    var wardrobes_id            : String!
    
    var search_flag             : String!
    var search_value            : String!
    var search_id               : String!
    var page                    : String!
    
    var requested_users         : String!
    
    var old_password            : String!
    var new_password            : String!
    
    var is_public               : String!
    var show_rack               : String!
    var user_type               : String!
    
    var status                  : String!
    var request_id              : String!

    var item_type               : String!
    var repost                  : String!
    var share_type              : String!
    var caption                 : String!
    var tag_brand               : String!
    var tag_people              : String!
    var add_link                : String!
    var hashtag                 : String!
    var tag_item                : String!
    var item_id                 : String!
    var is_like                 : String!
    var width                   : String!
    var height                  : String!
    //
    var type                    : String!
    var timestamp               : String!
    var pass_timestamp          : String!
    var end_timestamp           : String!
    
    var comment                 : String!
    
    var comment_id              : String!
    
    var report_id               : String!
    var report_type             : String!
    var offender_id             : String!
    var reason                  : String!
    
    var notificationId          : String!
    
    var name                    : String!
    
    var social_keys             : JSON!
    
    var tutorial_type           : String!

    override init() {
        super.init()
    }

    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }

        email = json["email"].stringValue
        password = json["password"].stringValue
        device_type = json["device_type"].stringValue
        device_token = json["device_token"].stringValue
        login_type = json["login_type"].stringValue
        fb_id = json["fb_id"].stringValue
        usernm_email = json["usernm_email"].stringValue
        
        user_id = json["user_id"].stringValue
        user_name = json["user_name"].stringValue
        display_name = json["display_name"].stringValue
        bio_txt = json["bio_txt"].stringValue
        
        wardrobes_id = json["wardrobes_id"].stringValue
        
        search_value = json["search_value"].stringValue
        search_flag = json["search_flag"].stringValue
        search_id = json["search_id"].stringValue
        page = json["page"].stringValue
        
        requested_users = json["requested_users"].stringValue

        old_password = json["old_password"].stringValue
        new_password = json["new_password"].stringValue
        
        is_public = json["is_public"].stringValue
        
        show_rack = json["show_rack"].stringValue
        
        user_type = json["user_type"].stringValue

        status = json["status"].stringValue
        request_id = json["request_id"].stringValue
        
        item_type = json["item_type"].stringValue
        repost = json["repost"].stringValue
        share_type = json["share_type"].stringValue
        caption    = json["caption"].stringValue
        tag_brand  = json["tag_brand"].stringValue
        tag_people = json["tag_people"].stringValue
        add_link   = json["add_link"].stringValue
        hashtag    = json["hashtag"].stringValue
        tag_item   = json["tag_item"].stringValue
        item_id     = json["item_id"].stringValue
        is_like     = json["is_like"].stringValue
        width       = json["width"].stringValue
        height     = json["height"].stringValue
        
        type = json["type"].stringValue
        timestamp = json["timestamp"].stringValue
        pass_timestamp = json["pass_timestamp"].stringValue
        end_timestamp = json["end_timestamp"].stringValue
        
        comment = json["comment"].stringValue
        
        comment_id = json["comment_id"].stringValue
        
        report_id = json["report_id"].stringValue
        report_type = json["report_type"].stringValue
        offender_id = json["offender_id"].stringValue
        reason = json["reason"].stringValue
        
        notificationId = json["notification_id"].stringValue
        
        name = json["name"].stringValue
        
        social_keys = json["social_keys"].object as! JSON
        
        tutorial_type = json["tutorial_type"].stringValue
    
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        dictionary["email"] = email
        dictionary["password"] = password
        dictionary["device_type"] = device_type
        dictionary["device_token"] = device_token
        dictionary["login_type"] = login_type
        dictionary["usernm_email"] = usernm_email
        dictionary["fb_id"] = fb_id
        
        dictionary["user_id"] = user_id
        dictionary["user_name"] = user_name
        dictionary["display_name"] = display_name
        dictionary["bio_txt"] = bio_txt
        
        dictionary["wardrobes_id"] = wardrobes_id
        
        dictionary["search_value"] = search_value
        dictionary["search_flag"] = search_flag
        dictionary["search_id"] = search_id
        dictionary["page"] = page

        dictionary["requested_users"] = requested_users

        dictionary["old_password"] = old_password
        dictionary["new_password"] = new_password
        
        dictionary["is_public"] = is_public
        dictionary["show_rack"] = show_rack
        
        dictionary["user_type"] = user_type
        
        dictionary["status"] = status
        dictionary["request_id"] = request_id
        
        dictionary["item_type"] = item_type
        dictionary["repost"] = repost
        dictionary["share_type"] = share_type
        dictionary["caption"] = caption
        dictionary["tag_brand"] = tag_brand
        dictionary["tag_people"] = tag_people
        dictionary["add_link"] = add_link
        dictionary["hashtag"] = hashtag
        dictionary["tag_item"] = tag_item
        dictionary["item_id"] = item_id
        dictionary["is_like"] = is_like
        dictionary["width"] = width
        dictionary["height"] = height

        dictionary["type"] = type
        dictionary["timestamp"] = timestamp
        dictionary["pass_timestamp"] = pass_timestamp
        dictionary["end_timestamp"] = end_timestamp
        
        dictionary["comment"] = comment
        
        dictionary["comment_id"] = comment_id
        
        dictionary["report_id"] = report_id
        dictionary["report_type"] = report_type
        dictionary["offender_id"] = offender_id
        dictionary["reason"] = reason
        
        dictionary["notification_id"] = notificationId
        
        dictionary["name"] = name
        
        dictionary["social_keys"] = social_keys
        
        dictionary["tutorial_type"] = tutorial_type
        
		return dictionary       

    }


    
    
}
