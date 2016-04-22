//
//  SSNetworkAPIClient.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 15..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation
import Alamofire

enum SSGender : String {
    case SSGenderMale = "Male"
    case SSGenderFemale = "Female"
}

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

    class func postLogin(email:String, password:String, completion: (error:NSError?) -> Void ) {
        let plainString = "\(email):\(password)" as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions([])

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"login",
            encoding: .JSON,
            headers: ["Authorization": "Basic " + base64String!])
            .responseJSON { response in

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let token = response.result.value!["token"] {
                        SSNetworkContext.sharedInstance.saveSharedAttribute(token!, forKey: "token")

                        completion(error: nil)
                    } else {
                        let error: NSError = NSError(domain: "com.ssom.error.AuthFailed", code: 999, userInfo: nil)

                        completion(error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(error: response.result.error!)
                }
        }

    }

    class func postUser(email:String, password:String, nickName:String? = "None", gender:SSGender? = .SSGenderFemale, completion: () -> Void ) {
        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt + "users",
            parameters: ["email":email, "password":password, "nickName":nickName!, "gender":gender!.rawValue],
            encoding: .JSON)
            .responseJSON { (response) in

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    completion()
                } else {
                    print("Response Error : \(response.result.error)")
                }
        }
    }
}