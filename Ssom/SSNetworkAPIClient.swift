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

public let acceptableStatusCodes: Range<Int> = 200..<300

public struct SSNetworkAPIClient {

// MARK: - Common
    static func getVersion(completion: (version: String?, error: NSError?) -> Void) {
        print(#function)

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
                          SSNetworkContext.serverUrlPrefixt+"version/ios",
                          encoding: .JSON)
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawData = response.result.value as? [String: String] {
                    completion(version: rawData["version"], error: nil)
                } else {
                    let error: NSError = NSError(domain: "com.ssom.error.VersionCheckFailed.Unknown", code: 999, userInfo: nil)

                    completion(version: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(version: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

// MARK: - Post
    static func getPosts(latitude latitude: Double = 0, longitude: Double = 0, completion: (viewModels: [SSViewModel]?, error: NSError?) -> Void) {
        var params: String! = nil
        if !(latitude == 0 && longitude == 0) {
//            params = "?lat=\(latitude)&lng=\(longitude)"
        }
        if let userId = SSAccountManager.sharedInstance.userUUID {
            let queryString = "userId=\(userId)"
            if params == nil {
                params = "?"+queryString
            } else {
                params = params.stringByAppendingString(queryString)
            }
        }

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
            SSNetworkContext.serverUrlPrefixt+"posts"+(params != nil ? params : ""),
            encoding: .JSON)
        .responseJSON { response in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                let rawDatas: Array = response.result.value as! [[String: AnyObject!]]
                var datas: Array = [SSViewModel]()

                for rawData in rawDatas {
                    let viewModel: SSViewModel = SSViewModel(modelDict: rawData)

                    datas.append(viewModel)
                }

                completion(viewModels: datas, error: nil)
            } else {
                print("Response Error : \(response.result.error)")

                completion(viewModels: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func postPost(token: String, model: SSWriteViewModel, completion: (error: NSError?) -> Void) {
        let params: [String: AnyObject] = ["userId": "\(model.userId)",
                                           "content": model.content.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!,
                                           "ssomType": model.ssomType.rawValue,
                                           "latitude": "\(model.myLatitude)",
                                           "longitude": "\(model.myLongitude)",
                                           "imageUrl": (model.profilePhotoUrl?.absoluteString)!,
                                           "minAge": model.ageType.rawValue,
                                           "userCount": model.peopleCountType.rawValue]

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"posts",
            parameters: params,
            encoding: .JSON,
            headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in

                print("request is : \(response.request)")

                if response.result.isSuccess {
                    if acceptableStatusCodes.contains(response.response!.statusCode) {
                        print("postPost result : \(response.result.value)")

                        completion(error: nil)
                    } else {
                        let failureReason = "Response status code was unacceptable: \(response.response!.statusCode)"
                        let err: NSError = NSError(domain: "com.ssom.error.UnacceptableStatusCode", code: 401, userInfo: [NSLocalizedDescriptionKey: failureReason])

                        completion(error: err)
                    }
                } else {
                    completion(error: response.result.error)
                }

                indicator.hideIndicator()
            }
    }

    static func deletePost(token: String, postId: String, completion: (error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.DELETE,
                          SSNetworkContext.serverUrlPrefixt+"posts/\(postId)",
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                if acceptableStatusCodes.contains(response.response!.statusCode) {
                    print("postPost result : \(response.result.value)")

                    completion(error: nil)
                } else {
                    let failureReason = "Response status code was unacceptable: \(response.response!.statusCode)"
                    let err: NSError = NSError(domain: "com.ssom.error.UnacceptableStatusCode", code: 401, userInfo: [NSLocalizedDescriptionKey: failureReason])

                    completion(error: err)
                }
            } else {
                print("Response Error : \(response.result.error)")
                
                completion(error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

// MARK: - File
    static func getFile(token: String, fileId: String, completion: (error: NSError?) -> Void) {
        let imagePath = fileId

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
                          SSNetworkContext.serverUrlPrefixt+"file/images/\(imagePath)",
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseData { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("getFile result : \(response.result.value)")

                completion(error: nil)
            } else {
                completion(error: response.result.error)
            }

            indicator.hideIndicator()
        }

    }

    static func postFile(token: String, fileExt: String, fileName: String, fileData: NSData, completion: (photoURLPath: String?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.upload(.POST,
                         SSNetworkContext.serverUrlPrefixt+"file/upload",
                         headers: ["Authorization": "JWT " + token],
                         multipartFormData: { (multipartFormData) in
                            multipartFormData.appendBodyPart(data: fileData, name: "pict", fileName: fileName, mimeType: "image/\(fileExt)")
                        },
                         encodingMemoryThreshold: 0,
                         encodingCompletion: { (encodingResult) in
                            switch encodingResult {
                            case .Success(let req, _, _):
                                // TODO: 현재 에러 메세지가 HTML로 내려오고 있는 경우가 있음(ex: 파일 업로드 허용 용량 초과)
                                req.responseJSON(completionHandler: { (response) in

                                    if response.result.isSuccess {
                                        print("postFile result : \(response.result.value)")

                                        let rawData = response.result.value as! NSDictionary
                                        let fileId: String = rawData["fileId"] as! String

                                        completion(photoURLPath: SSNetworkContext.serverUrlPrefixt+"file/images/\(fileId)", error: nil)
                                    } else {
                                        completion(photoURLPath: nil, error: response.result.error)
                                    }

                                    indicator.hideIndicator()
                                })
                            case .Failure(let error):
                                print(error)

                                indicator.hideIndicator()

//                                completion(error: error)
                            }
        })
    }

// MARK: - User & Session
    static func postLogin(userId email:String, password:String, completion: (error:NSError?) -> Void ) {
        let plainString = "\(email):\(password)" as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String = plainData?.base64EncodedStringWithOptions([])

        guard let playerId = SSAccountManager.sharedInstance.oneSignalPlayerId else {
            var errorCode = 601
            var errorDescription = "Unknown"
            if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errorCode) {
                errorCode = errorInfo.0
                errorDescription = errorInfo.1
            }

            let error = NSError(domain: "com.ssom.error.AuthFailed.NoPushKey", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

            completion(error: error)

            return
        }

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        // Basic Auth
        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"login",
            parameters: ["playerId": playerId],
            encoding: .JSON,
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

                            completion(error: nil)

                            if let imageUrl = rawDatas["profileImgUrl"] as? String {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(imageUrl, forKey: "profileImageUrl")
                            }

                            if let auth = FIRAuth.auth() {
                                auth.signInWithEmail(email, password: password, completion: { (user, error) in
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
                            let errorHandleBlock: (errorParamName: String, datas: [String: AnyObject]) -> Void = { (name, datas) in
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

                                completion(error: error)
                            }

                            if rawDatas.keys.contains("err") {
                                errorHandleBlock(errorParamName: "err", datas: rawDatas)
                            } else if rawDatas.keys.contains("error") {
                                errorHandleBlock(errorParamName: "error", datas: rawDatas)
                            }
                            else {
                                let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)

                                completion(error: error)
                            }

                        }
                    } else {
                        let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)

                        completion(error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(error: response.result.error!)
                }

                indicator.hideIndicator()
        }

    }
    static func postLogin(withFBSDKAccessToken token: String, email: String, completion: (error:NSError?) -> Void ) {

        guard let playerId = SSAccountManager.sharedInstance.oneSignalPlayerId else {
            var errorCode = 601
            var errorDescription = "Unknown"
            if let errorInfo = SSNetworkErrorHandler.sharedInstance.getErrorInfo(errorCode) {
                errorCode = errorInfo.0
                errorDescription = errorInfo.1
            }

            let error = NSError(domain: "com.ssom.error.AuthFailed.NoPushKey", code: errorCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])

            completion(error: error)

            return
        }

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        // Basic Auth
        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"facebook",
            parameters: ["playerId": playerId],
            encoding: .JSON,
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

                            completion(error: nil)

                            if let imageUrl = rawDatas["profileImgUrl"] as? String {
                                SSNetworkContext.sharedInstance.saveSharedAttribute(imageUrl, forKey: "profileImageUrl")
                            }

                            if let auth = FIRAuth.auth() {
                                auth.signInWithEmail(email, password: "facebook", completion: { (user, error) in
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
                            let errorHandleBlock: (errorParamName: String, datas: [String: AnyObject]) -> Void = { (name, datas) in
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

                                completion(error: error)
                            }

                            if rawDatas.keys.contains("err") {
                                errorHandleBlock(errorParamName: "err", datas: rawDatas)
                            } else if rawDatas.keys.contains("error") {
                                errorHandleBlock(errorParamName: "error", datas: rawDatas)
                            }
                            else {
                                let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)

                                completion(error: error)
                            }

                        }
                    } else {
                        let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)
                        
                        completion(error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")
                    
                    completion(error: response.result.error!)
                }
                
                indicator.hideIndicator()
        }
        
    }

    static func postLogout(token: String, completion: (error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
                          SSNetworkContext.serverUrlPrefixt + "logout",
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("getUser result : \(response.result.value)")
                
                completion(error: nil)
            } else {
                completion(error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func getUser(token: String, email: String, completion: (model: SSUserModel?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
            SSNetworkContext.serverUrlPrefixt + "users/\(email)",
            encoding: .JSON,
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("getUser result : \(response.result.value)")

                if let rawData = response.result.value as? [String: AnyObject] {
                    let userModel = SSUserModel(modelDict: rawData)

                    completion(model: userModel, error: nil)
                } else {
                    let error: NSError = NSError(domain: "com.ssom.error.NoUserData", code: 701, userInfo: nil)

                    completion(model: nil, error: error)
                }
            } else {
                completion(model: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func postUser(email:String, password:String, nickName:String? = "None", gender:SSGender? = .SSGenderFemale, completion: (error: NSError?) -> Void ) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt + "users",
            parameters: ["email":email, "password":password, "nickName":nickName!, "gender":gender!.rawValue],
            encoding: .JSON)
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

                            completion(error: error)
                        } else {
                            if let auth = FIRAuth.auth() {
                                auth.createUserWithEmail(email, password: password, completion: { (user, error) in
                                    if let err = error {
                                        print("Firebase Sign Up is failed!! : " + err.localizedDescription)
                                    } else {
                                        print("Firebase Sign Up is succeeded!! : \(user)")
                                    }
                                })
                            }
                            completion(error: nil)
                        }
                        
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.SignUp", code: 805, userInfo: nil)

                        completion(error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(error: response.result.error)
                }

                indicator.hideIndicator()
        }
    }

    static func deleteUserProfileImage(token: String, completion: (data: AnyObject?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.DELETE,
                          SSNetworkContext.serverUrlPrefixt+"users/profileImgUrl",
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                completion(data: nil, error: nil)
            } else {
                print("Response Error : \(response.result.error)")

                completion(data: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func postPurchaseHearts(token: String, purchasedHeartCount: Int, completion: (heartsCount: Int, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
                          SSNetworkContext.serverUrlPrefixt+"users/hearts",
                          parameters: ["count" : purchasedHeartCount, "deviceType": "iOS"],
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawDatas = response.result.value as? [String: AnyObject] {
                        if let heartsCount = rawDatas["heartsCount"] as? Int {

                            SSNetworkContext.sharedInstance.saveSharedAttribute(heartsCount, forKey: "heartsCount")

                            completion(heartsCount: heartsCount, error: nil)
                        }
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PurchaseHearts", code: 814, userInfo: nil)

                        completion(heartsCount: 0, error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(heartsCount: 0, error: response.result.error)
                }

                indicator.hideIndicator()
        }
    }

    static func getHearts(token: String, completion: (data: AnyObject?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
            SSNetworkContext.serverUrlPrefixt+"users/hearts",
            encoding: .JSON,
            headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    completion(data: nil, error: nil)
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(data: nil, error: response.result.error)
                }

                indicator.hideIndicator()
        }
    }

// MARK: - Chat
    static func getChatroomList(token: String, latitude: Double = 0, longitude: Double = 0, completion: (datas: [SSChatroomViewModel]?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        var params: String! = nil
        if !(latitude == 0 && longitude == 0) {
            params = "?lat=\(latitude)&lng=\(longitude)"
        }

        Alamofire.request(.GET,
                          SSNetworkContext.serverUrlPrefixt+"chatroom" + (params != nil ? params : ""),
                          encoding: .JSON,
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

                    completion(datas: datas, error: nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatRooms", code: 811, userInfo: nil)

                    completion(datas: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(datas: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func postChatroom(token: String, postId: String, latitude: Double = 0, longitude: Double = 0, completion: (chatroomId: String?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        var params: [String: AnyObject] = ["postId": postId]
        if !(latitude == 0 && longitude == 0) {
            params["lat"] = "\(latitude)"
            params["lng"] = "\(longitude)"
        }

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"chatroom",
            parameters: params,
            encoding: .JSON,
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

                        completion(chatroomId: nil, error: error)
                    } else {
                        if let chatroomId = rawDatas["chatroomId"] as? Int {
                            completion(chatroomId: String(chatroomId), error: nil)
                        } else {
                            let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatRoom", code: 812, userInfo: nil)

                            completion(chatroomId: nil, error: error)
                        }

                        if let heartsCount = rawDatas["hearts"] as? Int {
                            SSNetworkContext.sharedInstance.saveSharedAttribute(heartsCount, forKey: "heartsCount")
                        }
                    }
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatRoom", code: 812, userInfo: nil)

                    completion(chatroomId: nil, error: error)
                }

            } else {
                print("Response Error : \(response.result.error)")

                completion(chatroomId: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func deleteChatroom(token: String, chatroomId: String, completion: (data: AnyObject?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.DELETE,
                          SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)",
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let _ = response.result.value as? [String: AnyObject] {
                    completion(data: nil, error: nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.DeleteChatroom", code: 813, userInfo: nil)

                    completion(data: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(data: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func getChatMessages(token: String, chatroomId: String, completion: (datas: [SSChatViewModel]?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
            SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)/chats",
            encoding: .JSON,
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

                            completion(datas: nil, error: error)
                        } else {
                            let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatMessages", code: 803, userInfo: nil)

                            completion(datas: nil, error: error)
                        }

                    } else {

                        if let rawDatas = response.result.value as? [[String: AnyObject]] {
                            var datas: [SSChatViewModel] = [SSChatViewModel]()

                            for rawData: [String: AnyObject] in rawDatas {
                                let model: SSChatViewModel = SSChatViewModel(modelDict: rawData)
                                datas.append(model)
                            }

                            completion(datas: datas, error: nil)
                        } else {
                            let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatMessages", code: 803, userInfo: nil)
                            
                            completion(datas: nil, error: error)
                        }

                    }
                } else {
                    print("Response Error : \(response.result.error)")
                    
                    completion(datas: nil, error: response.result.error)
                }
                
                indicator.hideIndicator()
        }
    }

    static func postChatMessage(token: String, chatroomId: String, message: String, lastTimestamp: Int, completion: (datas: [SSChatViewModel]?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)/chats?lastTimestamp=\(lastTimestamp)",
            encoding: .JSON,
            parameters: ["msg": message],
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

                        completion(datas: nil, error: error)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatMessages", code: 803, userInfo: nil)

                        completion(datas: nil, error: error)
                    }

                } else {

                    if let rawDatas = response.result.value as? [[String: AnyObject]] {
                        var datas: [SSChatViewModel] = [SSChatViewModel]()

                        for rawData: [String: AnyObject] in rawDatas {
                            let model: SSChatViewModel = SSChatViewModel(modelDict: rawData)
                            datas.append(model)
                        }

                        completion(datas: datas, error: nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatMessages", code: 803, userInfo: nil)

                        completion(datas: nil, error: error)
                    }
                    
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(datas: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func postMeetRequest(token: String, chatRoomId: String, completion: (data: SSChatViewModel?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
                          SSNetworkContext.serverUrlPrefixt+"request",
                          encoding: .JSON,
                          parameters: ["chatroomId": chatRoomId],
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawData = response.result.value as? [String: AnyObject] {
                    let model = SSChatViewModel(modelDict: rawData)
                    completion(data: model, error: nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostMeetRequest", code: 804, userInfo: nil)

                    completion(data: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(data: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func putMeetRequest(token: String, chatRoomId: String, completion: (data: AnyObject?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.PUT,
                          SSNetworkContext.serverUrlPrefixt+"request",
                          parameters: ["chatroomId": chatRoomId],
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawData = response.result.value as? [String: AnyObject] {
                        completion(data: rawData, error: nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PutMeetRequest", code: 807, userInfo: nil)

                        completion(data: nil, error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(data: nil, error: response.result.error)
                }
                
                indicator.hideIndicator()
        }
    }

    static func deleteMeetRequest(token: String, chatRoomId: String, completion: (data: AnyObject?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.DELETE,
                          SSNetworkContext.serverUrlPrefixt+"request",
                          parameters: ["chatroomId": chatRoomId],
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let _ = response.result.value as? [String: AnyObject] {
                    completion(data: nil, error: nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.DeleteMeetRequest", code: 805, userInfo: nil)

                    completion(data: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(data: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func getUnreadCount(token: String, completion: (data: AnyObject?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
                          SSNetworkContext.serverUrlPrefixt+"chatroom/unreadCount",
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in
            print("request is : \(response.request)")

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawData = response.result.value as? [String: AnyObject] {
                    completion(data: rawData, error: nil)
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.GetUnreadCount", code: 806, userInfo: nil)

                    completion(data: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(data: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    // MARK: - Report
    static func postReport(token: String, postId: String, reason: String, completion: (data: AnyObject?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"reports",
            encoding: .JSON,
            parameters: ["postId": postId,
                        "content": reason],
            headers: ["Authorization": "JWT " + token])
            .responseJSON { (response) in
                print("request is : \(response.request)")

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let _ = response.result.value as? [String: AnyObject] {
                        completion(data: nil, error: nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostReport", code: 815, userInfo: nil)

                        completion(data: nil, error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(data: nil, error: response.result.error)
                }
                
                indicator.hideIndicator()
        }
    }
}
