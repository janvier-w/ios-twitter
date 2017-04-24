//
//  User.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class User: NSObject {
  static let UserDidLogoutNotificationName =
      NSNotification.Name(rawValue: "UserDidLogout")

  static var _currentUser: User?
  class var currentUser: User? {
    get {
      if _currentUser == nil {
        if let data = UserDefaults.standard.object(
            forKey: "currentUserData") as? Data {
          if let dictionary = try? JSONSerialization.jsonObject(
              with: data, options: []) as! [String : Any] {
            _currentUser = User(dictionary: dictionary)
          }
        }
      }
      return _currentUser
    }
    set(user) {
      _currentUser = user
      if let user = user {
        let data = try? JSONSerialization.data(
            withJSONObject: user.dict!, options: [])
        UserDefaults.standard.set(data, forKey: "currentUserData")
      } else {
        UserDefaults.standard.removeObject(forKey: "currentUserData")
      }
      UserDefaults.standard.synchronize()
    }
  }

  var dict: [String : Any]?
  var id: Int?
  var name: String?
  var screenName: String?
  var tagline: String?
  var bannerImageURL: URL?
  var profileImageURL: URL?
  var statusesCount: Int = 0
  var friendsCount: Int = 0
  var followersCount: Int = 0

  init(dictionary: [String : Any]) {
    dict = dictionary
    id = dictionary["id"] as? Int
    name = dictionary["name"] as? String
    screenName = dictionary["screen_name"] as? String
    tagline = dictionary["description"] as? String
    if let bannerImageURLString =
        dictionary["profile_banner_url"] as? String {
      bannerImageURL = URL(string: bannerImageURLString)
    }
    if let profileImageURLString =
        dictionary["profile_image_url_https"] as? String {
      profileImageURL = URL(string: profileImageURLString)
    }
    statusesCount = (dictionary["statuses_count"] as? Int) ?? 0
    friendsCount = (dictionary["friends_count"] as? Int) ?? 0
    followersCount = (dictionary["followers_count"] as? Int) ?? 0
  }
}
