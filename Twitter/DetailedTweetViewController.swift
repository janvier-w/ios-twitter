//
//  DetailedTweetViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/13/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol DetailedTweetViewControllerDelegate {
  @objc optional func detailedTweetViewController(
      _ detailedTweetViewController: DetailedTweetViewController,
      didUpdateTweet tweet: Tweet)

  @objc optional func detailedTweetViewController(
      _ detailedTweetViewController: DetailedTweetViewController,
      didPostReplyTweet tweet: Tweet)
}

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

  weak var delegate: DetailedTweetViewControllerDelegate?
  
  var tweet: Tweet!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    updateView()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier != nil {
      if segue.identifier == "ReplyToTweetSegue" {
        let navigationController = segue.destination as! UINavigationController
        let viewController = navigationController.topViewController as!
            NewTweetViewController
        viewController.delegate = self
        viewController.replyToTweet = tweet
      }
    }
  }

  func updateView() {
    if tweet.retweetUser != nil &&
       tweet.retweetUser!.screenName != User.currentUser!.screenName {
      retweetIndicatorLabel.isHidden = false
      retweetUserNameLabel.text = "\(tweet.retweetUser!.name!) Retweeted"
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
    } else {
      repostButton.setTitleColor(.lightGray, for: .normal)
    }
    if tweet.isFavorited {
      favoriteButton.setTitleColor(.red, for: .normal)
    } else {
      favoriteButton.setTitleColor(.lightGray, for: .normal)
    }
  }

  @IBAction func repostTweet(_ sender: Any) {
    TwitterClient.sharedInstance?.repostTweet(tweet.id,
        success: { (tweet: Tweet) in
          self.tweet = tweet
          self.updateView()
          self.delegate?.detailedTweetViewController?(self,
              didUpdateTweet: tweet)
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }

  @IBAction func favoriteTweet(_ sender: Any) {
    TwitterClient.sharedInstance?.favoriteTweet(tweet.id,
        success: { (tweet: Tweet) in
          self.tweet = tweet
          self.updateView()
          self.delegate?.detailedTweetViewController?(self,
              didUpdateTweet: tweet)
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }
}

extension DetailedTweetViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController,
      didPostTweet tweet: Tweet) {
    delegate?.detailedTweetViewController?(self, didPostReplyTweet: tweet)
  }
}
