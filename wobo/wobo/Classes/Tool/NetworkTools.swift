//
//  NetworkTools.swift
//  wobo
//
//  Created by Soul Ai on 11/12/2018.
//  Copyright © 2018 Soul Ai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

// API 接口定义
struct ConstAPI {
    static let kAPIBaseURL: String = ""
    //首页微游记
    static let kAPIHomeMoment: String = kAPIBaseURL + ""
    // 首页目的地
    static let kAPIHomeDestination: String = kAPIBaseURL + ""
}

class NetworkTools {
    
    static let shareInstance = NetworkTools()
    
    ///get
    func getRequest(url: String, param: [String: Any]?, successBlock: @escaping(_ json:JSON) -> (), failure: @escaping(_ error: Error) -> (),errorMsgHandler: @escaping(_ errorMsg:String) ->()) {// JSONEncoding 与 URLEncoding 服务接受数据的区别
        
        request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print("resopnse===\(response)")
            guard response.result.isSuccess else {
                // 网络连接或者服务错误的提示信息
                failure(response.error!)
                return
            }
            if let value = response.result.value {
                let json = JSON(value)
                // 请求成功 但是服务返回的报错信息
                guard json["errorCode"].intValue == 0 else {
                    if (json["errorCode"].intValue == 50000) {// Token 过期重新登录
                        errorMsgHandler(json["errorMsg"].stringValue)
                        SVProgressHUD.showInfo(withStatus: "授权失效,请重新登录!")
                        return
                    }
                    errorMsgHandler(json["errorMsg"].stringValue)
                    return
                }
                
                if json["result"].dictionary != nil {
                    successBlock(json["result"])
                    return
                } else {
                    successBlock(json)
                    return
                }
            }
        }
    }
    
    /// post
    func postRequest(url: String, param: [String: String], successBlock: @escaping(_ json:JSON) -> (), failure: @escaping(_ error: Error) ->(),errorMsgHandler: @escaping(_ errorMsg:String) ->()) { 
        
        request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(_):
                if let value = response.result.value {
                    let json = JSON(value)
                    guard json["errorCode"].intValue == 0 else {
                        if (json["errorCode"].intValue == 50000) {
                            errorMsgHandler(json["errorMsg"].stringValue)
                            SVProgressHUD.showInfo(withStatus: "授权失效,请重新登录!")
                            return
                        }
                        errorMsgHandler(json["errorMsg"].stringValue)
                        return
                    }
                    if json["result"].dictionary != nil {
                        successBlock(json["result"])
                        return
                    } else {
                        successBlock(json)
                        return
                    }
                }
            case .failure(let error):
                failure(error)
            }
        }
        
    }
    
    ///上传图片
    func upLoadImage(url: String, param: [String: String], photo:UIImage, successBlock: @escaping(_ dict: JSON) ->(), failure: @escaping(_ error: Error?) -> (), errorMsgHandler: @escaping(_ errorMsg:String) ->()) {
        
        upload(multipartFormData: { (form:MultipartFormData) in
//            let flag = param["flag"]
//            let userId = param["usetId"]
//            form.append(((flag?.data(using: String.Encoding.utf8))!), withName: "flag")
//            form.append((userId?.data(using: String.Encoding.utf8))!, withName: "userId")
            if let imageData = photo.jpegData(compressionQuality: 0.5) {
                form.append(imageData, withName: "appPhoto", fileName: "img.png", mimeType: "image/png")
            }
//            guard photo?.count != nil else {return}
//            for index in 0..<photo!.count {
//                if let imageData = (photo![index]).jpegData(compressionQuality: 0.5) {
//                    form.append(imageData, withName: "appPhoto", fileName: "img/(index).png", mimeType: "image/png")                    
//                }
//            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: HTTPMethod.post, headers: nil) { (result) in
            switch result {
                
            case .failure(let error):
                print(error)
                failure(error)  
                
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                //获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility), closure: { (progress) in
                    print(progress)//Double 成功回调
                })
                 //连接服务器成功后，对json的处理
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                        
                    case .success(let value):
                        let json = JSON(value)
                        successBlock(json)
                        print(json)
                    case .failure(let error):
                        print(error)
                    }
                })

            }
        }
        
    }
    

    ///上传视频
    func upLoadVideo(url: String, param: [String: String], video:Data, successBlock: @escaping(_ dict: JSON) ->(), failure: @escaping(_ error: Error?) -> (), progressComplete: @escaping(_ progress:Any?) ->()) {
        
        upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(video, withName: "file", fileName: "video.mp4", mimeType: "video/mp4")
            
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: HTTPMethod.post, headers: nil) { (encodingResult) in
            switch encodingResult {
                
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                //获取上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility), closure: { (progress) in
                    print(progress)
                    progressComplete(progress)
                })
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                        
                    case .success(let value):
                        let json = JSON(value)
                        successBlock(json)
                        print(json)
                    case .failure(let error):
                        print(error)
                    }
                })
                
            case .failure(let error):
                failure(error)
            }
        }
        
    }
    
}

extension NetworkTools {
    
    /// 请求AccessToken
    func loadAccessToken(_ code: String, finished: @escaping(_ dict: [String:Any]?, _ error: Error?) -> ()) {
        // 1.获取请求的URLString
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        let parameters = ["client_id" : app_key, "client_secret" : app_secret, "grant_type" : "authorization_code", "redirect_uri" : redirect_uri, "code" : code]
        
        request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            guard response.result.isSuccess else {
                finished(nil,response.error!)
                return
            }
//            print(response)
            if let json = response.result.value {
                let resultDict = json as! Dictionary<String,AnyObject> 
//                    print("------\(resultDict)")
                finished(resultDict,nil)  
            }
        }
    }
    
    // MARK:- 请求用户的信息
    ///请求用户的信息
    func loadUserInfo(_ access_token: String, uid: String,  finished: @escaping(_ result: [String: Any]?, _ error: Error?) -> ()) {
        let urlString = "https://api.weibo.com/2/users/show.json"
        let parameters = ["access_token" : access_token, "uid" : uid]
        request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
//            print(response)
            guard response.result.isSuccess else {
                finished(nil,response.error)
                return
            }
            if let json = response.result.value {
                let userDic = json as! Dictionary<String,AnyObject>
                finished(userDic,nil)
                
            }
        }
    }
    
    
}
