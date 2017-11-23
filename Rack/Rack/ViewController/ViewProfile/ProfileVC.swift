//
//  ProfileVC.swift
//  Rack
//
//  Created by hyperlink on 08/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import PeekView

class ProfileVC: UIViewController {
    
    //MARK:- Outlet
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblPrivateAccount: UILabel!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var headerView          : ProfileHeaderView!
    var constant            : CGFloat = 0.0
    let colum               : Float = 3.0,spacing :Float = 1.0
    
    //To manage navigation bar button
    var fromPage            = PageFrom.defaultScreen
    
    var tapGesture          = UITapGestureRecognizer()
    var longGesture         = UILongPressGestureRecognizer()
    
    var viewType            = profileViewType.me
    var userData            : UserModel? = nil
    
    var arrayItemData       : [ItemModel] = []
    var page                : Int = 1
    var isWSCalling         : Bool = true
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        print("Profile VC...")
        NotificationCenter.default.removeObserver(kNotificationProfileUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDataUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationRackWantUpdate)
        NotificationCenter.default.removeObserver(kNotificationNewPostAdded)
        NotificationCenter.default.removeObserver(kNotificationRackWantEdit)
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationWant)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "")
//        self.navigationItem.hidesBackButton = true
//        self.navigationItem.leftBarButtonItems = nil
//        self.navigationItem.rightBarButtonItems = nil
        
        //add notification for profile update 
        NotificationCenter.default.addObserver(self, selector: #selector(notificationProfileUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDataUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRackWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRackWantUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationEditItemDetails(_:)), name: NSNotification.Name(rawValue: kNotificationRackWantEdit), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWantUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationWant), object: nil)
        
        
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        longGesture.minimumPressDuration = kMinimumPressDuration
        collectionView.addGestureRecognizer(longGesture)
        
        lblPrivateAccount.text = "USER HAS SET ACCOUNT\nTO PRIVATE"
        lblPrivateAccount.applyStyle(labelFont: UIFont.applyBold(fontSize: 14.0), labelColor: UIColor.white)
        lblPrivateAccount.isHidden = true
        lblPrivateAccount.backgroundColor = UIColor.clear
        
        self.setupPullToRefresh()
        
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
//        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
//        self.collectionView.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
//        infinityIndicator.startAnimating()
        
        
    }
    
    func setUpData() {
        
        //to check user current User come from other user profile.
        if self.userData?.userId == UserModel.currentUser.userId && (fromPage != .defaultScreen) {
            viewType = .me
            fromPage = .fromSettingPage // to setup navigation bar button
        }
        
        switch viewType {
        case .me:
            //TODO:- Load old data that are available with us.
            self.userData = UserModel.currentUser
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.user_name = self.userData?.userName
            
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                if isSuccess {
                    
                } else {
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.user_name = self.userData?.userName
                    self.callUserDetailAPI(requestModel)
                }
            })
            
            break
        case .other:
            
            //TODO:- Check whether to show onboarding or no
            let requestModel1 = RequestModel()
            requestModel1.tutorial_type = tutorialFlag.OtherProfile.rawValue
            
            GFunction.shared.getTutorialState(requestModel1) { (isSuccess: Bool) in
                if isSuccess {
                    let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
                    onBoarding.tutorialType = .OtherProfile
                    self.present(onBoarding, animated: false, completion: nil)
                } else {
                    
                }
            }
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.user_name = self.userData?.userName
            
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                if isSuccess {
                    
                } else {
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.user_name = self.userData?.userName
                    self.callUserDetailAPI(requestModel)
                }
            })
            
            break
        }
    }
    
    func setupPullToRefresh() {
        
        self.collectionView.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            self.callUserDetailAPI(requestModel, withCompletion: { (isSuccess) in
                scrollView?.ins_endPullToRefresh()
            })
        }
        
        //bottom
        self.collectionView.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            if self.isWSCalling {
                self.isWSCalling = false
                
                let requestModel = RequestModel()
                requestModel.user_id = self.userData?.userId
                requestModel.item_type = (self.userData?.isShowRack())! ? StatusType.rack.rawValue : StatusType.want.rawValue
                requestModel.page = String(format: "%d", (self.page))
                self.callWantListAPI(requestModel, withCompletion: { (isSuccess) in
                    
                })
            }
        }
    }
    
    func handleLongPress(_ gesture : UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            
            let window = UIApplication.shared.keyWindow
            
            for peekView in window!.subviews {
                
                if peekView is PeekView {
                    UIView.animate(withDuration: 0.3, animations: {
                        peekView.alpha = 0.0
                    }, completion: { (isComplete : Bool) in
                        peekView.removeFromSuperview()
                    })
                }
            }
            
            return
        }
        
        let point = gesture.location(in: collectionView)
        
        guard let indexPath = self.collectionView.indexPathForItem(at: point) else {
            return
        }
        print(indexPath)
        
        let objAtIndex = arrayItemData[indexPath.row]
        
        let preViewVC = secondStoryBoard.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
        preViewVC.image = objAtIndex.image.url()
        
        PeekView.viewForController(parentViewController: self
            , contentViewController: preViewVC
            , expectedContentViewFrame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            , fromGesture: gesture
            , shouldHideStatusBar: true
            , menuOptions: []
            , completionHandler: nil
            , dismissHandler: nil)
        
    }
    
    func callAfterUserDetailServiceResponse() {
        
        
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //still require to check other conditions.
        if self.userData!.isProfileAccessible(viewType) {
            lblPrivateAccount.isHidden = true
        } else {
            lblPrivateAccount.isHidden = false 
        }
    }
    
    func btnThreeDotClicked() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
            
            //Report...
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
            vc.reportId = (self.userData?.userId)!
            vc.reportType = .profile
            vc.offenderId = (self.userData?.userId)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        let actionBlock = UIAlertAction(title: "Block", style: .default) { (action : UIAlertAction) in
            
            //Blocked...
            AlertManager.shared.showAlertTitle(title: "", message: "Are you sure you want to block this user?", buttonsArray: ["Cancel","Block"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    break
                case 1:
                    
                    let userOriginalData = self.userData
                    
                    //Block clicked
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.status = requestStatus.blocked.rawValue
                    
                    self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.unblock.rawValue)
                    
                    self.callUpdateRequestAPI(requestModel)
                    
                    break
                default :
                    break
                }
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
            
        }
        actionSheet.addAction(actionReport)
        actionSheet.addAction(actionBlock)
        actionSheet.addAction(actionCancel)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func setPageTitle() {
        switch fromPage {
        case .defaultScreen:
            
            var userName = self.userData?.userName
            if userName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "", let index = userName?.index(userName!.startIndex, offsetBy: 1) {
                userName = userName?.substring(from: index)
            }
            _ = addBarButtons(btnLeft: nil, btnRight: BarButton(image : #imageLiteral(resourceName: "btnSetting") ), title:userName)
            break
        case .fromSettingPage:
            //set When user come his in profile from other profile.
            var userName = self.userData?.userName
            if userName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "", let index = userName?.index(userName!.startIndex, offsetBy: 1) {
                userName = userName?.substring(from: index)
            }
            _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(image : #imageLiteral(resourceName: "btnSetting")), title:userName, isSwipeBack: true)
            
            break
            
        case .otherPage:
            var userName = self.userData?.userName
            
            if userName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "", let index = userName?.index(userName!.startIndex, offsetBy: 1) {
                userName = userName?.substring(from: index)
            }
            _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(image : #imageLiteral(resourceName: "btnDotVertical")), title: userName, isSwipeBack: true)
            break
        }
    }
    
    func changeFollowStatus(originalData : UserModel,data : UserModel,status : String) {
        
        if userData?.userId == UserModel.currentUser.userId {
            return
        }
        
        /*
         Other user's profile follower's count management based of their profile type and previous state
         */
        
        if !originalData.isPrivateProfile() {
            
            switch status {
            case FollowType.requested.rawValue:
                //Dont do anything as state is requested
                userData?.isFollowing = status.lowercased()
                break
            case FollowType.following.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! + 1)"
                userData?.isFollowing = status.lowercased()
                break
            case FollowType.follow.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! - 1)"
                userData?.isFollowing = status.lowercased()
                break
            case requestStatus.accepted.rawValue:
                userData?.followingCount = "\(Int((userData?.followingCount)!)! + 1)"
                userData?.requestStatus = status.lowercased()
                break
            case requestStatus.rejected.rawValue:
                userData?.requestStatus = status.lowercased()
                break
            case FollowType.unblock.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! - 1)"
                userData?.isFollowing = status.lowercased()
                break
            default:
                print("============Check changeFollowStatus Other user's followers count (Public Account)=================")
                break
            }
            
        } else {
            switch status {
            case FollowType.requested.rawValue:
                //Dont do anything as state is requested
                userData?.isFollowing = status.lowercased()
                break
            case FollowType.follow.rawValue:
                userData?.isFollowing = status.lowercased()
                break
            case requestStatus.accepted.rawValue:
                userData?.followingCount = "\(Int((userData?.followingCount)!)! + 1)"
                userData?.isFollowing = FollowType.following.rawValue
                userData?.requestStatus = status.lowercased()
                break
            case requestStatus.rejected.rawValue:
                userData?.requestStatus = status.lowercased()
                break
            case FollowType.unblock.rawValue:
                userData?.followersCount = "\(Int((userData?.followersCount)!)! - 1)"
                userData?.isFollowing = status.lowercased()
                break
            default:
                print("============Check changeFollowStatus Other user's followers count (Public Account)=================")
                break
            }
        }
        
        //still require to check other conditions.
        if self.userData!.isProfileAccessible(viewType) {
            lblPrivateAccount.isHidden = true
        } else {
            lblPrivateAccount.isHidden = false
        }
        
        let data = JSON(userData?.toDictionary() ?? [:])
        
        /*
         1. Count management in current user's profile
         2. Follower and Following user list would refect user's status
         */
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: data)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: data)
        
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationProfileUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Edit Profile.
         2. Updte Rack
         */
        
        switch viewType {
        case .me:
            
            self.fromPage = .defaultScreen
            self.setUpData()
            
            guard let jsonData   = notification.object as? JSON else {
                return
            }
            
            let notiWantData = ItemModel(fromJson: jsonData)
            
            let predict = NSPredicate(format: "itemId LIKE %@",notiWantData.itemId)
            let temp = self.arrayItemData.filter({ predict.evaluate(with: $0) })
            
            print(temp)
            
            if !temp.isEmpty {
                if let index = self.arrayItemData.index(of: temp[0]) {
                    self.arrayItemData.remove(at: index)
                }
            } else {
                self.arrayItemData.insert(notiWantData, at: 0)
            }
            
            UIView.animate(withDuration: 0.0, animations: {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }, completion: { (Bool) in
                
            })
            
            break
        case .other:
            
            break
        }
    }
    
    func notificationWantUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Update Want List
         2. Add new item
         */
        
        switch viewType {
        case .me:
            
            self.fromPage = .defaultScreen
            
            var notiWantData = ItemModel()
            
            if let jsonData   = notification.object as? JSON {
                notiWantData = ItemModel(fromJson: jsonData)
            } else if let jsonData   = notification.object as? ItemModel {
                notiWantData = jsonData
            } else {
                return
            }
            
                let requestModel = RequestModel()
                requestModel.user_id = self.userData?.userId
                self.callUserCountAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    if isSuccess {
                        let uData = UserModel(fromJson: jsonResponse)
                        self.userData?.rackCount = uData.rackCount
                        self.collectionView.reloadData()
                    }
                })
            
                let predict = NSPredicate(format: "itemId LIKE %@",notiWantData.itemId)
                let temp = self.arrayItemData.filter({ predict.evaluate(with: $0) })
                
                print(temp)
                
                if !temp.isEmpty {
                    if let index = self.arrayItemData.index(of: temp[0]) {
                        self.arrayItemData.remove(at: index)
//                        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                    }
                } else {
                    self.arrayItemData.insert(notiWantData, at: 0)
//                    self.collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
                }
                
            /*
             item_type == rack && user default == show_rack on
             item_type == want && user default == show_rack off
             */
            arrayItemData = arrayItemData.filter({ (obj : ItemModel) -> Bool in
                if obj.itemType! == "rack" && UserModel.currentUser.isShowRack() {
                    return true
                } else if obj.itemType! == "want" && !UserModel.currentUser.isShowRack() {
                    return true
                }
                return false
            })
            
            self.collectionView.reloadData()
            
            break
        case .other:
            
            break
        }
    }
    
    func notificationEditItemDetails(_ notification : Notification) {
        /*
         Item Details update
         */
        
        guard let _  = self.collectionView else {
            return
        }
        
        switch viewType {
        case .me:
            
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            self.callUserCountAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                if isSuccess {
                    let uData = UserModel(fromJson: jsonResponse)
                    self.userData?.rackCount = uData.rackCount
                    self.collectionView.reloadData()
                }
            })
            
            self.fromPage = .defaultScreen
            guard let jsonData   = notification.object as? ItemModel else {
                return
            }
            
            let predict = NSPredicate(format: "itemId LIKE %@",jsonData.itemId!)
            let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
            
            if !temp.isEmpty {
                if let index = self.arrayItemData.index(of: temp[0]) {
                    self.arrayItemData[index] = jsonData
                }
            } else {
                self.arrayItemData.insert(jsonData, at: 0)
            }
            
            /*
             item_type == rack && user default == show_rack on
             item_type == want && user default == show_rack off
             */
            arrayItemData = arrayItemData.filter({ (obj : ItemModel) -> Bool in
                if obj.itemType! == "rack" && UserModel.currentUser.isShowRack() {
                    return true
                } else if obj.itemType! == "want" && !UserModel.currentUser.isShowRack() {
                    return true
                }
                return false
            })
            
            self.collectionView.reloadData()
            
            break
        case .other:
            
            break
        }
        
    }
    
    func notificationUserDataUpdate(_ notification : Notification) {
        
        /* Notification Post Method call
         1.FollowerVC Click on follow/following
         2.Profile Button :- Follow/Following.
         */
        print("============Notification Method Called=================")
        print(notification.object!)
        
        guard let jsonData   = notification.object as? JSON else {
            return
        }
        
        let notiUserData = UserModel(fromJson: jsonData)
        
        //if own profile then update follow/following count
        if viewType == .me {
            let followData = FollowModel(fromJson: jsonData)
            
            if let followerCount = followData.loginFollowersCount {
                if followerCount != "" {
                    self.userData?.followersCount = followerCount
                }
            }
            
            if let followingCount = followData.loginFollowingCount {
                if followingCount != "" {
                    self.userData?.followingCount = followingCount
                }
            }
            self.collectionView.reloadData()
        }
        
        //it will also call for own user.
        //For now change only status. Require to replace other object also as per requirement.
        if self.userData?.userId == notiUserData.userId {
            self.userData?.isFollowing = notiUserData.isFollowing
            self.userData?.requestStatus = notiUserData.requestStatus
            
            
            let followData = FollowModel(fromJson: jsonData)
            if let followerCount = followData.followersCount {
                if followerCount != "" {
                    self.userData?.followersCount = followerCount
                }
            }
            
            if let followingCount = followData.followingCount {
                if followingCount != "" {
                    self.userData?.followingCount = followingCount
                }
            }
            
            self.collectionView.reloadData()
        }
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = collectionView else {
            return
        }
        
        collectionView.ins_beginPullToRefresh()
        
    }
    
    func notificationRackWantUpdate(_ notification : Notification) {
        
        if self.userData?.userId == UserModel.currentUser.userId {
            self.page = 1
            self.userData? = UserModel.currentUser
            collectionView.ins_beginInfinityScroll()
        }
    }
    
    func notificationItemDataDelete(_ notification : Notification) {
        
        //        print("============Notification Method Called=================")
        //        print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        
        arrayItemData = arrayItemData.filter { (objFollow : ItemModel) -> Bool in
            if objFollow.itemId == notiItemData.itemId {
                return false
            } else {
                return true
            }
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }, completion: { (Bool) in
            self.view.layoutIfNeeded()
        })
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callUserDetailAPI(_ requestModel : RequestModel,withCompletion block: ((Bool) -> Void)? = nil) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_data
         
         Parameter   : user_id or username
         
         Optional    :
         
         Comment     :
         
         
         ==============================
         
         */
        
        //        APICall.shared.CancelTask(url: kMethodUserData)
        
        APICall.shared.PUT(strURL: kMethodUserData
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    self.userData = UserModel(fromJson: response[kData])
                    
                    if self.userData?.userId == UserModel.currentUser.userId && (self.fromPage != .defaultScreen) {
                        self.viewType = .me
                        self.fromPage = .fromSettingPage // to setup navigation bar button
                    }
                    
                    //if API response for current then require to update userdefault and currentUserModel
                    switch self.viewType {
                    case .me:
                        //Save User Data into userDefaults.
                        self.userData?.saveUserDetailInDefaults()
                        
                        //load latest data in to current User
                        UserModel.currentUser.getUserDetailFromDefaults()
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) view his profile"
                        let lable = ""
                        let screenName = "User Profile"
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                        
                        //Google Analytics
                        
                        break
                        
                    case .other:
                        
                        self.callAfterUserDetailServiceResponse()
                        
                        //Google Analytics
                        
                        let category = "UI"
                        let action = "\(UserModel.currentUser.displayName!) view his profile \(self.userData!.getUserName()) 's profile"
                        let lable = ""
                        let screenName = "User Profile"
                        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                        
                        //Google Analytics
                        
                        break
                    }
                    
                    self.perform(#selector(self.setPageTitle), with: nil, afterDelay: 0.0)
                    
                    //TODO:- If need to reload header of collection view use the following
                    
                    //                    if #available(iOS 9.0, *) {
                    //                        print(self.collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(row: 0, section: 0)))
                    //                    } else {
                    //                        // Fallback on earlier versions
                    //                    }
                    
                    self.collectionView.performBatchUpdates({
                        
                    }, completion: { (isSuccess : Bool) in
                        
                        if isSuccess {
                            self.collectionView.reloadData()
                            self.collectionView.isHidden = false
                            
                            self.page = 1
                            let requestModel = RequestModel()
                            requestModel.user_id = self.userData?.userId
                            requestModel.item_type = (self.userData?.isShowRack())! ? StatusType.rack.rawValue : StatusType.want.rawValue
                            requestModel.page = String(format: "%d", (self.page))
                            self.callWantListAPI(requestModel, withCompletion: { (isSuccess) in
                                
                                //Google Analytics
                                
                                let category = "UI"
                                let action = "\(String(describing: self.userData!.displayName!)) view \(self.userData!.isShowRack() ? "racked" : "want") items"
                                let lable = ""
                                let screenName = "User Profile -> \(self.userData!.isShowRack() ? "Rack" : "Want") Item"
                                googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                                
                                //Google Analytics
                                
                            })
                            
                        }
                    })
                    
                    //handel nil.
                    if let _ = block {
                        block!(true)
                    }
                    
                    break
                    
                case noDataFound:
                    GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                        self.navigationController?.popViewController(animated: true)
                    }, andViewController: self)
                    break
                    
                default:
                    if let _ = block {
                        block!(false)
                    }
                    break
                }
            } else {
                
                if let _ = block {
                    block!(false)
                }
            }
        }
        
    }
    
    func callUpdateRequestAPI(_ requstModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/update_request
         
         Parameter   : status[accepted,rejected,blocked,unfollow],user_id
         
         Optional    :
         
         Comment     : This api will used for user update the request.
         
         
         ==============================
         
         */
        
        APICall.shared.CancelTask(url: kMethodUpdateRequest)
        
        APICall.shared.POST(strURL: kMethodUpdateRequest
            , parameter: requstModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response[kData])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response[kData])
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserRequest), object: response[kData][kNotificationDetail])
                    
                    if requstModel.status == FollowType.unfollow.rawValue || requstModel.status == FollowType.follow.rawValue {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUnfollow), object: response[kData])
                    }
                    
                    //                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                    
                default:
                    //                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
            }
        }
    }
    
    
    func callWantListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/rackwantlist
         
         Parameter   : user_id,item_type
         
         Optional    : page
         
         Comment     : This api will used for user send to new request
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodRackWantList
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                        self.collectionView.reloadData()
                    }
                    self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                    let newData = ItemModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    self.arrayItemData.append(contentsOf: newData)
                    self.collectionView.reloadData()
                    self.page = (self.page) + 1
                    
                    /*
                     To download image out of visible cell's as per client's requirement, this code is implemented
 
                    _ = newData.filter({ (obj : ItemModel) -> Bool in
                        
                        weak var img : UIImageView? = UIImageView()
                        img?.setImageWithDownload(obj.image.url())
                        
                        return true
                    })
                     */
                    
                    
                    block(true)
                    break
                    
                default:
                    //stop pagination
                    if self.page == 1{
                        self.arrayItemData.removeAll()
                        self.collectionView.reloadData()
                    }
                    
//                    self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                    block(false)
                    
                    break
                }
            } else {
                self.collectionView.ins_endInfinityScroll(withStoppingContentOffset: true)
                block(false)
                
            }
        }
    }
    
    func callUserCountAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool,JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_count
         
         Parameter   : user_id
         
         Optional    :
         
         Comment     : This api will used for updating user count
         
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodUserCount,
                           parameter: requestModel.toDictionary(),
                           withErrorAlert: false,
                           withLoader: false,
                           debugLog: false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    break
                    
                default:
                    
                    block(false,nil)
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
        
        
    }
    
    func callSendRequestAPI(_ requstModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/send_request
         
         Parameter   : user_id
         
         Optional    :
         
         Comment     : This api will used for user send to new request
         
         ==============================
         */
        
        APICall.shared.CancelTask(url: kMethodSendRequest)
        
        APICall.shared.GET(strURL: kMethodSendRequest
            , parameter: requstModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDataUpdate), object: response[kData])
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: response[kData])
                    
                    //                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                    
                default:
                    //                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked() {
        switch fromPage {
        case .defaultScreen:
            
            break
        case .fromSettingPage:
            _ = self.navigationController?.popViewController(animated: true)
            break
            
        case .otherPage:
            _ = self.navigationController?.popViewController(animated: true)
            break
        }
    }
    
    func rightButtonClicked() {
        
        switch fromPage {
        case .defaultScreen:
            
            let vc : SettingVC = secondStoryBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
        case .fromSettingPage:
            
            let vc : SettingVC = secondStoryBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .otherPage:
            //"3 Dot clicked..."
            self.btnThreeDotClicked()
            break
        }
        
    }
    
    //MARK: - Header View Action Clicked
    func btnRackedClicked(_ sender: UIButton) {
        self.viewRackClicked(sender)
    }
    
    
    func btnFollowersClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //if profile not accessible then return
        if !self.userData!.isProfileAccessible(viewType) {
            return
        }
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowerListVC") as! FollowerListVC
        vc.vcType = .follow
        vc.userData = self.userData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func btnFollowingClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //if profile not accessible then return
        if !self.userData!.isProfileAccessible(viewType) {
            return
        }
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "FollowerListVC") as! FollowerListVC
        vc.vcType = .following
        vc.userData = self.userData        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func btnFollowClicked(_ sender: UIButton) {
        
        let userOriginalData = self.userData
        
        if self.userData?.isFollowing.lowercased() == FollowType.follow.rawValue {
            
            //Following click
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            
            if (userData?.isPrivateProfile())! {
                self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.requested.rawValue)
            } else {
                self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.following.rawValue)
            }
            
            self.callSendRequestAPI(requestModel)
            
            
        } else if self.userData?.isFollowing.lowercased() == FollowType.following.rawValue {
            
            //unfllow clicked
            
            AlertManager.shared.showAlertTitle(title: "", message: "Unfollow \(self.userData!.getUserName())?", buttonsArray: ["Unfollow","Cancel"]) { (buttonIndex : Int) in
                switch buttonIndex {
                case 0 :
                    //Unfollow clicked
                    //call API
                    let requestModel = RequestModel()
                    requestModel.user_id = self.userData?.userId
                    requestModel.status = FollowType.unfollow.rawValue
                    
                    self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.follow.rawValue)
                    
                    self.callUpdateRequestAPI(requestModel)
                    
                    break
                case 1:
                    //Cancel clicked
                    
                    break
                default:
                    break
                }
            }
            
        } else if self.userData?.isFollowing.lowercased() == FollowType.requested.rawValue {
            
            //Unfollow clicked
            //call API
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.status = FollowType.unfollow.rawValue
            
            self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.follow.rawValue)
            
            self.callUpdateRequestAPI(requestModel)
            
        } else if self.userData?.isFollowing.lowercased() == FollowType.unfollow.rawValue {
            
            //Follow clicked
            //call API
            let requestModel = RequestModel()
            requestModel.user_id = self.userData?.userId
            requestModel.status = FollowType.follow.rawValue
            
            self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: FollowType.follow.rawValue)
            
            self.callUpdateRequestAPI(requestModel)
            
        } else {
            print("btnFollowClicked.. But Require to handel other click event.")
        }
        
    }
    
    func btnViewCountClicked(_ sender: UIButton) {
        self.viewRackClicked(sender)
    }
    
    func viewRackClicked(_ sender : Any) {
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        //still require to check other conditions. 
        //if profile not accessible then return
        if !self.userData!.isProfileAccessible(viewType) {
            return
        }
        
        weak var vc = secondStoryBoard.instantiateViewController(withIdentifier: "ViewRackVC") as? ViewRackVC
        vc?.userData = self.userData
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func btnAcceptClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        let userOriginalData = self.userData
        
        let requestModel = RequestModel()
        requestModel.user_id = self.userData?.userId
        requestModel.status = requestStatus.accepted.rawValue
        
        self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: requestStatus.accepted.rawValue)
        
        self.callUpdateRequestAPI(requestModel)
    }
    
    func btnRejecttClicked(_ sender: UIButton) {
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return
        }
        
        let userOriginalData = self.userData
        
        let requestModel = RequestModel()
        requestModel.user_id = self.userData?.userId
        requestModel.status = requestStatus.rejected.rawValue
        
        self.changeFollowStatus(originalData: userOriginalData!, data: self.userData!, status: requestStatus.rejected.rawValue)
        
        self.callUpdateRequestAPI(requestModel)
    }
    
    /*func btnIWantClicked(_ sender: UIButton) {
     guard self.userData != nil else {
     print("Some thing wrong.. In Profile VC Collection number of cell")
     return
     }
     
     //still require to check other conditions.
     //if profile not accessible then return
     if !self.userData!.isProfileAccessible(viewType) {
     return
     }
     
     let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ViewiRackVC") as! ViewiRackVC
     self.navigationController?.pushViewController(vc, animated: true)
     }*/
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func awakeFromNib() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.isHidden = true
        self.setUpView()
        self.setUpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = navigationController {
            AppDelegate.shared.transitionar.addTransition(forView: (navigationController?.topViewController?.view)!)
            navigationCOntroller = navigationController
        }
        
        //TabBarHidden:false
        self.tabBarController?.tabBar.isHidden = false
        
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.collectionView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.collectionView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
//        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
//        self.collectionView.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
//        infinityIndicator.startAnimating()
        
    }
}

//MARK: - CollectionView Delegate DataSource -
extension ProfileVC : PSCollectinViewDelegateDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return 0
        }
        
        //require to change at want list parsing.
        if !self.userData!.isProfileAccessible(viewType) {
            return 0
        }
        
        return arrayItemData.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        
        guard self.userData != nil else {
            print("Some thing wrong.. In Profile VC Collection number of cell")
            return CGSize(width: kScreenWidth, height: kScreenWidth + (30 * kHeightAspectRasio))
        }
        
        //Square cover image + want list label with 30 * aspect rasio + 30 (Accept Decline - button)
        if !(self.userData?.requestStatus.lowercased() == "pending") {
            return CGSize(width: kScreenWidth, height: kScreenWidth + (30 * kHeightAspectRasio))
        } else {
            return CGSize(width: kScreenWidth, height: kScreenWidth + (30 * kHeightAspectRasio))
            //            return CGSize(width: kScreenWidth, height: kScreenWidth + (30 * kHeightAspectRasio) + 30)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //value 2 - is left and right paddding of collection view
        //value 1 - is spacing between two cell collection view
        let value = floorf((Float(kScreenWidth - 2) - (colum - 1) * spacing) / colum);
        return CGSize(width: Double(value), height: Double(value))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        guard arrayItemData[indexPath.row] else {
//            return
//        }
        
        let objAtIndex = arrayItemData[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WantListCell", for: indexPath) as! WantListCell
        
//        DispatchQueue.main.async {
//            cell.imgWant.sd_cancelCurrentImageLoad()
            cell.imgWant.setImageWithDownload(objAtIndex.image.url())
//        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if headerView == nil {
            
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderView", for: indexPath) as! ProfileHeaderView
        }
        
        //to setview type. it must be before setUpData method
        headerView.viewType = self.viewType
        
        //TODO: - Parameter pass for data setup
        headerView.setUpData(self.userData)
        
        headerView.btnView.addTarget(self, action: #selector(btnViewCountClicked(_:)), for: .touchUpInside)
        headerView.btnRacked.addTarget(self, action: #selector(btnRackedClicked(_:)), for: .touchUpInside)
        headerView.btnFollower.addTarget(self, action: #selector(btnFollowersClicked(_:)), for: .touchUpInside)
        headerView.btnFollowing.addTarget(self, action: #selector(btnFollowingClicked(_:)), for: .touchUpInside)
        headerView.btnFollow.addTarget(self, action: #selector(btnFollowClicked(_:)), for: .touchUpInside)
        headerView.btnAccept.addTarget(self, action: #selector(btnAcceptClicked(_:)), for: .touchUpInside)
        headerView.btnReject.addTarget(self, action: #selector(btnRejecttClicked(_:)), for: .touchUpInside)
        //        headerView.btnIWant.addTarget(self, action: #selector(btnIWantClicked(_:)), for: .touchUpInside)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewRackClicked(_:)))
        tapGesture.numberOfTapsRequired = 1
        
        headerView.rackImage.isUserInteractionEnabled = true
        headerView.viewShimmer.isUserInteractionEnabled = true
        headerView.containerView.isUserInteractionEnabled = true
        
        headerView.rackImage.addGestureRecognizer(tapGesture)
        headerView.viewShimmer.addGestureRecognizer(tapGesture)
        headerView.containerView.addGestureRecognizer(tapGesture)
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "RackDetailVC") as! RackDetailVC
        vc.dictFromParent = arrayItemData[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//------------------------------------------------------
//MARK: - Header View Class -

class ProfileHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var rackImage: UIImageView!
    @IBOutlet weak var subContainer: UIView!
    @IBOutlet weak var imgShadow: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgVerify: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblViewRack: UILabel!
    @IBOutlet weak var lblWantList: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var constAcceptRejectHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewButton: UIView!
    @IBOutlet weak var btnView: UIButton!
    @IBOutlet weak var btnRacked: UIButton!
    @IBOutlet weak var btnFollower: UIButton!
    @IBOutlet weak var btnFollowing: UIButton!
    
    @IBOutlet weak var lblRacked: UILabel!
    @IBOutlet weak var lblFollower: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    
    @IBOutlet weak var btnFollow: UIButton!
    //    @IBOutlet weak var btnIWant: UIButton!
    
    @IBOutlet weak var tvAbout : UITextView!
    
    @IBOutlet weak var viewShimmer: FBShimmeringView!
    
    
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
    var viewType = profileViewType.me
    
    let attributedDict : Dictionary<String,Any> = [NSFontAttributeName:UIFont.applyRegular(fontSize: 10.0)
        ,NSForegroundColorAttributeName : UIColor.white
    ]
    let defaultDict : Dictionary<String,Any> = [NSFontAttributeName:UIFont.applyBold(fontSize: 13.0)
        ,NSForegroundColorAttributeName : UIColor.white
    ]
    
    var userData = UserModel()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //button multiline
        btnRacked.titleLabel?.lineBreakMode = .byWordWrapping
        btnRacked.titleLabel?.textAlignment = .center
        
        btnFollower.titleLabel?.lineBreakMode = .byWordWrapping
        btnFollower.titleLabel?.textAlignment = .center
        
        btnFollowing.titleLabel?.lineBreakMode = .byWordWrapping
        btnFollowing.titleLabel?.textAlignment = .center
        
        btnAccept.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 10.0), titleLabelColor: UIColor.colorFromHex(hex: kColorWhite))
        btnReject.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 10.0), titleLabelColor: UIColor.colorFromHex(hex: kColorRed))
        
        lblName.applyStyle(labelFont: UIFont.applyBold(fontSize: 12.0), labelColor: UIColor.white)
        
        btnView.applyStyle(titleLabelFont: UIFont.applyRegular(fontSize: 10.0), titleLabelColor: UIColor.white)
        
        //shinning view setup
        viewShimmer.isShimmering = true
        viewShimmer.shimmeringBeginFadeDuration = 1.0
        viewShimmer.shimmeringOpacity = 1.0
        viewShimmer.shimmeringAnimationOpacity = 0.2
        viewShimmer.shimmeringSpeed = 75.0
        viewShimmer.shimmeringOpacity = CGFloat(fmaxf(0.2, fminf(1.0, 0.8)))
        viewShimmer.shimmeringOpacity = CGFloat(fmaxf(1.0, fminf(1.0, 1.0)))
        viewShimmer.contentView = lblViewRack
        
        lblViewRack.applyViewShadow(shadowOffset: CGSize(width: 1.50, height: 1.50), shadowColor: UIColor.colorFromHex(hex: kColorDarkGray), shadowOpacity: 0.5)
        lblViewRack.applyStyle(labelFont: UIFont.applyRegular(fontSize: 18.0), labelColor: UIColor.white)
        
        viewShimmer.isHidden = true
        
        
        lblWantList.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: UIColor.white)
        
        
        //textView Setup
        tvAbout.applyStyle(textFont: UIFont.applyBold(fontSize: 11.0), textColor: UIColor.white)
        tvAbout.textContainerInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        //imgsetup
        imgProfile.applyStype(cornerRadius: (kScreenWidth * 0.1875) / 2) // (60/320) AspecRasio
        
        lblRacked.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.white)
        lblFollower.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.white)
        lblFollowing.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.white)
        
        //Attribute dynamic text setup
        let rackedAttributeText : NSMutableAttributedString = "0".getAttributedText(defaultDic: defaultDict
            , attributeDic: attributedDict
            , attributedStrings: [""])
        
        btnRacked.setAttributedTitle(rackedAttributeText, for: .normal)
        
        let followerAttributeText : NSMutableAttributedString = "0".getAttributedText(defaultDic: defaultDict
            , attributeDic: attributedDict
            , attributedStrings: [""])
        btnFollower.setAttributedTitle(followerAttributeText, for: .normal)
        
        
        let followingAttributeText : NSMutableAttributedString = "0".getAttributedText(defaultDic: defaultDict
            , attributeDic: attributedDict
            , attributedStrings: [""])
        btnFollowing.setAttributedTitle(followingAttributeText, for: .normal)
        
        btnFollow.isHidden = true
        
        //Require to set accept decline button view size if request status pending.
        btnReject.isHidden = true
        btnAccept.isHidden = true
        constAcceptRejectHeight.constant = 0
        //
        
    }
    
    func setUpData(_ userData : UserModel?) {
        
        
        guard let userData = userData else {
            return
        }
        
        self.userData = userData
        
        print("==============User Following : - ",self.userData.isFollowing,"==============")
        imgProfile.alpha = 1.0
        btnFollow.alpha = 1.0
        switch viewType {
        case .me:
            
            //TODO: TO manage Follow/UnFollow button + view position manage
            btnFollow.isHidden = true
            
            //            btnIWant.isHidden = false
            break
        case .other:
            
            //  Not require to configuration "constButtonBottom". Done from storyBoard :)
            if self.userData.isFollowing.lowercased() == FollowType.follow.rawValue {
                
                /*btnFollow.setTitle("FOLLOW", for: .normal)
                 
                 btnFollow.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0)
                 , titleLabelColor: UIColor.colorFromHex(hex: kColorRed)
                 , cornerRadius: 0.0, borderColor: UIColor.colorFromHex(hex: kColorRed)
                 , borderWidth: 1.5
                 , state: .normal)*/
                
                btnFollow.setBackgroundImage(#imageLiteral(resourceName: "iconFollow"), for: UIControlState())
                btnFollow.isHidden = false
                
            } else if self.userData.isFollowing.lowercased() == FollowType.following.rawValue {
                
                /*                btnFollow.setTitle("FOLLOWING", for: .normal)
                 btnFollow.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0)
                 , titleLabelColor: UIColor.colorFromHex(hex: kColorWhite)
                 , cornerRadius: 0.0, borderColor: UIColor.colorFromHex(hex: kColorWhite)
                 , borderWidth: 1.5
                 , state: .normal)*/
                
                btnFollow.setBackgroundImage(#imageLiteral(resourceName: "iconFollowing"), for: UIControlState())
                btnFollow.isHidden = false
                
            } else if self.userData.isFollowing.lowercased() == FollowType.requested.rawValue {
                
                /*btnFollow.setTitle("REQUESTED", for: .normal)
                 btnFollow.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0)
                 , titleLabelColor: UIColor.colorFromHex(hex: kColorGray123)
                 , cornerRadius: 0.0, borderColor: UIColor.colorFromHex(hex: kColorGray123)
                 , borderWidth: 1.5
                 , state: .normal)*/
                
                btnFollow.setBackgroundImage(#imageLiteral(resourceName: "iconFollow"), for: UIControlState())
                imgProfile.alpha = 0.3
                btnFollow.alpha = 0.3
                
                btnFollow.isHidden = false
                
            }else if self.userData.isFollowing.lowercased() == FollowType.unblock.rawValue{
                /*btnFollow.setTitle("UNBLOCK", for: .normal)
                 btnFollow.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0)
                 , titleLabelColor: UIColor.colorFromHex(hex: kColorGray123)
                 , cornerRadius: 0.0, borderColor: UIColor.colorFromHex(hex: kColorGray123)
                 , borderWidth: 1.5
                 , state: .normal)*/
                
                btnFollow.setBackgroundImage(UIImage(), for: UIControlState())
                
                btnFollow.isHidden = true
            } else {
                /*btnFollow.setTitle("FOLLOW", for: .normal)
                 btnFollow.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 12.0)
                 , titleLabelColor: UIColor.colorFromHex(hex: kColorRed)
                 , cornerRadius: 0.0, borderColor: UIColor.colorFromHex(hex: kColorRed)
                 , borderWidth: 1.5
                 , state: .normal)*/
                
                btnFollow.setBackgroundImage(UIImage(), for: UIControlState())
                
                btnFollow.isHidden = true
            }
            //            btnIWant.isHidden = true
            
            break
        }
        
        /*
         UIView.animate(withDuration: 0.3) {
         
         self.viewButton.layoutIfNeeded()
         self.btnRacked.layoutIfNeeded()
         self.btnFollow.layoutIfNeeded()
         self.btnFollower.layoutIfNeeded()
         self.btnFollowing.layoutIfNeeded()
         }
         */
        
        //MARK:- PENDING
        //Require to set accept decline button view size if request status pending.
        if !(self.userData.requestStatus.lowercased() == "pending") {
            btnReject.isHidden = true
            btnAccept.isHidden = true
            constAcceptRejectHeight.constant = 0
        }else {
            constAcceptRejectHeight.constant = 30
            btnReject.isHidden = false
            btnAccept.isHidden = false
        }
        
        //Other Data setup
        lblName.text = self.userData.displayName
        btnView.setTitle(GFunction.shared.getProfileCount(self.userData.viewCount), for: .normal)
        print("User View Count : - ",self.userData.viewCount)
        
        //image setup
        
//        rackImage.sd_setImage(with: self.userData.wardrobesImage.url())
        
        imgProfile.setImageWithDownload(self.userData.getUserProfile().url())
        rackImage.setImageWithDownload(self.userData.wardrobesImage.url(),withIndicator: false)
        
        //bio data set
        tvAbout.text = self.userData.bioTxt
        
        //Attribute dynamic text setup
        let racked = GFunction.shared.getProfileCount(self.userData.rackCount!) == "" ? "0" : GFunction.shared.getProfileCount(self.userData.rackCount!)
        let rackedAttributeText : NSMutableAttributedString = "\(racked)".getAttributedText(defaultDic: defaultDict
            , attributeDic: attributedDict
            , attributedStrings: [""])
        btnRacked.setAttributedTitle(rackedAttributeText, for: .normal)
        
        
        let follower = GFunction.shared.getProfileCount(self.userData.followersCount!) == "" ? "0" : GFunction.shared.getProfileCount(self.userData.followersCount!)
        let followerAttributeText : NSMutableAttributedString = "\(follower)".getAttributedText(defaultDic: defaultDict
            , attributeDic: attributedDict
            , attributedStrings: [""])
        btnFollower.setAttributedTitle(followerAttributeText, for: .normal)
        
        
        let following = GFunction.shared.getProfileCount(self.userData.followingCount!) == "" ? "0" : GFunction.shared.getProfileCount(self.userData.followingCount!)
        let followingAttributeText : NSMutableAttributedString = "\(following)".getAttributedText(defaultDic: defaultDict
            , attributeDic: attributedDict
            , attributedStrings: [""])
        btnFollowing.setAttributedTitle(followingAttributeText, for: .normal)
        
        //still require to check other conditions.
        if self.userData.isProfileAccessible(viewType) {
            viewShimmer.isHidden = false
            if (self.userData.isShowRack(viewType)) {
                lblViewRack.text = "WANT LIST"
                lblWantList.text = "RACK"
            } else {
                lblViewRack.text = "RACK"
                lblWantList.text = "WANT LIST"
            }
        } else {
            viewShimmer.isHidden = true
        }
        
        //user verify or not
        if !self.userData.isUserVerify() {
            imgVerify.isHidden = true
        } else {
            imgVerify.isHidden = false
        }
    }
    
    //------------------------------------------------------
    //MARK: Action Method
    
}

class WantListCell: UICollectionViewCell {
    
    @IBOutlet weak var imgWant: UIImageView!
    
    override func awakeFromNib() {
        imgWant.contentMode = .scaleAspectFill
    }
}
