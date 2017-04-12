//
//  User.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class User: NSObject {
  var name: String?
  var screenName: String?
  var tagline: String?
  var profileImageURL: URL?

  init(dictionary: [String : Any]) {
    name = dictionary["name"] as? String
    screenName = dictionary["screen_name"] as? String
    tagline = dictionary["description"] as? String
    if let profileImageURLString = dictionary["profile_image_url_https"] as? String {
      profileImageURL = URL(string: profileImageURLString)
    }
  }
}
