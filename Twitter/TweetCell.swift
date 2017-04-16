//
//  TweetCell.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/13/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol TweetCellDelegate {
  @objc optional func tweetCell(_ tweetCell: TweetCell,
      didUpdateTweet tweet: Tweet)
}

class TweetCell: UITableViewCell {
  @IBOutlet weak var retweetIndicatorLabel: UILabel!
  @IBOutlet weak var retweetUserNameLabel: UILabel!
  @IBOutlet weak var userProfileImageTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var creationTimeLabel: UILabel!
  @IBOutlet weak var textContentLabel: UILabel!
  @IBOutlet weak var replyButton: UIButton!
  @IBOutlet weak var repostButton: UIButton!
  @IBOutlet weak var repostCountLabel: UILabel!
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var favoriteCountLabel: UILabel!

  weak var delegate: TweetCellDelegate?

  var tweet: Tweet! {
    didSet {
      if let retweetUser = tweet.retweetUser {
        retweetIndicatorLabel.isHidden = false
        retweetUserNameLabel.text = "\(retweetUser.name!) Retweeted"
        retweetUserNameLabel.isHidden = false
        userProfileImageTopConstraint.constant = 6
      } else {
        retweetIndicatorLabel.isHidden = true
        retweetUserNameLabel.isHidden = true
        userProfileImageTopConstraint.constant = -10
      }

      userProfileImageView.setImageWith(tweet.user.profileImageURL!)
      userNameLabel.text = tweet.user.name
      userScreenNameLabel.text = "@\(tweet.user.screenName!)"
      textContentLabel.text = tweet.text

      if let creationTime = tweet.creationTime {
        var timeInterval = Int(-creationTime.timeIntervalSinceNow)
        if timeInterval >= 86400 {
          /* For tweets more than 1 day old. Example: 4/14/17. */
          let dateFormatter = DateFormatter()
          dateFormatter.setLocalizedDateFormatFromTemplate("M/d/yy")
          creationTimeLabel.text = dateFormatter.string(from: creationTime)
        } else if timeInterval >= 3600 {
          /* For tweets more than 1 hour old. Example: 9h. */
          timeInterval = Int(round(Double(timeInterval / 3600)))
          creationTimeLabel.text = "\(timeInterval)h"
        } else if timeInterval >= 60 {
          /* For tweets more than 1 minute old. Example: 9m. */
          timeInterval = Int(round(Double(timeInterval / 60)))
          creationTimeLabel.text = "\(timeInterval)m"
        } else {
          /* For tweets less than 1 minute old. Example: 9s. */
          creationTimeLabel.text = "\(timeInterval)s"
        }
      }

      if tweet.isRetweeted {
        repostButton.setTitleColor(
          UIColor.init(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0),
          for: .normal)
      }
      repostCountLabel.text = "\(tweet.retweetCount)"
      if tweet.isFavorited {
        favoriteButton.setTitleColor(.red, for: .normal)
      }
      favoriteCountLabel.text = "\(tweet.favoriteCount)"
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    userProfileImageView.clipsToBounds = true
    userProfileImageView.layer.cornerRadius = 3
  }

  @IBAction func replyTweet(_ sender: Any) {
    //TwitterClient.sharedInstance?.replyTweet(id: tweet.id)
  }

  @IBAction func repostTweet(_ sender: Any) {
    TwitterClient.sharedInstance?.repostTweet(tweet.id,
        success: { (tweet: Tweet) in
          self.tweet = tweet
          self.delegate?.tweetCell?(self, didUpdateTweet: tweet)
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }

  @IBAction func favoriteTweet(_ sender: Any) {
    TwitterClient.sharedInstance?.favoriteTweet(tweet.id,
        success: { (tweet: Tweet) in
          self.tweet = tweet
          self.delegate?.tweetCell?(self, didUpdateTweet: tweet)
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }
}
