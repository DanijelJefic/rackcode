//
//  PostImageAddTagVC.swift
//  Rack
//
//  Created by hyperlink on 29/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class PostImageAddTagVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet var imgPost : UIImageView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var postImage : UIImage = UIImage()
    var imageTagType : TagType = TagType.none
    var delegate    : SearchTagDelegate?
    var arrayTag : [PSTagView] = []
    
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
    
    func setUpView() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
        tapGesture.numberOfTapsRequired = 1
        imgPost.isUserInteractionEnabled = true
        imgPost.addGestureRecognizer(tapGesture)
        
        imgPost.image = self.postImage.imageScale(scaledToWidth: kScreenWidth)
        
        
        //Tag setup for editing
        for tagView in arrayTag {
            self.imgPost.addSubview(tagView)
        }
    }
     
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    func leftButtonClicked() {
 
    }
    
    func rightButtonClicked() {

        if self.delegate != nil {
            self.delegate?.searchTagDelegateMethod(imgPost.subviews,tagType:imageTagType)
        }
        _ = self.navigationController?.popViewController(animated: true)

        print()
    }
    
    func tapOnImage(_ gesture : UITapGestureRecognizer) {
     
        if let imgView = gesture.view  as? UIImageView {
        
           
            switch imageTagType {
            case .tagBrand , .tagItem , . addLink:
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchTagTextVC") as! SearchTagTextVC
                vc.imageTagType = self.imageTagType
                vc.tapLocation = gesture.location(in: imgView)
                vc.delegate = self
                self.navigationController!.pushViewController(vc, animated: true)
                break

            case .tagPeople:
                
                let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchPeopleTagVC") as! SearchPeopleTagVC
                vc.imageTagType = self.imageTagType
                vc.tapLocation = gesture.location(in: imgView)
                vc.delegate = self
                self.navigationController!.pushViewController(vc, animated: true)
                break
            
            default:
                print("Default Once called...")
                break
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
        _ = addBarButtons(btnLeft: nil, btnRight: BarButton(title: "Done"), title: "POST", isSwipeBack: false)
    }

}
    //MARK:- SearchTagDelegate -
extension PostImageAddTagVC : SearchTagDelegate {
    
    func searchTagDelegateMethod(_ tagDetail: Any, tagType : TagType?) {
        
        let dict = tagDetail as! Dictionary<String,Any>
        let tapLocation = dict["tapLocation"] as! CGPoint
        
        switch imageTagType {
        case .tagBrand , .tagItem:
         
            var jsonDict : Dictionary<String,Any> = dict 
            jsonDict["id"] = dict[kID]
            jsonDict["name"] = dict[kTitle]
            jsonDict["x_axis"] = tapLocation.x
            jsonDict["y_axis"] = tapLocation.y
            let tagDetail = SimpleTagModel(fromJson: JSON(jsonDict))

            let tag = PSTagView(tagName: dict[kTitle]! as! String , x: tapLocation.x, y: tapLocation.y, parrentView: imgPost,tagDetail: tagDetail)
            imgPost.addSubview(tag)

            break

        case .addLink:

            var jsonDict : Dictionary<String,Any> = dict
            jsonDict["name"] = dict[kTitle]
            jsonDict["x_axis"] = tapLocation.x
            jsonDict["y_axis"] = tapLocation.y
            let tagDetail = LinkTagModel(fromJson: JSON(jsonDict))
            
            let tag = PSTagView(tagName: dict[kTitle]! as! String , x: tapLocation.x, y: tapLocation.y, parrentView: imgPost,tagDetail: tagDetail)
            imgPost.addSubview(tag)
            break

        case .tagPeople:

            var jsonDict : Dictionary<String,Any> = dict
            jsonDict["user_id"] = dict[kID]
            jsonDict["x_axis"] = tapLocation.x
            jsonDict["y_axis"] = tapLocation.y
            let tagDetail = PeopleTagModel(fromJson: JSON(jsonDict))
            
            let tag = PSTagView(tagName: dict[kTitle]! as! String , x: tapLocation.x, y: tapLocation.y, parrentView: imgPost,tagDetail: tagDetail)
            imgPost.addSubview(tag)
            

            break
        default:
            break
        }
        
        


/*
        _ = imgPost.subviews.map({ (tagView : UIView) -> Void in
            
            if tagView is PSTagView {
                let tagView = tagView as! PSTagView
                print("Name         : ",tagView.lbl.text ?? "none")
                print("tapLocation  : ",tapLocation)
                print("TagView      : ",tagView.frame)
                print("CurrentPoint : ",tagView.cLayer.path?.currentPoint.x ?? "Not found path")
                print("Position     : ",tagView.tagLocation)
                print("Position     : ",tagView.tagDetail ?? "NotFound")
                print("=============================================")
            }

        })
 */
    }
}
