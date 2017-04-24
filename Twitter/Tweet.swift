//
//  Tweet.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  static let MaxTextLength = 140

  class func createTweets(dictionaries: [[String : Any]]) -> [Tweet] {
    var tweets = [Tweet]()

    for dictionary in dictionaries {
      /*
      for (key, val) in dictionary {
        print("[\(key)]: [\(val)]")
      }
      print(" ")
      */
      let tweet = Tweet(dictionary: dictionary)
      tweets.append(tweet)
    }

    return tweets
  }

  var retweetUser: User?
  var user: User!
  var id: Int!
  var creationTime: Date?
  var text: String?
  var retweetCount: Int = 0
  var isRetweeted: Bool = false
  var favoriteCount: Int = 0
  var isFavorited: Bool = false

  init(dictionary: [String : Any]) {
    if let tmpDictionary = dictionary["retweeted_status"] as? [String : Any] {
      retweetUser = User(dictionary: dictionary["user"] as! [String : Any])

      user = User(dictionary: tmpDictionary["user"] as! [String : Any])

      id = tmpDictionary["id"] as! Int

      /* Example: Wed Sep 05 00:37:15 +0000 2012 */
      if let creationTimeString = tmpDictionary["created_at"] as? String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        creationTime = dateFormatter.date(from: creationTimeString)
      }

      text = tmpDictionary["text"] as? String
      retweetCount = (tmpDictionary["retweet_count"] as? Int) ?? 0
      isRetweeted = (tmpDictionary["retweeted"] as? Bool) ?? false
      favoriteCount = (tmpDictionary["favorite_count"] as? Int) ?? 0
      isFavorited = (tmpDictionary["favorited"] as? Bool) ?? false
    } else {
      user = User(dictionary: dictionary["user"] as! [String : Any])

      id = dictionary["id"] as! Int

      /* Example: Wed Sep 05 00:37:15 +0000 2012 */
      if let creationTimeString = dictionary["created_at"] as? String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        creationTime = dateFormatter.date(from: creationTimeString)
      }

      text = dictionary["text"] as? String
      retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
      isRetweeted = (dictionary["retweeted"] as? Bool) ?? false
      favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
      isFavorited = (dictionary["favorited"] as? Bool) ?? false
    }
  }
}
