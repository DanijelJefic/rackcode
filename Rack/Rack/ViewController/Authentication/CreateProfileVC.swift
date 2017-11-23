//
//  CreateProfileVC.swift
//  Rack
//
//  Created by hyperlink on 01/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import AFNetworking

class CreateProfileVC: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    //MARK:- Outlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var textContainer: CustomTextContainer!
    
    @IBOutlet weak var btnEditProfile: UIButton!
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtDisplayName: UITextField!
    @IBOutlet weak var tvBio: UITextView!
    
    @IBOutlet weak var ivProfile: UIImageView!
    
    @IBOutlet weak var lblCountCharacter: UILabel!
    
    @IBOutlet weak var lblUserNameAvailabality: UILabel!
    @IBOutlet weak var idicatorView: UIView!
    
    
    @IBOutlet weak var imageAspec: NSLayoutConstraint!
    
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var btnSave: UIButton!
    var imagePicker : UIImagePickerController = UIImagePickerController()
    var fromPage = PageFrom.defaultScreen
    
    var userData = UserModel()
    var timer = Timer()
    var isValidUserName : Bool = false
    
    var fbModel : FacebookModel? = nil
    var imageProfile : UIImage = UIImage() // to check user profile image change or not at edit profile time
    
    
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func bottomViewAnimtion(){
        
        //        let widthConstraint = NSLayoutConstraint(item: ivProfile, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 160 * kHeightAspectRasio)
        //        let heightConstraint = NSLayoutConstraint(item: ivProfile, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 160 * kHeightAspectRasio)
        //
        //        ivProfile.addConstraints([widthConstraint, heightConstraint])
        //
    }
    
    func setUpView() {
        
        //Apply button style
        btnEditProfile.applyStyle(
            titleLabelFont: UIFont.applyRegular(fontSize: 12.0)
            , titleLabelColor: UIColor.white
        )
        
        //Apply Textfiled setup
        txtUserName.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: UIColor.white)
        txtDisplayName.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: UIColor.white)
        txtUserName.setAttributedPlaceHolder(placeHolderText: "Username", color: UIColor.white)
        txtDisplayName.setAttributedPlaceHolder(placeHolderText: "Display name", color: UIColor.white)
        
        //Apply Textview
        tvBio.text = "Bio"
        tvBio.backgroundColor = UIColor.clear
        tvBio.applyStyle(textFont: UIFont.applyRegular(fontSize: 12.0), textColor: UIColor.white)
        
        tvBio.inputAccessoryView = UIToolbar().addToolBar(self)
        
        //Other font setup
        lblCountCharacter.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: UIColor.colorFromHex(hex: kColorGray74))
        lblCountCharacter.text = "0/200"
        
        //availablity label setup
        lblUserNameAvailabality.applyStyle(labelFont: UIFont.applyBold(fontSize: 12.0))
        
        
        //profile image
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapOnProfileImage))
        tapGesture.numberOfTapsRequired = 1
        ivProfile.addGestureRecognizer(tapGesture)
        ivProfile.isUserInteractionEnabled = true
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        
    }
    
    func setUpData() {
        
        //if Facebook Data avialble then set in.
        if let _ = self.fbModel {
            
            if let name = self.fbModel?.name {
                txtDisplayName.text = name
            }
            
            if let strUrl = self.fbModel?.picture.data.url {
                ivProfile.setImageWithDownload(strUrl.url())
                ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
            }
        }
        
        switch fromPage {
        case .fromSettingPage:
            
            txtUserName.text = UserModel.currentUser.userName
            txtDisplayName.text = UserModel.currentUser.displayName
            tvBio.text = UserModel.currentUser.bioTxt
            
            self.downloadImage(url: UserModel.currentUser.profile.url(), completion: { (isSuccess, image) in
                if isSuccess {
                    
                    self.imageProfile = image
                    _ = self.checkSaveButtonStatus()
                }
            })
            
            /*
            let res = ImageResource(downloadURL: UserModel.currentUser.profile.url(), cacheKey: UserModel.currentUser.profile.url().lastPathComponent)
            
            self.ivProfile.kf.setImage(with: res, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                guard let image = image else {
                    return
                }
                self.ivProfile.image = image
                self.imageProfile = image
                
                _ = self.checkSaveButtonStatus()
            })
             */
            
            /*
            
            SDWebImageManager.sharedManager().downloadImage(with: UserModel.currentUser.profile.url(), options: 0, progress: { (a : Int, b : Int) in
                
            }, completed: { (image : UIImage?, error : Error?, SDImageCacheType, isComplete : Bool, url : URL?) in
                
                if isComplete {
                    //to manage store actual in variable and compare at image data passing
                    
                    guard let image = image else {
                        return
                    }
                    self.ivProfile.image = image
                    self.imageProfile = image
                    
                    _ = self.checkSaveButtonStatus()
                }
                
            })
            */
            ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
            
            //to manage save button status enable
            isValidUserName = true
            
            break
        case .defaultScreen:
            break
        default:
            print("Default one called...")
        }
        
        
    }
    
    
    func tapOnProfileImage(_ sender : UITapGestureRecognizer) {
        self.openImagePickerSelection(sender)
    }
    
    func openImagePickerSelection(_ sender : Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //If Profile Image Not equal to default image then only require remove photo options.
        if ivProfile.image != nil && !(ivProfile.image!.isEqualToImage(#imageLiteral(resourceName: "userProfile"))) {
            
            let actionRemove = UIAlertAction(title: "Remove Photo", style: .destructive) { (action : UIAlertAction) in
                self.ivProfile.image = #imageLiteral(resourceName: "userProfile")
                
                _ = self.checkSaveButtonStatus()
            }
            actionSheet.addAction(actionRemove)
            
        }
        
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { (action : UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let vc : CameraVC = mainStoryBoard.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                vc.delegate = self
                vc.mode = .profilePickerMode
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else {
                GFunction.shared.alert(title: "", message: NSLocalizedString("Camera is not available", comment: "") ,cancelButton: NSLocalizedString("OK", comment: ""))
            }
        }
        
        let actionGallery = UIAlertAction(title: "Gallery", style: .default) { (action : UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let vc : CameraRollVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraRollVC") as! CameraRollVC
                vc.delegate = self
                vc.mode = .profilePickerMode
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                GFunction.shared.alert(title: "", message: NSLocalizedString("Photo library is not available", comment: "") ,cancelButton: NSLocalizedString("OK", comment: ""))
            }
            
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action : UIAlertAction) in
            
        }
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionGallery)
        actionSheet.addAction(actionCancel)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func downloadImage(url : URL? ,completion: @escaping (_ status : Bool , _ data : UIImage) -> Void) {
        
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            print("Downloading Started")
            if let url = url {
                if let image = self.ivProfile.setImageWith(url)
                {
                    print("Downloading Finished")
                    completion(true , image)
                }
            }
        })
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked(){
        switch fromPage {
        case .defaultScreen:
            
            break
        case .fromSettingPage:
            if let _ = self.navigationController {
                _ = self.navigationController?.popViewController(animated: true)
            }
            break
        default:
            print("Default one called...")
        }
    }
    
    func rightButtonClicked() {
        
        switch fromPage {
        case .defaultScreen:
            
            //Check save button status. And stop calling API
            if self.validateView() == true {
                _ = self.checkSaveButtonStatus()
                return
            }
            
            let requestModel : RequestModel = RequestModel()
            requestModel.user_id = userData.userId
            requestModel.user_name = txtUserName.text
            requestModel.display_name = txtDisplayName.text
            requestModel.bio_txt = tvBio.text == "Bio" ? "" : tvBio.text
            requestModel.device_token = GFunction.shared.getDeviceToken()
            requestModel.device_type = "I"
            
            self.callCreateProfileAPI(requestModel)
            
            break
        case .fromSettingPage:
            
            let requestModel : RequestModel = RequestModel()
            requestModel.user_id = UserModel.currentUser.userId
            requestModel.user_name = txtUserName.text
            requestModel.display_name = txtDisplayName.text
            requestModel.bio_txt = tvBio.text == "Bio" ? "" : tvBio.text
            self.callEditProfileAPI(requestModel)
            
            break
        default:
            print("Default one called...")
        }
        
    }
    
    
    @IBAction func btnProfileClicked(_ sender: UIButton) {
        
        self.openImagePickerSelection(sender)
        
    }
    
    func validateView() -> Bool {
        
        
        guard let image = ivProfile.image else {
            return true
        }
        let isUserDefaultImage = image.isEqualToImage(#imageLiteral(resourceName: "userProfile"))
        
        let isError = false
        
        if isUserDefaultImage {
            return true
        } else if !isValidUserName {
            return true
        } else if txtDisplayName.text!.isEmpty {
            return true
        }
        
        return isError
    }
    
    func checkSaveButtonStatus() -> Bool {
        
        guard let _ = btnSave else {
            return false
        }
        
        //To handel image nil if image load from Facebook URL
        guard let image = ivProfile.image else {
            btnSave.isEnabled = false
            return false
        }
        
        //Check if user profile image, unique userName and displayName avialable then only save button enable.
        let isUserDefaultImage : Bool? = image.isEqualToImage(#imageLiteral(resourceName: "userProfile"))
        if !isUserDefaultImage! && isValidUserName && !txtDisplayName.text!.isEmpty {
            btnSave.isEnabled = true
            return true
        } else {
            btnSave.isEnabled = false
            return false
        }
        
    }
    
    func checkUserName() {
        
        let requestModel = RequestModel()
        
        //to pass user ID
        switch fromPage {
        case .defaultScreen:
            requestModel.user_id = self.userData.userId;
            break
        case .fromSettingPage:
            requestModel.user_id = UserModel.currentUser.userId
            break
        default:break
        }
        
        requestModel.user_name = txtUserName.text
        
        //textfield blank then not require to call API
        if txtUserName.text!.isEmpty == true {
            return
        }
        
        GFunction.shared.addActivityIndicator(view: idicatorView)
        self.callCheckUserNameAPI(requestModel) { (response,isValid) in
            
            GFunction.shared.removeActivityIndicator()
            if let _ = response {
                
                self.lblUserNameAvailabality.text = response?[kMessage].stringValue
                
                if isValid {
                    self.isValidUserName = true
                    self.lblUserNameAvailabality.textColor = UIColor.colorFromHex(hex: kColorWhite)
                    
                    
                } else {
                    self.lblUserNameAvailabality.textColor = UIColor.colorFromHex(hex: kColorRed)
                }
                
                _ = self.checkSaveButtonStatus()
                
            } else {
                self.lblUserNameAvailabality.text = ""
            }
            
        }
        
    }
    
    //------------------------------------------------------
    
    //MARK: - API Call
    
    func callCreateProfileAPI(_ requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/create_profile
         
         Parameter   : user_id,user_name,display_name,bio_txt(max 200 char),device_type[A,I],device_token,profile(image for user)
         
         Optional    :
         
         Comment     : This api will used for create or update user profile (Setup 2).
         
         
         ==============================
         
         */
        
        var imageData : Data? = nil
        //If image not equal default Image
        let isUserDefaultImage = ivProfile.image?.isEqualToImage(#imageLiteral(resourceName: "userProfile"))
        if !(isUserDefaultImage!) {
            imageData = UIImageJPEGRepresentation(ivProfile.image!, CGFloat(0.20))! as Data?
        }
        
        APICall.shared.CancelTask(url: kMethodCreateProfile)
        
        APICall.shared.POST(strURL: kMethodCreateProfile
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
                if let _ = imageData {
                    formData!.appendPart(withFileData: imageData! as Data, name: "profile", fileName: "profile.jpeg", mimeType: "image/jpeg")
                }
                
        }) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    let chooseRackVc : ChooseRackVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseRackVC") as! ChooseRackVC
                    chooseRackVc.userData = UserModel(fromJson: response[kData])
                    self.navigationController?.pushViewController(chooseRackVc, animated: true)
                    
                    
                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
                
            } else {
                GFunction.shared.showPopUpAlert(error?.localizedDescription)
            }
        }
    }
    
    func callCheckUserNameAPI(_ requestModel : RequestModel , withBlock completion : @escaping (JSON?,Bool) -> Void)  {
        
        /*
         ===========API CALL===========
         
         Method Name : user/check_username
         
         Parameter   : user_name
         
         Optional    :
         
         Comment     : This api will used for check the User Name.
         
         
         ==============================
         
         */
        
        APICall.shared.PUT(strURL: kMethodCheckUsername
            ,parameter: requestModel.toDictionary()
            ,withErrorAlert : false)
        { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    completion(response,true)
                    break
                    
                default :
                    print(response[kMessage].stringValue)
                    completion(response,false)
                    break
                }
                
            } else {
                completion(nil,false)
            }
            
        }
        
    }
    
    func callEditProfileAPI(_ requestModel : RequestModel) {
        
        
        /*
         ===========API CALL===========
         
         Method Name : user/create_profile
         
         Parameter   :
         
         Optional    : user_name,display_name,bio_txt,profile,wardrobes_id,wardrobes_image
         
         Comment     : This api will used for user update the user detail.
         
         
         ==============================
         
         */
        
        guard let ivProfileImage = ivProfile.image else {
            return
        }
        
        var imageData : Data? = nil
        //If image not equal default Image
        let isUserDefaultImage = ivProfileImage.isEqualToImage(self.imageProfile)
        if !(isUserDefaultImage) {
            imageData = UIImageJPEGRepresentation(ivProfile.image!, CGFloat(0.20))! as Data?
        }
        
        
        APICall.shared.POST(strURL: kMethodUserEdit
            , parameter: requestModel.toDictionary()
            , withLoader: true
            , constructingBodyWithBlock: { (formData : AFMultipartFormData?) in
                
                if let _ = imageData {
                    formData!.appendPart(withFileData: imageData! as Data, name: "profile", fileName: "profile.jpeg", mimeType: "image/jpeg")
                }
                
        }) { (response : Dictionary<String, Any>?, code : Int?, error : Error?) in
            
            if (error == nil) {
                let response = JSON(response ?? [:])
                let status = response[kCode].stringValue
                
                switch(status) {
                    
                case success:
                    
                    let userData = UserModel(fromJson: response[kData])
                    
                    //Save User Data into userDefaults.
                    userData.saveUserDetailInDefaults()
                    
                    //load latest data in to current User
                    UserModel.currentUser.getUserDetailFromDefaults()
                    
                    AlertManager.shared.showPopUpAlert("Edit Profile", message: response[kMessage].stringValue, forTime: 2.0, completionBlock: { (Int) in
                        if let _ = self.navigationController {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    })
                    
                    //post notification to profile vc to update data
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationProfileUpdate), object: userData)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationUserDetailsUpdate), object: nil)
                    
                    break
                default :
                    GFunction.shared.showPopUpAlert(response[kMessage].stringValue)
                    break
                }
            } else {
                GFunction.shared.showPopUpAlert(error?.localizedDescription)
            }
        }
    }
    
    //------------------------------------------------------
    
    //MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.isEqual(txtUserName) {
            textField.text = "@"
            
            isValidUserName = false
            lblUserNameAvailabality.text = ""
            _ = self.checkSaveButtonStatus()
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //If Textfield have only one character "@" then clear textfield text
        if textField.isEqual(txtUserName) && txtUserName.text?.characters.count == 1 {
            textField.text = ""
            lblUserNameAvailabality.text = ""
        }
        
        _ = self.checkSaveButtonStatus()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        
        if range.location == 0 && string == " " {
            return false
        }
        
        
        
        if textField.isEqual(txtUserName) {
            
            //To manage not removing @ sign
            if range.location == 1 && string == " " {
                return false
            }
            
            if string == " " {
                return false
            }
            
            if newLength != 0 {
                
                if timer.isValid {
                    timer.invalidate()
                }
                
                //to check save button status.
                isValidUserName = false
                
                self.lblUserNameAvailabality.text = ""
                
                timer = Timer.scheduledTimer(timeInterval: 0.5
                    , target: self
                    , selector: #selector(checkUserName), userInfo: txtUserName, repeats: false)
                
            }
            
            if newLength == 1 {
                
                if timer.isValid {
                    timer.invalidate()
                }
                
                //to check save button status.
                isValidUserName = false
                
                self.lblUserNameAvailabality.text = ""
                
                timer = Timer.scheduledTimer(timeInterval: 0.5
                    , target: self
                    , selector: #selector(checkUserName), userInfo: txtUserName, repeats: false)
                
            }
            
            if newLength == 1 && txtUserName.text!.characters.count > 2 {
                txtUserName.text = "@"
            }
            
            if string == "@" {
                return false
            }
            
            return newLength <= 31 && newLength > 0 && range.location != 0

        } else if textField.isEqual(txtDisplayName) {
            
            return newLength <= 30
        }
        
        _ = self.checkSaveButtonStatus()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTextFiled = textContainer.viewWithTag(textField.tag + 1)
        if textField.isEqual(txtDisplayName) {
            self.view.endEditing(true)
            //            tvBio.becomeFirstResponder()
        } else {
            nextTextFiled?.becomeFirstResponder()
        }
        
        return true
    }
    
    //------------------------------------------------------
    
    //MARK:- Textview Delegate method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Bio" {
            tvBio.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            tvBio.text = "Bio"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.characters.count + text.characters.count - range.length
        
        if (range.location == 0 && text == " ") || (range.location == 0 && text == "\n") {
            return false
        }
        
        if newLength <= 200 {
            
        } else {
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let lenght = textView.text.characters.count
        lblCountCharacter.text = "\(lenght)/200"
    }
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        self.setUpData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Reuuire to save button disable. Button array getting from addBarButtons.
        var arrayButton = [UIButton]()
        
        //To manage navigation bar button. At edit profile and create Profile
        switch fromPage {
        case .defaultScreen:
            arrayButton = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Save"), title: "CREATE PROFILE",isSwipeBack: false)
            break
        case .fromSettingPage:
            arrayButton = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: BarButton(title: "Save"), title: "EDIT PROFILE")
            break
        default:
            print("Default one called...")
        }
        
        //Apply rightBarButton reference to btnSave
        btnSave = arrayButton[1]
        
        //Google Analytics
        
        let action = "\(String(describing: UserModel.currentUser.displayName == nil ? UserModel.currentUser.displayName! : "New User")) view \(String(describing: self.title))"
        googleAnalytics().createEvent(withCategory: "UI", action: action, label: "", onScreen: self.title)
        
        //Google Analytics
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ManageSave Button management
        _ = self.checkSaveButtonStatus()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}

extension CreateProfileVC : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        ivProfile.image = info[UIImagePickerControllerEditedImage] as? UIImage
        ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
        
        _ = self.checkSaveButtonStatus()
        
    }
}

extension CreateProfileVC : ChooseRectDelegate {
    
    func getSelectedReckDetail(data: Dictionary<String, Any>) {
        
        if let image = data[kImage] as? UIImage {
            ivProfile.image = image
            ivProfile.applyStype(cornerRadius: ivProfile.frame.size.width / 2)
        }
        _ = self.checkSaveButtonStatus()
        
    }
}
