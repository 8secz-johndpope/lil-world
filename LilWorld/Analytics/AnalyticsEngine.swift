//
//  AnalyticsEngine.swift
//  Artmosphere
//
//  Created by Aleksandr Novikov on 22.08.16.
//  Copyright © 2016 Kula Tech. All rights reserved.
//

import UIKit
import Flurry_iOS_SDK
import Firebase

protocol AnalyticsEvent {
    var name : String {get}
    var parameters : [String : NSObject]? {get}
}

class AnalyticsEngine {
    
    class func initializeWithFlurryTrackerID(_ flurryTrackerID : String) {
        
        // Firebase
        FirebaseApp.configure()
        
        // Flurry
        Flurry.startSession(flurryTrackerID)
        Flurry.setCrashReportingEnabled(true)
        Flurry.setDebugLogEnabled(false)
        
        prepareForScreenEvents()
    }
    
    class func trackEvent(_ event: AnalyticsEvent) {
        trackEvent(event.name, parameters: event.parameters)
    }
    
    fileprivate class func trackEvent(_ event : String, parameters: [String: NSObject]? = nil) {
        Flurry.logEvent(event, withParameters: parameters)
        Analytics.logEvent(event, parameters: parameters)
//        FBSDKAppEvents.logEvent(event, parameters: parameters)
    }
    
    class func fullEventNameForScreenView(_ screen: AnalyticsScreen) -> String {
         return "View_\(screen.rawValue)_screen"
    }
    
    class func trackAppearEventForScreen(_ screen: AnalyticsScreen) {
        let screenName = screen.rawValue
        Analytics.logEvent("View", parameters: ["Screen" : screenName as NSObject])
        
        let fullEventName = fullEventNameForScreenView(screen)
        Flurry.logEvent(fullEventName, withParameters: nil, timed: true)
  //      FBSDKAppEvents.logEvent(fullEventName, parameters: nil)
    }
    
    class func trackDisappearEventForScreen(_ screen: AnalyticsScreen) {
        let fullEventName = fullEventNameForScreenView(screen)
        Flurry.endTimedEvent(fullEventName, withParameters: nil)
    }
    
    class func prepareForScreenEvents() {
        UIViewController.swapImplementations(#selector(UIViewController.viewDidAppear(_:)), swizzledSelector: #selector(UIViewController.analytics_viewDidAppear(_:)))
        UIViewController.swapImplementations(#selector(UIViewController.viewDidDisappear(_:)), swizzledSelector: #selector(UIViewController.analytics_viewDidDisappear(_:)))
    }
}

// MARK: - For screen view events
extension UIViewController {
    fileprivate struct AssociatedKeys {
        static var DescriptiveName = "analyticsScreenName"
    }
    
    var analyticsScreenName: AnalyticsScreen? {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String {
                return AnalyticsScreen(rawValue: value)
            } else {
                return nil
            }
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue.rawValue as NSString?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    class func swapImplementations(_ originalSelector : Selector, swizzledSelector: Selector) {
        
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    func analytics_viewDidAppear(_ animated: Bool) {
        analytics_viewDidAppear(animated)
        
        if let name = analyticsScreenName {
            AnalyticsEngine.trackAppearEventForScreen(name)
        }
    }
    
    func analytics_viewDidDisappear(_ animated: Bool) {
        analytics_viewDidDisappear(animated)
        
        if let name = analyticsScreenName {
            AnalyticsEngine.trackDisappearEventForScreen(name)
        }
    }
}
