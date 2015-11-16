//
//  SSNetworkAPIClient.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 15..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation
import Alamofire

public class SSNetworkAPIClient {
    class func getPosts(completion: (AnyObject!) -> Void) {
        Alamofire.request(.GET, SSNetworkContext.serverUrlPrefixt+"posts")
        .responseJSON { response in
            print("Response JSON : \(response.result.value)")

            completion(response.result.value)
        }
    }
}