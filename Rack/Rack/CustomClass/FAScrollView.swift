//
//  FAScrollView.swift
//  FAImageCropper
//
//  Created by Fahid Attique on 12/02/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

extension CGFloat {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}

class FAScrollView: UIScrollView{
    
    // MARK: Class properties
    
    var imageView:UIImageView = UIImageView()
    var isFlag : Bool = false
    var imageToDisplay:UIImage? = nil{
        
        didSet {
            
            self.imageView.image = nil
            self.zoomScale = 1.0
            self.imageView.image = self.imageToDisplay
            self.minimumZoomScale = 1.0
            self.imageView.frame.size = self.sizeForImageToDisplay()
            self.imageView.center = self.center
            self.contentSize = self.imageView.frame.size
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            self.updateLayout()
            self.resetImage()
            
            switch self.mode {
            case .defaultPickerMode , .profilePickerMode:
                
                break
            case .imagePostPickerMode:
                self.zoomWithoutAnimation()
                self.zoomWithoutAnimation()
                break
            }
        }
    }
    var mode = PickerMode.defaultPickerMode
    
    // MARK : Class Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewConfigurations()
    }
    
    func updateLayout() {
        imageView.center = center;
        var frame:CGRect = imageView.frame;
        if (frame.origin.x < 0) { frame.origin.x = 0 }
        if (frame.origin.y < 0) { frame.origin.y = 0 }
        imageView.frame = frame
    }
    
    func resetImage() {
        let actualWidth:CGFloat = imageToDisplay!.size.width
        let actualHeight:CGFloat = imageToDisplay!.size.height
        let imgRatio:CGFloat = max(actualWidth,actualHeight) / min(actualWidth,actualHeight)
        
        switch mode {
        case .defaultPickerMode , .profilePickerMode:
            setZoomScale(1.0, animated: false)
            break
        case .imagePostPickerMode:
            setZoomScale(imgRatio, animated: false)
            break
        }
        
        updateLayout()
        
    }
    
    func zoom() {
        
        let actualWidth:CGFloat = imageView.image!.size.width
        let actualHeight:CGFloat = imageView.image!.size.height
        let imgRatio:CGFloat = max(actualWidth,actualHeight) / min(actualWidth,actualHeight)
        
        let scale = zoomScaleWithNoWhiteSpaces().roundTo(places: 4)
        
        if imgRatio > 1.0 && (zoomScale.roundTo(places: 4) !=  scale) {
            setZoomScale(scale, animated: true)
        }
        else if zoomScale.roundTo(places: 4) ==  scale {
            
            if imageToDisplay!.size.height > imageToDisplay!.size.width {
                setZoomScale(imgRatio * 0.5, animated: true)
            } else {
                minimumZoomScale = 1.0
                setZoomScale(minimumZoomScale, animated: true)
            }
        }
        
        //        if (zoomScale <= 1.0) { setZoomScale(zoomScaleWithNoWhiteSpaces(), animated: true) }
        //        else{ setZoomScale(minimumZoomScale, animated: true) }
        updateLayout()
        
    }
    
    /*func zoomWithoutAnimation() {
     
     let actualWidth:CGFloat = imageView.image!.size.width
     let actualHeight:CGFloat = imageView.image!.size.height
     let imgRatio:CGFloat = max(actualWidth,actualHeight) / min(actualWidth,actualHeight)
     
     let scale = zoomScaleWithNoWhiteSpaces().roundTo(places: 4)
     
     if imgRatio > 1.0 && (zoomScale.roundTo(places: 4) !=  scale) {
     setZoomScale(scale, animated: false)
     }
     else if zoomScale.roundTo(places: 4) ==  scale {
     
     if imageToDisplay!.size.height > imageToDisplay!.size.width {
     minimumZoomScale = scale * 0.805
     setZoomScale(minimumZoomScale, animated: false)
     } else {
     
     
     //                minimumZoomScale = 1.0
     // print(imageToDisplay!.size.height)
     // print(imageToDisplay!.size.width)
     // print(scale)
     
     if scale >= 1.7692852{
     
     //                        let tempRation:CGFloat = max(actualWidth,actualHeight) / min(actualWidth,actualHeight)
     //                        let tempRation1:CGFloat = min(1080,actualHeight) / min(actualWidth,1920)
     let tempRation1:CGFloat = max(1080,actualHeight) / max(actualWidth,1920)
     
     // print(scale * 0.5652)//(1080/1920)
     minimumZoomScale = scale * tempRation1
     // print(minimumZoomScale)
     setZoomScale(minimumZoomScale, animated: false)
     
     }else {
     zoomScale = 1.0
     minimumZoomScale = 1.0
     setZoomScale(minimumZoomScale, animated: true)
     
     }
     }
     }
     
     
     //        if (zoomScale <= 1.0) { setZoomScale(zoomScaleWithNoWhiteSpaces(), animated: true) }
     //        else{ setZoomScale(minimumZoomScale, animated: true) }
     updateLayout()
     
     }*/
    
    
    
    func zoomWithoutAnimation() {
        
        let actualWidth:CGFloat = imageView.image!.size.width
        let actualHeight:CGFloat = imageView.image!.size.height
        let imgRatio:CGFloat = max(actualWidth,actualHeight) / min(actualWidth,actualHeight)
        let scale = zoomScaleWithNoWhiteSpaces().roundTo(places: 4)
        if imgRatio > 1.0 && (zoomScale.roundTo(places: 4) !=  scale) {
            setZoomScale(scale, animated: false)
        }
        else if zoomScale.roundTo(places: 4) ==  scale {
            
            if imageToDisplay!.size.height > imageToDisplay!.size.width {
                
                minimumZoomScale = scale * 0.805
                setZoomScale(minimumZoomScale, animated: false)
            }
            else
            {
                if scale >= 1.7692852
                {
                    let tempRation1:CGFloat = max(1080,actualHeight) / max(actualWidth,1920)
                    
                    if (scale * tempRation1) - 0.1 > 1.0 {
                        minimumZoomScale = (scale * tempRation1) - 0.1
                        setZoomScale(minimumZoomScale, animated: false)
                    }
                    else
                    {
                        zoomScale = 1.0
                        minimumZoomScale = 1.0
                        setZoomScale(minimumZoomScale, animated: false)
                    }
                }
                else
                {
                    zoomScale = 1.0
                    minimumZoomScale = 1.0
                    setZoomScale(minimumZoomScale, animated: false)
                }
            }
        }
        
        updateLayout()
    }
    
    // MARK: Private Functions
    
    private func viewConfigurations(){
        
        clipsToBounds = false;
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        bouncesZoom = true
        bounces = false
        decelerationRate = UIScrollViewDecelerationRateFast
        delegate = self
        maximumZoomScale = 5.0
        addSubview(imageView)
        
    }
    
    private func sizeForImageToDisplay() -> CGSize{
        
        switch mode {
        case .defaultPickerMode , .profilePickerMode:
            zoomScale = 1.0
            minimumZoomScale = 1.0
            
            var frame: CGRect = imageView.frame
            if imageToDisplay!.size.height > imageToDisplay!.size.width {
                frame.size.width = self.bounds.size.width
                frame.size.height = (self.bounds.size.width / imageToDisplay!.size.width) * imageToDisplay!.size.height
            }
            else {
                frame.size.height = self.bounds.size.height
                frame.size.width = (self.bounds.size.height / imageToDisplay!.size.height) * imageToDisplay!.size.width
            }
            imageView.frame = frame
            
            self.contentSize = imageView.bounds.size
            
            let newContentOffsetX: CGFloat = (self.contentSize.width / 2) - (self.bounds.size.width / 2)
            let newContentOffsetY: CGFloat = (self.contentSize.height / 2) - (self.bounds.size.height / 2)
            self.contentOffset = CGPoint(x: newContentOffsetX, y: newContentOffsetY)
            
            zoomScale = 1.0
            
            return  imageView.bounds.size
            
        case .imagePostPickerMode:
            
            var actualWidth:CGFloat = imageToDisplay!.size.width
            var actualHeight:CGFloat = imageToDisplay!.size.height
            var imgRatio:CGFloat = actualWidth/actualHeight
            let maxRatio:CGFloat = frame.size.width/frame.size.height
            
            if imgRatio != maxRatio{
                if(imgRatio < maxRatio){
                    imgRatio = frame.size.height / actualHeight
                    actualWidth = imgRatio * actualWidth
                    actualHeight = frame.size.height
                }
                else{
                    imgRatio = frame.size.width / actualWidth
                    actualHeight = imgRatio * actualHeight
                    actualWidth = frame.size.width
                }
            }
            else {
                imgRatio = frame.size.width / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = frame.size.width
            }
            
            //To set minimum zoomScale
            let imgRatio1:CGFloat = max(actualWidth,actualHeight) / min(actualWidth,actualHeight)
            
            //If square image then not require to set
            if imgRatio1 != 1 {
                zoomScale = imgRatio
                minimumZoomScale = imgRatio1 * 0.805
            }
            
            return  CGSize(width: actualWidth, height: actualHeight)
        }
    }
    
    private func zoomScaleWithNoWhiteSpaces() -> CGFloat{
        
        let imageViewSize:CGSize  = imageView.bounds.size
        let scrollViewSize:CGSize = bounds.size;
        let widthScale:CGFloat  = scrollViewSize.width / imageViewSize.width
        let heightScale:CGFloat = scrollViewSize.height / imageViewSize.height
        return max(widthScale, heightScale)
    }
    
}

extension FAScrollView:UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateLayout()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView.pinchGestureRecognizer!.state {
        case .changed:
            break
        case .ended:
            break
        default: break
        }
    }
}
