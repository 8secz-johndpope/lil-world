//
//  PushManager.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 16/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation
import Alamofire

class PushManager {
    
    class func registerDeviceToken(_ deviceToken: String) {
        Alamofire.request(PushAPIRouter.postToken(deviceToken)).responseJSON { response in
        }
    }
}
