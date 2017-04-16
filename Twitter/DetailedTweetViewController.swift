//
//  DetailedTweetViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/13/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import AFNetworking

class DetailedTweetViewController: UIViewController {
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var textContentLabel: UILabel!
  @IBOutlet weak var creationTimeLabel: UILabel!
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var favoriteCountLabel: UILabel!
  
  var tweet: Tweet!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    userProfileImageView.setImageWith(tweet.user.profileImageURL!)
    userProfileImageView.clipsToBounds = true
    userProfileImageView.layer.cornerRadius = 3

    userNameLabel.text = tweet.user.name
    userScreenNameLabel.text = "@\(tweet.user.screenName!)"
    textContentLabel.text = tweet.text

    /* Example: 12/1/17 00:30 AM */
    if let creationTime = tweet.creationTime {
      let dateFormatter = DateFormatter()
      dateFormatter.setLocalizedDateFormatFromTemplate("M/d/yy KK:mm a")
      creationTimeLabel.text = dateFormatter.string(from: creationTime)
    }

    retweetCountLabel.text = "\(tweet.retweetCount)"
    favoriteCountLabel.text = "\(tweet.favoriteCount)"
  }

  @IBAction func replyTweet(_ sender: Any) {
  }

  @IBAction func repostTweet(_ sender: Any) {
    TwitterClient.sharedInstance?.repostTweet(tweet.id,
        success: { (tweet: Tweet) in
          self.tweet = tweet
          self.retweetCountLabel.text = "\(tweet.retweetCount)"
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }

  @IBAction func favoriteTweet(_ sender: Any) {
    TwitterClient.sharedInstance?.favoriteTweet(tweet.id,
        success: { (tweet: Tweet) in
          self.tweet = tweet
          self.favoriteCountLabel.text = "\(tweet.favoriteCount)"
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }
}
