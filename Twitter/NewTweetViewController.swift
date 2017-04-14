//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/13/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import AFNetworking

class NewTweetViewController: UIViewController {
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var tweetContentText: UITextView!

  let user = User.currentUser!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let url = user.profileImageURL {
      userProfileImageView.setImageWith(url)
      userProfileImageView.clipsToBounds = true
      userProfileImageView.layer.cornerRadius = 3
    }

    userNameLabel.text = user.name
    userScreenNameLabel.text = "@\(user.screenName!)"
  }

  @IBAction func cancelTweet(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func postTweet(_ sender: Any) {
    TwitterClient.sharedInstance?.postTweet(tweetContentText.text,
        success: { (tweet: Tweet) in
          self.dismiss(animated: true, completion: nil)
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }
}
