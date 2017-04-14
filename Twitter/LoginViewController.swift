//
//  LoginViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  @IBAction func login(_ sender: Any) {
    TwitterClient.sharedInstance?.login(
        success: {
          self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }
}
