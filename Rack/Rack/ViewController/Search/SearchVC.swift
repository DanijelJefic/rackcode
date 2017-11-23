//
//  SearchVC.swift
//  Rack
//
//  Created by hyperlink on 17/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit


@objc protocol SearchTextDelegate {
    
    @objc func searchTextDelegateMethod(_ searchBar : UISearchBar);
}


class SearchVC: GLViewPagerViewController {

    //MARK:- Outlet
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionSearchOption: UICollectionView!
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    let arraySearchOptions = ["DISCOVER","PEOPLE","HASHTAG","BRAND","ITEM NAME"]
    let arrayTempColor = [UIColor.red,UIColor.green,UIColor.brown,UIColor.black,UIColor.purple,UIColor.yellow]

    var arrayControllers : Array! = [UIViewController]()
    var pageviewController = UIPageViewController()
    
    let cellWidthPadding : CGFloat = 20.0
    
    var tabTitles: NSArray = NSArray()
    
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
        
        

        //Navigation Bar setup
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        self.navigationItem.titleView = searchBar
        
        //search
        
        if let _ = searchBar {
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.delegate = self
            searchBar.tintColor = UIColor.colorFromHex(hex: kColorGray74)
        }
        
        arrayControllers = []
        
        //pageView Controller setup
        //["DISCOVER","PEOPLE","HASHTAG","BRAND NAME","ITEM NAME"]
        let discoverVC = secondStoryBoard.instantiateViewController(withIdentifier: "DiscoverVC") as! DiscoverVC
        let peopleVC = secondStoryBoard.instantiateViewController(withIdentifier: "PeopleVC") as! PeopleVC
        let hashTagVC = secondStoryBoard.instantiateViewController(withIdentifier: "HashTagVC") as! HashTagVC
        let brandVC = secondStoryBoard.instantiateViewController(withIdentifier: "BrandVC") as! BrandVC
        let itemNameVC = secondStoryBoard.instantiateViewController(withIdentifier: "ItemNameVC") as! ItemNameVC
        //let tendingVC = secondStoryBoard.instantiateViewController(withIdentifier: "TendingVC") as! TendingVC

        arrayControllers.append(discoverVC)
        arrayControllers.append(peopleVC)
        arrayControllers.append(hashTagVC)
        arrayControllers.append(brandVC)
        arrayControllers.append(itemNameVC)
        //arrayControllers.append(tendingVC)
        
        self.setDataSource(newDataSource: self)
        self.setDelegate(newDelegate: self)
        self.padding = 10
        self.leadingPadding = 0
        self.trailingPadding = 0
        self.defaultDisplayPageIndex = 0
        
        self.tabAnimationType = GLTabAnimationType.GLTabAnimationType_WhileScrolling
        self.indicatorColor = UIColor.colorFromHex(hex: kColorWhite)
        self.supportArabic = false
        self.fixTabWidth = false
        
        self.tabTitles = self.arraySearchOptions as NSArray

        self.loadView()
        
        
        
    }
    
    func withDelay() {
        
        self._selectTab(tabIndex: 0, animate: true)
        let currentLabel:UILabel = self.tabViewAtIndex(index: 0) as! UILabel
        currentLabel.font = UIFont.applyBold(fontSize: 12.0)
    }
    
    func getCurrentPageViewController() -> (UIViewController? , Int?)? {
        
        let index = self._currentPageIndex
        let firstViewController = self.arrayControllers[index]
        return(firstViewController,index)
        

        /*if let firstViewController = pageviewController.viewControllers?.first,
            let index = arrayControllers.index(of: firstViewController) {
            return(firstViewController,index)
        } else {
            return(nil,nil)
        }*/
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = navigationController {
            navigationController?.delegate = AppDelegate.shared.transitionar
        }
        
        //Google Analytics
        
        let category = "UI"
        let action = "\(UserModel.currentUser.displayName!) view search"
        let lable = ""
        let screenName = "Search"
        googleAnalytics().createEvent(withCategory: category, action: action, label: lable, onScreen: screenName)
        
        //Google Analytics
    }
    override func viewDidAppear(_ animated: Bool) {
        searchBar.isHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.isHidden = true

    }
    
}

//MARK:- SearchBar Delegate
extension SearchVC : UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        if let (vc,index) = getCurrentPageViewController() {
            
            print(index ?? "index Not fount")
            
            if vc is DiscoverVC {
                
                /*
                 Where there is search bar first responder on discover, move the tab to next tab
                 As per client's reqirement
                 */
                
                pageviewController.setViewControllers([arrayControllers[1]], direction: .forward, animated: false, completion: nil)
                self._selectTab(tabIndex: 1, animate: true)
                self.didChangeTabToIndex(self, index: 1, fromTabIndex: 0)
                
            }
        }
        
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let (vc,index) = getCurrentPageViewController() {
         
            print(index ?? "index Not fount")
            
            if vc is DiscoverVC {
                
                /*
                 Where there is search bar first responder on discover, move the tab to next tab
                 As per client's reqirement
                 */
                
                pageviewController.setViewControllers([arrayControllers[1]], direction: .forward, animated: false, completion: nil)
                self._selectTab(tabIndex: 1, animate: true)
                self.didChangeTabToIndex(self, index: 1, fromTabIndex: 0)
                
                /*let vc = vc as! DiscoverVC
                if vc.responds(to: #selector(vc.delegate?.searchTextDelegateMethod(_:))) {
                    vc.delegate?.searchTextDelegateMethod(searchBar)
                }*/
                
            } else if vc is PeopleVC {

                let vc = vc as! PeopleVC
                if vc.responds(to: #selector(vc.delegate?.searchTextDelegateMethod(_:))) {
                    vc.delegate?.searchTextDelegateMethod(searchBar)
                }
                
            }else if vc is HashTagVC {
                
                let vc = vc as! HashTagVC
                if vc.responds(to: #selector(vc.delegate?.searchTextDelegateMethod(_:))) {
                    vc.delegate?.searchTextDelegateMethod(searchBar)
                }
            }else if vc is BrandVC {
                
                let vc = vc as! BrandVC
                if vc.responds(to: #selector(vc.delegate?.searchTextDelegateMethod(_:))) {
                    vc.delegate?.searchTextDelegateMethod(searchBar)
                }
            }else if vc is ItemNameVC {
                
                let vc = vc as! ItemNameVC
                if vc.responds(to: #selector(vc.delegate?.searchTextDelegateMethod(_:))) {
                    vc.delegate?.searchTextDelegateMethod(searchBar)
                }
            }else if vc is TendingVC {
                
                let vc = vc as! TendingVC
                if vc.responds(to: #selector(vc.delegate?.searchTextDelegateMethod(_:))) {
                    vc.delegate?.searchTextDelegateMethod(searchBar)
                }
            }
            
        }
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}

extension SearchVC : GLViewPagerViewControllerDataSource,GLViewPagerViewControllerDelegate {
    
    func numberOfTabsForViewPager(_ viewPager: GLViewPagerViewController) -> Int {
        return self.tabTitles.count
    }
    
    func viewForTabIndex(_ viewPager: GLViewPagerViewController, index: Int) -> UIView {
        let label:UILabel = UILabel.init()
        label.text = self.tabTitles.object(at: index) as? String
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = viewPager._currentPageIndex == index ? UIFont.applyBold(fontSize: 12.0) : UIFont.applyRegular(fontSize: 12.0)
        return label
        
    }
    
    func contentViewControllerForTabAtIndex(_ viewPager: GLViewPagerViewController, index: Int) -> UIViewController {
        return self.arrayControllers[index]
    }
    
    func widthForTabIndex(_ viewPager: GLViewPagerViewController, index: Int) -> CGFloat {
        
        let searchTypeText = self.tabTitles.object(at: index) as? String
        let size = searchTypeText?.sizeOfString(font: UIFont.applyBold(fontSize: 13.0))
        
        return (size?.width)!
    }
    
    func didChangeTabToIndex(_ viewPager: GLViewPagerViewController, index: Int, fromTabIndex: Int) {
        
        let prevLabel:UILabel = viewPager.tabViewAtIndex(index: fromTabIndex) as! UILabel
        prevLabel.font = UIFont.applyRegular(fontSize: 12.0)
        
        let currentLabel:UILabel = viewPager.tabViewAtIndex(index: index) as! UILabel
        currentLabel.font = UIFont.applyBold(fontSize: 12.0)
        
        if index == 0 && searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        
    }
}

class SearchOption: UICollectionViewCell {
    
    @IBOutlet var lblTextType : UILabel!
    @IBOutlet var bottomLine : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        lblTextType.applyStyle(labelFont: UIFont.applyRegular(fontSize: 12.0), labelColor: UIColor.white)
        bottomLine.isHidden = true
    }
    
    override var isSelected: Bool {
        
        didSet {
            lblTextType.font = isSelected ? UIFont.applyBold(fontSize: 12.0) : UIFont.applyRegular(fontSize: 12.0)
            bottomLine.isHidden = isSelected ? false : true
        }
    }

}


