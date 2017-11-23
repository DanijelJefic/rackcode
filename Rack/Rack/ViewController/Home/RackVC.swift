//
//  RackVC.swift
//  Rack
//
//  Created by hyperlink on 19/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//


import UIKit
import Foundation
import ActiveLabel
import Crashlytics
import PinterestSDK

var constRackCell: UInt8 = 0
//MARK:- RackVC -
class RackVC: UIViewController {
    
    enum RackCellType : String {
        case normalCell
        case multiImageCell
    }
    typealias cellType = RackCellType
    
    //MARK:- Outlet
    @IBOutlet var tblHome : UITableView!
    @IBOutlet var viewNoFollowerFound: UIView!
    @IBOutlet var btnFollow: UIButton!
    @IBOutlet var lblNoFollowersTitle: UILabel!
    @IBOutlet var lblNoFollowersMsg: UILabel!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    
    var arrayItemData : [ItemModel] = []
    var normalCellPopUp : NormalCellPopUp = NormalCellPopUp(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
    var heightAtIndexPath = NSMutableDictionary()
    /*var isZooming = false
    var originalImageCenter:CGPoint?
    var currentImageView : UIImageView = UIImageView()
    var cellMain : RackCell = RackCell()
    var panGesture : UIPanGestureRecognizer = UIPanGestureRecognizer()
    var scrollViewMain = UIScrollView()*/
    var isWSCalling         : Bool = true
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
        //remove observer
        NotificationCenter.default.removeObserver(kNotificationItemDetailUpdate)
        NotificationCenter.default.removeObserver(kNotificationItemDetailDelete)
        NotificationCenter.default.removeObserver(kNotificationNewPostAdded)
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
        NotificationCenter.default.removeObserver(kNotificationRepostCountUpdate)
        NotificationCenter.default.removeObserver(kNotificationUnfollow)
        NotificationCenter.default.removeObserver(kNotificationWant)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
        
        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //        currentImageView.isUserInteractionEnabled = true
        
        //        currentImageView.clipsToBounds = false
        
        //        if #available(iOS 10.0, *) {
        //            self.tblHome.prefetchDataSource = self
        //        } else {
        //            // Fallback on earlier versions
        //        }
        
        tblHome.decelerationRate = UIScrollViewDecelerationRateNormal
        
        self.view.backgroundColor = UIColor.colorFromHex(hex: kColorDarkGray)
        
        //view no followers found set up
        self.viewNoFollowerFound.backgroundColor = UIColor.colorFromHex(hex: kColorDarkGray)
        lblNoFollowersTitle.applyStyle(labelFont: UIFont.applyBold(fontSize: 14.0), labelColor: UIColor.white)
        lblNoFollowersMsg.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: UIColor.white)
        btnFollow.applyStyle(titleLabelFont: nil, titleLabelColor: nil, cornerRadius: btnFollow.frame.size.height / 2, borderColor: UIColor.white, borderWidth: 3.0, state: UIControlState.normal)
        
        //setup for autoPullTorefresh and paggination
        self.setupPullToRefresh()
        
        self.perform(#selector(self.addLoaderWithDelayPullToRefresh), with: nil, afterDelay: 0.0)
        
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblHome.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
        
        //TODO: Remove at WS calling time. Its just for prototype time
        //to hide tag collection options without collection
        //self.perform(#selector(autoHideTagCollectionOptionView), with: nil, afterDelay: 2.0)
        
        //add notification for comment update
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationNewPostAdded(_:)), name: NSNotification.Name(rawValue: kNotificationNewPostAdded), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationRepostCountUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationRepostCountUpdate), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationItemDataDelete(_:)), name: NSNotification.Name(rawValue: kNotificationItemDetailDelete), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUnfollow(_:)), name: NSNotification.Name(rawValue: kNotificationUnfollow), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationWant(_:)), name: NSNotification.Name(rawValue: kNotificationWant), object: nil)
        
    }
    
    func addLoaderWithDelayPullToRefresh() {
        let pullToRefresh : INSPullToRefreshBackgroundViewDelegate = INSDefaultPullToRefresh(frame: CGRect(x: 0, y: 0, width: 24, height: 24), back: nil, frontImage: #imageLiteral(resourceName: "iconFacebook"))
        self.tblHome.ins_pullToRefreshBackgroundView.delegate = pullToRefresh as INSPullToRefreshBackgroundViewDelegate!
        self.tblHome.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh as! UIView)
        
        self.tblHome.ins_beginPullToRefresh()
    }
    
    func addLoaderWithDelayInfinityScroll() {
        let infinityIndicator: INSAnimatable = INSDefaultInfiniteIndicator(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        self.tblHome.ins_infiniteScrollBackgroundView.addSubview(infinityIndicator as! UIView)
        infinityIndicator.startAnimating()
    }
    
    func setupPullToRefresh() {
        
        //top
        self.tblHome.ins_addPullToRefresh(withHeight: 40.0) { (scrollView) in
            let requestModel = RequestModel()
            requestModel.type = PageRefreshType.top.rawValue
            
            let firstItem : ItemModel?
            let lastItem : ItemModel?
            
            firstItem = self.arrayItemData.first
            lastItem = self.arrayItemData.last
            
            /*
            /*
             Data is added from app side, we dont get proper insertdate. So fetching insertdate of data that we got from WS
             */
            
            firstItem = self.arrayItemData.first(where: { (obj : ItemModel) -> Bool in
                if obj.dataFromWS == true {
                    return true
                } else {
                    return false
                }
            })*/
            
            if firstItem != nil {
                if let insertDate = firstItem?.getInsertDate() {
                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
                    requestModel.timestamp = insertDate.getTimeStampFromDate().string
                }
                if firstItem != nil {
                    if lastItem != firstItem {
                        if let insertDate = lastItem?.getInsertDate() {
                            let insertDate = Date().convertToLocal(sourceDate: insertDate)
                            requestModel.end_timestamp = insertDate.getTimeStampFromDate().string
                        }
                    }
                }
            } else {
                requestModel.type = PageRefreshType.bottom.rawValue
            }
            
            //call API for top data
            self.callItemListAPI(requestModel, withCompletion: { (isSuccess) in
                
                self.tblHome.ins_endPullToRefresh()
                self.updateTimeofVisibleCell()
            })
        }
        
        //bottom
        self.tblHome.ins_addInfinityScroll(withHeight: 40.0) { (scrollView) in
            let requestModel = RequestModel()
            requestModel.type = PageRefreshType.bottom.rawValue
            
            /*
             Pass normalCell rackCell's type for down pagination
             From array
             */
            
            var lastItem : ItemModel?
//            lastItem = self.arrayItemData.last
            
            lastItem = self.arrayItemData.reversed().first(where: { (obj : ItemModel) -> Bool in
                if obj.rackCell == RackCellType.normalCell.rawValue {
                    return true
                } else {
                    return false
                }
            })
            
            if lastItem != nil {
                if let insertDate = lastItem?.getInsertDate() {
                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
                    requestModel.timestamp = insertDate.getTimeStampFromDate().string
                }
            }
            
            if let passLastItem = self.arrayItemData.last {
                if passLastItem.rackCell == RackCellType.multiImageCell.rawValue {
                    if let insertDate = passLastItem.getPassInsertDate() {
                        let insertDate = Date().convertToLocal(sourceDate: insertDate)
                        requestModel.pass_timestamp = insertDate.getTimeStampFromDate().string
                    }
                }
            }
            
            
            //            var pass_lastItem : ItemModel?
            //
            //            pass_lastItem = self.arrayItemData.reversed().first(where: { (obj : ItemModel) -> Bool in
            //                if obj.rackCell == RackCellType.multiImageCell.rawValue {
            //                    return true
            //                } else {
            //                    return false
            //                }
            //            })
            //
            //            if pass_lastItem != nil {
            //                if let insertDate = pass_lastItem?.getInsertDate() {
            //                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
            //                    requestModel.pass_timestamp = insertDate.getTimeStampFromDate().string
            //                }
            //            }
            
            //            if let lastItem = self.arrayItemData.last {
            //                if let insertDate = lastItem.getInsertDate() {
            //                    let insertDate = Date().convertToLocal(sourceDate: insertDate)
            //                    requestModel.timestamp = insertDate.getTimeStampFromDate().string
            //                }
            //            }
            
            if self.isWSCalling {
                self.isWSCalling = false
                //call API for bottom data
                self.callItemListAPI(requestModel, withCompletion: { (isSuccess) in
                    
                })
            }
        }
    }
    
    func callAfterServiceResponse(_ data : JSON,pageRefresh : PageRefreshType?) {
        
        guard pageRefresh != nil else {
            //            print("Some thing worong with page refresh enum.. Please check first")
            return
        }
        
        switch pageRefresh! {
        case .top:
            //            print("Top")
            
            let tempData = ItemModel.modelsFromDictionaryArray(array: data.arrayValue)
            
            /*
             To download image out of visible cell's as per client's requirement, this code is implemented
             */
            /*_ = tempData.filter({ (obj : ItemModel) -> Bool in
             if obj.rackCell == RackCellType.normalCell.rawValue {
             weak var img : UIImageView? = UIImageView()
             img?.setImageWithDownload(obj.image.url())
             } else {
             _ = obj.itemData.filter({ (obj1 : ItemModel) -> Bool in
             weak var img : UIImageView? = UIImageView()
             img?.setImageWithDownload(obj.image.url())
             return true
             })
             }
             return true
             })*/
            
            _ = tempData.filter({ (obj : ItemModel) -> Bool in
                
                let predict = NSPredicate(format: "itemId LIKE %@",obj.itemId!)
                let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
                
                /* When to add item
                 //1. No match with item_id in existing data
                 //2. Add item only if multiimagecell's item_data is not empty
                 */
                if temp .isEmpty {
                    if (obj.itemData .isEmpty) && obj.rackCell == RackCellType.multiImageCell.rawValue {
                        //print("//dont insert empty data")
                    } else {
                        arrayItemData.insert(obj, at: 0)
                    }
                }
                    /* When to replace or remove item
                     //1. if match with item_id in existing data, replace that data to obj
                     //2. Remove item if multiimagecell's item_data is empty
                     */
                else {
                    if let index = arrayItemData.index(of: temp[0]) {
                        if obj.itemData .isEmpty && obj.rackCell == RackCellType.multiImageCell.rawValue {
                            
                            if let index = arrayItemData.index(of: temp[0]) {
                                arrayItemData.remove(at: index)
                            }
                        }else {
                            arrayItemData[index] = obj
                        }
                    }
                    else {
                        //print("Something went wrong in pull to refresh top.")
                    }
                }
                
                return true
            })
            /*
             
             _ = tempData.filter({ (obj : ItemModel) -> Bool in
             
             let predict = NSPredicate(format: "itemId LIKE %@",obj.itemId!)
             let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
             
             if obj.rackCell == RackCellType.normalCell.rawValue {
             
             if temp .isEmpty {
             if (obj.itemData .isEmpty) && obj.rackCell == RackCellType.multiImageCell.rawValue {
             print("dont insert empty data")
             } else {
             arrayItemData.insert(obj, at: 0)
             }
             }
             else {
             if let index = arrayItemData.index(of: temp[0]) {
             
             if obj.itemData .isEmpty && obj.rackCell == RackCellType.multiImageCell.rawValue {
             if let index = arrayItemData.index(of: temp[0]) {
             arrayItemData.remove(at: index)
             }
             } else {
             arrayItemData[index] = obj
             }
             
             }
             else {
             print("Something went wrong in pull to refresh top.")
             }
             }
             
             } else {
             /* When to add item
             //1. No match with item_id in existing data
             //2. Add item only if multiimagecell's item_data is not empty
             */
             if temp .isEmpty {
             if (obj.itemData .isEmpty) && obj.rackCell == RackCellType.multiImageCell.rawValue {
             print("dont insert empty data")
             } else {
             if obj.caption == MultiImageCellManageType.added.rawValue {
             arrayItemData.insert(obj, at: 0)
             }
             }
             }
             /* When to replace or remove item
             //1. if match with item_id in existing data, replace that data to obj
             //2. Remove item if multiimagecell's item_data is empty
             */
             else {
             if let index = arrayItemData.index(of: temp[0]) {
             if obj.itemData .isEmpty && obj.rackCell == RackCellType.multiImageCell.rawValue && obj.caption == MultiImageCellManageType.remove.rawValue {
             
             if let index = arrayItemData.index(of: temp[0]) {
             arrayItemData.remove(at: index)
             }
             }else {
             if obj.caption == MultiImageCellManageType.replace.rawValue {
             arrayItemData[index] = obj
             }
             }
             }
             else {
             print("Something went wrong in pull to refresh top.")
             }
             }
             }
             
             return true
             })*/
            
            let arraySort = arrayItemData.sorted(by: { (obj1 : ItemModel, obj2 : ItemModel) -> Bool in
                return obj1.insertdate > obj2.insertdate
            })
            
            arrayItemData = arraySort
            
            self.tblHome.reloadData()
            
            if arrayItemData.count == 0 {
                self.addNoFollowersFoundView()
            } else {
                self.viewNoFollowerFound.removeFromSuperview()
            }
            
            break
        case .bottom:
            //            print("Bottom")
            
            let newData = ItemModel.modelsFromDictionaryArray(array: data.arrayValue)
            
            arrayItemData.append(contentsOf: newData)
            
            var lastNormal = ""
            var lastLike = ""
            
            _ = newData.filter({ (obj : ItemModel) -> Bool in
                if obj.rackCell == RackCellType.normalCell.rawValue {
                    lastNormal = obj.insertdate
                } else {
                    _ = obj.itemData.filter({ (obj1 : ItemModel) -> Bool in
                        lastLike = obj.insertdate
                        return true
                    })
                }
                return true
            })
            
            print("Normal Cell :- \(lastNormal)   --------- Like blocks :- \(lastLike)")
            
            /*
             To download image out of visible cell's as per client's requirement, this code is implemented
 
            _ = newData.filter({ (obj : ItemModel) -> Bool in
                if obj.rackCell == RackCellType.normalCell.rawValue {
                    weak var img : UIImageView? = UIImageView()
                    img?.setImageWithDownload(obj.image.url())
                    
                } else {
                    _ = obj.itemData.filter({ (obj1 : ItemModel) -> Bool in
                        weak var img : UIImageView? = UIImageView()
                        img?.setImageWithDownload(obj.image.url())
                        return true
                    })
                }
                return true
            })*/
 
            self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
            self.tblHome.reloadData()
            self.addGestureToCell()
            break
        }
    }
    
    func setUpDetailText(_ lblDetail : ActiveLabel, userName : String, obj : ItemModel) {
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
                    attribute[NSFontAttributeName] = UIFont.applyRegular(fontSize: 13.0)
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
    
    func likeLabelSingleTap(_ sender : UITapGestureRecognizer) {
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            //let indexPath
            if let indexPath = tblHome.indexPath(for: cell) {
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "LikeListVC") as! LikeListVC
                vc.dictFromParent = ItemModel(fromJson: JSON(arrayItemData[indexPath.row].toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackMultiImageCell {
            
            //let indexPath
            if let indexPath = tblHome.indexPath(for: cell) {
                print("Like Action :- Rack Multiple Cell \(indexPath)")
            }
        }
        
    }
    
    func profileViewSingleTap(_ sender : UITapGestureRecognizer) {
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                //Require to change view type according to POST type. At WS parsing time
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(arrayItemData[indexPath.row].toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackMultiImageCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                //Require to change view type according to POST type. At WS parsing time
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.viewType = .other
                vc.fromPage = .otherPage
                vc.userData = UserModel(fromJson: JSON(arrayItemData[indexPath.row].toDictionary()))
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func imagePostSingleTap(_ sender : UITapGestureRecognizer) {
        
        /*
         cancelPreviousPerformRequests -
         */
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                //                let dictAtIndex : ItemModel = arrayItemData[indexPath.row]
                //                debugPrint(dictAtIndex.toDictionary())
                cell.imgPost.removeAllPSTagView()
                cell.collectionViewTag.isHidden = !cell.collectionViewTag.isHidden
            }
        }
    }
    
    
    func imagePostDoubleTap(_ sender : UITapGestureRecognizer) {
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            if let indexPath = tblHome.indexPath(for: cell) {
                
                let dictAtIndex : ItemModel = self.arrayItemData[indexPath.row]
                
                cell.btnLike.isSelected = true
                
                if !dictAtIndex.loginUserLike {
                    
                    dictAtIndex.likeCount = "\(Int(dictAtIndex.likeCount)! + 1)"
                    
                    self.arrayItemData[indexPath.row] = dictAtIndex
                    cell.lblLike.text = GFunction.shared.getProfileCount(dictAtIndex.likeCount)
                    
                    self.tblHome.beginUpdates()
                    self.tblHome.endUpdates()
                }
                
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    cell.btnLike.scaleAnimation(0.15, scale: -0.05)
                    
                    cell.contentView.isUserInteractionEnabled = false
                    cell.btnLikeBig.isHidden = false
                    cell.btnLikeBig.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    
                }) { (isComplete : Bool) in
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.btnLikeBig.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        
                    }, completion: { (isComplete : Bool) in
                        cell.btnLikeBig.isHidden = true
                        cell.contentView.isUserInteractionEnabled = true
                        
                        if !dictAtIndex.loginUserLike {
                            
                            dictAtIndex.loginUserLike = true
                            
                            let requestModel = RequestModel()
                            requestModel.item_id = dictAtIndex.itemId
                            requestModel.is_like = cell.btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: dictAtIndex)
                            
                            self.callLikeAPI(requestModel,
                                             withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                                                
                            })
                        }
                    })
                }
            }
        }
    }
    
    /*
    func imagePostPanGesture(sender:UIPanGestureRecognizer) {
        //        if let cell = objc_getAssociatedObject(sender.view, &constRackCell) as? RackCell {
        if self.isZooming && sender.state == .began {
            //                self.originalImageCenter = cellMain.imgPost.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: self.view)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: currentImageView.superview)
        }
        else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            
            guard let center = self.originalImageCenter else {return}
            currentImageView.removeFromSuperview()
            cellMain.imgPost.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.cellMain.imgPost.transform = CGAffineTransform.identity
                self.cellMain.imgPost.center = center
            }, completion: { _ in
                self.isZooming = false
            })
        }
        //        }
    }
    
    func imagePostPinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        if sender.state == .changed || sender.state == .began {
            tblHome.isScrollEnabled = false
        }else{
            tblHome.isScrollEnabled = true
        }
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            let imageZoomXib : ImageZoom = ImageZoom(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
            imageZoomXib.setData(img: cell.imgPost.image!, sender: sender)
            
            if !(AppDelegate.shared.window?.subviews.contains(imageZoomXib))! {
                AppDelegate.shared.window?.addSubview(imageZoomXib)
                AppDelegate.shared.window?.bringSubview(toFront: imageZoomXib)
            }
            /*
             cellMain = cell
             if sender.state == .began {
             cell.imgPost.isHidden = true
             self.originalImageCenter = cell.imgPost.center
             currentImageView = UIImageView(image: cell.imgPost.image)
             currentImageView.isUserInteractionEnabled = true
             let point: CGPoint = cell.imgPost.superview!.convert(cell.imgPost.frame.origin, to: nil)
             let startingRect = CGRect(x: point.x, y: point.y, width: cell.imgPost.frame.size.width, height: cell.imgPost.frame.size.height)
             currentImageView.frame = startingRect
             currentImageView.clipsToBounds = true
             
             panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePostPanGesture(sender:)))
             panGesture.delegate = self
             panGesture.maximumNumberOfTouches = 2
             currentImageView.addGestureRecognizer(panGesture)
             currentImageView.isUserInteractionEnabled = true
             
             self.view.addSubview(currentImageView)
             
             /*panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePostPanGesture(sender:)))
             panGesture.delegate = self
             currentImageView.addGestureRecognizer(panGesture)
             currentImageView.isUserInteractionEnabled = true
             objc_setAssociatedObject(currentImageView, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
             currentImageView.gestureRecognizerShouldBegin(panGesture)
             AppDelegate.shared.window?.addSubview(currentImageView)*/
             
             let currentScale = currentImageView.frame.size.width / currentImageView.bounds.size.width
             let newScale = currentScale*sender.scale
             
             if newScale > 1 {
             self.isZooming = true
             }
             
             
             } else if sender.state == .changed {
             
             //                guard let view = currentImageView else {return}
             let view = currentImageView
             let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
             y: sender.location(in: view).y - view.bounds.midY)
             let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
             .scaledBy(x: sender.scale, y: sender.scale)
             .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
             
             let currentScale = currentImageView.frame.size.width / currentImageView.bounds.size.width
             var newScale = currentScale*sender.scale
             
             if newScale < 1 {
             newScale = 1
             let transform = CGAffineTransform(scaleX: newScale, y: newScale)
             currentImageView.transform = transform
             sender.scale = 1
             } else if newScale > 2 {
             /*newScale = 2
             let transform = CGAffineTransform(scaleX: newScale, y: newScale)
             currentImageView.transform = transform
             sender.scale = 1*/
             } else {
             view.transform = transform
             sender.scale = 1
             }
             
             } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
             
             guard let center = self.originalImageCenter else {return}
             currentImageView.removeFromSuperview()
             cell.imgPost.isHidden = false
             UIView.animate(withDuration: 0.3, animations: {
             cell.imgPost.transform = CGAffineTransform.identity
             cell.imgPost.center = center
             }, completion: { _ in
             self.isZooming = false
             })
             }*/
        }
    }*/
    
    /*
     func imagePostPanGesture(sender:UIPanGestureRecognizer) {
     if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
     if self.isZooming && sender.state == .began {
     self.originalImageCenter = sender.view?.center
     } else if self.isZooming && sender.state == .changed {
     
     let translation = sender.translation(in: self.view)
     let view = currentImageView
     view.center = CGPoint(x:view.center.x + translation.x,
     y:view.center.y + translation.y)
     
     sender.setTranslation(CGPoint.zero, in: currentImageView.superview)
     }
     else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
     
     guard let center = self.originalImageCenter else {return}
     currentImageView.removeFromSuperview()
     cell.imgPost.isHidden = false
     
     UIView.animate(withDuration: 0.3, animations: {
     cell.imgPost.transform = CGAffineTransform.identity
     cell.imgPost.center = center
     }, completion: { _ in
     self.isZooming = false
     })
     }
     }
     }
     
     func imagePostPinchGesture(_ sender: UIPinchGestureRecognizer) {
     
     if sender.state == .changed || sender.state == .began {
     tblHome.isScrollEnabled = false
     }else{
     tblHome.isScrollEnabled = true
     }
     
     if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
     
     if sender.state == .began {
     self.originalImageCenter = sender.view?.center
     currentImageView = UIImageView(image: cell.imgPost.image)
     let point: CGPoint = cell.imgPost.superview!.convert(cell.imgPost.frame.origin, to: nil)
     let startingRect = CGRect(x: point.x, y: point.y, width: cell.imgPost.frame.size.width, height: cell.imgPost.frame.size.height)
     currentImageView.frame = startingRect
     
     AppDelegate.shared.window?.addSubview(currentImageView)
     
     let currentScale = currentImageView.frame.size.width / currentImageView.bounds.size.width
     let newScale = currentScale*sender.scale
     
     if newScale > 1 {
     self.isZooming = true
     }
     
     cell.imgPost.isHidden = true
     
     } else if sender.state == .changed {
     
     //                guard let view = currentImageView else {return}
     let view = currentImageView
     let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
     y: sender.location(in: view).y - view.bounds.midY)
     let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
     .scaledBy(x: sender.scale, y: sender.scale)
     .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
     
     let currentScale = currentImageView.frame.size.width / currentImageView.bounds.size.width
     var newScale = currentScale*sender.scale
     
     if newScale < 1 {
     newScale = 1
     let transform = CGAffineTransform(scaleX: newScale, y: newScale)
     currentImageView.transform = transform
     sender.scale = 1
     } else if newScale > 2 {
     /*newScale = 2
     let transform = CGAffineTransform(scaleX: newScale, y: newScale)
     currentImageView.transform = transform
     sender.scale = 1*/
     } else {
     view.transform = transform
     sender.scale = 1
     }
     
     } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
     
     guard let center = self.originalImageCenter else {return}
     currentImageView.removeFromSuperview()
     cell.imgPost.isHidden = false
     UIView.animate(withDuration: 0.3, animations: {
     cell.imgPost.transform = CGAffineTransform.identity
     cell.imgPost.center = center
     }, completion: { _ in
     self.isZooming = false
     })
     }
     }
     }
     */
    
     // PinchGestureRecognizer Method
    func imagePostPinchGesture(_ sender: UIPinchGestureRecognizer) {
        
        if sender.state == .changed || sender.state == .began {
            tblHome.isScrollEnabled = false
        }else{
            tblHome.isScrollEnabled = true
        }
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            
            //indexpath
            if let _ = tblHome.indexPath(for: cell) {
                TMImageZoom.shared().gestureStateChanged(sender, withZoom: cell.imgPost)
            }
            
            /*
             As newsfeed stuck while tapping on imgPost user's scrolls, we added pan gesture when image zooms (Pinch Begins) and pan delegate is removed  as it ends
             */
            
            /*if sender.state == .began {
                //panGesture Configuration
                cell.panGesture.delegate = self
                cell.panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePostPanGesture(sender:)))
                cell.imgPost.isUserInteractionEnabled = true
                cell.imgPost.addGestureRecognizer(cell.panGesture)
                objc_setAssociatedObject(cell.panGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }*/
            
            if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
                
            }
        }
    }
    
    func imagePostPanGesture(sender:UIPanGestureRecognizer){
        
        if let cell = objc_getAssociatedObject(sender, &constRackCell) as? RackCell {
            guard cell.pinchGesture.state == .began || cell.pinchGesture.state == .changed else {return}
            //indexpath
            if let _ = tblHome.indexPath(for: cell) {
                TMImageZoom.shared().moveImage(sender)
            }
            /*
            if sender.state == .began {
                cell.pinchGesture.delegate = nil
                cell.imgPost.removeGestureRecognizer(cell.pinchGesture)
            }
            */
            /*
             As newsfeed stuck while tapping on imgPost user's scrolls, we added pan gesture when image zooms (Pinch Begins) and pan delegate is removed  as it ends
             */
            
            /*if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
                cell.panGesture.delegate = nil
                cell.imgPost.removeGestureRecognizer(cell.panGesture)
                
                cell.pinchGesture.delegate = self
                cell.imgPost.addGestureRecognizer(cell.pinchGesture)
            }*/
        }
    }
    
    func autoHideTagCollectionOptionView() {
        
        /*
         max visible cell's timer would start
         */
        
        let visibleRect = CGRect(origin: tblHome.contentOffset, size: tblHome.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath: IndexPath = tblHome.indexPathForRow(at: visiblePoint) {
            if let rackCell = tblHome.cellForRow(at: visibleIndexPath) as? RackCell {
                
                rackCell.collectionViewTag.alpha = 1.0
                UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
                    rackCell.collectionViewTag.alpha = 0.0
                    
                }, completion: { (isComplete : Bool) in
                    rackCell.collectionViewTag.isHidden = true
                    rackCell.collectionViewTag.alpha = 1.0
                })
            }
        }
        
        /*
         
         //To Auto hide tag collection options.
         let visibleCell = tblHome.visibleCells
         let rackCell  = visibleCell.filter{ $0 is RackCell}
         
         for cell in rackCell {
         if let rackCell = cell as? RackCell {
         rackCell.collectionViewTag.alpha = 1.0
         UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveLinear, animations: {
         rackCell.collectionViewTag.alpha = 0.0
         
         }, completion: { (isComplete : Bool) in
         rackCell.collectionViewTag.isHidden = true
         rackCell.collectionViewTag.alpha = 1.0
         })
         //At a time perform only one hide then return.
         return
         }
         }*/
    }
    
    func updateTimeofVisibleCell() {
        
        if let visibleIndexPath = tblHome.indexPathsForVisibleRows {
            for indexPath in visibleIndexPath {
                if let cell = tblHome.cellForRow(at: indexPath) as? RackCell {
                    let objAtIndex = arrayItemData[indexPath.row]
                    cell.lblTime.text = objAtIndex.calculatePostTime()
                }
            }
        }
        
        
    }
    
    func addGestureToCell() {
        
        self.removeGestureToCell()
        //To Auto hide tag collection options.
        let visibleCell = tblHome.visibleCells
        let rackCell  = visibleCell.filter{ $0 is RackCell}
        
        for cell in rackCell {
            if let cell = cell as? RackCell {
                //singletap configuration for profileview
                cell.profileViewGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
                cell.profileViewGesture.numberOfTapsRequired = 1
                cell.profileViewGesture.numberOfTouchesRequired = 1
                cell.profileView.addGestureRecognizer(cell.profileViewGesture)
                cell.profileView.isUserInteractionEnabled = true
                
                //Set Cell on gesture objc_
                objc_setAssociatedObject(cell.profileViewGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                //singletap configuration for likelabel
                cell.likeLabelGesture = UITapGestureRecognizer(target: self, action: #selector(likeLabelSingleTap(_:)))
                cell.likeLabelGesture.numberOfTapsRequired = 1
                cell.likeLabelGesture.numberOfTouchesRequired = 1
                cell.lblLike.addGestureRecognizer(cell.likeLabelGesture)
                cell.lblLike.isUserInteractionEnabled = true
                
                //Set Cell on gesture objc_
                objc_setAssociatedObject(cell.likeLabelGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                //Set Cell on gesture objc_
                //            objc_setAssociatedObject(cell.singleTapGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                //singletap configuration
                cell.singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostSingleTap(_:)))
                cell.singleTapGesture.numberOfTapsRequired = 1
                cell.singleTapGesture.numberOfTouchesRequired = 1
                cell.imgPost.addGestureRecognizer(cell.singleTapGesture)
                cell.imgPost.isUserInteractionEnabled = true
                
                //Set Cell on gesture objc_
                objc_setAssociatedObject(cell.singleTapGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                //doubletap configuration
                cell.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePostDoubleTap(_:)))
                cell.doubleTapGesture.numberOfTapsRequired = 2
                cell.doubleTapGesture.numberOfTouchesRequired = 1
                cell.imgPost.addGestureRecognizer(cell.doubleTapGesture)
                cell.imgPost.isUserInteractionEnabled = true
                
                //Set Cell on gesture objc_
                objc_setAssociatedObject(cell.doubleTapGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                //fail single when double tap perform
                cell.singleTapGesture .require(toFail: cell.doubleTapGesture)
                
                //pinchGesture Configuration
                cell.pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(imagePostPinchGesture(_:)))
                cell.pinchGesture.delegate = self
                cell.imgPost.addGestureRecognizer(cell.pinchGesture)
                cell.imgPost.isUserInteractionEnabled = true
                cell.pinchGesture.scale = 1
                
                objc_setAssociatedObject(cell.pinchGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                cell.panGesture = UIPanGestureRecognizer(target: self, action: #selector(imagePostPanGesture(sender:)))
                cell.panGesture.delegate = self
                cell.imgPost.addGestureRecognizer(cell.panGesture)
                
                objc_setAssociatedObject(cell.panGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func removeGestureToCell() {
        //To Auto hide tag collection options.
        let visibleCell = tblHome.visibleCells
        let rackCell  = visibleCell.filter{ $0 is RackCell}
        
        for cell in rackCell {
            if let cell = cell as? RackCell {
                
                cell.profileView.removeGestureRecognizer(cell.profileViewGesture)
                cell.lblLike.removeGestureRecognizer(cell.likeLabelGesture)
                cell.imgPost.removeGestureRecognizer(cell.singleTapGesture)
                cell.imgPost.removeGestureRecognizer(cell.doubleTapGesture)
                cell.imgPost.removeGestureRecognizer(cell.pinchGesture)
                cell.imgPost.removeGestureRecognizer(cell.panGesture)
            }
        }
        
    }
    
    func showAnimationMethod() {
        self.view.addSubview(self.normalCellPopUp)
        self.normalCellPopUp.isHidden = true
        self.normalCellPopUp.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        
        UIView.animate(withDuration: 0.1
            , animations: {
                self.normalCellPopUp.isHidden = false
                self.normalCellPopUp.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }) { (complete : Bool) in
            
        }
    }
    
    func addNoFollowersFoundView() {
        self.viewNoFollowerFound.frame = self.tblHome.frame
        if !self.tblHome.subviews.contains(self.viewNoFollowerFound) {
            self.tblHome.addSubview(self.viewNoFollowerFound)
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationWant(_ notification : Notification) {
        /*
         Unwant -> delete it from table
         */
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        
        let predict = NSPredicate(format: "ownerUid LIKE %@ AND shareType == want",notiItemData.ownerUid!)
        let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
        
        if !temp.isEmpty {
            if let index = self.arrayItemData.index(of: temp[0]) {
                self.arrayItemData.remove(at: index)
                self.tblHome.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                
                self.tblHome.reloadData()
            }
        }
    }
    
    func notificationItemDataUpdate(_ notification : Notification) {
        /* Notification Post Method call
         1. Comment VC add msg
         2. Comment view add msg
         3. Update want or unwant
         */
        
        //        print("============Notification Method Called=================")
        //        print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        arrayItemData = arrayItemData.map { (objFollow : ItemModel) -> ItemModel in
            
            if objFollow.itemId == notiItemData.itemId {
                return notiItemData
            } else {
                return objFollow
            }
        }
        
        
        
        //        let predict = NSPredicate(format: "itemId LIKE %@",notiItemData.itemId!)
        //        let temp = arrayItemData.filter({ predict.evaluate(with: $0) })
        //
        //        if !temp.isEmpty {
        //            self.tblHome.reloadData()
        //        }
        //
        /*arrayItemData = arrayItemData.filter({ (objFollow : ItemModel) -> Bool in
         
         let cellType = RackCellType(rawValue: objFollow.rackCell)
         
         switch cellType! {
         case .normalCell:
         return true
         case .multiImageCell:
         
         objFollow.itemData = objFollow.itemData.map { (objFollow : ItemModel) -> ItemModel in
         
         if objFollow.itemId == notiItemData.itemId {
         return notiItemData
         } else {
         return objFollow
         }
         }
         return true
         }
         })*/
        
        //        UIView.performWithoutAnimation({
        
        //            self.tblHome.setNeedsLayout()
        //        })
        
        //        UIView.animate(withDuration: 0.0, animations: {
        //            DispatchQueue.main.async {
        
        self.tblHome.reloadData()
        
        //            }
        //        }, completion: { (Bool) in
        ////            self.view.layoutIfNeeded()
        //        })
        
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
        
        arrayItemData = arrayItemData.filter({ (objFollow : ItemModel) -> Bool in
            
            let cellType = RackCellType(rawValue: objFollow.rackCell)
            
            switch cellType! {
            case .normalCell:
                return true
            case .multiImageCell:
                
                objFollow.itemData = objFollow.itemData.filter({ (objFollow : ItemModel) -> Bool in
                    if objFollow.itemId == notiItemData.itemId {
                        return false
                    } else {
                        return true
                    }
                })
                
                return true
            }
        })
        
        //        UIView.animate(withDuration: 0.0, animations: {
        //            DispatchQueue.main.async {
        self.tblHome.reloadData()
        //            }
        //        }, completion: { (Bool) in
        ////            self.view.layoutIfNeeded()
        //        })
        
        if arrayItemData.count == 0 {
            self.addNoFollowersFoundView()
        }
    }
    
    func notificationNewPostAdded(_ notification : Notification) {
        /* Notification Post Method call
         1. Comment VC add msg
         2. Comment view add msg
         */
        
        //        print("============Notification Method Called=================")
        //        print(notification.object!)
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        arrayItemData.insert(notiItemData, at: 0)
        self.tblHome.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.automatic)
        self.tblHome.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
        
        self.viewNoFollowerFound.removeFromSuperview()
    }
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblHome else {
            return
        }
        
        //        UIView.animate(withDuration: 0.0, animations: {
        //            DispatchQueue.main.async {
        self.tblHome.reloadData()
        //            }
        //        }, completion: { (Bool) in
        //
        //        })
    }
    
    func notificationRepostCountUpdate(_ notification : Notification) {
        
        guard let jsonData   = notification.object as? ItemModel else {
            return
        }
        
        let notiItemData = jsonData
        //change main data
        arrayItemData = arrayItemData.map { (objFollow : ItemModel) -> ItemModel in
            
            if notiItemData.shareType == PostShareType.repost.rawValue && notiItemData.subParentId == objFollow.itemId {
                objFollow.loginUserRepost = true
            }
            
            if objFollow.itemId == notiItemData.parentId || objFollow.itemId == notiItemData.itemId || objFollow.parentId == notiItemData.parentId {
                objFollow.repostCount = notiItemData.repostCount
                return objFollow
            } else {
                return objFollow
            }
        }
        
        arrayItemData = arrayItemData.filter({ (objFollow : ItemModel) -> Bool in
            
            let cellType = RackCellType(rawValue: objFollow.rackCell)
            
            switch cellType! {
            case .normalCell:
                return true
            case .multiImageCell:
                
                objFollow.itemData = objFollow.itemData.map { (objFollow : ItemModel) -> ItemModel in
                    
                    if notiItemData.shareType == PostShareType.repost.rawValue && notiItemData.subParentId == objFollow.itemId {
                        objFollow.loginUserRepost = true
                    }
                    
                    if objFollow.itemId == notiItemData.parentId || objFollow.itemId == notiItemData.itemId || objFollow.parentId == notiItemData.parentId {
                        objFollow.repostCount = notiItemData.repostCount
                        return objFollow
                    } else {
                        return objFollow
                    }
                }
                return true
            }
        })
        
        //        UIView.performWithoutAnimation({
        //            self.tblHome.reloadData()
        //            self.tblHome.setNeedsLayout()
        //        })
        
        //        UIView.animate(withDuration: 0.0, animations: {
        //            DispatchQueue.main.async {
        self.tblHome.reloadData()
        //            }
        //        }, completion: { (Bool) in
        //
        //        })
        
    }
    
    func notificationUnfollow(_ notification : Notification) {
        
        guard let jsonData   = notification.object as? Any else {
            return
        }
        
        let notiItemData = UserModel(fromJson: notification.object as! JSON)
        
        let predict1 = NSPredicate(format: "userId != %@",notiItemData.userId)
        
        self.arrayItemData = self.arrayItemData.filter({ predict1.evaluate(with: $0) })
        
        /*//change main data
         
         arrayItemData = arrayItemData.filter({ (objFollow : ItemModel) -> Bool in
         
         let cellType = RackCellType(rawValue: objFollow.rackCell)
         
         switch cellType! {
         case .normalCell:
         
         arrayItemData = arrayItemData.filter { (objFollow : ItemModel) -> Bool in
         if objFollow.userId == notiItemData.userId {
         return false
         } else {
         return true
         }
         }
         
         return true
         case .multiImageCell:
         
         objFollow.itemData = objFollow.itemData.filter({ (objFollow : ItemModel) -> Bool in
         if objFollow.userId == notiItemData.userId {
         return false
         } else {
         return true
         }
         })
         
         return true
         }
         })*/
        
        //        UIView.animate(withDuration: 0.0, animations: {
        //            DispatchQueue.main.async {
        self.tblHome.reloadData()
        //            }
        //        }, completion: { (Bool) in
        //
        //        })
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callItemListAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : item/itemlist
         
         Parameter   : type[top,down]
         
         Optional    : timestamp, pass_timestamp
         
         Comment     : This api will used for any user get follower and following list.
         
         ==============================
         */
        
        APICall.shared.PUT(strURL: kMethodItemList
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            self.isWSCalling = true
            if (error == nil) {
                
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    self.viewNoFollowerFound.removeFromSuperview()
                    self.callAfterServiceResponse(response[kData],pageRefresh: PageRefreshType(rawValue: requestModel.type)!)
                    
                    block(true)
                    break
                    
                case myfeedlistempty:
                    self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
                    self.arrayItemData.removeAll()
                    self.tblHome.reloadData()
                    self.lblNoFollowersTitle.text = response[kTitle].stringValue
                    self.lblNoFollowersMsg.text = response[kMessage].stringValue
                    self.addNoFollowersFoundView()
                    
                    block(false)
                    break
                    
                default:
                    self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
                    
                    block(false)
                    break
                }
            } else {
                self.tblHome.ins_endInfinityScroll(withStoppingContentOffset: true)
                
                block(false)
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
                    
                    //Google Analytics
                    
                    let category = "UI"
                    let action = "\(UserModel.currentUser.displayName!) liked an item"
                    let lable = ""
                    let screenName = "Feed"
                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics
                    
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
    
    func callWantAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : item/itemwant
         
         Parameter   : item_id
         
         Optional    :
         
         Comment     : This api will used for user to save particular item to want list.
         
         ==============================
         */
        
        APICall.shared.CancelTask(url: kMethodWantList)
        
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
    
    func callUserDataAPI(_ requestModel : RequestModel, withCompletion block:@escaping (Bool, JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/user_data
         
         Parameter   : user_name
         
         Optional    :
         
         Comment     : This api will used for user can view user by username
         
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodUserData
            , parameter: requestModel.toDictionary()
            , withErrorAlert : false
        ) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    block(true,response[kData])
                    break
                    
                default:
                    
                    block(false, nil)
                    break
                }
            } else {
                block(false, nil)
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func btnDotTapped(_ sender : UIButton) {
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        self.tblHome.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        
        if let dictAtIndex = arrayItemData[indexPath.row] as? ItemModel {
            
            if let cell = tblHome.cellForRow(at: indexPath) as? RackCell {
                
                guard cell.imgPost.image != nil && cell.imgPost.image!.size != CGSize.zero else {
                    return
                }
                
//                let rect : CGRect = cell.imgPost.convert(cell.imgPost.frame, to: self.view)
//                normalCellPopUp.contentViewTopConstraint.constant = rect.origin.y
                normalCellPopUp.delegate = self
                normalCellPopUp.imgPost = cell.imgPost.image!
                normalCellPopUp.setUpData(dictAtIndex)
                
                showAnimationMethod()
            }
        }
    }
    
    func btnLikeClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
            return
        }
        cell.btnLike.scaleAnimation(0.15, scale: -0.05)
        
        let dictAtIndex : ItemModel = arrayItemData[indexPath.row]
        let status = dictAtIndex.loginUserLike!
        dictAtIndex.loginUserLike = !status
        cell.btnLike.isSelected = !status
        dictAtIndex.likeCount = cell.btnLike.isSelected ? "\(Int(dictAtIndex.likeCount)! + 1)" : "\(Int(dictAtIndex.likeCount)! - 1)"
        arrayItemData[indexPath.row] = dictAtIndex
        
        cell.lblLike.text = GFunction.shared.getProfileCount(dictAtIndex.likeCount)
        
        let requestModel = RequestModel()
        requestModel.item_id = dictAtIndex.itemId
        requestModel.is_like = cell.btnLike.isSelected ? StatusType.like.rawValue : StatusType.unlike.rawValue
        
        //        to handel crash
        //                guard self.tblHome != nil else {
        //                    return
        //                }
        //
        //
        //            self.tblHome.reloadData()
        
        
        
        //         self.tblHome.reloadRows(at: [indexPath], with: .none)
        
        
        //        self.tblHome.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: dictAtIndex)
        
        
        
        self.callLikeAPI(requestModel,
                         withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
        })
        
    }
    
    func btnCommentClicked(_ sender : UIButton) {
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
            return
        }
        
        let dictAtIndex : ItemModel = arrayItemData[indexPath.row]
        
        cell.btnComment.scaleAnimation(0.15, scale: -0.05)
        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        vc.dictFromParent = dictAtIndex
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func btnRepostClicked(_ sender : UIButton) {
        
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
            return
        }
        
        guard cell.imgPost.image != nil && cell.imgPost.image!.size != CGSize.zero else {
            return
        }
        
        cell.btnRepost.scaleAnimation(0.15, scale: -0.05)
        
        let dictAtIndex : ItemModel = arrayItemData[indexPath.row]
        if !dictAtIndex.loginUserRepost {
            
            let objAtIndex = arrayItemData[indexPath.row]
            let obj = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
            obj.imgPost = cell.imgPost.image
            obj.dictFromParent = objAtIndex
            obj.shareType = .repost
            
            let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
            navigationController.navigationBar.barStyle = .black
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func btnWantClicked(_ sender : UIButton)  {
        guard let indexPath = sender.buttonIndexPath  else {
            return
        }
        
        guard let cell = tblHome.cellForRow(at: indexPath) as? RackCell else {
            return
        }
        cell.btnWant.scaleAnimation(0.15, scale: -0.05)
        
        let objAtIndex = arrayItemData[indexPath.row]
        
        let status = objAtIndex.loginUserWant!
        cell.btnWant.isSelected = !status
        objAtIndex.loginUserWant = !status
        
        let requestModel = RequestModel()
        requestModel.item_id = objAtIndex.itemId
        requestModel.type = cell.btnWant.isSelected ? StatusType.want.rawValue : StatusType.unwant.rawValue
        
        self.callWantAPI(requestModel,
                         withCompletion: { (isSuccess : Bool, jsonResponse : JSON?) in
                            
                            if isSuccess {
                                
                                let data = jsonResponse!["item_detail"]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationWant), object: data)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationItemDetailUpdate), object: objAtIndex)
                            } else {
                                
                            }
                            
                            //to handel crash
                            guard self.tblHome != nil else {
                                return
                            }
                            //self.tblHome.reloadRows(at: [indexPath], with: .none)
        })
        
    }
    
    @IBAction func btnNoFollower(_ sender: UIButton) {
        let vc : FollowFriendVC = mainStoryBoard.instantiateViewController(withIdentifier: "FollowFriendVC") as! FollowFriendVC
        vc.userData = UserModel.currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //------------------------------------------------------
    
    //MARK:- ScrollView Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView .isEqual(tblHome) {
            
            /*
             cancelPreviousPerformRequests - 
             */
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.autoHideTagCollectionOptionView), object: nil)
            self.perform(#selector(self.autoHideTagCollectionOptionView), with: nil, afterDelay: 5.0)
            self.addGestureToCell()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)  {
        if scrollView .isEqual(tblHome) {
//            self.autoHideTagCollectionOptionView()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView .isEqual(tblHome) {
            self.addGestureToCell()
        } /*else if scrollView .isEqual(scrollViewMain){
            scrollViewMain.removeFromSuperview()
        }*/
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView .isEqual(tblHome) {
//            self.removeGestureToCell()
        } /*else if scrollView .isEqual(scrollViewMain){
            scrollViewMain.removeFromSuperview()
        }*/
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView .isEqual(tblHome) {
            self.removeGestureToCell()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        /*if scrollView .isEqual(scrollViewMain){
            currentImageView.translatesAutoresizingMaskIntoConstraints = false
            return currentImageView
        }*/
        return nil
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        /*if scrollView .isEqual(scrollViewMain){
            scrollViewMain.removeFromSuperview()
        }*/
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:- Check whether to show onboarding or no
        let requestModel = RequestModel()
        requestModel.tutorial_type = tutorialFlag.Newsfeed.rawValue
        
        GFunction.shared.getTutorialState(requestModel) { (isSuccess: Bool) in
            if isSuccess {
                let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
                onBoarding.tutorialType = .Newsfeed
                self.present(onBoarding, animated: false, completion: nil)
            } else {
                
            }
        }
        
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = addBarButtons(btnLeft: nil, btnRight: nil, title: "", isSwipeBack: false)
        self.navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logoSmall"))
        
        
         //Google Analytics
         
         let category = "UI"
         let action = "\(UserModel.currentUser.displayName!) view feeds"
         let lable = ""
         let screenName = "Feed"
         googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
         
         //Google Analytics
         
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
}

extension RackVC : PSTableDelegateDataSource/*, UITableViewDataSourcePrefetching*/ {
    
    //    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    //        let urls = indexPaths.map { arrayItemData[$0.row].image }
    //        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    //    }
    
    /*func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
     
     _ = indexPaths.filter { (indexPath : IndexPath) -> Bool in
     let objAtIndex = arrayItemData[indexPath.row]
     
     let cellType = RackCellType(rawValue: objAtIndex.rackCell)
     
     switch cellType! {
     case .normalCell:
     
     let identifier = "RackCell"
     let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! RackCell
     
     cell.imgPost.sd_cancelCurrentImageLoad()
     cell.imgPost.setImageWithDownload(objAtIndex.image.url(), itemData : objAtIndex)
     
     let width  : Float = Float(objAtIndex.width)!
     let height : Float = Float(objAtIndex.height)!
     cell.constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
     
     break
     
     case .multiImageCell:
     
     break
     }
     return true
     }
     }
     
     func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
     _ = indexPaths.filter { (indexPath : IndexPath) -> Bool in
     let objAtIndex = arrayItemData[indexPath.row]
     
     let cellType = RackCellType(rawValue: objAtIndex.rackCell)
     
     switch cellType! {
     case .normalCell:
     
     let identifier = "RackCell"
     let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! RackCell
     
     cell.imgPost.sd_cancelCurrentImageLoad()
     
     break
     
     case .multiImageCell:
     
     break
     }
     return true
     }
     }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItemData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        switch cellType! {
        case .normalCell:
            
            /*let width  : Float = Float(objAtIndex.width)!
             let height : Float = Float(objAtIndex.height)!
             let imageHeight = kScreenWidth / CGFloat(width) * CGFloat(height)
             
             let bottomViewHeight = objAtIndex.likeCount != "0" && objAtIndex.commentCount != "0" ? 60.0 : 40.0
             
             let caption = objAtIndex.caption
             let captionHeight = caption?.findHeightForText(text: caption!, havingWidth: kScreenWidth - 20, havingHeight: CGFloat.greatestFiniteMagnitude, andFont: UIFont.applyRegular(fontSize: 13.0))
             
             return (47.0) + imageHeight + CGFloat(bottomViewHeight) + (captionHeight?.height)! + 18.0*/
            
            return UITableViewAutomaticDimension
            
        case .multiImageCell:
            return (kScreenWidth / 3.2) + (60.0)
        }
    }
    
    /*
     Like flickering issue solution
     Please dont remove this code - Start
     */
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //Like flickering issue solution
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
        
        let objAtIndex = arrayItemData[indexPath.row]
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        switch cellType! {
        case .normalCell:
            if let cell = cell as? RackCell {
                cell.imgPost.setImageWithDownload(objAtIndex.image.url())
                cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
                let width  : Float = Float(objAtIndex.width)!
                let height : Float = Float(objAtIndex.height)!
                let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
                if Float(heightConstant) > Float(kScreenHeight - 108) {
                    cell.constImageHeight.constant = kScreenWidth
                    cell.imgPost.contentMode = .scaleAspectFill
                    
                } else {
                    cell.constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
                    cell.imgPost.contentMode = .scaleToFill
                }
            }
        default:
            break
        }
    }
    
    /*
     Like flickering issue solution
     Please dont remove this code - End
     */
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayItemData[indexPath.row]
        
        let cellType = RackCellType(rawValue: objAtIndex.rackCell)
        
        if arrayItemData.count - 5 == indexPath.row {
            self.tblHome.ins_beginInfinityScroll()
        }
        
        switch cellType! {
        case .normalCell:
            
            let identifier = "RackCell"
            //            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! RackCell
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! RackCell
            
//            cell.imgPost.sd_cancelCurrentImageLoad()
            
            cell.imgPost.setImageWithDownload(objAtIndex.image.url()/*, itemData : objAtIndex*/)
            cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
            
            cell.selectionStyle = .none
            
            //Manage using height constant.
            let width  : Float = Float(objAtIndex.width)!
            let height : Float = Float(objAtIndex.height)!
//            cell.constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
//            cell.imgPost.contentMode = .scaleToFill
            
            let heightConstant = kScreenWidth / CGFloat(width) * CGFloat(height)
            
            if Float(heightConstant) > Float(kScreenHeight - 108) {
                cell.constImageHeight.constant = kScreenWidth
                cell.imgPost.contentMode = .scaleAspectFill
            } else {
                cell.constImageHeight.constant = kScreenWidth / CGFloat(width) * CGFloat(height)
                cell.imgPost.contentMode = .scaleToFill
            }
            
            cell.lblUserName.text = objAtIndex.getUserName()
            cell.lblPostType.text = objAtIndex.itemType == "rack" ? "Racked" : "Wants"
            cell.lblTime.text = objAtIndex.calculatePostTime()
            cell.btnDot.tag = indexPath.row
            
            let str = objAtIndex.caption.characters.count > 0 ? "\(objAtIndex.getUserName()) \(objAtIndex.caption!)" : ""
            cell.lblDetail.text = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            /*
             To avoid Active label leaving 1 space issue
             */
            
            if objAtIndex.caption.characters.count == 0 {
                cell.constLblDetailHeight.constant = 0
                cell.constLblDetailHeight.priority = 999
            } else {
                cell.constLblDetailHeight.priority = 250
            }
            
            cell.lblLike.text = GFunction.shared.getProfileCount(objAtIndex.likeCount)
            //like button state management
            cell.btnLike.isSelected = objAtIndex.loginUserLike
            
            cell.btnComment.isSelected = objAtIndex.loginUserComment
            
            //want button state management
            cell.btnWant.isSelected = objAtIndex.loginUserWant
            
            //repost button state management
            cell.btnRepost.isSelected = objAtIndex.loginUserRepost
            
            //1. owner's user item, dont show repost button
            //2. from ws if repost = no, dont show repost button
            if objAtIndex.userId != UserModel.currentUser.userId {
                if objAtIndex.repost == "yes" {
                    cell.btnRepost.isUserInteractionEnabled = true
                    cell.lblRepost.isHidden = false
                } else {
                    cell.btnRepost.isUserInteractionEnabled = false
                    cell.lblRepost.isHidden = true
                }
            } else {
                cell.btnRepost.isUserInteractionEnabled = false
                cell.lblRepost.isHidden = true
            }
            
            //want button state management
            //1. owner's user item, dont show want button
            if objAtIndex.userId == UserModel.currentUser.userId {
                cell.btnWant.isHidden = true
                cell.lblWant.isHidden = true
            } else {
                cell.btnWant.isHidden = false
                cell.lblWant.isHidden = false
            }
            
            cell.lblComment.text = GFunction.shared.getProfileCount(objAtIndex.commentCount)
            cell.btnRepost.badgeString = GFunction.shared.getProfileCount(objAtIndex.repostCount)
            cell.btnLikeBig.isHidden = true
            
            //comment lable click management. Hast Tag , UserName and mentioned user
            cell.lblDetail.numberOfLines = 0
            self.setUpDetailText(cell.lblDetail,userName : objAtIndex.caption.characters.count > 0 ? objAtIndex.getUserName() : "", obj : objAtIndex)
            
            cell.collectionViewTag.isHidden = false
            
            //addAction for cell button
            cell.btnDot.addTarget(self, action: #selector(btnDotTapped(_:)), for: .touchUpInside)
            cell.btnLike.addTarget(self, action: #selector(btnLikeClicked(_:)), for: .touchUpInside)
            cell.btnComment.addTarget(self, action: #selector(btnCommentClicked(_:)), for: .touchUpInside)
            cell.btnRepost.addTarget(self, action: #selector(btnRepostClicked(_:)), for: .touchUpInside)
            cell.btnWant.addTarget(self, action: #selector(btnWantClicked(_:)), for: .touchUpInside)
            
            //add indexpth in to buttonIndex
            cell.btnLike.buttonIndexPath = indexPath
            cell.btnComment.buttonIndexPath = indexPath
            cell.btnRepost.buttonIndexPath = indexPath
            cell.btnWant.buttonIndexPath = indexPath
            
            //remove All subview of image
            cell.imgPost.removeAllPSTagView()
            
            cell.configureCollectionViewForTag(objAtIndex)
            
            //To manage click of tag option collection click in to rack VC
            cell.tagOptionSelectionSelection = { tagIndexPath , type in
                //             print("Item Indedx Path ",indexPath.row,"Tag Index path :",tagIndexPath.row)
                
                cell.imgPost.removeAllPSTagView()
                cell.collectionViewTag.isHidden = true
                
                switch type {
                    
                case .none:
                    //             print("Require to handel User Post...")
                    
                    if let userData = objAtIndex as? ItemModel {
                        //Require to change view type according to POST type. At WS parsing time
                        let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                        vc.viewType = .other
                        vc.fromPage = .otherPage
                        
                        let userData = UserModel()
                        userData.userId = objAtIndex.ownerUid
                        vc.userData = UserModel(fromJson: JSON(userData.toDictionary()))
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                    break
                case .tagBrand ,.tagItem ,.tagPeople, .addLink:
                    
                    //Change Datasource and Also change parameter of showTagOnImage at service time.
                    
                    //                For Passing Tag Taga With Image
                    let scaleFactor = cell.imgPost.image?.getPostImageScaleFactor(kScreenWidth)
                    //                SimpleTagModel.changeTagCondinateTomDeviceImageScaleFactor(tagData.brandTag, scaleFactor: Float(scaleFactor!))
                    
                    guard cell.imgPost.image != nil else {
                        return
                    }
                    
                    if let tagData = objAtIndex.tagDetail {
                        
                        if type.rawValue == TagType.tagBrand.rawValue {
                            
                            var detail = tagData.brandTag
                            
                            //change image (x,y) to pass
                            //                        detail = SimpleTagModel.changeTagCondinateTomDeviceImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                            
                            let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                            
                            let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.brand)
                            for singleTag in tagView {
                                singleTag.delegate = self
                                cell.imgPost.addSubview(singleTag)
                            }
                        } else if type.rawValue == TagType.tagItem.rawValue {
                            
                            var detail = tagData.itemTag
                            
                            //change image (x,y) to pass
                            //                        detail = SimpleTagModel.changeTagCondinateTomDeviceImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                            
                            let tagDetail = SimpleTagModel.dictArrayFromModelArray(array: detail!)
                            
                            let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.item)
                            for singleTag in tagView {
                                singleTag.delegate = self
                                cell.imgPost.addSubview(singleTag)
                            }
                        } else if type.rawValue == TagType.addLink.rawValue {
                            
                            var detail = tagData.linkTag
                            
                            //change image (x,y) to pass
                            //                        detail = LinkTagModel.changeTagCondinateTomDeviceImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                            
                            let tagDetail = LinkTagModel.dictArrayFromModelArray(array: detail!)
                            let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.link)
                            for singleTag in tagView {
                                singleTag.delegate = self
                                cell.imgPost.addSubview(singleTag)
                            }
                        } else if type.rawValue == TagType.tagPeople.rawValue {
                            
                            var detail = tagData.userTag
                            
                            //change image (x,y) to pass
                            //                        detail = PeopleTagModel.changeTagCondinateTomDeviceImageScaleFactor(detail!, scaleFactor: Float(scaleFactor!))
                            
                            let tagDetail = PeopleTagModel.dictArrayFromModelArray(array: detail!)
                            let tagView = PSTagView.showTagOnImage(tagDetail, parentView: cell.imgPost, mainImage : cell.imgPost.image!, searchType: searchFlagType.people)
                            for singleTag in tagView {
                                singleTag.delegate = self
                                cell.imgPost.addSubview(singleTag)
                            }
                        }
                    }
                    break
                default:
                    break
                }
                
            }
            
            return cell
            
        case .multiImageCell:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RackMultiImageCell") as! RackMultiImageCell
            cell.configureMultiImageCell(objAtIndex.itemData)
            
//            cell.imgProfile.sd_cancelCurrentImageLoad()
            cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
            cell.lblUserName.text = objAtIndex.getUserName()
            cell.lblPostType.text = objAtIndex.userLikeCount
            
            cell.lblTime.text = objAtIndex.calculatePostTime()
            
            //singletap configuration for profileview
            cell.profileViewGesture = UITapGestureRecognizer(target: self, action: #selector(profileViewSingleTap(_:)))
            cell.profileViewGesture.numberOfTapsRequired = 1
            cell.profileViewGesture.numberOfTouchesRequired = 1
            cell.profileView.addGestureRecognizer(cell.profileViewGesture)
            cell.profileView.isUserInteractionEnabled = true
            
            //Set Cell on gesture objc_
            objc_setAssociatedObject(cell.profileViewGesture, &constRackCell, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            //Getting Index From collectionview selected indexpath
            cell.multiImageSelection = { imageIndexPath in
                //                print("Collection Image Selected From tablecell",indexPath,"Collection Cell",imageIndexPath)
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "RackDetailVC") as! RackDetailVC
                vc.dictFromParent = (self.arrayItemData[indexPath.row]).itemData[imageIndexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }
    }
}

extension RackVC : PSTagViewTapDelegate {
    
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

extension RackVC : NormalCellPopUpDelegate {
    func handleBtnClick(btn : NormalCellType, data : ItemModel, img : UIImage) {
        
        if btn == .edit {
            
            let obj = secondStoryBoard.instantiateViewController(withIdentifier: "UploadVC") as! UploadVC
            obj.imgPost = img
            obj.dictFromParent = data
            obj.shareType = .main
            
            let navigationController : UINavigationController = UINavigationController(rootViewController: obj)
            navigationController.navigationBar.barStyle = .black
            self.present(navigationController, animated: true, completion: nil)
            
        } else if btn == .report {
            
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "ReportVC") as! ReportVC
            vc.reportId = data.userId
            vc.reportType = .item
            vc.offenderId = data.userId
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            //            print("Button delete pressed")
        }
    }
}

extension RackVC : UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

//MARK:- RackCell -

class RackCell: UITableViewCell {
    
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
    
    @IBOutlet weak var collectionViewTag: UICollectionView!
    @IBOutlet weak var constCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constImageHeight: NSLayoutConstraint!
    @IBOutlet var constLblDetailHeight: NSLayoutConstraint!
    
    /*var arrayTagType :[Dictionary<String,Any>] = {
     
     var array = [Dictionary<String,Any>]()
     
     array.append(["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none])
     array.append(["img" : #imageLiteral(resourceName: "iconTag") ,kAction : TagType.tagBrand])
     array.append(["img" : #imageLiteral(resourceName: "iconProdTag") ,kAction : TagType.tagItem])
     array.append(["img" : #imageLiteral(resourceName: "iconUserTag") ,kAction : TagType.tagPeople])
     array.append(["img" : #imageLiteral(resourceName: "iconAddLink") ,kAction : TagType.addLink])
     
     return array
     }()*/
    
    var arrayTagType : [Dictionary<String,Any>] = [Dictionary<String,Any>]()
    
    //To manage dyanamic hegith width for tag collectionView
    let collectionCellHeight = 30
    let collectionCellSpacing = 5
    
    var profileViewGesture = UITapGestureRecognizer()
    var likeLabelGesture = UITapGestureRecognizer()
    var doubleTapGesture = UITapGestureRecognizer()
    var singleTapGesture = UITapGestureRecognizer()
    var pinchGesture = UIPinchGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    var tagOptionSelectionSelection :((IndexPath,TagType) -> Void)?
    
    /*var isZooming = false
     var originalImageCenter:CGPoint?
     var pan = UIPanGestureRecognizer()*/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //50 topview and 20 is paddind from top and bottom for image
        //        imgProfile.applyStype(cornerRadius: ((50 * kHeightAspectRasio) - 20) / 2)
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.height / 2)
        
        //        panGesture.delegate = self
        //        pinchGesture.delegate = self
        
        
        
        lblUserName.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: UIColor.white)
        lblPostType.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0), labelColor: UIColor.white)
        lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0), labelColor: UIColor.white)
        
        btnLikeBig.isHidden = true
        
        lblLike.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        lblComment.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        lblRepost.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        lblWant.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0,isAspectRasio: true), labelColor: UIColor.white)
        
        lblDetail.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.colorFromHex(hex: kColorGray74))
        
        collectionViewTag.dataSource = self
        collectionViewTag.delegate = self
        collectionViewTag.isHidden = true
        
        /*let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
         pinch.delegate = self
         self.imgPost.addGestureRecognizer(pinch)*/
        
    }
    
    /*func pan(sender: UIPanGestureRecognizer) {
     if self.isZooming && sender.state == .began {
     self.originalImageCenter = sender.view?.center
     } else if self.isZooming && sender.state == .changed {
     let translation = sender.translation(in: self)
     if let view = sender.view {
     view.center = CGPoint(x:view.center.x + translation.x,
     y:view.center.y + translation.y)
     }
     sender.setTranslation(CGPoint.zero, in: self.imgPost.superview)
     } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
     
     guard let center = self.originalImageCenter else {return}
     
     pan.delegate = nil
     self.imgPost.removeGestureRecognizer(pan)
     
     UIView.animate(withDuration: 0.3, animations: {
     self.imgPost.transform = CGAffineTransform.identity
     self.imgPost.center = center
     }, completion: { _ in
     self.isZooming = false
     })
     }
     }
     
     func pinch(sender:UIPinchGestureRecognizer) {
     
     if sender.state == .changed || sender.state == .began {
     (self.superview! as! UIScrollView).isScrollEnabled = false
     }else{
     (self.superview! as! UIScrollView).isScrollEnabled = true
     }
     
     if sender.state == .began {
     
     pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
     pan.delegate = self
     self.imgPost.addGestureRecognizer(pan)
     
     let currentScale = self.imgPost.frame.size.width / self.imgPost.bounds.size.width
     let newScale = currentScale*sender.scale
     
     if newScale > 1 {
     self.isZooming = true
     }
     } else if sender.state == .changed {
     
     guard let view = sender.view else {return}
     
     let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
     y: sender.location(in: view).y - view.bounds.midY)
     let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
     .scaledBy(x: sender.scale, y: sender.scale)
     .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
     
     let currentScale = self.imgPost.frame.size.width / self.imgPost.bounds.size.width
     var newScale = currentScale*sender.scale
     
     if newScale < 1 {
     newScale = 1
     let transform = CGAffineTransform(scaleX: newScale, y: newScale)
     self.imgPost.transform = transform
     sender.scale = 1
     }else {
     view.transform = transform
     sender.scale = 1
     }
     
     } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
     
     guard let center = self.originalImageCenter else {return}
     
     UIView.animate(withDuration: 0.3, animations: {
     self.imgPost.transform = CGAffineTransform.identity
     self.imgPost.center = center
     }, completion: { _ in
     self.isZooming = false
     })
     }
     }*/
    
    func btnTapAnimation(_ sender : UIView) {
        
        UIView.animate(withDuration: 3.0, animations: {
            
            self.contentView.isUserInteractionEnabled = false
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            
        }) { (isComplete : Bool) in
            
            UIView.animate(withDuration: 3.0, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                
            }, completion: { (isComplete : Bool) in
                self.contentView.isUserInteractionEnabled = true
            })
        }
    }
    
    func configureCollectionViewForTag(_ sender : Any?) {
        /* ====================================================================================
         //TODO: Configuration CollectionView from cellForRowAtIndexPath of tableView.
         ====================================================================================*/
        
        arrayTagType = [
            ["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none],
            ["img" : #imageLiteral(resourceName: "iconTag") ,kAction : TagType.tagBrand],
            ["img" : #imageLiteral(resourceName: "iconProdTag") ,kAction : TagType.tagItem],
            ["img" : #imageLiteral(resourceName: "iconUserTag") ,kAction : TagType.tagPeople],
            ["img" : #imageLiteral(resourceName: "iconAddLink") ,kAction : TagType.addLink]
        ]
        
        let itemDetail = (sender as! ItemModel)
        
        let tagDetail = itemDetail.tagDetail
        
        arrayTagType = arrayTagType.filter({ (objTag : Dictionary<String, Any>) -> Bool in
            let detail = tagDetail?.toDictionary()
            return detail![(objTag[kAction] as! TagType).rawValue] != nil && (detail![(objTag[kAction] as! TagType).rawValue] as! [Dictionary<String, Any>]).count > 0
        })
        
        if itemDetail.userId != itemDetail.ownerUid {
            arrayTagType.insert(["img" : #imageLiteral(resourceName: "iconUserPost") ,kAction : TagType.none], at: 0)
        }
        
        collectionViewTag.reloadData()
        
        //CollectionView Height Management. if User tag option will be dynamic.For Now its static if dyanamic then uncomment following code.
        let collectionHeight = (arrayTagType.count * collectionCellHeight) //+ ((arrayTagType.count - 1) * collectionCellSpacing)
        self.constCollectionHeight.constant = CGFloat(collectionHeight)
    }
    
    /*override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
     return true
     }*/
    
}

extension RackCell : PSCollectinViewDelegateDataSource {
    
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
        
        //        print(dictAtIndex[kAction] ?? "wrong")
        //manage tag in rack vc
        self.tagOptionSelectionSelection!(indexPath,dictAtIndex[kAction] as! TagType)
    }
    
}
//MARK:- RackTagCell -
class RackTagCell: UICollectionViewCell {
    
    @IBOutlet var imgIcon : UIImageView!
    
}

//MARK:- RackMultiImageCell -
class RackMultiImageCell: UITableViewCell {
    
    @IBOutlet var profileView : UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPostType: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var collectionImage: UICollectionView!
    
    var profileViewGesture  = UITapGestureRecognizer()
    
    var multiImageSelection :((IndexPath) -> Void)?
    
    var arrayImage : [ItemModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //50 topview and 20 is paddind from top and bottom for image
        //        imgProfile.applyStype(cornerRadius: ((imgProfile.frame.size.height * kHeightAspectRasio) - 20) / 2)
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.height / 2)
        
        lblUserName.applyStyle(labelFont: UIFont.applyBold(fontSize: 12.0), labelColor: UIColor.white)
        lblPostType.applyStyle(labelFont: UIFont.applyRegular(fontSize: 11.0), labelColor: UIColor.white)
        lblTime.applyStyle(labelFont: UIFont.applyRegular(fontSize: 9.0), labelColor: UIColor.white)
        
        collectionImage.delegate = self
        collectionImage.dataSource = self
    }
    
    func configureMultiImageCell(_ sender : [ItemModel]?) {
        
        if let _ = sender {
            self.arrayImage = sender!
            collectionImage.reloadData()
        }
        
    }
}

extension RackMultiImageCell : PSCollectinViewDelegateDataSource/*, UICollectionViewDataSourcePrefetching*/ {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? RackCollectioCell {
            cell.imgView.setImageWithDownload(self.arrayImage[indexPath.row].image.url())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RackCollectioCell", for: indexPath) as! RackCollectioCell
        cell.imgView.setImageWithDownload(self.arrayImage[indexPath.row].image.url())
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth / 3.2, height: (kScreenWidth / 3.2))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Call in to RackVC TableView CellForRowAtIndex
        self.multiImageSelection!(indexPath)
    }
}

//MARK:- RackCollectioCell -
class RackCollectioCell: UICollectionViewCell {
    
    @IBOutlet var imgView : UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.contentMode = .scaleAspectFill
    }
    
}

