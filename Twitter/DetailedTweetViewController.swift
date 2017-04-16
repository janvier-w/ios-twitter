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
  @IBOutlet weak var retweetIndicatorLabel: UILabel!
  @IBOutlet weak var retweetUserNameLabel: UILabel!
  @IBOutlet weak var userProfileImageViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var textContentLabel: UILabel!
  @IBOutlet weak var creationTimeLabel: UILabel!
  @IBOutlet weak var retweetCountLabel: UILabel!
  @IBOutlet weak var favoriteCountLabel: UILabel!
  @IBOutlet weak var replyButton: UIButton!
  @IBOutlet weak var repostButton: UIButton!
  @IBOutlet weak var favoriteButton: UIButton!
  
  var tweet: Tweet!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if let retweetUser = tweet.retweetUser {
      retweetIndicatorLabel.isHidden = false
      retweetUserNameLabel.text = "\(retweetUser.name!) Retweeted"
      retweetUserNameLabel.isHidden = false
      userProfileImageViewTopConstraint.constant = 6
    } else {
      retweetIndicatorLabel.isHidden = true
      retweetUserNameLabel.isHidden = true
      userProfileImageViewTopConstraint.constant = -10
    }

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

    if tweet.isRetweeted {
      repostButton.setTitleColor(
          UIColor.init(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0),
          for: .normal)
    }
    if tweet.isFavorited {
      favoriteButton.setTitleColor(.red, for: .normal)
    }
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
