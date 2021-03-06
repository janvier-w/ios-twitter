//
//  TwitterClient.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let TwitterBaseURL = URL(string: "https://api.twitter.com")
let TwitterConsumerKey = "nCjUCjTEVtt2Si7qGgptGyK00"
let TwitterConsumerSecret = "u921ZTv1aFyHs64KJ4G5lUAWAJyFHvKOj8eGjGrVZAL4B31xqk"

class TwitterClient: BDBOAuth1SessionManager {
  static let sharedInstance = TwitterClient(baseURL: TwitterBaseURL,
      consumerKey: TwitterConsumerKey, consumerSecret: TwitterConsumerSecret)

  var loginSuccess: (() -> Void)?
  var loginFailure: ((Error) -> Void)?

  func login(success: @escaping (() -> Void),
      failure: @escaping ((Error) -> Void)) {
    loginSuccess = success
    loginFailure = failure

    deauthorize()
    fetchRequestToken(withPath: "oauth/request_token", method: "POST",
        callbackURL: URL(string: "jw-twitter://oauth"), scope: nil,
        success: { (requestToken: BDBOAuth1Credential?) in
          if let authToken = requestToken?.token {
            if let authURL = URL(
                string: "oauth/authorize?oauth_token=\(authToken)",
                relativeTo: TwitterBaseURL) {
              UIApplication.shared.open(authURL, options: [:],
                  completionHandler: nil)
            }
          }
        }, failure: { (error: Error!) in
          failure(error)
        })
  }

  func handleOpenURL(url: URL) {
    let requestToken = BDBOAuth1Credential(queryString: url.query)

    fetchAccessToken(withPath: "oauth/access_token", method: "POST",
        requestToken: requestToken,
        success: { (accessToken: BDBOAuth1Credential?) in
          self.currentAccount(success: { (user: User) in
            User.currentUser = user
            self.loginSuccess?()
          }, failure: { (error: Error) in
            self.loginFailure?(error)
          })
        }, failure: { (error: Error!) in
          self.loginFailure?(error)
        })
  }
  
  func logout() {
    User.currentUser = nil
    deauthorize()
    
    NotificationCenter.default.post(name: User.UserDidLogoutNotificationName,
        object: nil)
  }

  func currentAccount(success: @escaping (User) -> Void,
      failure: @escaping (Error) -> Void) {
    get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
        success: { (task: URLSessionDataTask, response: Any?) in
          let user = User(dictionary: response as! [String : Any])
          success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
          failure(error)
        })
  }

  func homeTimeline(maxId: Int?, sinceId: Int?,
      success: @escaping ([Tweet]) -> Void,
      failure: @escaping (Error) -> Void) {
    var parameters = [String : String]()
    if let maxId = maxId {
      parameters["max_id"] = "\(maxId)"
    }
    if let sinceId = sinceId {
      parameters["since_id"] = "\(sinceId)"
    }

    get("1.1/statuses/home_timeline.json",
        parameters: parameters, progress: nil,
        success: { (task: URLSessionDataTask, response: Any?) in
          let tweets = Tweet.createTweets(
              dictionaries: response as! [[String : Any]])
          success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
          failure(error)
        })
  }

  func userTimeline(userId: Int, maxId: Int?,
      success: @escaping ([Tweet]) -> Void,
      failure: @escaping (Error) -> Void) {
    var parameters: [String : String] = ["user_id" : "\(userId)"]
    if let maxId = maxId {
      parameters["max_id"] = "\(maxId)"
    }

    get("1.1/statuses/user_timeline.json",
        parameters: parameters, progress: nil,
        success: { (task: URLSessionDataTask, response: Any?) in
          let tweets = Tweet.createTweets(
              dictionaries: response as! [[String : Any]])
          success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
          failure(error)
        })
  }

  func mentionsTimeline(maxId: Int?, sinceId: Int?,
      success: @escaping ([Tweet]) -> Void,
      failure: @escaping (Error) -> Void) {
    var parameters = [String : String]()
    if let maxId = maxId {
      parameters["max_id"] = "\(maxId)"
    }
    if let sinceId = sinceId {
      parameters["since_id"] = "\(sinceId)"
    }

    get("1.1/statuses/mentions_timeline.json",
        parameters: parameters, progress: nil,
        success: { (task: URLSessionDataTask, response: Any?) in
          let tweets = Tweet.createTweets(
              dictionaries: response as! [[String : Any]])
          success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
          failure(error)
        })
  }

  func postTweet(_ content: String, inReplyToStatusId statusId: Int?,
      success: @escaping (Tweet) -> Void,
      failure: @escaping (Error) -> Void) {
    /*
    if let escapedContent = content.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed) {
    */
      var parameters: [String : Any] = ["status" : content]
      if let id = statusId {
        parameters["in_reply_to_status_id"] = id
      }

      post("1.1/statuses/update.json",
          parameters: parameters, progress: nil,
          success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! [String : Any])
            success(tweet)
          }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
          })
    /*
    }
    */
  }

  func repostTweet(_ id: Int, success: @escaping (Tweet) -> Void,
      failure: @escaping (Error) -> Void) {
      post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil,
          success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! [String : Any])
            success(tweet)
          }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
          })
  }

  func favoriteTweet(_ id: Int, success: @escaping (Tweet) -> Void,
      failure: @escaping (Error) -> Void) {
      let parameters = ["id" : id]

      post("1.1/favorites/create.json",
          parameters: parameters, progress: nil,
          success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! [String : Any])
            success(tweet)
          }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
          })
  }
}
