//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!

  var tweets: [Tweet]!

  var isRequestingMoreData = false
  var requestingMoreDataIndicator: ActivityIndicatorView?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let nib = UINib(nibName: "TweetCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "TweetCell")

    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 98

    /* Allow pull to refresh */
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshTimeline(_:)),
        for: .valueChanged)
    tableView.insertSubview(refreshControl, at: 0)

    /* Set up activity indicator for requesting more data */
    let frame = CGRect(x: 0, y: tableView.contentSize.height,
        width: tableView.bounds.size.width,
        height: ActivityIndicatorView.defaultHeight)
    requestingMoreDataIndicator = ActivityIndicatorView(frame: frame)
    requestingMoreDataIndicator!.isHidden = true
    tableView.addSubview(requestingMoreDataIndicator!)

    var inset = tableView.contentInset
    inset.bottom += ActivityIndicatorView.defaultHeight
    tableView.contentInset = inset

    refreshTimeline(refreshControl)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier != nil {
      if segue.identifier == "DetailedTweetSegue" {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
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
        let indexPath = tableView.indexPath(for: cell)
        let navigationController = segue.destination as! UINavigationController
        let viewController = navigationController.topViewController as!
            NewTweetViewController
        viewController.delegate = self
        viewController.replyToTweet = tweets[indexPath!.row]
      }
    }
  }

  @IBAction func logout(_ sender: Any) {
    TwitterClient.sharedInstance?.logout()
  }

  func refreshTimeline(_ refreshControl: UIRefreshControl) {
    TwitterClient.sharedInstance?.homeTimeline(maxId: nil, sinceId: nil,
        success: { (tweets: [Tweet]) in
          self.tweets = tweets
          self.tableView.reloadData()
          refreshControl.endRefreshing()
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
          refreshControl.endRefreshing()
        })
  }
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
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

extension TweetsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if !isRequestingMoreData {
      /* Set threshold to one screen length before the bottom of the results */
      let scrollOffsetThreshold = tableView.contentSize.height -
          tableView.bounds.size.height

      /* Request for more data when the user has scrolled past the threshold */
      if scrollView.contentOffset.y > scrollOffsetThreshold &&
         tableView.isDragging {
        isRequestingMoreData = true

        /* Update position of activity indicator and start loading it */
        let frame = CGRect(x: 0, y: tableView.contentSize.height,
            width: tableView.bounds.size.width,
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

    TwitterClient.sharedInstance?.homeTimeline(maxId: maxId, sinceId: nil,
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
          self.tableView.reloadData()
        }, failure: { (error: Error) in
          self.isRequestingMoreData = false
          self.requestingMoreDataIndicator!.stopAnimating()
          print("ERROR: \(error.localizedDescription)")
        })
  }
}

extension TweetsViewController: TweetCellDelegate {
  func tweetCell(_ tweetCell: TweetCell, didUpdateTweet tweet: Tweet) {
    if let indexPath = tableView.indexPath(for: tweetCell) {
      tweets[indexPath.row] = tweet
    }
  }

  func tweetCell(_ tweetCell: TweetCell, willShowUserProfile user: User) {
    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
    let profileViewController = storyboard.instantiateViewController(
        withIdentifier: "ProfileViewController") as! ProfileViewController

    profileViewController.user = user
    navigationController?.pushViewController(profileViewController,
        animated: true)
  }
}

extension TweetsViewController: DetailedTweetViewControllerDelegate {
  func detailedTweetViewController(
      _ detailedTweetViewController: DetailedTweetViewController,
      didUpdateTweet tweet: Tweet) {
    if tweets != nil {
      for index in 0..<tweets.count {
        if tweets[index].id == tweet.id {
          tweets[index] = tweet
          tableView.reloadRows(at: [IndexPath(row: index, section: 0)],
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
      tableView.reloadData()
    }
  }
}

extension TweetsViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController,
      didPostTweet tweet: Tweet) {
    if tweets != nil {
      tweets.insert(tweet, at: 0)
      tableView.reloadData()
    }
  }
}
