//
//  Tweet.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class Tweet: NSObject {
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
    if let creationTimeString = dictionary["created_at"] as? String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
      creationTime = dateFormatter.date(from: creationTimeString)
    }
    text = dictionary["text"] as? String
    retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
    favoriteCount = (dictionary["favourites_count"] as? Int) ?? 0
  }
}
