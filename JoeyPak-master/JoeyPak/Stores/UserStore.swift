//
//  UserStore.swift
//  JoeyPak
//
//  Created by Rocco Del Priore on 9/19/17.
//  Copyright © 2017 Rocco Del Priore. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import ParticleExtensions

class UserStore {
    private static let accountDetailsEndpoint = "account_details"
    private static let userLookupEndpoint = "user_lookup"
    private static let fetchUserEndpoint = "user_lookup_uid"
    public static let authTokenKey = "auth_token"
    private static let balenceKey = "balance"
    private static let nameKey = "name"
    private static let pageKey = "page"
    private static let fbImageKey = "fb_img"
    private static let fbUIDKey = "fb_uid"
    private static let fbTokenKey = "fb_token"
    static let sharedInstance = UserStore()
    private let rootURL = URL(string: "http://13.56.210.36:3000/")
    private(set) public var currentUser: User?
    private(set) public var authToken: String?
    private(set) public var balence: Int = 0
    private var users = [String: User]()

    //MARK: Actions
    private func refreshCurrentJoeyUser(name: String, facebookId: String, facebookImage: String, success: @escaping (String, Int) -> Void, failure: @escaping (Error?) -> Void) {
        //Declare Variables
        guard var url = rootURL?.appendingWebComponent(component: UserStore.accountDetailsEndpoint) else {
                return
        }
        
        //Configure Parameters
        url.setParameters(parameters: [UserStore.nameKey: name, UserStore.fbImageKey: facebookImage, UserStore.fbUIDKey: facebookId, UserStore.fbTokenKey: FBSDKAccessToken.current().tokenString])
        
        //Configure Request
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 200)
        request.httpMethod = "GET"
        
        //Make Request
        let task = URLSession.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
            if data != nil {
                do {
                    let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! Dictionary<String, Any>
                    guard
                        let token = json[UserStore.authTokenKey] as? String,
                        let balence = json[UserStore.balenceKey] as? Int else {
                            failure(error)
                            return
                    }
                    
                    success(token, balence)
                } catch let error as NSError {
                    failure(error)
                }
            }
            else {
                failure(error)
            }
        }
        task.resume()
    }
    private func refreshCurrentFacebookUser(success: @escaping (String, String, URL) -> Void, failure: @escaping (Error?) -> Void?) {
        if (FBSDKAccessToken.current() != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let dictionary = result as? Dictionary<String, Any> {
                        //Parse Facebook Dictionary
                        let id: String = dictionary["id"] as! String
                        let name: String = dictionary["name"]! as! String
                        let pictureDictionary = dictionary["picture"] as! Dictionary<String, Dictionary<String, Any>>
                        let picture: String = pictureDictionary["data"]!["url"]! as! String
                        let pictureURL = URL(string: picture)!
                        
                        success(id, name, pictureURL)
                    }
                    else {
                        failure(error)
                    }
                }
                else {
                    failure(error)
                }
            })
        }
        else {
            failure(nil)
        }
    }
    public func refreshCurrentUser(completion: @escaping (User?) -> Void) {
        self.refreshCurrentFacebookUser(success: { (id, name, pictureURL) in
            self.refreshCurrentJoeyUser(name: name, facebookId: id, facebookImage: pictureURL.absoluteString, success: { (token, balence) in
                DispatchQueue.main.async {
                    self.authToken   = token
                    self.balence     = balence
                    self.currentUser = User(json: [User.uniqueIdKey: id, User.nameKey: name, User.imageURLKey: pictureURL as Any])
                    self.users[self.currentUser!.uniqueId] = self.currentUser
                    
                    completion(self.currentUser)
                }
            }, failure: { (error) in
                print("Failed to refresh Joey User", error)
            })
        }, failure: { (error) in
            print("Failed to refresh Facebook User", error)
        })
    }
    
    //MARK: Accessors
    public func searchForUsers(searchString: String, page: Int, success: @escaping ([User]) -> Void, failure: @escaping (Error?) -> Void?) {
        //Declare Variables
        guard
            var url = rootURL?.appendingWebComponent(component: UserStore.userLookupEndpoint),
            let authToken = self.authToken else {
                return
        }
        
        //Configure Parameters
        url.setParameters(parameters: [UserStore.authTokenKey: authToken, UserStore.nameKey: searchString, UserStore.pageKey: String.init(format: "%i", page)])
        
        //Configure Request
        let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 200)
        request.httpMethod = "GET"
        
        //Make Request
        let task = URLSession.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
            if data != nil {
                do {
                    let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! Array<Dictionary<String, Any>>
                    var users = [User]()
                    for dictionary in json {
                        if let user = User(json: dictionary) {
                            if user != self.currentUser {
                                users.append(user)
                            }
                        }
                    }
                    success(users)
                } catch let error as NSError {
                    failure(error)
                }
            }
            else {
                failure(error)
            }
        }
        task.resume()
    }
    public func fetchUser(uniqueId: String, completion: @escaping (User) -> Void) {
        if (users.keys.contains(uniqueId)) {
            completion(users[uniqueId]!)
        }
        else {
            //Declare Variables
            guard
                var url = rootURL?.appendingWebComponent(component: UserStore.fetchUserEndpoint),
                let authToken = self.authToken else {
                    return
            }
            
            //Configure Parameters
            url.setParameters(parameters: [UserStore.fbUIDKey: uniqueId, UserStore.authTokenKey: authToken, UserStore.pageKey: "0"])
            
            //Configure Request
            let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 200)
            request.httpMethod = "GET"
            
            //Make Request
            let task = URLSession.defaultSession.dataTask(with: request as URLRequest) { (data, response, error) in
                if data != nil {
                    do {
                        let json  = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! Dictionary<String, Any>
                        if let user = User(json: json) {
                            self.users[user.uniqueId] = user
                            completion(user)
                        }
                    } catch let error as NSError {
                        print("fetchUser received invalid response.")
                    }
                }
            }
            task.resume()
        }
    }
}
