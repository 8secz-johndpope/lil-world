//
//  ArtmossphereAnalyticsEvents.swift
//  Artmosphere
//
//  Created by admin on 23.08.16.
//  Copyright © 2016 Kula Tech. All rights reserved.
//

import Foundation

enum AnalyticsScreen : String {
    case Editor = "Editor"
    case AboutUs = "About_Us"
    case Share = "Share"
    case Feed = "Feed"
    case Shop = "Shop"
    case Banner = "Banner"
}

// Menu Item event

struct AnalyticsMenuItemEvent : AnalyticsEvent {
    var item: AnalyticsMenuItem
    var name: String {
        return "Menu_\(item)"
    }
    var parameters: [String : NSObject]? {
        return nil
    }
}

enum AnalyticsMenuItem : String {
    case NewPhoto
    case Shop
    case Feed
    case RateUs = "Rate_us"
    case AboutUs = "About_us"
    
    case ShopRestorePurchases = "Shop_RestorePurchases"
}

// Sticker catagory events
struct AnalyticsStickerCategoryEvent : AnalyticsEvent {
    var category: String
    var name : String {
        return "Edit_Categories_\(category)"
    }
    var parameters: [String : NSObject]? {
        return nil
    }
}

// Share events
struct AnalyticsShareEvent : AnalyticsEvent {
    var socialName: AnalyticsShareType
    var name : String {
        return "Share_\(socialName)"
    }
    var parameters: [String : NSObject]? {
        return nil
    }
}

enum AnalyticsShareType : String {
    case Tumblr
    case VK
    case FB
    case Instagram
    case Other
    case Twitter
    case Contest
    case SaveToGallery
}

// Edit events
struct AnalyticsEditActionEvent : AnalyticsEvent {
    var action : AnalyticsEditAction
    var name : String {
        return "Edit_\(action)"
    }
    var parameters: [String : NSObject]? {
        return nil
    }
}

enum AnalyticsEditAction {
    case crop
    case rotate
    case brighness
    case contrast
    case saturation
}

// other events
enum CommonEventName : String {
    case PhotoGallery = "Photo_Gallery"
    case PhotoCamera = "Photo_Camera"
    case Menu = "Menu"
    case OpenApp = "OpenApp"
}

extension CommonEventName {
    var parameterName : String {
        return "with"
    }
}

struct CommonAnalyticsEvent : AnalyticsEvent {
    var name : String
    var parameters: [String : NSObject]?
    
    init(event: CommonEventName, parameter: String?) {
        self.name = event.rawValue
        if let parameter = parameter {
            self.parameters = [event.parameterName : parameter as NSObject]
        }
    }
}

