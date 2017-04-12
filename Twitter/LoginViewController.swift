//
//  LoginViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let TwitterBaseURL = URL(string: "https://api.twitter.com")
let TwitterConsumerKey = "nCjUCjTEVtt2Si7qGgptGyK00"
let TwitterConsumerSecret = "u921ZTv1aFyHs64KJ4G5lUAWAJyFHvKOj8eGjGrVZAL4B31xqk"

class LoginViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func login(_ sender: Any) {
    let twitterClient = BDBOAuth1SessionManager(baseURL: TwitterBaseURL,
        consumerKey: TwitterConsumerKey, consumerSecret: TwitterConsumerSecret)

    twitterClient?.deauthorize()
    twitterClient?.fetchRequestToken(withPath: "oauth/request_token",
        method: "GET", callbackURL: URL(string: "jw-twitter://oauth"), scope: nil,
        success: { (requestToken: BDBOAuth1Credential?) in
          print("Received the request token: \(requestToken?.token ?? "NULL")")

          if let authToken = requestToken?.token {
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(authToken)")
            if let url = authURL {
              UIApplication.shared.open(url, options: [:],
                  completionHandler: { (isSuccess: Bool) in
                    print("Successfully authorize")
                  })
            }
          }
        }, failure: { (error: Error!) in
          print("ERROR: \(error.localizedDescription)")
        })
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
