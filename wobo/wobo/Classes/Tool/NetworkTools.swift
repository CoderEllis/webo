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
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
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
                let resultDict = json as! Dictionary<String,Any> 
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
                let userDic = json as! Dictionary<String,Any>
                finished(userDic,nil)
                
            }
        }
    }
    
    
    // MARK:- 请求首页数据
    ///请求首页数据
    func loadStatuses(_ since_id: Int, _ max_id: Int, finished: @escaping(_ result: [[String: Any]]?, _ error: Error?) -> ()) {
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json?"
        // 2.获取请求的参数  since_id 包装成字符串
        let access_token = (UserAccountViewModel.shareIntance.account?.access_token)!
        let parameters = ["access_token": access_token, "since_id": "\(since_id)", "max_id": "\(max_id)"]
        request(urlString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard response.result.isSuccess else {
                finished(nil,response.error)
                return
            }
//            print(response)
            if let value = response.result.value {
                let json = JSON(value)
                if let data = json.dictionaryObject {
                    finished(data["statuses"] as? Array<[String: Any]>,nil) //== [[String: Any]]
                } else {
                    print("失败")
                }
            }
        }  
    }
    
    ///发送微博
    func sendStatus(_ statusText: String, isSuccess: @escaping (_ isSuccess: Bool) -> ()) {
        let urlString = "https://api.weibo.com/2/statuses/update.json"
        let access_token = (UserAccountViewModel.shareIntance.account?.access_token)!
        let parameters = ["access_token": access_token, "status": statusText]
        request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            guard response.result.isSuccess else {
                isSuccess(false)
                return
            }
            isSuccess(true)
        }
    }
    
    ///发送微博并且携带照片
    func sendStatus(_ statusText: String, image: UIImage, isSuccess: @escaping (_ isSuccess: Bool) -> ()) {
        let urlString = "https://api.weibo.com/2/statuses/upload.json"
        let parameters = ["access_token" : (UserAccountViewModel.shareIntance.account?.access_token)!, "status": statusText]
        
        upload(multipartFormData: { (formData) in
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                formData.append(imageData, withName: "appPhoto", fileName: "img.png", mimeType: "image/png")
            }
            
            for (key, value) in parameters {
                formData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: urlString, method: .post, headers: nil) { (result) in
            switch result {
            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility), closure: { (progress) in
                    print(progress)
                })
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(_):    
                        isSuccess(true)
                    case .failure(_):
                        isSuccess(false)
                    }
                })
            case .failure(_):
                isSuccess(false) 
            }
            }
    }
    
    
//    if let json = response.result.value {
//        let data = json as! Dictionary<String,Any>
//        
//        finished(data["statuses"]as? [[String: Any]],nil)
//    }
    
    /*
     class NetWorkTool{
     class func requestData(type : MethodType,url : String , parameters : Parameters? = nil , finishCallback : @escaping ( _ respont : AnyObject)->() ){
     let temp = type == .GET ? HTTPMethod.get : HTTPMethod.post
     Alamofire.request(url, method : temp, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON {
     (response) in
     guard response.result.value != nil else{
     mPrint(pl: response.error!)
     return
     }
     finishCallback(response.value as AnyObject)
     }
     }
     
     class func requestData(type : MethodType,url : String , parameters : Parameters? = nil ,headers : [String: String]? = nil, finishCallback : @escaping ( _ respont : AnyObject)->() ){
     let temp = type == .GET ? HTTPMethod.get : HTTPMethod.post
     Alamofire.request(url, method: temp, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON {
     (response) in
     guard response.result.value != nil else{
     mPrint(pl:"————————————————————————————请求失败\(response.error!)————————————————————————")
     return
     }
     finishCallback(response.value as AnyObject)
     }
     }
     /*短信验证码*/
     class func smsRequest(phone :String,templateId : String) -> String{
     //随机数
     var random :[String] = ["\(Int(arc4random_uniform(899999) + 100000))"]
     //用户id
     let sid = "8a216da85b8e6bb1015ba87e9e470808"
     //令牌
     let token = "117c29456e24416da39b225be6e223aa"
     //当前时间
     let nowTime = MyTools.dateNow
     //sig参数 md5加密 字符串大写
     let sig = "\(sid)\(token)\(MyTools.timeToFormate(time: nowTime,state: 2))".md5().uppercased()
     let smsHeadRequestURL = "/2013-12-26/Accounts/\(sid)/SMS/TemplateSMS?sig=\(sig)"
     //请求地址
     //        let smsURL = "https://app.cloopen.com:8883"+"\(smsHeadRequestURL)"
     let smsURL = "http://sytest.canta.com.cn/index.php/jkindex/testsms"
     let auth = MyTools.base64Encoding(plainString:  ("\(sid)"+":"+"\(MyTools.timeToFormate(time: nowTime, state: 2))"))
     
     //请求头
     let head : [String : String] = ["Accept":"application/json","Content-Type":"application/json;charset=utf-8","content-length":"300","Authorization":"\(auth)"]
     //请求体{"appId":"8a216da85b8e6bb1015ba87e9e470808","datas":["11111","222"],"templateId":"236875","to":"17702404552"}
     let body : [String : Any] = ["appId":"\(sid)","datas": "\(random)","templateId":"\(templateId)","to":"\(phone)"]
     requestData(type: .POST, url: smsURL, parameters: body,headers: head) { ( response) in
     let json = JSON(response)
     mPrint(pl:json)
     //status:200
     guard let status = json["statusCode"].string else{
     mPrint(pl: "null")
     return
     }
     guard status == "000000" else{
     mPrint(pl: status)
     return
     }
     guard let smsMessageSid = json["smsMessageSid"].string else {
     return
     }
     guard smsMessageSid == "236875" else{
     mPrint(pl: "模板不对")
     return
     }
     mPrint(pl: "成功")
     }
     return random[0]
     }
     }
     
     */
}
