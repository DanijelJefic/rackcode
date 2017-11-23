//
//  RackDetailVC.swift
//  Rack
//
//  Created by hyperlink on 30/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import ActiveLabel
import FBSDKCoreKit
import FBSDKLoginKit

class RackDetailVC: UIViewController {
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblComment: UITableView!
    
    @IBOutlet var headerView : UIView!
    
    @IBOutlet var profileView : UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPostType: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnDot: UIButton!
    
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var btnLikeBig: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var lblRepost: UILabel!
    @IBOutlet weak var btnRepost: MIBadgeButton!
    @IBOutlet weak var lblWant: UILabel!
    @IBOutlet weak var btnWant: UIButton!
    
    @IBOutlet weak var lblDetail: ActiveLabel!
    
    @IBOutlet weak var imgLine: UIImageView!
    
    @IBOutlet weak var collectionViewTag: UICollectionView!
    
    @IBOutlet weak var constImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constLblDetailHeight: NSLayoutConstraint!
    @IBOutlet weak var constCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var constViewBottomHeight: NSLayoutConstraint!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
    var arrayTagType :[Dictionary<String,Any>] = {
        
        var array = [Dictionary<String,Any>]()
        
        array.append(["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none])
        array.append(["img" : #imageLiteral(resourceName: "iconTag") ,kAction : TagType.tagBrand])
        array.append(["img" : #imageLiteral(resourceName: "iconProdTag") ,kAction : TagType.tagItem])
        array.append(["img" : #imageLiteral(resourceName: "iconUserTag") ,kAction : TagType.tagPeople])
        array.append(["img" : #imageLiteral(resourceName: "iconAddLink") ,kAction : TagType.addLink])
        
        return array
    }()
    
    //To manage dyanamic hegith width for tag collectionView
    let collectionCellHeight = 30
    let collectionCellSpacing = 5
    
    var dictFromParent : ItemModel = ItemModel()
    var copyDictFromParent : ItemModel = ItemModel()
    var likeLabelGesture = UITapGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    var pinchGesture = UIPinchGestureRecognizer()
    var arraySocialKeys : [Dictionary<String , Dictionary<String,Any>>] = []
    
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Rack Detail Deinit....")
        
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationItemDetailUpdate)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationRepostCountUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //50 topview and 20 is paddind from top and bottom for image
//        imgProfile.applyStype(cornerRadius: ((50 * kHeightAspectRasio) - 20) / 2)
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.height  / 2)
        
        lblUserName.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: UIColor.white)
        lblPostType.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0), labelColor: UIColor.white)
        lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0), labelColor: UIColor.white)
        
        lblLike.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        lblComment.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        lblRepost.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        lblWant.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        
        lblDetail.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: UIColor.colorFromHex(hex: kColorGray74))
        
        btnLikeBig.isHidden = true
        collectionViewTag.isHidden = true
        
        //singletap configuration for profileview
        var profileViewGesture = UITapGestureRecognizer()
        profileViewGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
        profileViewGesture.numberOfTapsRequired = 1
        profileViewGesture.numberOfTouchesRequired = 1
        profileView.addGestureRecognizer(profileViewGesture)
        profileView.isUserInteractionEnabled = true
        
        //singletap configuration
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostSingleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        imgPost.addGestureRecognizer(singleTapGesture)
        imgPost.isUserInteractionEnabled = true
        
        //doubletap configuration
        let  doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        imgPost.addGestureRecognizer(doubleTapGesture)
        imgPost.isUserInteractionEnabled = true
        
        //pinchGesture Configuration
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePostPinchGesture(_:)))
        imgPost.addGestureRecognizer(pinchGesture)
        imgPost.isUserInteractionEnabled = true
        pinchGesture.scale = 1
        pinchGesture.delegate = self
//        pinchGesture .require(toFail: )
        
        //pan gesture configuration
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePostPanGesture(sender:)))
        panGesture.delegate = self
        imgPost.addGestureRecognizer(panGesture)
        
        //fail single when double tap perform
        singleTapGesture .require(toFail: doubleTapGesture)
        
        //data setup
        
        imgProfile.setImageWithDownload(dictFromParent.getUserProfile().url())
        lblUserName.text = dictFromParent.getUserName()
        lblPostType.text = dictFromParent.itemType == "rack" ? "Racked" : "Wants"
        lblTime.text = dictFromParent.calculatePostTime()
        
        lblDetail.text = dictFromParent.caption.characters.count > 0 ? "\(dictFromParent.getUserName()) \(dictFromParent.caption!)" : ""
        
        if dictFromParent.caption.characters.count == 0 {
            constLblDetailHeight.constant = 0
            constLblDetailHeight.priority = 999
        } else {
            constLblDetailHeight.priority = 250
        }
        
        lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
        lblComment.text = GFunction.shared.getProfileCount(dictFromParent.commentCount)
        btnRepost.badgeString = GFunction.shared.getProfileCount(dictFromParent.repostCount)
        
        /*
         //1. Tableview stucking issue. So solve out using image height constant.
         //        imgPost.image = (dictFromParent["img"] as! UIImage).imageScale(scaledToWidth: kScreenWidth)
         */
        //Manage using height constant.
        imgPost.setImageWithDownload(dictFromParent.image.url())
        
        let width  : Float = Float(dictFromParent.width)!
        let height : Float = Float(dictFromParent.height)!
//        constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
        
        let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
        
        if Float(heightConstant) > Float(kScreenHeight - 108) {
            constImageHeight.constant = kScreenWidth
            imgPost.contentMode = .scaleAspectFill
        } else {
            constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
            imgPost.contentMode = .scaleToFill
        }
        
        imgPost.clipsToBounds = true
        
        self.lblDetail.numberOfLines = 0
        self.setUpDetailText(lblDetail,userName : dictFromParent.caption.characters.count > 0 ? dictFromParent.getUserName() : "", obj: dictFromParent)
        
        btnLike.isSelected = dictFromParent.loginUserLike
        
        btnComment.isSelected = dictFromParent.loginUserComment
        
        //want button state management
        btnWant.isSelected = dictFromParent.loginUserWant
        
        //repost button state management
        btnRepost.isSelected = dictFromParent.loginUserRepost
        
        //1. owner's user item, dont show repost button
        //2. from ws if repost = no, dont show repost button
        if dictFromParent.userId != UserModel.currentUser.userId {
            if dictFromParent.repost == "yes" {
                btnRepost.isUserInteractionEnabled = true
                lblRepost.isHidden = false
            } else {
                btnRepost.isUserInteractionEnabled = false
                lblRepost.isHidden = true
            }
        } else {
            btnRepost.isUserInteractionEnabled = false
            lblRepost.isHidden = true
        }
        
        //want button state management
        //1. owner's user item, dont show want button
        if dictFromParent.userId == UserModel.currentUser.userId {
            btnWant.isHidden = true
            lblWant.isHidden = true
        } else {
            btnWant.isHidden = false
            lblWant.isHidden = false
        }
        
        
        //singletap configuration for likelabel
        likeLabelGesture = UITapGestureRecognizer(target: self, action: #selector(likeLabelSingleTap(_:)))
        likeLabelGesture.numberOfTapsRequired = 1
        likeLabelGesture.numberOfTouchesRequired = 1
        lblLike.addGestureRecognizer(likeLabelGesture)
        lblLike.isUserInteractionEnabled = true
        
        arrayTagType = arrayTagType.filter({ (objTag : Dictionary<String, Any>) -> Bool in
            let detail = (dictFromParent.tagDetail!).toDictionary()
            return detail[(objTag[kAction] as! TagType).rawValue] != nil && (detail[(objTag[kAction] as! TagType).rawValue] as! [Dictionary<String, Any>]).count > 0
        })
        
        if dictFromParent.userId != dictFromParent.ownerUid {
            arrayTagType.insert(["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none], at: 0)
        }
        
        collectionViewTag.reloadData()
        
        //CollectionView Height Management. if User tag option will be dynamic.For Now its static if dyanamic then uncomment following code.
        let collectionHeight = (arrayTagType.count * collectionCellHeight) //+ ((arrayTagType.count - 1) * collectionCellSpacing)
        self.constCollectionHeight.constant = CGFloat(collectionHeight)
        
        self.collectionViewTag.isHidden = false
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
        self.perform(#selector(self.autoHideTagCollectionOptionView), with: nil, afterDelay: 5.0)
        
    }
    
    func setUpData() {
        //setup for autoPullTorefresh and paggination
        self.setupPullToRefresh()
        
        self.perform(#selector(self.addLoaderWithDelay), with: nil, afterDelay: 0.3)
    }
    
    func addLoaderWithDelay() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblComment.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblComment.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        self.tblComment.ins_beginPullToRefresh()
    }
    
    func setUpDetailText(_ lblDetail : ActiveLabel, userName : String, obj : Any) {
        /*
         \b - consider full word
         ^ - starting with username
         */
        let customType1 = ActiveType.custom(pattern: "^(\\b)\(userName)(\\b)")
        let customType2 = ActiveLabel.CustomActiveTypes.hashtag
        let customTypeMention = ActiveLabel.CustomActiveTypes.mention
        
        lblDetail.enabledTypes = [customType1, .mention, customType2, customTypeMention]
        
        lblDetail.customize { (label : ActiveLabel) in
            
            label.customColor[customType1] = UIColor.white
            
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var attribute = attributes
                switch type {
                    
                case customType1, customTypeMention, .mention :
                    attribute[NSFontAttributeName] = UIFont.applyBold(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = UIColor.white
                    break
                case customType2 :
                    attribute[NSFontAttributeName] = UIFont.applyRegular(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = UIColor.white
                    break
                case .hashtag :
                    attribute[NSFontAttributeName] = UIFont.applyRegular(fontSize: 11.0)
                    attribute[NSForegroundColorAttributeName] = UIColor.white
                    break
                default: ()
                }
                return attribute
            }
            
            
            label.handleCustomTap(for: customType1) {
                print("CustomType \($0)")
                
                let objData = ["user_name" : $0]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            label.handleCustomTap(for: customType2) {
                print("Custom HashTag : \($0)")
                
                let objAtIndex = ["name" : $0.replacingOccurrences(of: "#", with: "")]
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
                vc.searchFlagType = searchFlagType.hashtag.rawValue
                vc.searchData = SearchText(fromJson: JSON(objAtIndex))
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            label.handleHashtagTap({ ( str : String) in
                print("HashTag : \(str)")
            })
            
            label.handleMentionTap({ (str : String) in
                print("Mention : \(str)")
                
                let objData = ["user_name" : str]
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(objData))
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        
    }
    func setupPullToRefresh() {
        
        self.tblComment.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            let requestModel = RequestModel()
            requestModel.item_id = self.dictFromParent.itemId
            
            //call API for bottom data
            self.callItemDetailListAPI(requestModel,
                                       withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                        
                                        //stop pagination
                                        self.tblComment.ins_endPullToRefresh()
                                        
                                        if isSuccess {
                                            
                                            self.dictFromParent = ItemModel(fromJson: jsonResponse)
                                            self.dictFromParent.commentData = ItemModel(fromJson: jsonResponse).commentData.reversed()
                                            
                                            self.setUpView()
                                            
                                            UIView.animate(withDuration: 0.0, animations: {
                                                DispatchQueue.main.async {
                                                    self.tblComment.reloadData()
                                                }
                                            }, completion: { (Bool) in
                                                self.tblComment.isHidden = false
                                            })
                                            
                                        } else {
                                            
                                        }
            })
        }
        
    }
    
    func profileViewSingleTap(_ sender : UITapGestureRecognizer) {
        
        //Require to change view type according to POST type. At WS parsing time
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(dictFromParent.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func imagePostSingleTap(_ sender : UITapGestureRecognizer) {
        
        /*
         cancelPreviousPerformRequests -
         */
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
        
        imgPost.removeAllPSTagView()
        collectionViewTag.isHidden = !collectionViewTag.isHidden
    }
    
    func imagePostDoubleTap(_ sender : UITapGestureRecognizer) {
        
        btnLike.scaleAnimation(0.15, scale: -0.05)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.btnLikeBig.superview?.isUserInteractionEnabled = false
            self.btnLikeBig.isHidden = false
            self.btnLikeBig.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
        }) { (isComplete : Bool) in
            
            UIView.animate(withDuration: 0.5, animations: {
                self.btnLikeBig.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                
            }, completion: { (isComplete : Bool) in
                self.btnLikeBig.isHidden = true
                self.btnLikeBig.superview?.isUserInteractionEnabled = true
            })
            
        }
        
        if !dictFromParent.loginUserLike {
            
            dictFromParent.loginUserLike = true
            dictFromParent.likeCount = "\(Int(dictFromParent.likeCount)! + 1)"
            
            btnLike.isSelected = true
            lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
            
            //TODO:- Check in ios 9.0 (Table is animated even if animation is set to none)
            //       self.tblHome.reloadRows(at: [indexPath], with: .none)
            
            let requestModel = RequestModel()
            requestModel.item_id = dictFromParent.itemId
            requestModel.is_like = btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
            
            //to handel crash
            guard self.tblComment != nil else {
                return
            }
            
            UIView.animate(withDuration: 0.0, animations: {
                DispatchQueue.main.async {
                    self.tblComment.reloadData()
                }
            }, completion: { (Bool) in
                
            })
            
            self.callLikeAPI(requestModel,
                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                
            })
        }
        
    }
    
    // PinchGestureRecognizer Method
    func imagePostPinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        if sender.state == .began {
            AppDelegate.shared.isSwipeBack = false
        }
        
        if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
           AppDelegate.shared.isSwipeBack = true
        }
 
        if sender.state == .changed || sender.state == .began {
            tblComment.isScrollEnabled = false
        }else{
            tblComment.isScrollEnabled = true
        }
        
        TMImageZoom.shared().gestureStateChanged(sender, withZoom: imgPost)
        
    }
    
    func imagePostPanGesture(sender:UIPanGestureRecognizer){
        
        guard pinchGesture.state == .began || pinchGesture.state == .changed else {return}
        /*
        if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            if (self.navigationController != nil) && self.navigationController?.delegate == nil {
                navigationCOntroller = self.navigationController
                self.navigationController?.delegate = AppDelegate.shared.transitionar
            }
        }
        */
        TMImageZoom.shared().moveImage(sender)
    }
    
    func scrollToBottom(){
        //        DispatchQueue.global(qos: .background).async {
        let indexPath = IndexPath(row: dictFromParent.commentData.count - 1, section: 0)
        self.tblComment.scrollToRow(at: indexPath, at: .bottom, animated: true)
        //        }
    }
    
    func likeLabelSingleTap(_ sender : UITapGestureRecognizer) {
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "LikeListVC") as! LikeListVC
        vc.dictFromParent = dictFromParent
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func userNameSingleTap(_ sender : UITapGestureRecognizer) {
        
        let index = (sender.view?.tag)!
        
        let dictAtIndex = dictFromParent.commentData[index] as CommentModel
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileImgSingleTap(_ sender : UITapGestureRecognizer) {
        
        let index = (sender.view?.tag)!
        
        let dictAtIndex = dictFromParent.commentData[index] as CommentModel
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        vc.viewType = .other
        vc.fromPage = .otherPage
        vc.userData = UserModel(fromJson: JSON(dictAtIndex.toDictionary()))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func autoHideTagCollectionOptionView() {
        collectionViewTag.alpha = 1.0
        UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
            self.collectionViewTag.alpha = 0.0
            
        }, completion: { (isComplete : Bool) in
            self.collectionViewTag.isHidden = true
            self.collectionViewTag.alpha = 1.0
        })
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationItemDataUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Comment VC add msg
         2. Comment view add msg
         3. Update want or unwant
         */
        
        print("============Notification Method Called=================")
        print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        
        if dictFromParent.itemId == notiItemData.itemId {
            dictFromParent = notiItemData
            
            setUpView()
            
            UIView.animate(withDuration: 0.0, animations: {
                DispatchQueue.main.async {
                    self.tblComment.reloadData()
                }
            }, completion: { (Bool) in
                
            })
        }
        
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblComment else {
            return
        }
        
        setUpView()
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblComment.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }
    
    func notificationItemDataDelete(_ notification : Notification) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func notificationRepostCountUpdate(_ notification : Notification) {
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        if jsonData.shareType == PostShareType.repost.rawValue && jsonData.subParentId == dictFromParent.itemId {
            
            dictFromParent.loginUserRepost = true
            self.setUpView()
        }
        
        if  dictFromParent.itemId == jsonData.parentId || dictFromParent.itemId == jsonData.itemId || dictFromParent.parentId == jsonData.parentId {
            
            dictFromParent.repostCount = jsonData.repostCount
            self.setUpView()
            
        } else {
            
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblComment.reloadData()
            }
        }, completion: { (Bool) in
            
        })
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    func callWantAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : item/itemwant
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user to save particular item to want list.
         
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodWantList
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
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
    
    func callLikeAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : request/item_like
         
         Parameter   : is_like('like','unlike'),item_id
         
         Optional    :
         
         Comment     : This api will used for user like or unlike comment.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodItemLike
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    
                    //Google Analytics
                    
                    let category = "UI"
                    let action = "\(UserModel.currentUser.displayName!) liked an item \(self.dictFromParent.itemId!) in detail"
                    let lable = ""
                    let screenName = "Item detail"
                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics
                    
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
    
    func callItemDetailListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/comment_list
         
         Parameter   : item_id
         
         Optional    : page
         
         Comment     : This api will used for item wise comment listing.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodItemDetail
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    break
                    
                default:
                    //stop pagination
                    self.tblComment.ins_endPullToRefresh()
                    block(false,nil)
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
    }
    
    func callDeleteCommentAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : request/delete_comment
         
         Parameter   : comment_id
         
         Optional    :
         
         Comment     : This api will used for user delete comment.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodDeleteComment
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
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
    
    func callDeleteItemAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/deleteitem
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user can deleted the item detail.
         
         ==============================
         
         */
        
        APICall.shared.GET(strURL: kMethodItemDelete
            , parameter: requestModel.toDictionary()
            ,withLoader : false)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true)
                    break
                    
                default:
                    block(false)
                    break
                }
            } else {
                block(false)
            }
        }
    }
    
    func callItemSharingAPI(_ requestModel : RequestModel) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/sharing
         
         Parameter   : item_id,social_keys
         
         Optional    :
         
         Comment     : This api will used for item sharing
         
         ==============================
         */
        
        APICall.shared.POST(strURL: kMethodItemSharing
            , parameter: requestModel.toDictionary()
            , withErrorAlert: true
            , withLoader: false
            , constructingBodyWithBlock: { (formData) in
                
        }
            , withBlock: { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
                
        })
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func rightButtonClicked() {
        
        if dictFromParent.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionDelete = UIAlertAction(title: "Delete Post", style: .default) { (action : UIAlertAction) in
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this post? This cannot be undone.", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        let requestModel = RequestModel()
                        requestModel.item_id = self.dictFromParent.itemId
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: self.dictFromParent)
                        
                        self.callDeleteItemAPI(requestModel, withCompletion: { (isSuccess : Bool) in
                            if isSuccess {
                                
                            }
                        })
                        
                        break
                    case 1:
                        
                        break
                    default :
                        break
                    }
                }
            }
            
            let actionEdit = UIAlertAction(title: "Edit Post", style: .default) { (action : UIAlertAction) in
                
                let obj = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
                obj.imgPost = self.imgPost.image
                obj.dictFromParent = self.dictFromParent
                obj.shareType = .main
                
                let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
                navigationController.navigationBar.barStyle = .black
                self.present(navigationController, animated: true, completion: nil)
                
            }
            
            let actionShare = UIAlertAction(title: "Share on Facebook", style: .default) { (action : UIAlertAction) in
                
                let loginManager : FBSDKLoginManager = FBSDKLoginManager()
                loginManager.logOut()
                
                loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (result, error) in
                    if (error == nil) {
                        
                        let fbloginresult : FBSDKLoginManagerLoginResult = result!
                        
                        if (fbloginresult.grantedPermissions != nil) {
                            if(fbloginresult.grantedPermissions.contains("publish_actions")) {
                                let fbAccessToken = FBSDKAccessToken.current().tokenString
                                print("fbAccessToken \(String(describing: fbAccessToken))")
                                
                                self.arraySocialKeys = []
                                self.arraySocialKeys.append(["facebook" : ["access_token" : fbAccessToken!]])
                                
                                let requestModel = RequestModel()
                                requestModel.item_id = self.dictFromParent.itemId
                                requestModel.social_keys = JSON(self.arraySocialKeys)
                                self.callItemSharingAPI(requestModel)
                                
                            } else {
                                //                            AlertManager.shared.showAlertTitle(title: "Facebook Error"
                                //                                ,message: "Publish action not granted.")
                            }
                        }
                    }
                }
                
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionDelete)
            actionSheet.addAction(actionEdit)
            actionSheet.addAction(actionShare)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionReport = UIAlertAction(title: "Report Post", style: .default) { (action : UIAlertAction) in
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                vc.reportId = self.dictFromParent.itemId
                vc.reportType = .item
                vc.offenderId = self.dictFromParent.userId
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnLikeClicked(_ sender : UIButton) {
        
        btnLike.scaleAnimation(0.15, scale: -0.05)
        
        let status = dictFromParent.loginUserLike!
        dictFromParent.loginUserLike = !status
        btnLike.isSelected = !status
        dictFromParent.likeCount = btnLike.isSelected ? "\(Int(dictFromParent.likeCount)! + 1)" : "\(Int(dictFromParent.likeCount)! - 1)"
        lblLike.text = GFunction.shared.getProfileCount(dictFromParent.likeCount)
        
        //TODO:- Check in ios 9.0 (Table is animated even if animation is set to none)
        //       self.tblHome.reloadRows(at: [indexPath], with: .none)
        
        let requestModel = RequestModel()
        requestModel.item_id = dictFromParent.itemId
        requestModel.is_like = btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: dictFromParent)
        
        //to handel crash
        guard self.tblComment != nil else {
            return
        }
        
        setUpView()
        self.tblComment.reloadData()
        
        self.callLikeAPI(requestModel,
                         withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
        })
        
    }
    
    @IBAction func btnCommentClicked(_ sender : UIButton) {
        
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.dictFromParent = dictFromParent
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnRepostClicked(_ sender : UIButton) {
        
        let obj = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
        obj.imgPost = imgPost.image
        obj.dictFromParent = dictFromParent
        obj.shareType = .repost
        let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
        navigationController.navigationBar.barStyle = .black
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func btnWantClicked(_ sender : UIButton) {
        btnWant.scaleAnimation(0.15, scale: -0.05)
        
        let objAtIndex = dictFromParent
        
        let status = objAtIndex.loginUserWant!
        btnWant.isSelected = !status
        dictFromParent.loginUserWant = !status
        
        let requestModel = RequestModel()
        requestModel.item_id = dictFromParent.itemId
        requestModel.type = btnWant.isSelected ? StatusType.want.rawValue : StatusType.unwant.rawValue
        
        self.callWantAPI(requestModel,
                         withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                            
                            if isSuccess {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
                            } else {
                                
                            }
                            
                            //to handel crash
                            guard self.tblComment != nil else {
                                return
                            }
                            //self.tblHome.reloadRows(at: [indexPath], with: .none)
        })

            
            /*let requestModel = RequestModel()
            requestModel.item_id = dictFromParent.itemId
            dictFromParent.loginUserWant = true
            btnWant.isSelected = true
            
            self.callWantAPI(requestModel,
                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                
                                if isSuccess {
                                    
                                } else {
                                    
                                }
            })*/
        
    }
    
    func btnChatReplayClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        guard let _ = tblComment.cellForRow(at: indexPath) as? CommentCell else {
            return
        }
        
        let dictAtIndex : CommentModel = dictFromParent.commentData[indexPath.row]
        
        let commentView : CommentView = CommentView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        AppDelegate.shared.window!.addSubview(commentView)
        commentView.delegate = self
        commentView.dictFromParent = dictFromParent
        commentView.setUpData(dictAtIndex)
        commentView.showAnimationMethod()
        
    }
    
    func btnDotClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        guard let cell = tblComment.cellForRow(at: indexPath) as? CommentCell else {
            return
        }
        
        let dictAtIndex : CommentModel = dictFromParent.commentData[indexPath.row]
        
        /*
         1. Logged in user's post and logged in user's comment -> [Report, Delete, Cancel]
         2. Logged in user's comment -> [Delete, Cancel]
         3. If it doesn't satisfy any of the above mentioned condition's then -> [Report, Cancel]
         */
        
        if dictAtIndex.userId != UserModel.currentUser.userId && self.dictFromParent.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                vc.reportId = dictAtIndex.userId
                vc.reportType = .comment
                vc.offenderId = self.dictFromParent.userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            let actionBlock = UIAlertAction(title: "Delete", style: .default) { (action : UIAlertAction) in
                
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this comment?", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        self.dictFromParent.commentData.remove(at: indexPath.row)
                        self.tblComment.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        
                        self.tblComment.reloadData()
                        
                        let requestModel = RequestModel()
                        requestModel.comment_id = dictAtIndex.commentId
                        
                        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! - 1)
                        
                        let arrayLoggedUsersComment = self.dictFromParent.commentData.filter({ (objComment : CommentModel) -> Bool in
                            
                            if objComment.userId == UserModel.currentUser.userId {
                                return true
                            } else {
                                return false
                            }
                            
                        })
                        
                        if arrayLoggedUsersComment.isEmpty {
                            self.dictFromParent.loginUserComment = false
                        } else {
                            self.dictFromParent.loginUserComment = true
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
                        
                        self.callDeleteCommentAPI(requestModel)
                        
                        break
                    case 1:
                        
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
            
        } else if dictAtIndex.userId == UserModel.currentUser.userId {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionBlock = UIAlertAction(title: "Delete", style: .default) { (action : UIAlertAction) in
                
                AlertManager.shared.showAlertTitle(title: "", message: "Delete this comment?", buttonsArray: ["Delete","Cancel"]) { (buttonIndex : Int) in
                    switch buttonIndex {
                    case 0 :
                        
                        self.dictFromParent.commentData.remove(at: indexPath.row)
                        self.tblComment.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        
                        self.tblComment.reloadData()
                        
                        let requestModel = RequestModel()
                        requestModel.comment_id = dictAtIndex.commentId
                        
                        self.dictFromParent.commentCount = String(Int(self.dictFromParent.commentCount)! - 1)
                        
                        let arrayLoggedUsersComment = self.dictFromParent.commentData.filter({ (objComment : CommentModel) -> Bool in
                            
                            if objComment.userId == UserModel.currentUser.userId {
                                return true
                            } else {
                                return false
                            }
                            
                        })
                        
                        if arrayLoggedUsersComment.isEmpty {
                            self.dictFromParent.loginUserComment = false
                        } else {
                            self.dictFromParent.loginUserComment = true
                        }
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
                        
                        self.callDeleteCommentAPI(requestModel)
                        
                        break
                    case 1:
                        
                        break
                    default :
                        break
                    }
                }
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionBlock)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionReport = UIAlertAction(title: "Report", style: .default) { (action : UIAlertAction) in
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
                vc.reportId = dictAtIndex.userId
                vc.reportType = .comment
                vc.offenderId = self.dictFromParent.userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
                
            }
            
            actionSheet.addAction(actionReport)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
        }
        
    }
    
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        copyDictFromParent = dictFromParent
        self.tblComment.isHidden = true
//        setUpView()
        
        tblComment.estimatedRowHeight = 95
        tblComment.rowHeight = UITableViewAutomaticDimension
        
        tblComment.estimatedSectionHeaderHeight = 328
        tblComment.sectionHeaderHeight = UITableViewAutomaticDimension
        
        setUpData()
        
        //add notification for item data update
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataDelete(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRepostCountUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRepostCountUpdate), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: BarButton(image : #imageLiteral(resourceName: "btnDotVertical") ), title: dictFromParent.getUserName())
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) see item \(self.dictFromParent.itemId!) in detail"
        let lable = ""
        let screenName = "Item Detail"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if copyDictFromParent != dictFromParent {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: self.dictFromParent)
        }
    }
}
//MARK: - TableView Delegate Datasource -
extension RackDetailVC : PSTableDelegateDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictFromParent.commentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictAtIndex = dictFromParent.commentData[indexPath.row] as CommentModel
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        cell.selectionStyle = .none
        cell.lblUserName.text = dictAtIndex.getUserName()
        cell.lblComment.text = dictAtIndex.comment
        self.setUpDetailText(cell.lblComment,userName : dictAtIndex.getUserName(), obj : dictAtIndex)
        cell.ivProfile.setImageWith(dictAtIndex.getUserProfile().url())
        cell.lblTime.text = dictAtIndex.calculatePostTime()
        cell.btnDot.buttonIndexPath = indexPath
        cell.btnReplay.buttonIndexPath = indexPath
        
        cell.btnReplay.addTarget(self, action: #selector(btnChatReplayClicked(_:)), for: .touchUpInside)
        cell.btnDot.addTarget(self, action: #selector(btnDotClicked(_:)), for: .touchUpInside)
        
        cell.lblUserName.tag = indexPath.row
        //singletap configuration for profileview
        cell.userNameLabelGesture = UITapGestureRecognizer(target: self, action: #selector(userNameSingleTap(_:)))
        cell.userNameLabelGesture.numberOfTapsRequired = 1
        cell.userNameLabelGesture.numberOfTouchesRequired = 1
        cell.lblUserName.addGestureRecognizer(cell.userNameLabelGesture)
        cell.lblUserName.isUserInteractionEnabled = true
        
        cell.ivProfile?.tag = indexPath.row
        //singletap configuration for profileview
        cell.profileImgGesture = UITapGestureRecognizer(target: self, action: #selector(profileImgSingleTap(_:)))
        cell.profileImgGesture.numberOfTapsRequired = 1
        cell.profileImgGesture.numberOfTouchesRequired = 1
        cell.ivProfile?.addGestureRecognizer(cell.profileImgGesture)
        cell.ivProfile?.isUserInteractionEnabled = true
        
        return cell
    }
    
}
//MARK: - CollectionView Delegate Datasource -
extension RackDetailVC : PSCollectinViewDelegateDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayTagType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dictAtIndex = arrayTagType[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RackTagCell", for: indexPath) as! RackTagCell
        cell.imgIcon.image = dictAtIndex["img"] as? UIImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dictAtIndex = arrayTagType[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell!.scaleAnimation(0.15, scale: -0.05)
        print(dictAtIndex[kAction] ?? "wrong")
        
        imgPost.removeAllPSTagView()
        collectionViewTag.isHidden = true
        
        let type = dictAtIndex[kAction] as! TagType
        
        switch type {
            
        case .none:
            
            if let userData = dictFromParent as? ItemModel {
                //Require to change view type according to POST type. At WS parsing time
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                
                let userDataPass = UserModel()
                userDataPass.userId = dictFromParent.ownerUid
                vc.userData = UserModel(fromJson: JSON(userDataPass.toDictionary()))
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            break
        case .tagBrand ,.tagItem ,.tagPeople, .addLink:
            
            //Change Datasource and Also change parameter of showTagOnImage at service time.
            
            //                For Passing Tag Taga With Image
            //                let scaleFactor = cell.imgPost.image?.getPostImageScaleFactor(kScreenWidth)
            //                SimpleTagModel.changeTagCondinateTomDeviceImageScaleFactor(tagData.brandTag, scaleFactor: Float(scaleFactor!))
            
            guard imgPost.image != nil else {
                return
            }
            
            //                For Passing Tag Taga With Image
            let scaleFactor = imgPost.image?.getPostImageScaleFactor(kScreenWidth)
            
            if let tagData = dictFromParent.tagDetail {
                
                if type.rawValue == TagType.tagBrand.rawValue {
                    
                    var detail = tagData.brandTag
                    
                    //change image (x,y) to pass
//                    detail = SimpleTagModel.changeTagCondinateTomOrignalImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                    
                    let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: imgPost, mainImage : imgPost.image!, searchType: searchFlagType.brand)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        imgPost.addSubview(singleTag)
                    }
                } else if type.rawValue == TagType.tagItem.rawValue {
                    
                    var detail = tagData.itemTag
                    
                    //change image (x,y) to pass
//                    detail = SimpleTagModel.changeTagCondinateTomOrignalImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                    
                    let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                    
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: imgPost, mainImage : imgPost.image!, searchType: searchFlagType.item)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        imgPost.addSubview(singleTag)
                    }
                } else if type.rawValue == TagType.addLink.rawValue {
                    
                    var detail = tagData.linkTag
                    
                    //change image (x,y) to pass
//                    detail = LinkTagModel.changeTagCondinateTomOrignalImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                    
                    let tagDetail = LinkTagModel.dictArrayFromModelArray(array: detail!)
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: imgPost, mainImage : imgPost.image!, searchType: searchFlagType.link)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        imgPost.addSubview(singleTag)
                    }
                } else if type.rawValue == TagType.tagPeople.rawValue {
                    
                    var detail = tagData.userTag
                    
//                    detail = PeopleTagModel.changeTagCondinateTomOrignalImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                    
                    let tagDetail = PeopleTagModel.dictArrayFromModelArray(array: detail!)
                    let tagView = PSTagView.showTagOnImage(tagDetail, parentView: imgPost, mainImage : imgPost.image!, searchType: searchFlagType.people)
                    for singleTag in tagView {
                        singleTag.delegate = self
                        imgPost.addSubview(singleTag)
                    }
                }
            }
            break
            
        default:

            print("hash tag")
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard self.dictFromParent != nil && dictFromParent.width != "" && self.dictFromParent.likeCount != "" else {
            return 0
        }
        
        /*
         Image height
         */
        
        var imageHeight : CGFloat = 0.0
        let width  : Float = Float(dictFromParent.width)!
        let height : Float = Float(dictFromParent.height)!
        //        constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
        
        let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
        
        if Float(heightConstant) > Float(kScreenHeight - 108) {
            imageHeight = kScreenWidth
        } else {
            imageHeight = kScreenWidth / CGFloat(width) * CGFloat(height)
        }
        
        /*
         Caption height
         */
        
        let caption = self.self.dictFromParent.caption == "" ? "" : self.dictFromParent.userName + " " + self.dictFromParent.caption
        
        /*
         Bottom View - contains like, comment, repost and want
         Default - 40 for icons
         Condition :- if view contains like count or comment count then 20 * kHeightAspectRasio
         */
        
        let buttonViewHeight = Int(self.dictFromParent.likeCount)! > 0 || Int(self.dictFromParent.commentCount)! > 0 ? 40 + (20 * kHeightAspectRasio) : 40
        constViewBottomHeight.constant = buttonViewHeight
        
        /*
         Header View height :-
         Profile view   +
         image height   +
         bottom view    +
         caption        +
         image view line     +
         padding (5+3+9)
         */
        
        let headerHeight = self.profileView.frame.size.height + imageHeight + CGFloat(buttonViewHeight) + String().findHeightForText(text: caption, havingWidth: kScreenWidth - 20, havingHeight: CGFloat.greatestFiniteMagnitude, andFont: UIFont.applyRegular(fontSize: 12.0)).height + imgLine.frame.size.height + 17
        
        return headerHeight
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        guard self.dictFromParent != nil else {
//            print("Some thing wrong.. In Profile VC Collection number of cell")
//            return CGSize(width: kScreenWidth, height: kScreenWidth + (30 * kHeightAspectRasio))
//        }
//
//        //Profile View + Image +
//        return CGSize(width: kScreenWidth, height: kScreenWidth)
//    }
}

extension RackDetailVC : CommentViewDelegate {
    
    func sendCommentDelegate(_ data: Any?) {
        dictFromParent = data as! ItemModel
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblComment.reloadData()
            }
        }, completion: { (Bool) in
            
        })
        
//        if dictFromParent.commentData.count > 0 {
//            tblComment.scrollToRow(at: IndexPath(row: dictFromParent.commentData.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
//        }
    }
}

extension RackDetailVC : PSTagViewTapDelegate {
    
    func tapOnTagDelegate(_ sender : Any) {
        let pstag = sender as! PSTagView
        
        switch pstag.tagType {
        case .brand:
            
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
            vc.searchFlagType = searchFlagType.brand.rawValue
            vc.searchData = SearchText(fromJson: JSON(pstag.tagDetail!))
            self.navigationController?.pushViewController(vc, animated: true)
            break
            
        case .people:
            
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.viewType = .other
            vc.fromPage = .otherPage
            vc.userData = UserModel(fromJson: JSON(pstag.tagDetail!))
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .item:
            
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchDetailVC") as! SearchDetailVC
            vc.searchFlagType = searchFlagType.item.rawValue
            vc.searchData = SearchText(fromJson: JSON(pstag.tagDetail!))
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case .link:
            
            var strLink = SearchText(fromJson: JSON(pstag.tagDetail!)).name
            
            if (strLink?.hasPrefix("http://"))! || (strLink?.hasPrefix("https://"))! {
                //link is correct
            } else {
                strLink = "http://\(strLink!)"
            }
            
            let link = strLink?.url()
            
            if UIApplication.shared.canOpenURL(link!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(link!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(link!)
                }
            }
            
            break
            
        default:
            break
        }
    }
}

extension RackDetailVC : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("first =========== \(gestureRecognizer)")
        print("second --------- \(otherGestureRecognizer)")
        /*
        if (gestureRecognizer.isEqual(pinchGesture) || gestureRecognizer.isEqual(panGesture)) {
            if (otherGestureRecognizer.isEqual(pinchGesture) || otherGestureRecognizer.isEqual(panGesture)) {
                return true
            }
        }
        
        return false
         */
        return true
    }
}
