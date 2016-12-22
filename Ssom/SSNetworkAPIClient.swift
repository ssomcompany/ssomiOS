//
//  SSNetworkAPIClient.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 15..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import Foundation
import Alamofire
import FirebaseAuth

enum SSGender : String {
    case SSGenderMale = "Male"
    case SSGenderFemale = "Female"
}

public let acceptableStatusCodes: CountableRange<Int> = 200..<300

public struct SSNetworkAPIClient {

// MARK: - Common
    static func getVersion(_ completion: @escaping (_ version: String?, _ error: NSError?) -> Void) {
        print(#function)

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()
        Alamofire.request(SSNetworkContext.serverUrlPrefixt + "version/ios",
                          method: .get)
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawData = response.result.value as? [String: String] {
                    completion(rawData["version"], nil)
                } else {
                    let error: NSError = NSError(domain: "com.ssom.error.VersionCheckFailed.Unknown", code: 999, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

// MARK: - Post
    static func getPosts(latitude: Double = 0, longitude: Double = 0, completion: @escaping (_ viewModels: [SSViewModel]?, _ error: NSError?) -> Void) {
        var params: String! = nil
        if !(latitude == 0 && longitude == 0) {
            params = "?lat=\(latitude)&lng=\(longitude)"
        }
        if let userId = SSAccountManager.sharedInstance.userUUID {
            let queryString = "userId=\(userId)"
            if params == nil {
                params = "?"+queryString
            } else {
                params = params + "&" + queryString
            }
        }

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"posts"+(params != nil ? params : ""),
                          method: .get)
        .responseJSON { response in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                let rawDatas: Array = response.result.value as! [[String: AnyObject?]]
                var datas: Array = [SSViewModel]()

                for rawData in rawDatas {
                    let viewModel: SSViewModel = SSViewModel(modelDict: rawData)

                    datas.append(viewModel)
                }

                completion(datas, nil)
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func postPost(_ token: String, model: SSWriteViewModel, completion: @escaping (_ error: NSError?) -> Void) {
        let params: [String: String] = ["userId": "\(model.userId)",
                                           "content": model.content.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                                           "ssomType": model.ssomType.rawValue,
                                           "latitude": "\(model.myLatitude)",
                                           "longitude": "\(model.myLongitude)",
                                           "imageUrl": (model.profilePhotoUrl?.absoluteString)!,
                                           "minAge": "\(model.ageType.rawValue)",
                                           "userCount": "\(model.peopleCountType.rawValue)"]

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"posts",
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in

                print("request is : \(response.request)")

                if response.result.isSuccess {
                    if acceptableStatusCodes.contains(response.response!.statusCode) {
                        print("postPost result : \(response.result.value)")

                        completion(nil)
                    } else {
                        let failureReason = "Response status code was unacceptable: \(response.response!.statusCode)"
                        let err: NSError = NSError(domain: "com.ssom.error.UnacceptableStatusCode", code: 401, userInfo: [NSLocalizedDescriptionKey: failureReason])

                        completion(err)
                    }
                } else {
                    completion(response.result.error as NSError?)
                }

                indicator.hideIndicator()
            }
    }

    static func deletePost(_ token: String, postId: String, completion: @escaping (_ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"posts/\(postId)",
            method: .delete,
            encoding: JSONEncoding.default,
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                if acceptableStatusCodes.contains(response.response!.statusCode) {
                    print("postPost result : \(response.result.value)")

                    completion(nil)
                } else {
                    let failureReason = "Response status code was unacceptable: \(response.response!.statusCode)"
                    let err: NSError = NSError(domain: "com.ssom.error.UnacceptableStatusCode", code: 401, userInfo: [NSLocalizedDescriptionKey: failureReason])

                    completion(err)
                }
            } else {
                print("Response Error : \(response.result.error)")
                
                completion(response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

// MARK: - File
    static func getFile(_ token: String, fileId: String, completion: @escaping (_ error: NSError?) -> Void) {
        let imagePath = fileId

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"file/images/\(imagePath)",
            method: .get,
            headers: ["Authorization": "JWT " + token])
        .responseData { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("getFile result : \(response.result.value)")

                completion(nil)
            } else {
                completion(response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }

    }

    static func postFile(_ token: String, fileExt: String, fileName: String, fileData: Data, completion: @escaping (_ photoURLPath: String?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData, withName: "pict", fileName: fileName, mimeType: "image/\(fileExt)")
        }, usingThreshold: 0,
           to: SSNetworkContext.serverUrlPrefixt+"file/upload",
           method: .post,
           headers: ["Authorization": "JWT " + token],
           encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let req, _, _):
                // TODO: 현재 에러 메세지가 HTML로 내려오고 있는 경우가 있음(ex: 파일 업로드 허용 용량 초과)
                req.responseJSON(completionHandler: { (response) in

                    if response.result.isSuccess {
                        print("postFile result : \(response.result.value)")

                        let rawData = response.result.value as! NSDictionary
                        let fileId: String = rawData["fileId"] as! String

                        completion(SSNetworkContext.serverUrlPrefixt+"file/images/\(fileId)", nil)
                    } else {
                        completion(nil, response.result.error as NSError?)
                    }

                    indicator.hideIndicator()
                })
            case .failure(let error):
                print(error)

                indicator.hideIndicator()

//                completion(error: error)
            }
        })
    }

// MARK: - User & Session
    static func postLogin(userId email:String, password:String, completion: @escaping (_ error:NSError?) -> Void ) {
        let plainString = "\(email):\(password)" as NSString
        let plainData = plainString.data(using: String.Encoding.utf8.rawValue)
        let base64String = plainData?.base64EncodedString(options: [])

        guard let playerId = SSAccountManager.sharedInstance.oneSignalPlayerId else {
            var errorCode = 601
            var errorDescription = "Unknown"
            if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errorCode) {
                errorCode = errorInfo.0
                errorDescription = errorInfo.1
            }

            let error = NSError(domain: "com.ssom.error.AuthFailed.NoPushKey", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

            completion(error)

            return
        }

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        // Basic Auth
        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"login",
                          method: .post,
                          parameters: ["playerId": playerId],
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "Basic " + base64String!])
            .responseJSON { response in

                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawDatas: [String: AnyObject] = response.result.value as? [String: AnyObject] {

                        if let token = rawDatas["token"] as? String {
                            SSNetworkContext.sharedInstance.saveSharedAttribute(token, forKey: "token")
                            if let userUUID = rawDatas["userId"] as? String {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(userUUID, forKey: "userId")
                            }
                            if let heartsCount = rawDatas["hearts"] as? Int {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(heartsCount, forKey: "heartsCount")
                            }

                            completion(nil)

                            if let imageUrl = rawDatas["profileImgUrl"] as? String {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(imageUrl, forKey: "profileImageUrl")
                            }

                            if let auth = FIRAuth.auth() {
                                auth.signIn(withEmail: email, password: password, completion: { (user, error) in
                                    if let err = error {
                                        print("Firebase Sign in is failed!! : \(err)")
                                    } else {
                                        print("Firebase Sign in succeeds!! : \(user)")
                                    }
                                })
                            }

                            SSNetworkAPIClient.getUser(token, email: email, completion: { (model, error) in
                                if let err = error {
                                    print(err.localizedDescription)

                                    SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                                } else {
                                    if let m = model {
                                        SSNetworkContext.sharedInstance.saveSharedAttribute(m.toDictionary(), forKey: "userModel")
                                    }
                                }
                            })

                        } else {
                            let errorHandleBlock: (_ errorParamName: String, _ datas: [String: AnyObject]) -> Void = { (name, datas) in
                                var errorCode = 999
                                var errorDescription = datas["result"] as! String
                                if let err = rawDatas[name] as? Int {
                                    errorCode = err
                                } else {
                                    if let errName = datas["msg"] as? String {
                                        if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errName) {
                                            errorCode = errorInfo.0
                                            errorDescription = errorInfo.1
                                        } else {
                                            errorDescription = errName
                                        }
                                    }
                                }
                                let error = NSError(domain: "com.ssom.error.ServeError.AuthFailed", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

                                completion(error)
                            }

                            if rawDatas.keys.contains("err") {
                                errorHandleBlock("err", rawDatas)
                            } else if rawDatas.keys.contains("error") {
                                errorHandleBlock("error", rawDatas)
                            }
                            else {
                                let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)

                                completion(error)
                            }

                        }
                    } else {
                        let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)

                        completion(error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(response.result.error! as NSError?)
                }

                indicator.hideIndicator()
        }

    }
    static func postLogin(withFBSDKAccessToken token: String, email: String, completion: @escaping (_ error:NSError?) -> Void ) {

        guard let playerId = SSAccountManager.sharedInstance.oneSignalPlayerId else {
            var errorCode = 601
            var errorDescription = "Unknown"
            if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errorCode) {
                errorCode = errorInfo.0
                errorDescription = errorInfo.1
            }

            let error = NSError(domain: "com.ssom.error.AuthFailed.NoPushKey", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

            completion(error)

            return
        }

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        // Basic Auth
        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"facebook",
                          method: .post,
                          parameters: ["playerId": playerId],
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "Bearer " + token])
            .responseJSON { response in

                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawDatas: [String: AnyObject] = response.result.value as? [String: AnyObject] {

                        if let token = rawDatas["token"] as? String {
                            SSNetworkContext.sharedInstance.saveSharedAttribute(token, forKey: "token")
                            if let userUUID = rawDatas["userId"] as? String {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(userUUID, forKey: "userId")
                            }
                            if let heartsCount = rawDatas["hearts"] as? Int {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(heartsCount, forKey: "heartsCount")
                            }

                            completion(nil)

                            if let imageUrl = rawDatas["profileImgUrl"] as? String {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(imageUrl, forKey: "profileImageUrl")
                            }

                            if let auth = FIRAuth.auth() {
                                auth.signIn(withEmail: email, password: "facebook", completion: { (user, error) in
                                    if let err = error {
                                        print("Firebase Sign-in is failed!! : \(err)")
                                    } else {
                                        print("Firebase Sign-in succeeds!! : \(user)")
                                    }
                                })
                            }

                            SSNetworkAPIClient.getUser(token, email: email, completion: { (model, error) in
                                if let err = error {
                                    print(err.localizedDescription)

                                    SSAlertController.showAlertConfirm(title: "Error", message: err.localizedDescription, completion: nil)
                                } else {
                                    if let m = model {
                                        SSNetworkContext.sharedInstance.saveSharedAttribute(m.toDictionary(), forKey: "userModel")
                                    }
                                }
                            })

                        } else {
                            let errorHandleBlock: (_ errorParamName: String, _ datas: [String: AnyObject]) -> Void = { (name, datas) in
                                var errorCode = 999
                                var errorDescription = datas["result"] as! String
                                if let err = rawDatas[name] as? Int {
                                    errorCode = err
                                } else {
                                    if let errName = datas["msg"] as? String {
                                        if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errName) {
                                            errorCode = errorInfo.0
                                            errorDescription = errorInfo.1
                                        } else {
                                            errorDescription = errName
                                        }
                                    }
                                }
                                let error = NSError(domain: "com.ssom.error.ServeError.AuthFailed", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

                                completion(error)
                            }

                            if rawDatas.keys.contains("err") {
                                errorHandleBlock("err", rawDatas)
                            } else if rawDatas.keys.contains("error") {
                                errorHandleBlock("error", rawDatas)
                            }
                            else {
                                let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)

                                completion(error)
                            }

                        }
                    } else {
                        let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)
                        
                        completion(error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")
                    
                    completion(response.result.error! as NSError?)
                }
                
                indicator.hideIndicator()
        }
        
    }

    static func postLogout(_ token: String, completion: @escaping (_ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt + "logout",
                          method: .post,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("getUser result : \(response.result.value)")
                
                completion(nil)
            } else {
                completion(response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func getUser(_ token: String, email: String, completion: @escaping (_ model: SSUserModel?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt + "users/\(email)",
            method: .get,
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("getUser result : \(response.result.value)")

                if let rawData = response.result.value as? [String: AnyObject] {
                    let userModel = SSUserModel(modelDict: rawData)

                    completion(userModel, nil)
                } else {
                    let error: NSError = NSError(domain: "com.ssom.error.NoUserData", code: 701, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func postUser(_ email:String, password:String, nickName:String? = "None", gender:SSGender? = .SSGenderFemale, completion: @escaping (_ error: NSError?) -> Void ) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt + "users",
                          method: .post,
                          parameters: ["email":email, "password":password, "nickName":nickName!, "gender":gender!.rawValue],
                          encoding: JSONEncoding.default)
            .responseJSON { (response) in

                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawDatas = response.result.value as? [String: AnyObject] {

                        if rawDatas.keys.contains("err") {
                            var errorCode = 501
                            var errorDescription = rawDatas["result"] as! String
                            if let err = rawDatas["err"] as? Int {
                                errorCode = err
                            } else {
                                if let errName = rawDatas["err"] as? String {
                                    if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errName) {
                                        errorCode = errorInfo.0
                                        errorDescription = errorInfo.1
                                    } else {
                                        errorDescription = errName
                                    }
                                }
                            }
                            let error = NSError(domain: "com.ssom.error.ServeError.SignUp", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

                            completion(error)
                        } else {
                            if let auth = FIRAuth.auth() {
                                auth.createUser(withEmail: email, password: password, completion: { (user, error) in
                                    if let err = error {
                                        print("Firebase Sign Up is failed!! : " + err.localizedDescription)
                                    } else {
                                        print("Firebase Sign Up is succeeded!! : \(user)")
                                    }
                                })
                            }
                            completion(nil)
                        }
                        
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.SignUp", code: 805, userInfo: nil)

                        completion(error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(response.result.error as NSError?)
                }

                indicator.hideIndicator()
        }
    }

    static func deleteUserProfileImage(_ token: String, completion: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"users/profileImgUrl",
                          method: .delete,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                completion(nil, nil)
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func postPurchaseHearts(_ token: String, purchasedHeartCount: Int, completion: @escaping (_ heartsCount: Int, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"users/hearts",
                          method: .post,
                          parameters: ["count" : purchasedHeartCount, "deviceType": "iOS"],
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawDatas = response.result.value as? [String: AnyObject] {
                        if let heartsCount = rawDatas["heartsCount"] as? Int {

                            SSNetworkContext.sharedInstance.saveSharedAttribute(heartsCount, forKey: "heartsCount")

                            completion(heartsCount, nil)
                        }
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PurchaseHearts", code: 814, userInfo: nil)

                        completion(0, error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(0, response.result.error as NSError?)
                }

                indicator.hideIndicator()
        }
    }

    static func getHearts(_ token: String, completion: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"users/hearts",
                          method: .get,
                          headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    completion(nil, nil)
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(nil, response.result.error as NSError?)
                }

                indicator.hideIndicator()
        }
    }

// MARK: - Chat
    static func getChatroomList(_ token: String, latitude: Double = 0, longitude: Double = 0, completion: @escaping (_ datas: [SSChatroomViewModel]?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        var params: String! = nil
        if !(latitude == 0 && longitude == 0) {
            params = "?lat=\(latitude)&lng=\(longitude)"
        }

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"chatroom" + (params != nil ? params : ""),
                          method: .get,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawDatas = response.result.value as? [[String: AnyObject]] {
                    var datas: [SSChatroomViewModel] = [SSChatroomViewModel]()

                    for rawData: [String: AnyObject] in rawDatas {
                        let model: SSChatroomViewModel = SSChatroomViewModel(modelDict: rawData)
                        datas.append(model)
                    }

                    completion(datas, nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatRooms", code: 811, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func postChatroom(_ token: String, postId: String, latitude: Double = 0, longitude: Double = 0, completion: @escaping (_ chatroomId: String?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        var params: [String: Any] = ["postId": postId]
        if !(latitude == 0 && longitude == 0) {
            params["lat"] = "\(latitude)"
            params["lng"] = "\(longitude)"
        }

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"chatroom",
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawDatas = response.result.value as? [String: AnyObject] {

                    if rawDatas.keys.contains("err") {
                        var errorCode = 501
                        var errorDescription = rawDatas["result"] as! String
                        if let err = rawDatas["err"] as? Int {
                            errorCode = err
                        } else {
                            if let errName = rawDatas["err"] as? String {
                                if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errName) {
                                    errorCode = errorInfo.0
                                    errorDescription = errorInfo.1
                                } else {
                                    if let errDescription = rawDatas["msg"] as? String {
                                        errorDescription = errDescription
                                    } else {
                                        errorDescription = errName
                                    }
                                }
                            }
                        }
                        let error = NSError(domain: "com.ssom.error.ServeError.PostChatRoom", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

                        completion(nil, error)
                    } else {
                        if let chatroomId = rawDatas["chatroomId"] as? Int {
                            completion(String(chatroomId), nil)
                        } else {
                            let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatRoom", code: 812, userInfo: nil)

                            completion(nil, error)
                        }

                        if let heartsCount = rawDatas["hearts"] as? Int {
                            SSNetworkContext.sharedInstance.saveSharedAttribute(heartsCount, forKey: "heartsCount")
                        }
                    }
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatRoom", code: 812, userInfo: nil)

                    completion(nil, error)
                }

            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func putChatroomLastAccessTime(_ token: String, chatroomId: String, completion: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)/lastAccessTimestamp",
            method: .put,
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let _ = response.result.value as? [String: AnyObject] {
                    completion(nil, nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PutChatroomLastAccessTime", code: 816, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                if acceptableStatusCodes.contains(response.response!.statusCode) {
                    print("putChatroomLastAccessTime result : \(response.result.value)")

                    completion(nil, nil)
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(nil, response.result.error as NSError?)
                }
            }
            
            indicator.hideIndicator()
        }
    }

    static func deleteChatroom(_ token: String, chatroomId: String, completion: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)",
            method: .delete,
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let _ = response.result.value as? [String: AnyObject] {
                    completion(nil, nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.DeleteChatroom", code: 813, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func getChatMessages(_ token: String, chatroomId: String, completion: @escaping (_ datas: [SSChatViewModel]?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)/chats",
            method: .get,
            headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in

                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawDatas = response.result.value as? [String: AnyObject] {

                        if rawDatas.keys.contains("err") {
                            var errorCode = 501
                            var errorDescription = rawDatas["result"] as! String
                            if let err = rawDatas["err"] as? Int {
                                errorCode = err
                            } else {
                                if let errDescription = rawDatas["err"] as? String {
                                    errorDescription = errDescription
                                }
                            }
                            let error = NSError(domain: "com.ssom.error.ServeError.ListChatMessages", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

                            completion(nil, error)
                        } else {
                            let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatMessages", code: 803, userInfo: nil)

                            completion(nil, error)
                        }

                    } else {

                        if let rawDatas = response.result.value as? [[String: AnyObject]] {
                            var datas: [SSChatViewModel] = [SSChatViewModel]()

                            for rawData: [String: AnyObject] in rawDatas {
                                let model: SSChatViewModel = SSChatViewModel(modelDict: rawData)
                                datas.append(model)
                            }

                            completion(datas, nil)
                        } else {
                            let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatMessages", code: 803, userInfo: nil)
                            
                            completion(nil, error)
                        }

                    }
                } else {
                    print("Response Error : \(response.result.error)")
                    
                    completion(nil, response.result.error as NSError?)
                }
                
                indicator.hideIndicator()
        }
    }

    static func postChatMessage(_ token: String, chatroomId: String, message: String, lastTimestamp: Int, completion: @escaping (_ datas: [SSChatViewModel]?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)/chats?lastTimestamp=\(lastTimestamp)",
            method: .post,
            parameters: ["msg": message],
            encoding: JSONEncoding.default,
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawDatas = response.result.value as? [String: AnyObject] {

                    if rawDatas.keys.contains("err") {
                        var errorCode = 501
                        var errorDescription = rawDatas["result"] as! String
                        if let err = rawDatas["err"] as? Int {
                            errorCode = err
                        } else {
                            if let errDescription = rawDatas["err"] as? String {
                                if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errDescription) {
                                    errorCode = errorInfo.0
                                    errorDescription = errorInfo.1
                                } else {
                                    errorDescription = errDescription
                                }
                            } else if let errDescription = rawDatas["msg"] as? String {
                                errorDescription = errDescription
                            }
                        }
                        let error = NSError(domain: "com.ssom.error.ServeError.PostChatMessages", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

                        completion(nil, error)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatMessages", code: 803, userInfo: nil)

                        completion(nil, error)
                    }

                } else {

                    if let rawDatas = response.result.value as? [[String: AnyObject]] {
                        var datas: [SSChatViewModel] = [SSChatViewModel]()

                        for rawData: [String: AnyObject] in rawDatas {
                            let model: SSChatViewModel = SSChatViewModel(modelDict: rawData)
                            datas.append(model)
                        }

                        completion(datas, nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatMessages", code: 803, userInfo: nil)

                        completion(nil, error)
                    }
                    
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func postMeetRequest(_ token: String, chatRoomId: String, completion: @escaping (_ data: SSChatViewModel?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"request",
                          method: .post,
                          parameters: ["chatroomId": chatRoomId],
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawData = response.result.value as? [String: AnyObject] {
                    let model = SSChatViewModel(modelDict: rawData)
                    completion(model, nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostMeetRequest", code: 804, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func putMeetRequest(_ token: String, chatRoomId: String, completion: @escaping (_ data: SSChatViewModel?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"request",
                          method: .put,
                          parameters: ["chatroomId": chatRoomId],
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawData = response.result.value as? [String: AnyObject] {
                        let model = SSChatViewModel(modelDict: rawData)
                        completion(model, nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PutMeetRequest", code: 807, userInfo: nil)

                        completion(nil, error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(nil, response.result.error as NSError?)
                }
                
                indicator.hideIndicator()
        }
    }

    static func deleteMeetRequest(_ token: String, chatRoomId: String, completion: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"request",
                          method: .delete,
                          parameters: ["chatroomId": chatRoomId],
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let _ = response.result.value as? [String: AnyObject] {
                    completion(nil, nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.DeleteMeetRequest", code: 805, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    static func getUnreadCount(_ token: String, completion: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"chatroom/unreadCount",
                          method: .get,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawData = response.result.value as? [String: AnyObject] {
                    completion(rawData as AnyObject?, nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.GetUnreadCount", code: 806, userInfo: nil)

                    completion(nil, error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(nil, response.result.error as NSError?)
            }

            indicator.hideIndicator()
        }
    }

    // MARK: - Report
    static func postReport(_ token: String, postId: String, reason: String, completion: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(SSNetworkContext.serverUrlPrefixt+"reports",
                          method: .post,
                          parameters: ["postId": postId,
                                       "content": reason],
                          encoding: JSONEncoding.default,
                          headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let _ = response.result.value as? [String: AnyObject] {
                        completion(nil, nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostReport", code: 815, userInfo: nil)

                        completion(nil, error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(nil, response.result.error as NSError?)
                }
                
                indicator.hideIndicator()
        }
    }
}
