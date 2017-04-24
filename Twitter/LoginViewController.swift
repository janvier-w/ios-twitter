//
//  LoginViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/12/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "LoginSegue" {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let hamburgerViewController = segue.destination as! HamburgerViewController
      let menuViewController = storyboard.instantiateViewController(
          withIdentifier: "MenuViewController") as! MenuViewController

      /* WARNING: These two statements are not interchangeable. Switching them
       *          will crash the app since the hamburgerViewController is nil.
       */
      menuViewController.hamburgerViewController = hamburgerViewController
      hamburgerViewController.menuViewController = menuViewController
    }
  }

  @IBAction func login(_ sender: Any) {
    TwitterClient.sharedInstance?.login(
        success: {
          self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        }, failure: { (error: Error) in
          print("ERROR: \(error.localizedDescription)")
        })
  }
}
