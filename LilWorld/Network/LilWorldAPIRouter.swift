//
//  Network.swift
//  LilWorld
//
//  Created by Roman Fedyanin on 16/02/16.
//  Copyright © 2016 Adno. All rights reserved.
//

import Alamofire

enum LilWorldAPIRouter: URLRequestConvertible {
    static let baseURLString = "http://178.62.217.151:8301/v1"
    static var clientSecret: String = "d3UIustzS3lPOwBVIg51zQ672KtpFU4yz2Dt5bMgVgw"
    
    case socialPosts(Int)
    case productIDs
    case sections(String)
    case treeHash
    case stickers([Int])
    case contestUpload
    
    var method: HTTPMethod {
        switch self {
        case .socialPosts:
            return .get
        case .productIDs:
            return .get
        case .sections:
            return .get
        case .treeHash:
            return .get
        case .stickers:
            return .get
        case .contestUpload:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .socialPosts(_):
            return "social_posts"
        case .productIDs:
            return "product_ids"
        case .sections:
            return "sections"
        case .treeHash:
            return "tree_md5"
        case .stickers:
            return "files"
        case .contestUpload:
            return "contest_file/upload"
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() -> URLRequest {
        let URL = Foundation.URL(string: type(of: self).baseURLString)!
        var urlRequest = Foundation.URLRequest(url: URL.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        urlRequest.httpMethod = method.rawValue
        
        urlRequest.setValue(type(of: self).clientSecret, forHTTPHeaderField: "X-Auth-Token")
        
        switch self {
        case .socialPosts(let page):
            return try! URLEncoding.default.encode(urlRequest, with: ["page":page, "order_desc":"date", "filter_approved":"t"])
        case .productIDs():
            return try! URLEncoding.default.encode(urlRequest, with: nil)
        case .sections(let language):
            return try! URLEncoding.default.encode(urlRequest, with: ["language":language])
        case .treeHash():
            return try! URLEncoding.default.encode(urlRequest, with: nil)
        case .stickers(let sections):
            return try! URLEncoding.default.encode(urlRequest, with: ["unlimit":true, "filter_section_id":sections,"order_lang":LanguageHelper.currentLanguageISOCode()])
        case .contestUpload:
            return try! JSONEncoding.default.encode(urlRequest, with: nil)

        }
    }
}
