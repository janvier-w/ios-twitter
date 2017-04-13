//
//  TweetCell.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/13/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var creationTimeLabel: UILabel!
  @IBOutlet weak var textContentLabel: UILabel!

  var tweet: Tweet! {
    didSet {
      userProfileImageView.setImageWith(tweet.user.profileImageURL!)
      userNameLabel.text = tweet.user.name
      userScreenNameLabel.text = "@\(tweet.user.screenName!)"
      textContentLabel.text = tweet.text

      if let creationTime = tweet.creationTime {
        if creationTime.timeIntervalSinceNow < -60 {
          let timeInterval = Int(round(
              creationTime.timeIntervalSinceNow / -60))
          creationTimeLabel.text = "\(timeInterval)m"
        } else if creationTime.timeIntervalSinceNow < -3600 {
          let timeInterval = Int(round(
              creationTime.timeIntervalSinceNow / -3600))
          creationTimeLabel.text = "\(timeInterval)h"
        } else {
          let dateFormatter = DateFormatter()
          dateFormatter.locale = Locale(identifier: "en_US")
          dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yy")
          creationTimeLabel.text = dateFormatter.string(from: creationTime)
        }
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

    userProfileImageView.clipsToBounds = true
    userProfileImageView.layer.cornerRadius = 3
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
}
