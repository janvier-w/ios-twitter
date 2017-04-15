//
//  Tweet.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class Tweet: NSObject {
  var id: Int!
  var user: User!
  var creationTime: Date?
  var text: String?
  var retweetCount: Int = 0
  var favoriteCount: Int = 0

  class func createTweets(dictionaries: [[String : Any]]) -> [Tweet] {
    var tweets = [Tweet]()

    for dictionary in dictionaries {
      let tweet = Tweet(dictionary: dictionary)
      tweets.append(tweet)
    }

    return tweets
  }

  init(dictionary: [String : Any]) {
    id = dictionary["id"] as! Int

    user = User(dictionary: dictionary["user"] as! [String : Any])

    /* Example: Wed Sep 05 00:37:15 +0000 2012 */
    if let creationTimeString = dictionary["created_at"] as? String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
      creationTime = dateFormatter.date(from: creationTimeString)
    }

    text = dictionary["text"] as? String
    retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
    favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
  }
}
