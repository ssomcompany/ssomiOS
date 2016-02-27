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
    class func getPosts(completion: ([SSViewModel]!) -> Void) {
        Alamofire.request(.GET, SSNetworkContext.serverUrlPrefixt+"posts")
        .responseJSON { response in

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                let rawDatas: Array = response.result.value as! [[String: AnyObject!]]
                var datas: Array = [SSViewModel]()

                for rawData in rawDatas {
                    let viewModel: SSViewModel = SSViewModel.init(modelDict: rawData)

                    datas.append(viewModel)
                }

                completion(datas)
            } else {
                print("Response Error : \(response.result.error)")
            }
        }
    }
}