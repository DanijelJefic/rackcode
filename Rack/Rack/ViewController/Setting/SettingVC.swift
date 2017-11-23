//
//  SettingVC.swift
//  Rack
//
//  Created by hyperlink on 09/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import MessageUI
import Messages

var constCellSwitchKey: UInt8 = 0

let kID             : String = "id"
let kTitle          : String = "title"
let kSubTitle       : String = "subTitle"
let kIsPushAction   : String = "kIsPushAction"
let kAction         : String = "kAction"
let kCellType       : String = "kCellType"


class SettingVC: UIViewController {

    //Other Setup
    enum settingCellType {
        case normalCell
        case switchTypeCell
        case switchTypeWithOutSubtitleCell
    }
    
    enum cellAction {
        case privateAccount
        case blockedUser
        case myActivity
        case shareRack
        case feedback
        case aboutUs
        case changePassword
        case editProfile
        case selectWardRobe
        case showRack
    }
    
    typealias cellType = settingCellType
    typealias action   = cellAction
    
    //MARK:- Outlet
    
    @IBOutlet weak var tblSetting: UITableView!
    
    
    @IBOutlet var viewFooter: UIView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var btnLogout2: UIButton!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var arrayDataSoruce : [Dictionary<String,Any>] = [
        [kTitle:"Private Account",kSubTitle:"Accept followers to your accounts",kCellType:cellType.switchTypeCell,kIsPushAction:false,kAction:action.privateAccount]
        ,[kTitle:"Blocked Users",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:true,kAction:action.blockedUser]
        ,[kTitle:"My Activity",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:true,kAction:action.myActivity]
        ,[kTitle:"Share Rack",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:false,kAction:action.shareRack]
        ,[kTitle:"Feedback",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:false,kAction:action.feedback]
        ,[kTitle:"About Us",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:true,kAction:action.aboutUs]
        ,[kTitle:"Change Password",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:true,kAction:action.changePassword]
        ,[kTitle:"Edit Profile",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:true,kAction:action.editProfile]
        ,[kTitle:"Select Rack",kSubTitle:"",kCellType:cellType.normalCell,kIsPushAction:true,kAction:action.selectWardRobe]
        ,[kTitle:"Show Rack",kSubTitle:"",kCellType:cellType.switchTypeWithOutSubtitleCell,kIsPushAction:false,kAction:action.showRack]
    ]
    
    let isShowRack = UserModel.currentUser.showRack
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Here we go...")
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {

        //TabBarHidden:true
        self.tabBarController?.tabBar.isHidden = true

        //set table footer view
        tblSetting.tableFooterView = viewFooter
        btnLogout2.applyStyle(titleLabelFont: UIFont.applyBold(fontSize: 13.0), titleLabelColor: UIColor.white)

        
        //TODO: Manage Remove Change Password if user login with facebook Account
        if UserModel.currentUser.loginType.uppercased() == "F" {
            arrayDataSoruce = arrayDataSoruce.filter { ( dictAtIndex : [String : Any]) -> Bool in
                if (dictAtIndex[kTitle] as? String) == "Change Password" {
                    return false
                }
                return true
            }
        }

    }
    
    func sendMail() {

        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["info@rackinternational.com.au"])
            composeVC.setSubject("Rack Feedback!")
            composeVC.setMessageBody("Rack App!", isHTML: false)
            present(composeVC, animated: true, completion:nil)
        }
        else {
            
            GFunction.shared.showPopup(with: "Email not configured", forTime: 2, withComplition: {
            }, andViewController: self)
        }
    }
    
    func shareApp() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionFB = UIAlertAction(title: "Facebook", style: .default) { (action : UIAlertAction) in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let mySLComposerSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                mySLComposerSheet?.setInitialText("Download Rack App today!\nDownload the Rack App now!")
                mySLComposerSheet?.add(URL(string: "https://itunes.apple.com/us/app/rack-ios/id1122994287?ls=1&mt=8"))
                
                mySLComposerSheet?.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.cancelled:
                        print("Post Canceled")
                        break
                        
                    case SLComposeViewControllerResult.done:
                        GFunction.shared.showPopup(with: "Shared successfully!", forTime: Int(2.0), withComplition: {
                        }, andViewController: self)
                        break
                    }
                }
                
                self.present(mySLComposerSheet!, animated: true, completion: nil)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Email", style: .default) { (action : UIAlertAction) in

            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                // Configure the fields of the interface.
                composeVC.setToRecipients(["info@rackinternational.com.au"])
                composeVC.setSubject("Download Rack App today!")
                composeVC.setMessageBody("Download the Rack App now! https://itunes.apple.com/us/app/rack-ios/id1122994287?ls=1&mt=8", isHTML: false)
                self.present(composeVC, animated: true, completion: nil)
            }
            else {
                GFunction.shared.showPopup(with: "Email not configured", forTime: 2, withComplition: {
                }, andViewController: self)
            }
        }

        let actionSMS = UIAlertAction(title: "SMS", style: .default) { (action : UIAlertAction) in
            
            if MFMessageComposeViewController.canSendText() {
                let messageComposer = MFMessageComposeViewController()
                messageComposer.subject = "Download Rack App today!"
                let message: String = "Download the Rack App now! https://itunes.apple.com/us/app/rack-ios/id1122994287?ls=1&mt=8"
                messageComposer.body = message
                messageComposer.messageComposeDelegate = self
                self.present(messageComposer, animated: true, completion: { _ in })
            }
            else {
                GFunction.shared.showPopup(with: "SMS can not be send!", forTime: 2, withComplition: {
                }, andViewController: self)
            }

            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
            
        }
        actionSheet.addAction(actionFB)
        actionSheet.addAction(actionEmail)
        actionSheet.addAction(actionSMS)
        actionSheet.addAction(actionCancel)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callLogoutAPI() {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/logout
         
         Parameter   :
         
         Optional    :
         
         Comment     : This api will used for user logout.
         
         
         ==============================
         
         */
        
        
        APICall.shared.GET(strURL: kMethodLogout
            , parameter: nil
            ,withLoader : true)
        { (response : Dictionary<String, Any>?, code:Int, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    GFunction.shared.userLogOut(AppDelegate.shared.window)
                    
                    //Google Analytics
                    
                    let category = "UI"
                    let action = "\(UserModel.currentUser.displayName!) logout his account"
                    let lable = ""
                    let screenName = "Settings-Logout"
                    googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
                    
                    //Google Analytics

                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
            }
            
        }
        
    }
    
    func callChangeAccountTypeAPI(requestModel : RequestModel, withCompletion block:@escaping (Bool,JSON?,String?) -> Void) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/profile_public
         
         Parameter   : public[public,private]
         
         Optional    :
         
         Comment     : This api will used for change the profile public or private.
         
         
         ==============================
         
         */
        
        APICall.shared.POST(strURL: kMethodProfilePublic
            , parameter: requestModel.toDictionary()
            , withErrorAlert : true
            )
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in

            if (error == nil) {
             
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true, response[kData], response[kMessage].stringValue)

                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    block(false, nil, nil)
                    break
                }
            } else {

                block(false, nil, nil)
            }
            
            
        }
        
        
    }

    func callShowRackAPI(requestModel : RequestModel, withCompletion block:@escaping (Bool,JSON?) -> Void) {
        
        /*
         ===========API CALL===========
         
         Method Name : user/show_rack
         
         Parameter   : show_rack[yes,no]
         
         Optional    :
         
         Comment     : This api will used for user profile show the rack item or not.
         
         
         ==============================
         
         */
        
        APICall.shared.CancelTask(url: kMethodShowRack)
        
        APICall.shared.POST(strURL: kMethodShowRack
            , parameter: requestModel.toDictionary()
            , withErrorAlert : true
            )
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    block(true,response[kData])
                    
                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    block(false,nil)
                    break
                }
            } else {
                
                block(false,nil)
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    func leftButtonClicked() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    func switchValueChanged(_ sender : UISwitch) {
    
        if let cell = objc_getAssociatedObject(sender, &constCellSwitchKey) as? SettingCell {

            if let indexPath = tblSetting.indexPath(for: cell) {
                
                let dictAtIndex = arrayDataSoruce[indexPath.row]
                let action = dictAtIndex[kAction] as! action
                
                switch action {
                case .privateAccount:
                    //Private Account

                    let requestModel = RequestModel()
                    requestModel.is_public = cell.btnSwitch.isOn ? profileType.kPrivate.rawValue : profileType.kPublic.rawValue
                    
                    cell.btnSwitch.isEnabled = false
                    self.callChangeAccountTypeAPI(requestModel: requestModel, withCompletion: { (isSuccess : Bool , jsonResponse : JSON?, message : String?) in

                        cell.btnSwitch.isEnabled = true

                        if isSuccess {

                            //Update status in current object
                            UserModel.currentUser.isPublic = jsonResponse!["is_public"].stringValue

                            //Override user object to update user status
                            UserModel.currentUser.saveUserDetailInDefaults()
                            
                            if message != nil {
                                GFunction.shared.showPopup(with: message!, forTime: 2, withComplition: {
                                }, andViewController: self)
                            }
                        }

                        //to rollback to actual status of user profile.
                        guard (cell.btnSwitch) != nil else {
                            return
                        }
                        cell.btnSwitch.setOn(UserModel.currentUser.isPrivateProfile(), animated: false)
                        
                        if !UserModel.currentUser.isPrivateProfile() {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserPrivacyPublic), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: nil)
                        }

                    })
                    
                    break

                case .showRack:

                    //show rack
                    let requestModel = RequestModel()
                    requestModel.show_rack = cell.btnSwitch.isOn ? "yes" : "no"
                    
                    cell.btnSwitch.isEnabled = false
                    self.callShowRackAPI(requestModel: requestModel, withCompletion: { (isSuccess : Bool , jsonResponse : JSON?) in
                        
                        cell.btnSwitch.isEnabled = true
                        
                        if isSuccess {
                            
                            let userData = UserModel(fromJson: jsonResponse!)
                            
                            //Save User Data into userDefaults.
                            userData.saveUserDetailInDefaults()
                            
                            //load latest data in to current User
                            UserModel.currentUser.getUserDetailFromDefaults()
                            
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationRackWantUpdate), object: nil)
                            
                        } else {
                        
                            //to rollback to actual status of user profile.
                            guard (cell.btnSwitch) != nil else {
                                return
                            }
                            cell.btnSwitch.setOn(UserModel.currentUser.isShowRack(), animated: false)
                        }
                    })
                    
                    break
                default:
                    print("Default One called")
                    break
                }
            }
        }
    }
    
    @IBAction func btnLogOutClicked(_ sender : UIButton) {
        
        AlertManager.shared.showAlertTitle(title: "LOG OUT", message: "Are you sure you want to logout?", buttonsArray: ["CANCEL","OK"]) { (buttonIndex : Int) in
            switch buttonIndex {
            case 0 :
                //Cancel clicked
                break
            case 1:
                //Ok clicked
                self.callLogoutAPI()

                break
            default:
                break
            }
            
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:- Check whether to show onboarding or no
        let requestModel = RequestModel()
        requestModel.tutorial_type = tutorialFlag.Setting.rawValue
        
        GFunction.shared.getTutorialState(requestModel) { (isSuccess: Bool) in
            if isSuccess {
                let onBoarding = mainStoryBoard.instantiateViewController(withIdentifier: "OnboardingBaseVC") as! OnboardingBaseVC
                onBoarding.tutorialType = .Setting
                self.present(onBoarding, animated: false, completion: nil)
            } else {
                
            }
        }
         
        setUpView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = addBarButtons(btnLeft: BarButton(title : "Back"), btnRight: nil, title: "SETTINGS")
        
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
        
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
        
    }
    
}

extension SettingVC : PSTableDelegateDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dictAtIndex = arrayDataSoruce[indexPath.row] as Dictionary
        
        let cellType = dictAtIndex[kCellType] as! cellType
        
        switch cellType {
        case .switchTypeCell:

            return (70 * kHeightAspectRasio)
        case .normalCell:
            return (50 * kHeightAspectRasio)
        case .switchTypeWithOutSubtitleCell:
            return (50 * kHeightAspectRasio)
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDataSoruce.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dictAtIndex = arrayDataSoruce[indexPath.row] as Dictionary
        
        let cellType = dictAtIndex[kCellType] as! cellType
        
        switch cellType {
        case .switchTypeCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell1") as! SettingCell
            cell.lblTitle.text = dictAtIndex[kTitle] as? String
            cell.lblSubTitle.text = dictAtIndex[kSubTitle] as? String

            cell.btnSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            objc_setAssociatedObject(cell.btnSwitch, &constCellSwitchKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            cell.selectionStyle = .none
            
            //to manage profile type (public/private)
            cell.btnSwitch.setOn(UserModel.currentUser.isPrivateProfile(), animated: false)

            return cell
            
        case .normalCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell2") as! SettingCell
            cell.lblTitle.text = dictAtIndex[kTitle] as? String
            cell.lblSubTitle.text = dictAtIndex[kSubTitle] as? String
            
            
            if dictAtIndex[kIsPushAction] as! Bool == true {
                cell.btnAction.isHidden = false
            } else {
                cell.btnAction.isHidden = true
            }
            cell.selectionStyle = .none
            return cell
            
        case .switchTypeWithOutSubtitleCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell3") as! SettingCell
            cell.lblTitle.text = dictAtIndex[kTitle] as? String
            cell.lblSubTitle.text = dictAtIndex[kSubTitle] as? String

            cell.btnSwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            objc_setAssociatedObject(cell.btnSwitch, &constCellSwitchKey, cell, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            cell.selectionStyle = .none
            
            //to show rack (yes/no)
            cell.btnSwitch.setOn(UserModel.currentUser.isShowRack(), animated: false)
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dictAtIndex = arrayDataSoruce[indexPath.row]
        let action = dictAtIndex[kAction] as! action
        
        switch action {
        case .blockedUser:
            let blockVC = secondStoryBoard.instantiateViewController(withIdentifier: "BlockedUserVC") as! BlockedUserVC
            self.navigationController?.pushViewController(blockVC, animated: true)
            break
        
        case .myActivity:
            let myActivityVC = secondStoryBoard.instantiateViewController(withIdentifier: "MyActivityVC") as! MyActivityVC
            self.navigationController?.pushViewController(myActivityVC, animated: true)
            break
        
        case .shareRack:
            self.shareApp()
            break
        
        case .feedback:
            self.sendMail()
            break

        case .aboutUs:
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "AboutInfoVC") as! AboutInfoVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
      
        case .changePassword:
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
            self.navigationController?.pushViewController(vc, animated: true)
            break
   
        case .editProfile:
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "CreateProfileVC") as! CreateProfileVC
            vc.fromPage = .fromSettingPage
            self.navigationController?.pushViewController(vc, animated: true)
            break
    
        case .selectWardRobe:
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ChooseRackVC") as! ChooseRackVC
            vc.fromPage = .fromSettingPage
            self.navigationController?.pushViewController(vc, animated: true)
            break
    
        default:
            print("Default One Called...")
            break
        }
    }

}

extension SettingVC : MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if result == .sent {
            GFunction.shared.alert(title: "", message: "Feedback sent!", cancelButton: "OK")
        }

        self.dismiss(animated: true, completion: nil)
    }
}
extension SettingVC : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)
    }
}


//------------------------------------------------------

//MARK: - Setting Cell -

class SettingCell: UITableViewCell {
    
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var btnAction: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.applyStyle(labelFont: UIFont.applyBold(fontSize: 13.0), labelColor: UIColor.white)
        lblSubTitle.applyStyle(labelFont: UIFont.applyBold(fontSize: 12.0), labelColor: UIColor.colorFromHex(hex: kColorGray74))
        

    }
}

