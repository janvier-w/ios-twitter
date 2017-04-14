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
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 90

    TwitterClient.sharedInstance?.homeTimeline(
        success: { (tweets: [Tweet]) in
          self.tweets = tweets
          self.tableView.reloadData()
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }

  @IBAction func logout(_ sender: Any) {
    TwitterClient.sharedInstance?.logout()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier != nil {
      if segue.identifier == "DetailedTweetSegue" {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let viewController = segue.destination as! DetailedTweetViewController
        viewController.tweet = tweets[indexPath!.row]
      } else if segue.identifier == "NewTweetSegue" {
        /*
        let navigationController = segue.destination as! UINavigationController
        let viewController = navigationController.topViewController as!
            NewTweetViewController
        viewController.delegate = self
        */
      }
    }
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
    cell.tweet = tweets[indexPath.row]

    return cell
  }
}
