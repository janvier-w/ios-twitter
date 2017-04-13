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
          self.loginSuccess?()
        }, failure: { (error: Error!) in
          self.loginFailure?(error)
        })
  }

  func userAccount(success: @escaping (User) -> Void,
      failure: @escaping (Error) -> Void) {
    get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
        success: { (task: URLSessionDataTask, response: Any?) in
          let user = User(dictionary: response as! [String : Any])
          success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
          failure(error)
        })
  }

  func homeTimeline(success: @escaping ([Tweet]) -> Void,
      failure: @escaping (Error) -> Void) {
    get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil,
        success: { (task: URLSessionDataTask, response: Any?) in
          let tweets = Tweet.createTweets(
              dictionaries: response as! [[String : Any]])
          success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
          failure(error)
        })
  }
}
