//
//  NotificationVC.swift
//  Rack
//
//  Created by hyperlink on 12/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import ActiveLabel

var constCellFollowKey: UInt8 = 0
var constCellAcceptKey: UInt8 = 0

let kSubDetail       : String = "SubDetail"
let kTime            : String = "Time"
let kProfileImage    : String = "ProfileImage"
let kDetailImage     : String = "DetailImage"
let kIsRead          : String = "kIsRead"


enum notificationRead : String {
    
    case read
    case unread
    
}
class NotificationVC: UIViewController {

    //Other Setup
    
    enum notificationCellType : String {
        case normalCell // like with photo
        case notificationWithOutImageCell // general
        case followCell
        case acceptCell
    }
    
    enum cellAction {
        
        case followUser
        case unfollowUser
        case accpetRequest
        case rejectRequest
        case none
    }
    
   
    
    typealias cellType = notificationCellType
    typealias action   = cellAction
    
    //------------------------------------------------------
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblNotification: UITableView!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
    var arrayDataSoruce : [NotificationModel] = [
        /*[kTitle:"BETTY HAYNES",kSubTitle:"has liked your", kSubDetail : "Louis Vuiton Handbag." , kCellType : cellType.normalCell , kTime : 600 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg"), kDetailImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.none,kIsRead :notificationRead.unread],
     
        [kTitle:"KATE SWANSTON",kSubTitle:"has liked your", kSubDetail : "Louis Vuiton Handbag." , kCellType : cellType.normalCell , kTime : 1000 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg"), kDetailImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.none,kIsRead :notificationRead.unread],
        
        [kTitle:"KATE SWANSTON + 10 OTHERS",kSubTitle:"has liked your", kSubDetail : "Louis Vuiton Handbag." , kCellType : cellType.normalCell , kTime : 6000 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg"), kDetailImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.none,kIsRead :notificationRead.unread],
        
         [kTitle:"CHARLIE WADE",kSubTitle:"has accepted your friend request.", kSubDetail : "Louis Vuiton Handbag." , kCellType : cellType.notificationWithOutImageCell , kTime : 7800 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg"), kDetailImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.none,kIsRead :notificationRead.read],
        
        [kTitle:"BETTY HAYNES",kSubTitle:"has liked your", kSubDetail : "Louis Vuiton Handbag." , kCellType : cellType.followCell , kTime : 10000 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.unfollowUser,kIsRead :notificationRead.read],
        
        [kTitle:"BETTY HAYNES",kSubTitle:"has liked your", kSubDetail : "Louis Vuiton Handbag." , kCellType : cellType.followCell , kTime : 12000 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.followUser,kIsRead :notificationRead.read],
        
        [kTitle:"BETTY HAYNES",kSubTitle:"has liked your", kSubDetail : "Louis Vuiton Handbag." , kCellType : cellType.normalCell , kTime : 14000 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg"), kDetailImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.none,kIsRead :notificationRead.read],
      
        [kTitle:"Jolly HAYNES",kSubTitle:"requested to follow you.", kSubDetail : "" , kCellType : cellType.acceptCell , kTime : 245000 , kProfileImage : #imageLiteral(resourceName: "myBG.jpg") ,kAction : action.none,kIsRead :notificationRead.read]*/
    ]
    
    var page                : Int = 1
    var isWSCalling         : Bool = true
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationUserPrivacyPublic)
        NotificationCenter.default.removeObserver(kNotificationUserRequest)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationFollowListUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {

        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        //set table footer view
        tblNotification.tableFooterView = UIView()
        tblNotification.estimatedRowHeight = 95
        tblNotification.rowHeight = UITableViewAutomaticDimension
        
        //setUp for pull to refresh
        self.setupPullToRefresh()
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblNotification.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        
        
        //add notification for user privacy change to public
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserPrivacyPublic(_:)), name: NSNotification.Name(rawValue: kNotificationUserPrivacyPublic), object: nil)
        
        //add notification for user accepts or decline a particular request
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserAcceptsDeclineRequest(_:)), name: NSNotification.Name(rawValue: kNotificationUserRequest), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFollowListUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationFollowListUpdate), object: nil)
    }
    
    func addLoaderWithDelay() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblNotification.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblNotification.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
    }
    
    func callApi() {
        
        guard let _  = self.tblNotification else {
            return
        }
        
        self.tblNotification.ins_beginPullToRefresh()
    }
    
    func setupPullToRefresh() {
        
        //top
        self.tblNotification.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            
            let requestModel = RequestModel()
            /*requestModel.type = PageRefreshType.top.rawValue
             
             if let firstItem = self.arrayDataSoruce.first {
             
             if let insertDate = firstItem.getInsertDate() {
             let insertDate = Date().convertToLocal(sourceDate: insertDate)
             requestModel.timestamp = insertDate.getTimeStampFromDate().string
             }
             } else {*/
            requestModel.type = PageRefreshType.bottom.rawValue
            //}
            
            //call API for top data
            self.callNotificationListAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                self.tblNotification.ins_endPullToRefresh()
                
                if isSuccess {
                    self.arrayDataSoruce = []
                    self.arrayDataSoruce.append(contentsOf: NotificationModel.modelsFromDictionaryArray(array: jsonResponse!.arrayValue))
                    
                    /*var tempData = NotificationModel.modelsFromDictionaryArray(array: jsonResponse!.arrayValue)
                     
                     tempData = tempData.filter({ (obj : NotificationModel) -> Bool in
                     
                     
                     /*
                     Override requested type to is following you type
                     */
                     let predict = NSPredicate(format: "userId LIKE %@ AND rackCell == %@ ",obj.userId!, notificationCellType.notificationWithOutImageCell.rawValue)
                     let temp = self.arrayDataSoruce.filter({ predict.evaluate(with: $0) })
                     
                     print(temp)
                     
                     if !temp.isEmpty {
                     if let index = self.arrayDataSoruce.index(of: temp[0]) {
                     self.arrayDataSoruce.remove(at: index)
                     }
                     }
                     
                     /*
                     Override comment, like bunch
                     */
                     if let _ = obj.itemData {
                     
                     let predict1 = NSPredicate(format: "itemData.itemId LIKE %@ AND rackCell == %@ AND notificationType == %@",obj.itemData.itemId!, notificationCellType.normalCell.rawValue,obj.notificationType)
                     let temp1 = self.arrayDataSoruce.filter({ predict1.evaluate(with: $0) })
                     
                     print(temp1)
                     
                     if !temp1.isEmpty {
                     if let index = self.arrayDataSoruce.index(of: temp1[0]) {
                     self.arrayDataSoruce.remove(at: index)
                     }
                     }
                     }
                     return true
                     })
                     
                     self.arrayDataSoruce.insert(contentsOf: tempData, at: 0)*/
                    
                    guard self.tblNotification != nil else {
                        return
                    }
                    self.tblNotification.reloadData()
                    
                } else {
                    
                }
            })
        }
        
        //bottom
        self.tblNotification.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            
            let requestModel = RequestModel()
            requestModel.type = PageRefreshType.bottom.rawValue
            
            if let lastItem = self.arrayDataSoruce.last {
                if let insertDate = lastItem.getInsertDate() {
                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
                    requestModel.timestamp = insertDate.getTimeStampFromDate().string
                }
            }
            
            //call API for bottom data
            self.callNotificationListAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                scrollView?.ins_endInfinityScroll(withStoppingContentOffset: true)
                if self.isWSCalling {
                    self.isWSCalling = false
                    if isSuccess {
                        self.arrayDataSoruce.append(contentsOf: NotificationModel.modelsFromDictionaryArray(array: jsonResponse!.arrayValue))
                        guard self.tblNotification != nil else {
                            return
                        }
                        self.tblNotification.reloadData()
                    } else {
                        
                    }
                }
            })
        }
    }

    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationUserPrivacyPublic(_ notification : Notification) {
        /* Notification Post Method call
         1. Remove all request cell when privacy changes from private to public
         */
        
        print("============Notification Method Called=================")
        
        arrayDataSoruce = arrayDataSoruce.filter({ (objNotify : NotificationModel) -> Bool in
            if objNotify.rackCell == notificationCellType.acceptCell.rawValue{
                return false
            } else {
                return true
            }
        })
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationUserAcceptsDeclineRequest(_ notification : Notification) {
        /* Notification Post Method call
         1. Remove request of a particular user
         */
        
        print("============Notification Method Called=================")
        
        guard !(notification.object! as! JSON).isEmpty else {
            return
        }
        
        let notiItemData = NotificationModel(fromJson: notification.object as! JSON)
        
        //Replace accept request with following block
        arrayDataSoruce = arrayDataSoruce.map { (objNotify : NotificationModel) -> NotificationModel in
            if objNotify.rackCell == notificationCellType.acceptCell.rawValue && objNotify.userId == notiItemData.userId {
                return notiItemData
            } else {
                return objNotify
            }
        }
        
        //Remove reject request block
        arrayDataSoruce = arrayDataSoruce.filter({ (objNotify : NotificationModel) -> Bool in
            if objNotify.rackCell == notificationCellType.acceptCell.rawValue && objNotify.userId == notiItemData.userId {
                return false
            } else {
                return true
            }
        })
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblNotification else {
            return
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationFollowListUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. FollowerVC Click on follow/following
         2. Profile follow/following
         */
        
        print("============Notification Method Called=================")
        print(notification.object!)
        
        guard let jsonData   = notification.object as? JSON else {
            return
        }
        
        let notiFollowData = NotificationModel(fromJson: jsonData)
        
        //change main data
        arrayDataSoruce = arrayDataSoruce.map { (objFollow : NotificationModel) -> NotificationModel in
            
            if objFollow.userId == notiFollowData.userId {
                objFollow.isFollowing = notiFollowData.isFollowing
                return objFollow
            } else {
                return objFollow
            }
        }
        
        
        arrayDataSoruce = arrayDataSoruce.filter({ (objFollow : NotificationModel) -> Bool in
            
            if objFollow.isFollowing.lowercased() == "unblock" {
                return false
            } else {
                return true
            }
            
        })
        
        tblNotification.reloadData()
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callNotificationListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/notification_list
         
         Parameter   : type[top,down]
         
         Optional    : timestamp
         
         Comment     : This api will used for user get the notification list
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodNotificationList
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.page = self.page + 1
                    
                    /*
                     Set notification badge count
                     */
                    GFunction.shared.setNotificationCount()
                    
                    block(true,response[kData])
                    break
                    
                case noDataFound:
                    self.tblNotification.ins_removeInfinityScroll()
                    
                    if self.page == 1 {
                        GFunction.shared.showPopup(with: response[kMessage].stringValue, forTime: 2, withComplition: {
                        }, andViewController: self)
                    }
                    
                    block(false,nil)
                    break
                    
                default:
                    self.tblNotification.ins_removeInfinityScroll()
                    
                    block(false,nil)
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
    }
    
    func callUpdateRequestAPI(_ requstModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/update_request
         
         Parameter   : status[accepted,rejected,blocked,unfollow],user_id
         
         Optional    :
         
         Comment     : This api will used for user update the request.
         
         ==============================
         
         */
        
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
                    
                    block(true,response[kData][kNotificationDetail])
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
                    
                    break
                    
                default:
                    
                    break
                }
            }
        }
    }

    func callUpdateReadRequestAPI(_ requstModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/unread_notification
         
         Parameter   : notification_id
         
         Optional    :
         
         Comment     : This api will used for read notification
         
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodRequestNotificationRead
            , parameter: requstModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    
                    
                    break
                    
                default:
                    
                    break
                }
            } else {
                
            }
            
        }
    }
    
    //--------------------------------------------------------------------------
    //MARK:- Action Method
    
    func btnAcceptClicked(_ sender: UIButton) {
        
        if let cell = objc_getAssociatedObject(sender, &constCellAcceptKey) as? NotificationCell {
            
            if let indexPath = tblNotification.indexPath(for: cell) {
                
                let data = arrayDataSoruce[indexPath.row]
                let requestModel = RequestModel()
                requestModel.user_id = data.userId
                requestModel.status = requestStatus.accepted.rawValue
                self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    if isSuccess && jsonResponse != nil {
                        self.arrayDataSoruce.insert(NotificationModel(fromJson: jsonResponse), at: indexPath.row)
                        
                        UIView.animate(withDuration: 0.0, animations: {
                            DispatchQueue.main.async {
                                self.tblNotification.reloadData()
                            }
                        }, completion: { (Bool) in
                            
                        })
                        
                    }
                })
                
                arrayDataSoruce.remove(at: indexPath.row)
                tblNotification.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                
                tblNotification.reloadData()
            }
        }
    }
    
    func btnRejecttClicked(_ sender: UIButton) {
        
        if let cell = objc_getAssociatedObject(sender, &constCellAcceptKey) as? NotificationCell {
            
            if let indexPath = tblNotification.indexPath(for: cell) {
                
                let data = arrayDataSoruce[indexPath.row]
                let requestModel = RequestModel()
                requestModel.user_id = data.userId
                requestModel.status = requestStatus.rejected.rawValue
                
                self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                    
                })
                
                arrayDataSoruce.remove(at: indexPath.row)
                tblNotification.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                
                tblNotification.reloadData()
            }
        }
    }

    
    func followUser(sender : UIButton)  {
        if let cell = objc_getAssociatedObject(sender, &constCellFollowKey) as? NotificationCell {
            
            if let indexPath = tblNotification.indexPath(for: cell) {
                
                let dictAtIndex = arrayDataSoruce[indexPath.row]
                let action = dictAtIndex.isFollowing.lowercased()
          
                if action == FollowType.following.rawValue {
                    
                    AlertManager.shared.showAlertTitle(title: "", message: "Unfollow \(dictAtIndex.getUserName())?", buttonsArray: ["Unfollow","Cancel"]) { (buttonIndex : Int) in
                        switch buttonIndex {
                        case 0 :
                            //Unfollow clicked
                            //call API
                            let requestModel = RequestModel()
                            requestModel.user_id = dictAtIndex.userId
                            requestModel.status = FollowType.unfollow.rawValue
                            
                            dictAtIndex.isFollowing = FollowType.follow.rawValue
                            
                            cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnUnfollow"), for: UIControlState())
                            
                            self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                
                            })
                            
                            break
                        case 1:
                            //Cancel clicked
                            
                            break
                        default:
                            break
                        }
                        
                    }
                } else if action == FollowType.requested.rawValue {
                    
                    //Unfollow clicked
                    //call API
                    let requestModel = RequestModel()
                    requestModel.user_id = dictAtIndex.userId
                    requestModel.status = FollowType.unfollow.rawValue
                    
                    dictAtIndex.isFollowing = FollowType.follow.rawValue
                    
                    cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnUnfollow"), for: UIControlState())
                    
                    self.callUpdateRequestAPI(requestModel, withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                        
                    })
                    
                } else if action == FollowType.follow.rawValue {
                    
                    //Following click
                    let requestModel = RequestModel()
                    requestModel.user_id = dictAtIndex.userId
                    
                    if (dictAtIndex.isPrivateProfile()) {
                        //requested
                        cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnRequested"), for: UIControlState())
                        dictAtIndex.isFollowing = FollowType.requested.rawValue
                    } else {
                        //following
                        cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnFollow"), for: UIControlState())
                        dictAtIndex.isFollowing = FollowType.following.rawValue
                    }
                    
                    self.callSendRequestAPI(requestModel)
                    
                } else {
                    print("btnFollowClicked.. But Require to handel other click event.")
                }
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "NOTIFICATIONS", isSwipeBack: false)
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.0)
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view notifications"
        let lable = ""
        let screenName = "Notification"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}

extension NotificationVC : PSTableDelegateDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDataSoruce.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictAtIndex = arrayDataSoruce[indexPath.row] as NotificationModel
        
        let cellType = notificationCellType(rawValue: dictAtIndex.rackCell)
        
        switch cellType! {
     
        case .normalCell:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "nNormalCell") as! NotificationCell
            
            cell.lblName.text = dictAtIndex.getUserName()
            cell.lblDetail.text = dictAtIndex.message
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.imgDetailPhoto?.setImageWithDownload(dictAtIndex.itemData.image.url())
            cell.selectionStyle = .none
            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
            
            return cell
            
        case .notificationWithOutImageCell:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "nnotificationWithOutImageCell") as! NotificationCell
            
            cell.lblName.text = dictAtIndex.getUserName()
            cell.lblDetail.text = dictAtIndex.message
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.selectionStyle = .none
            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
            
            return cell
            
        case .followCell:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "nsendCell") as! NotificationCell
            
            cell.lblName.text = dictAtIndex.getUserName()
            cell.lblDetail.text = dictAtIndex.message
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.selectionStyle = .none
            cell.btnFollow?.addTarget(self, action: #selector(followUser(sender:)), for: .touchUpInside)
            objc_setAssociatedObject(cell.btnFollow, &constCellFollowKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if dictAtIndex.isFollowing.lowercased() == FollowType.follow.rawValue {
                
                cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnUnfollow"), for: UIControlState())
                
            } else if dictAtIndex.isFollowing.lowercased() == FollowType.following.rawValue {
                
                cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnFollow"), for: UIControlState())
                
            } else if dictAtIndex.isFollowing.lowercased() == FollowType.requested.rawValue {
                
                cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnRequested"), for: UIControlState())
                
            } else {
                
                cell.btnFollow?.setImage(#imageLiteral(resourceName: "btnUnfollow"), for: UIControlState())
            }
        
            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
          
            return cell
            
        case .acceptCell:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "nacceptCell") as! NotificationCell
            
            cell.lblName.text = dictAtIndex.getUserName()
            cell.lblDetail.text = dictAtIndex.message
            cell.lblTime.text = dictAtIndex.calculatePostTime()
            cell.imgProfile.setImageWithDownload(dictAtIndex.getUserProfile().url())
            cell.selectionStyle = .none
            cell.btnAccept?.addTarget(self, action: #selector(btnAcceptClicked(_:)), for: .touchUpInside)
            cell.btnReject?.addTarget(self, action: #selector(btnRejecttClicked(_:)), for: .touchUpInside)
           
            objc_setAssociatedObject(cell.btnAccept, &constCellAcceptKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(cell.btnReject, &constCellAcceptKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            cell.checkCellReadUnread(notificationRead(rawValue : dictAtIndex.isRead)!)
            return cell

        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let dictAtIndex = arrayDataSoruce[indexPath.row] as NotificationModel
        dictAtIndex.isRead = notificationRead.read.rawValue
        let cellType = notificationCellType(rawValue: dictAtIndex.rackCell)
        
        let requestModel = RequestModel()
        requestModel.notificationId = dictAtIndex.id
        self.callUpdateReadRequestAPI(requestModel)
        
        switch cellType! {
        case .normalCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "RackDetailVC") as! RackDetailVC
            vc.dictFromParent = dictAtIndex.itemData
            
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        case .notificationWithOutImageCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.viewType = .other
            vc.fromPage = .otherPage
            vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        case .followCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.viewType = .other
            vc.fromPage = .otherPage
            vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        case .acceptCell:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.viewType = .other
            vc.fromPage = .otherPage
            vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
            self.navigationController?.pushViewController(vc, animated: true)
            break
        
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblNotification.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
}

//------------------------------------------------------

//MARK: - Notification Cell -

class NotificationCell: UITableViewCell {
    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var lblDetail: UILabel!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnAccept: UIButton?
    @IBOutlet weak var btnReject: UIButton?
    @IBOutlet weak var btnFollow: UIButton?
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgDetailPhoto: UIImageView?
    @IBOutlet weak var bottomLine: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblName.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: UIColor.white)
        lblDetail.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.lightGray)
        
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.width / 2)
        
        if self.reuseIdentifier == "nNormalCell" {
            lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.white)
        }
        
        if self.reuseIdentifier == "nnotificationWithOutImageCell" {
            lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.white)
        }
        
        if self.reuseIdentifier == "nsendCell" {
            
        }
        
        if self.reuseIdentifier == "nacceptCell" {
            lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 10.0), labelColor: UIColor.white)
        }
        
   }
    
    func checkCellReadUnread(_ isRead : notificationRead) {
        
        switch isRead {
        case .read:
            self.backgroundColor = UIColor.colorFromHex(hex: kColorDarkGray)
            self.contentView.backgroundColor = UIColor.colorFromHex(hex: kColorDarkGray)
            self.contentView.applyViewShadow(shadowOffset: CGSize(width: 0, height: 2), shadowColor: UIColor.black, shadowOpacity: 0.2)
            self.bottomLine?.isHidden = false
            break
        case .unread:
            self.backgroundColor = UIColor.colorFromHex(hex: kColorGray38)
            self.contentView.backgroundColor = UIColor.colorFromHex(hex: kColorGray38)
            self.contentView.applyViewShadow(shadowOffset: CGSize(width: 0, height: 2), shadowColor: UIColor.colorFromHex(hex: kColorDarkGray), shadowOpacity: 0.2)
            self.bottomLine?.isHidden = true
            break
        }
    }
    
}
