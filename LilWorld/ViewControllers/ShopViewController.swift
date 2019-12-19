//
//  ShopViewController.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 04/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import UIKit
import SWRevealViewController

class ShopViewController: UIViewController {

    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectView: UIView!
    weak var pageViewController: UIPageViewController? = nil
    var fullVersionSetsViewController: ShopTableViewController? = nil
    var otherSetsViewController: ShopTableViewController? = nil
    @IBOutlet weak var fullVersionSetsButton: UIButton!
    @IBOutlet weak var otherSetsButton: UIButton!
    @IBOutlet weak var selectViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var restorePurchasesButton: UIButton!
    @IBOutlet weak var restorePurchasesActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.attributedText = NSAttributedString(string: localized("Shop_title"), attributes: GlobalConstants.kTitleAttributes)
        
        pageViewController = self.childViewControllers.first as? UIPageViewController
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        
        setupPageScrollViewDelegate(self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        fullVersionSetsViewController =  storyboard.instantiateViewController(withIdentifier: "ShopTableViewController") as? ShopTableViewController
        otherSetsViewController = storyboard.instantiateViewController(withIdentifier: "ShopTableViewController") as? ShopTableViewController
        fullVersionSetsViewController?.delegate = self
        otherSetsViewController?.delegate = self
        otherSetsViewController?.mainSets = false
        pageViewController?.setViewControllers([fullVersionSetsViewController!], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        if self.revealViewController() != nil {
            self.revealViewController().delegate = self
            sideMenuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fullVersionSetsViewController?.setsTableView?.reloadData()
        otherSetsViewController?.setsTableView?.reloadData()

        self.revealViewController().panGestureRecognizer().isEnabled = true
    }
}

//MARK: - Actions

extension ShopViewController {

    @IBAction func fullVersionSetsButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        fullVersionSetsButton.isSelected = true
        otherSetsButton.isSelected = false
        selectFullVersionSets()
        pageViewController?.setViewControllers([fullVersionSetsViewController!], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
    }
    
    @IBAction func otherSetsButtonPressed(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        fullVersionSetsButton.isSelected = false
        otherSetsButton.isSelected = true
        selectOtherSets()
        pageViewController?.setViewControllers([otherSetsViewController!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
    }
    
    @IBAction func restorePurchasesButtonPressed(_ sender: UIButton) {
        AnalyticsEngine.trackEvent(AnalyticsMenuItemEvent(item: .ShopRestorePurchases))
        buyingProcessStarted()
        prepareToStartRestorePurchases()
        StoreHelper.sharedInstance.restorePurchases { (productId, nothingToRestore, error) -> () in
            if let productId = productId {
                print("restored product: \(productId)")
                StoreHelper.sharedInstance.addProductId(productId)
            } else {
                self.prepareToFinishRestorePurchases()
                self.buyingProcessFinished()
                if let error = error, error._code == 2 {
                    return
                }
                let alertTitle =  localized(nothingToRestore ? "Alerts_restorePurchasesSuccessTitle" : "Alerts_restorePurchasesErrorTitle")
                let alertMessage = localized(nothingToRestore ? "Alerts_restorePurchasesSuccessMessage" : "Alerts_restorePurchasesErrorMessage")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                if nothingToRestore {
                    print("restored all products")
                }
            }
        }
    }
}

//MARK: - Private

extension ShopViewController {
    
    fileprivate func changeSelectViewConstraintToSelectView(_ view: UIView) {
        selectView.superview?.removeConstraint(selectViewCenterXConstraint)
        selectViewCenterXConstraint = NSLayoutConstraint(item: selectView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        selectView.superview?.addConstraint(selectViewCenterXConstraint)
        
        setupPageScrollViewDelegate(nil)
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.selectView.superview?.layoutIfNeeded()
            }, completion: { (finished) -> Void in
            self.setupPageScrollViewDelegate(self)
        }) 
    }
    
    fileprivate func selectFullVersionSets() {
        changeSelectViewConstraintToSelectView(fullVersionSetsButton)
    }
    
    fileprivate func selectOtherSets() {
        changeSelectViewConstraintToSelectView(otherSetsButton)
    }
    
    fileprivate func prepareToStartRestorePurchases() {
        restorePurchasesActivityIndicator.startAnimating()
        restorePurchasesActivityIndicator.isHidden = false
        restorePurchasesButton.isHidden = true
    }
    
    fileprivate func prepareToFinishRestorePurchases() {
        self.restorePurchasesActivityIndicator.stopAnimating()
        self.restorePurchasesButton.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSetViewControllerSegue" {
            self.revealViewController().panGestureRecognizer().isEnabled = false
            if let setController = segue.destination as? SetViewController {
                setController.setObject = sender as! Section
                let parentID = (sender as! Section).parent_id
                if let parentSection = Section.mr_findFirst(with: NSPredicate(format: "section_id = \(parentID)")) {
                    setController.mainSet = !parentSection.extra
                }
                
            }
        }
    }
    
    fileprivate func setupPageScrollViewDelegate(_ delegate: UIScrollViewDelegate?) {
        if let pageViewController = pageViewController {
            for testView in pageViewController.view!.subviews {
                if let scrollView = testView as? UIScrollView {
                    scrollView.delegate = delegate
                }
            }
        }
    }
}

//MARK: - UIPageViewControllerDataSource

extension ShopViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == otherSetsViewController {
            return fullVersionSetsViewController
        }
        return nil
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == fullVersionSetsViewController {
            return otherSetsViewController
        }
        return nil
    }
}

//MARK: - UIPageViewControllerDelegate

extension ShopViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard !previousViewControllers.isEmpty else {
            return
        }
        let previousViewController = previousViewControllers.first
        if previousViewController == fullVersionSetsViewController {
            otherSetsButtonPressed(otherSetsButton)
        } else {
            fullVersionSetsButtonPressed(fullVersionSetsButton)
        }
    }
}

//MARK: - UIScrollViewDelegate

extension ShopViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (fullVersionSetsButton.isSelected && scrollView.contentOffset.x < scrollView.bounds.size.width - 50 && scrollView.contentOffset.x > scrollView.bounds.size.width * 0.5) {
            if self.revealViewController().frontViewPosition == .left {
                self.revealViewController().revealToggle(self)
            }
        }
        if (otherSetsButton.isSelected && scrollView.contentOffset.x > scrollView.bounds.size.width + 50) {
            if self.revealViewController().frontViewPosition == .right {
                self.revealViewController().revealToggle(self)
            }
        }
    }
}

//MARK: - ShopTableViewControllerDelegate

extension ShopViewController: ShopTableViewControllerDelegate {
    
    func buyingProcessStarted() {
        self.coverWithForegroundViewWithColor(UIColor(red: 1, green:1, blue: 1, alpha: 0.5))
        self.view.isUserInteractionEnabled = false
    }
    
    func buyingProcessFinished() {
        fullVersionSetsViewController?.updateInterfaceWithCurrentPurchases()
        otherSetsViewController?.updateInterfaceWithCurrentPurchases()
        self.removeForegroundView()
        self.view.isUserInteractionEnabled = true
    }
    
    func selectedCellWithObject(_ object: Section) {
        self.performSegue(withIdentifier: "ShowSetViewControllerSegue", sender: object)
    }
}

//MARK: - SWRevealViewControllerDelegate

extension ShopViewController: SWRevealViewControllerDelegate {
    
    func revealController(_ revealController: SWRevealViewController!, animateTo position: FrontViewPosition) {
        if position == .left {
            self.view.isUserInteractionEnabled = true
        } else {
            self.view.isUserInteractionEnabled = false
        }
    }
}
