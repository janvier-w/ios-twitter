//
//  DetailedTweetViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/13/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

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
      userNameLabel.text = tweet.user.name
      userScreenNameLabel.text = "@\(tweet.user.screenName!)"
      textContentLabel.text = tweet.text

      if let creationTime = tweet.creationTime {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy KK:mm a")
        creationTimeLabel.text = dateFormatter.string(from: creationTime)
      }

      retweetCountLabel.text = "\(tweet.retweetCount)"
      favoriteCountLabel.text = "\(tweet.favoriteCount)"
    
    userProfileImageView.clipsToBounds = true
    userProfileImageView.layer.cornerRadius = 3
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
