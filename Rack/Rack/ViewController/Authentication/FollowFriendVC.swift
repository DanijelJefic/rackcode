//
//  FollowFriendVC.swift
//  Rack
//
//  Created by hyperlink on 06/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit


var constHeaderKey: UInt8 = 0

class FollowFriendVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var tblFriend: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var tapGestureHeaderView = UITapGestureRecognizer()
    var arraySelectedIndexPath : [FriendModel] = []
    

    var header = UIView()
    var lblSelectAll = UILabel()
    var buttonSelectAll = UIButton()
    
    var userData = UserModel()
    var arrayMainData : [FriendModel] = []
    var arrayOperational : [FriendModel] = []
    
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(kNotificationUserDetailsUpdate)
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {

        self.updateNavigationTitle()
        
        
        
        tblFriend.allowsMultipleSelection = true
        
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.delegate = self
        searchBar.tintColor = UIColor.white
        
        tblFriend.tableFooterView = UIView()
        
        self.callSearchAPI(withFiltering: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationUserDetailsUpdate(_:)), name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
        
    }
    
    func headerViewTapGesture(_ gesture : UITapGestureRecognizer) {
 
        if let headerView = gesture.view {
         
            if let btnSelectAll = objc_getAssociatedObject(headerView, &constHeaderKey) as? UIButton {
                self.btnSelectAllClicked(btnSelectAll)
            }
        }
    }
    
    func btnSelectAllStateManagement(_ button : UIButton){

    
        let isFalseExitst = arrayOperational.map { (obj : FriendModel) -> Bool in
            return  arraySelectedIndexPath.contains(where: { (innerObj : FriendModel) -> Bool in
                return obj.id == innerObj.id
            })
        }
       
        
        if isFalseExitst.contains(false) {
            buttonSelectAll.isSelected = false
        } else {
            buttonSelectAll.isSelected = true
        }
        
        
        self.updateNavigationTitle()
        
    }
    
    func updateNavigationTitle() {
        if arraySelectedIndexPath.count == 0 {
            self.title = "FOLLOW YOUR FRIENDS"
        } else {
            self.title = "SELECTED \(arraySelectedIndexPath.count)"
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - Notification Method
    
    func notificationUserDetailsUpdate(_ notification : Notification) {
        
        guard let _  = tblFriend else {
            return
        }
        
        UIView.animate(withDuration: 0.0, animations: {
            DispatchQueue.main.async {
                self.tblFriend.reloadData()
            }
        }, completion: { (Bool) in
            
        })
    }

    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callSearchAPI(withFiltering isMainData : Bool) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/search
         
         Parameter   : search_flag[discover,people,hashtag,brand,item]
         
         Optional    : search_value,page
         
         Comment     : 
         
         
         ==============================
         
         */

        let requestModel = RequestModel()
        requestModel.search_flag = searchFlag.people.rawValue
        requestModel.search_value = searchBar.text


        if isMainData {
            GFunction.shared.addActivityIndicator(view: tblFriend)
        }
        
        
        
        APICall.shared.POST(strURL: kMethodSearch
        , parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            GFunction.shared.removeActivityIndicator()

            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:

                    if isMainData {
                        self.arrayMainData = FriendModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                        self.arrayOperational = self.arrayMainData
                    } else {
                        self.arrayOperational = FriendModel.modelsFromDictionaryArray(array: response[kData].arrayValue)
                    }
                    
                    /*
                     To download image out of visible cell's as per client's requirement, this code is implemented
 
                    _ = self.arrayOperational.filter({ (obj : FriendModel) -> Bool in
                        weak var img : UIImageView? = UIImageView()
                        img?.setImageWithDownload(obj.getUserProfile().url())
                        return true
                    })
                     */
                    self.tblFriend.reloadData()

                    break
                default :
                    print(response[kMessage].stringValue)
                    break
                }
            }
            
        }
        
    }

    func callCreateFriendAPI(requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/create_friend
         
         Parameter   : user_id,device_type[A,I],device_token,requested_users(Parsing user id separated by comma)
         
         Optional    :
         
         Comment     :
         
         
         ==============================
         
         */
        
        self.searchBar.resignFirstResponder()
        
        APICall.shared.POST(strURL: kMethodCreateFriend
            , parameter: requestModel.toDictionary()
            ,withErrorAlert : true
            ,withLoader: true)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            GFunction.shared.removeActivityIndicator()

            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    let userData = UserModel(fromJson: response[kData])

                    //Save User Data into userDefaults.
                    userData.saveUserDetailInDefaults()
                    
                    GFunction.shared.userLogin(AppDelegate.shared.window)
                    
                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
                
            } else {
                AlertManager.shared.showPopUpAlert("", message: error?.localizedDescription, forTime: 2.0, completionBlock: { (Int) in
                })
            }
            
        }
        
    }

    
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func rightButtonClicked() {
//        GFunction.shared.userLogin(AppDelegate.shared.window)

        let requestModel = RequestModel()
        requestModel.user_id = userData.userId
        requestModel.device_type = "I"
        requestModel.device_token = GFunction.shared.getDeviceToken()
        //Pass requested_users as a string and seprated by comma
        requestModel.requested_users = arraySelectedIndexPath.map{$0.id!}.joined(separator: ",")
        
        self.callCreateFriendAPI(requestModel: requestModel)
    }

    func btnSelectAllClicked(_ button : UIButton) {
        
        if button.isSelected {
            button.isSelected = false
            arraySelectedIndexPath.removeAll()
            tblFriend.reloadRows(at: tblFriend.indexPathsForVisibleRows!, with: .none)
        } else {
            button.isSelected = true
            arraySelectedIndexPath.removeAll()
           
            arraySelectedIndexPath.append(contentsOf: arrayOperational)
            tblFriend.reloadRows(at: tblFriend.indexPathsForVisibleRows!, with: .none)
        }

        self.updateNavigationTitle()
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        _ = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Done"), title: "FOLLOW YOUR FRIENDS",isSwipeBack: false)

        searchBar.layoutIfNeeded()
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
}

//MARK:- SearchBar Delegate
extension FollowFriendVC : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == "" {
            arrayOperational = arrayMainData
        } else {
            let predict = NSPredicate(format: "userName CONTAINS[cd] %@ OR userName LIKE[cd] %@",searchText, searchText)
            
            arrayOperational = arrayMainData.filter { predict.evaluate(with: $0) }

            self.callSearchAPI(withFiltering: false)
            
        }
        tblFriend.reloadData()

    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        searchBar.text = ""

        arrayOperational = arrayMainData
        tblFriend.reloadData()
        self.btnSelectAllStateManagement(buttonSelectAll)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      
        self.view.endEditing(true)
    }
}

extension FollowFriendVC : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32 * kHeightAspectRasio
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOperational.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        header = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 32*kHeightAspectRasio))
        header.backgroundColor = UIColor.black

        lblSelectAll = UILabel(frame: CGRect(x: 10, y: 0, width: kScreenWidth - 50, height: 32*kHeightAspectRasio))
        lblSelectAll.text = "Select all"
        lblSelectAll.applyStyle(labelFont: UIFont.applyBold(fontSize: 14.0), labelColor: UIColor.white)
        
        buttonSelectAll.frame = CGRect(x: kScreenWidth - 35, y: 0, width: 35, height: 32*kHeightAspectRasio)
        buttonSelectAll.setImage(#imageLiteral(resourceName: "radioNormalWhite"), for: .normal)
        buttonSelectAll.setImage(#imageLiteral(resourceName: "radioSelectedWhite") , for: .selected)
        buttonSelectAll.addTarget(self, action: #selector(btnSelectAllClicked(_:)), for: .touchUpInside)
        buttonSelectAll.contentHorizontalAlignment = .left
        
        header.addSubview(lblSelectAll)
        header.addSubview(buttonSelectAll)
        
        tapGestureHeaderView = UITapGestureRecognizer(target: self, action: #selector(headerViewTapGesture(_:)))
        tapGestureHeaderView.numberOfTapsRequired = 1
        header.addGestureRecognizer(tapGestureHeaderView)
        header.isUserInteractionEnabled = true
        objc_setAssociatedObject(header, &constHeaderKey, buttonSelectAll, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return header
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let objAtIndex = arrayOperational[indexPath.row] as FriendModel
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell") as! FollowerCell
        
        cell.selectionStyle = .none
        cell.lblUserName.text = objAtIndex.getUserName()
        cell.lblDisplayName.text = objAtIndex.displayName

        cell.imgProfile.setImageWithDownload(objAtIndex.getUserProfile().url())
        
        //user verify or not
        if objAtIndex.isUserVerify() {
            cell.imgVerify.isHidden = false
        } else {
            cell.imgVerify.isHidden = true
        }

        cell.btnSelect.isUserInteractionEnabled = false
       
        //To manage cell selection only selected array only
        if arraySelectedIndexPath.contains(where: { $0.id == objAtIndex.id }) {
            cell.btnSelect.isSelected = true
        } else {
            cell.btnSelect.isSelected = false
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let objAtIndex = arrayOperational[indexPath.row] as FriendModel
        
        if arraySelectedIndexPath.contains(where: { $0.id == objAtIndex.id }) {
            arraySelectedIndexPath = arraySelectedIndexPath.filter{$0.id != objAtIndex.id}
        } else {
            arraySelectedIndexPath.append(objAtIndex) // add indexpath to select row
        }
        
        
        tblFriend.reloadRows(at: [indexPath], with: .none)
//            tblFriend.reloadRows(at: tblFriend.indexPathsForVisibleRows!, with: .none)
        
        //btnSelectAll state management
        self.btnSelectAllStateManagement(buttonSelectAll)
    }

    
    
    //MARK: - ScrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

class FollowerCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var imgVerify: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblUserName.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: UIColor.white)
        lblDisplayName.applyStyle(labelFont: UIFont.applyRegular(fontSize: 13.0), labelColor: UIColor.white)
        imgProfile.applyStype(cornerRadius: imgProfile.frame.size.width / 2)
    
    }
 /*
    override var isSelected: Bool {
        didSet {
         btnSelect.isSelected = isSelected
        }
    }
   */
}
