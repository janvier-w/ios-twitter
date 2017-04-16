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
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var creationTimeLabel: UILabel!
  @IBOutlet weak var textContentLabel: UILabel!

  weak var delegate: TweetCellDelegate?

  var tweet: Tweet! {
    didSet {
      userProfileImageView.setImageWith(tweet.user.profileImageURL!)
      userNameLabel.text = tweet.user.name
      userScreenNameLabel.text = "@\(tweet.user.screenName!)"
      textContentLabel.text = tweet.text

      if let creationTime = tweet.creationTime {
        if creationTime.timeIntervalSinceNow < -86400 {
          /* For tweets more than 1 day old. Example: 4/14/17. */
          let dateFormatter = DateFormatter()
          dateFormatter.setLocalizedDateFormatFromTemplate("M/d/yy")
          creationTimeLabel.text = dateFormatter.string(from: creationTime)
        } else if creationTime.timeIntervalSinceNow < -3600 {
          /* For tweets more than 1 hour old. Example: 9h. */
          let timeInterval = Int(round(
              creationTime.timeIntervalSinceNow / -3600))
          creationTimeLabel.text = "\(timeInterval)h"
        } else if creationTime.timeIntervalSinceNow < -60 {
          /* For tweets more than 1 minute old. Example: 9m. */
          let timeInterval = Int(round(
              creationTime.timeIntervalSinceNow / -60))
          creationTimeLabel.text = "\(timeInterval)m"
        } else {
          /* For tweets less than 1 minute old. Example: 9s. */
          let timeInterval = Int(-creationTime.timeIntervalSinceNow)
          creationTimeLabel.text = "\(timeInterval)s"
        }
      }
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
