//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/22/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  @IBOutlet weak var userBannerImageView: UIImageView!
  @IBOutlet weak var userProfileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreenNameLabel: UILabel!
  @IBOutlet weak var statusesCountLabel: UILabel!
  @IBOutlet weak var friendsCountLabel: UILabel!
  @IBOutlet weak var followersCountLabel: UILabel!
  @IBOutlet weak var tweetsTableView: UITableView!

  var user: User!
  var tweets: [Tweet]!

  var isRequestingMoreData = false
  var requestingMoreDataIndicator: ActivityIndicatorView?

  override func viewDidLoad() {
    super.viewDidLoad()

    let nib = UINib(nibName: "TweetCell", bundle: nil)
    tweetsTableView.register(nib, forCellReuseIdentifier: "TweetCell")

    tweetsTableView.dataSource = self
    tweetsTableView.delegate = self
    tweetsTableView.rowHeight = UITableViewAutomaticDimension
    tweetsTableView.estimatedRowHeight = 98

    if user == nil {
      user = User.currentUser
    }

    title = user.name

    if let url = user.bannerImageURL {
      userBannerImageView.setImageWith(url)
    }

    if let url = user.profileImageURL {
      userProfileImageView.setImageWith(url)
      userProfileImageView.clipsToBounds = true
      userProfileImageView.layer.cornerRadius = 3
    }

    userNameLabel.text = user.name
    userScreenNameLabel.text = "@\(user.screenName!)"
    statusesCountLabel.text = "\(user.statusesCount)"
    friendsCountLabel.text = "\(user.friendsCount)"
    followersCountLabel.text = "\(user.followersCount)"

    /* Allow pull to refresh */
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshTimeline(_:)),
        for: .valueChanged)
    tweetsTableView.insertSubview(refreshControl, at: 0)

    /* Set up activity indicator for requesting more data */
    let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height,
        width: tweetsTableView.bounds.size.width,
        height: ActivityIndicatorView.defaultHeight)
    requestingMoreDataIndicator = ActivityIndicatorView(frame: frame)
    requestingMoreDataIndicator!.isHidden = true
    tweetsTableView.addSubview(requestingMoreDataIndicator!)

    var inset = tweetsTableView.contentInset
    inset.bottom += ActivityIndicatorView.defaultHeight
    tweetsTableView.contentInset = inset

    refreshTimeline(refreshControl)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier != nil {
      if segue.identifier == "DetailedTweetSegue" {
        let cell = sender as! UITableViewCell
        let indexPath = tweetsTableView.indexPath(for: cell)
        let viewController = segue.destination as! DetailedTweetViewController
        viewController.delegate = self
        viewController.tweet = tweets[indexPath!.row]
      } else if segue.identifier == "NewTweetSegue" {
        let navigationController = segue.destination as! UINavigationController
        let viewController = navigationController.topViewController as!
            NewTweetViewController
        viewController.delegate = self
      } else if segue.identifier == "ReplyToTweetSegue" {
        let replyToButton = sender as! UIButton
        let cell = replyToButton.superview!.superview as! UITableViewCell
        let indexPath = tweetsTableView.indexPath(for: cell)
        let navigationController = segue.destination as! UINavigationController
        let viewController = navigationController.topViewController as!
            NewTweetViewController
        viewController.delegate = self
        viewController.replyToTweet = tweets[indexPath!.row]
      }
    }
  }

  func refreshTimeline(_ refreshControl: UIRefreshControl) {
    TwitterClient.sharedInstance?.userTimeline(userId: user.id!, maxId: nil,
        success: { (tweets: [Tweet]) in
          self.tweets = tweets
          self.tweetsTableView.reloadData()
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
      -> Int {
    if tweets != nil {
      return tweets.count
    }
    return 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
      -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
        withIdentifier: "TweetCell", for: indexPath) as! TweetCell
    cell.delegate = self
    cell.tweet = tweets[indexPath.row]

    return cell
  }

  func tableView(_ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    performSegue(withIdentifier: "DetailedTweetSegue",
        sender: tableView.cellForRow(at: indexPath))
  }
}

extension ProfileViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if !isRequestingMoreData {
      /* Set threshold to one screen length before the bottom of the results */
      let scrollOffsetThreshold = tweetsTableView.contentSize.height -
          tweetsTableView.bounds.size.height

      /* Request for more data when the user has scrolled past the threshold */
      if scrollView.contentOffset.y > scrollOffsetThreshold &&
         tweetsTableView.isDragging {
        isRequestingMoreData = true

        /* Update position of activity indicator and start loading it */
        let frame = CGRect(x: 0, y: tweetsTableView.contentSize.height,
            width: tweetsTableView.bounds.size.width,
            height: ActivityIndicatorView.defaultHeight)
        requestingMoreDataIndicator!.frame = frame
        requestingMoreDataIndicator!.startAnimating()

        requestMoreData()
      }
    }
  }

  func requestMoreData() {
    var maxId: Int?
    if tweets != nil && tweets.count > 0 {
      /* Twitter suggestion to optimize requests specifiying 'max_id', which
       * prevents the server from returning one duplicate tweet
       */
      maxId = tweets.last!.id - 1
    }

    TwitterClient.sharedInstance?.userTimeline(userId: user.id!, maxId: maxId,
        success: { (tweets: [Tweet]) in
          if self.tweets == nil {
            self.tweets = tweets
          } else {
            for tweet in tweets {
              self.tweets.append(tweet)
            }
          }
          self.isRequestingMoreData = false
          self.requestingMoreDataIndicator!.stopAnimating()
          self.tweetsTableView.reloadData()
        }, failure: { (error: Error) in
          self.isRequestingMoreData = false
          self.requestingMoreDataIndicator!.stopAnimating()
          print("ERROR: \(error.localizedDescription)")
        })
  }
}

extension ProfileViewController: TweetCellDelegate {
  func tweetCell(_ tweetCell: TweetCell, didUpdateTweet tweet: Tweet) {
    if let indexPath = tweetsTableView.indexPath(for: tweetCell) {
      tweets[indexPath.row] = tweet
    }
  }

  func tweetCell(_ tweetCell: TweetCell, willShowUserProfile user: User) {
    if user.id != self.user.id {
      let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
      let profileViewController = storyboard.instantiateViewController(
          withIdentifier: "ProfileViewController") as! ProfileViewController

      profileViewController.user = user
      navigationController?.pushViewController(profileViewController,
          animated: true)
    }
  }
}

extension ProfileViewController: DetailedTweetViewControllerDelegate {
  func detailedTweetViewController(
      _ detailedTweetViewController: DetailedTweetViewController,
      didUpdateTweet tweet: Tweet) {
    if tweets != nil {
      for index in 0..<tweets.count {
        if tweets[index].id == tweet.id {
          tweets[index] = tweet
          tweetsTableView.reloadRows(at: [IndexPath(row: index, section: 0)],
              with: .top)
          break
        }
      }
    }
  }

  func detailedTweetViewController(
      _ detailedTweetViewController: DetailedTweetViewController,
      didPostReplyTweet tweet: Tweet) {
    if tweets != nil {
      tweets.insert(tweet, at: 0)
      tweetsTableView.reloadData()
    }
  }
}

extension ProfileViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController,
      didPostTweet tweet: Tweet) {
    if tweets != nil {
      tweets.insert(tweet, at: 0)
      tweetsTableView.reloadData()
    }
  }
}
