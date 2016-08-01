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

public let acceptableStatusCodes: Range<Int> = 200..<300

public struct SSNetworkAPIClient {

// MARK: - Post
    static func getPosts(completion: (viewModels: [SSViewModel]?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET, SSNetworkContext.serverUrlPrefixt+"posts")
        .responseJSON { response in

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

                if response.result.isSuccess {
                    if acceptableStatusCodes.contains(response.response!.statusCode) {
                        print("postPost result : \(response.result.value)")

                        completion(error: nil)
                    } else {
                        let failureReason = "Response status code was unacceptable: \(response.response!.statusCode)"
                        let err: NSError = Error.errorWithCode(.StatusCodeValidationFailed, failureReason: failureReason)

                        completion(error: err)
                    }
                } else {
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

        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        // Basic Auth
        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"login",
            encoding: .JSON,
            headers: ["Authorization": "Basic " + base64String!])
            .responseJSON { response in

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let value: [String: AnyObject] = response.result.value as? [String: AnyObject] {

                        if let token = value["token"] as? String {
                            SSNetworkContext.sharedInstance.saveSharedAttribute(token, forKey: "token")

                            completion(error: nil)

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

                            let errorResult = value["error"]
                            if errorResult != nil {
                                let error: NSError = NSError(domain: "com.ssom.error.AuthFailed.Unknown", code: 999, userInfo: nil)

                                completion(error: error)
                            } else {
                                let error: NSError = errorResult as! NSError
                                
                                completion(error: error)
                            }

                        }
                    } else {
                        let error: NSError = NSError(domain: "com.ssom.error.AuthFailed", code: 999, userInfo: nil)

                        completion(error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(error: response.result.error!)
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

            if response.result.isSuccess {
                print("getUser result : \(response.result.value)")

                if let rawData = response.result.value as? [String: AnyObject] {
                    let userModel = SSUserModel(modelDict: rawData)

                    completion(model: userModel, error: nil)
                } else {
                    let error: NSError = NSError(domain: "com.ssom.error.NoUserData", code: 700, userInfo: nil)

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

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    completion(error: nil)
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(error: response.result.error)
                }

                indicator.hideIndicator()
        }
    }

// MARK: - Chat
    static func getChatroomList(token: String, completion: (datas: [SSChatroomViewModel]?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.GET,
                          SSNetworkContext.serverUrlPrefixt+"chatroom",
                          encoding: .JSON,
                          headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

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
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatRooms", code: 801, userInfo: nil)

                    completion(datas: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(datas: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }

    static func postChatroom(token: String, postId: String, completion: (chatroomId: String?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"chatroom",
            parameters: ["postId": postId],
            encoding: .JSON,
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let chatroomId = response.result.value as? String {
                        completion(chatroomId: chatroomId, error: nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.PostChatRoom", code: 802, userInfo: nil)

                        completion(chatroomId: nil, error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")

                    completion(chatroomId: nil, error: response.result.error)
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

                if response.result.isSuccess {
                    print("Response JSON : \(response.result.value)")

                    if let rawDatas = response.result.value as? [[String: AnyObject]] {
                        var datas: [SSChatViewModel] = [SSChatViewModel]()

                        for rawData: [String: AnyObject] in rawDatas {
                            let model: SSChatViewModel = SSChatViewModel(modelDict: rawData)
                            datas.append(model)
                        }

                        completion(datas: datas, error: nil)
                    } else {
                        let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatMessages", code: 802, userInfo: nil)

                        completion(datas: nil, error: error)
                    }
                } else {
                    print("Response Error : \(response.result.error)")
                    
                    completion(datas: nil, error: response.result.error)
                }
                
                indicator.hideIndicator()
        }
    }

    static func postChatMessage(token: String, chatroomId: String, message: String, lastTimestamp: Int, completion: (datas: SSChatViewModel?, error: NSError?) -> Void) {
        let indicator: SSIndicatorView = SSIndicatorView()
        indicator.showIndicator()

        Alamofire.request(.POST,
            SSNetworkContext.serverUrlPrefixt+"chatroom/\(chatroomId)/chats",
            encoding: .JSON,
            parameters: ["msg": message, "lastTimestamp": lastTimestamp],
            headers: ["Authorization": "JWT " + token])
        .responseJSON { (response) in

            if response.result.isSuccess {
                print("Response JSON : \(response.result.value)")

                if let rawDatas = response.result.value as? [String: AnyObject] {

                    if rawDatas.keys.contains("err") {
                        var errorCode = 500
                        if let err = rawDatas["err"] as? Int {
                            errorCode = err
                        }
                        let error = NSError(domain: "com.ssom.error.ServeError.ListChatMessages", code: errorCode, userInfo: [NSLocalizedDescriptionKey: rawDatas["result"] as! String])

                        completion(datas: nil, error: error)
                    } else {
                        let datas: SSChatViewModel = SSChatViewModel(modelDict: rawDatas)

                        completion(datas: datas, error: nil)
                    }
                } else {
                    let error = NSError(domain: "com.ssom.error.NotJSONDataFound.ListChatMessages", code: 802, userInfo: nil)

                    completion(datas: nil, error: error)
                }
            } else {
                print("Response Error : \(response.result.error)")

                completion(datas: nil, error: response.result.error)
            }

            indicator.hideIndicator()
        }
    }
}