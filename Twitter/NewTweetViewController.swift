//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/13/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import AFNetworking

@objc protocol NewTweetViewControllerDelegate {
  @objc optional func newTweetViewController(
      _ newTweetViewController: NewTweetViewController,
      didPostTweet tweet: Tweet)
}

class NewTweetViewController: UIViewController {
  @IBOutlet weak var numRemainingCharsItem: UIBarButtonItem!
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var replyToIndicatorLabel: UILabel!
  @IBOutlet weak var replyToUserScreenNameLabel: UILabel!
  @IBOutlet weak var tweetContentText: UITextView!
  @IBOutlet weak var tweetContentTextTopConstraint: NSLayoutConstraint!

  weak var delegate: NewTweetViewControllerDelegate?

  let user = User.currentUser!
  var replyToTweet: Tweet?

  override func viewDidLoad() {
    super.viewDidLoad()

    let numRemainingChars = Tweet.MaxTextLength -
        Int(tweetContentText.text.characters.count)
    numRemainingCharsItem.title = "\(numRemainingChars)"

    if let url = user.profileImageURL {
      userProfileImageView.setImageWith(url)
      userProfileImageView.clipsToBounds = true
      userProfileImageView.layer.cornerRadius = 3
    }

    userNameLabel.text = user.name
    userScreenNameLabel.text = "@\(user.screenName!)"

    if let tweet = replyToTweet {
      if tweet.retweetUser != nil &&
         tweet.retweetUser!.screenName != User.currentUser!.screenName {
        replyToUserScreenNameLabel.text =
            "@\(tweet.user.screenName!) and @\(tweet.retweetUser!.screenName!)"
      } else {
        replyToUserScreenNameLabel.text = "@\(tweet.user.screenName!)"
      }
      replyToIndicatorLabel.isHidden = false
      replyToUserScreenNameLabel.isHidden = false
      tweetContentTextTopConstraint.constant = 8
    } else {
      replyToIndicatorLabel.isHidden = true
      replyToUserScreenNameLabel.isHidden = true
      tweetContentTextTopConstraint.constant = -23
    }

    tweetContentText.delegate = self
  }

  @IBAction func cancelTweet(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func postTweet(_ sender: Any) {
    if var tweetText = tweetContentText.text {
      if let tweet = replyToTweet {
        if tweet.retweetUser != nil &&
           tweet.retweetUser!.screenName != User.currentUser!.screenName {
          tweetText =
              "@\(tweet.user.screenName!) @\(tweet.retweetUser!.screenName!) " +
              tweetText
        } else {
          tweetText =
              "@\(tweet.user.screenName!) " +
              tweetText
        }
      }

      TwitterClient.sharedInstance?.postTweet(tweetText,
          inReplyToStatusId: replyToTweet?.id,
          success: { (tweet: Tweet) in
            self.dismiss(animated: true, completion: nil)
            self.delegate?.newTweetViewController?(self, didPostTweet: tweet)
          }, failure: { (error: Error) in
            print("ERROR: \(error.localizedDescription)")
          })
    }
  }
}

extension NewTweetViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    let numRemainingChars = Tweet.MaxTextLength -
        Int(tweetContentText.text.characters.count)
    numRemainingCharsItem.title = "\(numRemainingChars)"
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
      replacementText text: String) -> Bool {
    /* Limit number of characters that can be entered in text view, which takes
     * into account for the user cutting/deleting text and selecting text
     * followed by pasting shorter or longer text
     */
    return Int(tweetContentText.text.characters.count) - range.length +
        text.characters.count <= Tweet.MaxTextLength
  }
}
