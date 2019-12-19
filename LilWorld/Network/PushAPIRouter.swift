//
//  PushAPIRouter.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 16/03/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Foundation

import Alamofire

enum PushAPIRouter: URLRequestConvertible {
    static let baseURLString = "http://178.62.217.151:8301/v1"
    static var clientSecret: String = "d3UIustzS3lPOwBVIg51zQ672KtpFU4yz2Dt5bMgVgw"
    
    case postToken(String)
    
    var method: HTTPMethod {
        switch self {
        case .postToken(_):
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .postToken(_):
            return "device_token"
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() -> URLRequest {
        let URL = Foundation.URL(string: PushAPIRouter.baseURLString)!
        var urlRequest = URLRequest(url: URL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.setValue(PushAPIRouter.clientSecret, forHTTPHeaderField: "X-Auth-Token")
        
        switch self {
        case .postToken(let token):
            let parameters: Parameters = [
                "device_token": token,
                "device_type_id":"1"
            ]
            let encodedURLRequest = try! URLEncoding.queryString.encode(urlRequest, with: parameters)
            return encodedURLRequest
        }
    }
    
}
