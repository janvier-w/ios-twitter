//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/22/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {
  @IBOutlet weak var menuView: UIView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var contentLeftMarginConstraint: NSLayoutConstraint!

  var originalContentLeftMargin: CGFloat!
  var menuViewController: UIViewController! {
    didSet(oldContentViewController) {
      /* WARNING: This is a hack to have the viewDidLoad() called to initialize
       *          the menuView. This works because view is a lazy property.
       */
      view.layoutIfNeeded()

      if oldContentViewController != nil {
        oldContentViewController.willMove(toParentViewController: nil)
        oldContentViewController.view.removeFromSuperview()
        oldContentViewController.didMove(toParentViewController: nil)
      }

      menuViewController.willMove(toParentViewController: self)
      menuView.addSubview(menuViewController.view)
      menuViewController.didMove(toParentViewController: self)

      view.layoutIfNeeded()
    }
  }
  var contentViewController: UIViewController! {
    didSet(oldContentViewController) {
      /* WARNING: This is a hack to have the viewDidLoad() called to initialize
       *          the contentView. This works because view is a lazy property.
       */
      view.layoutIfNeeded()

      if oldContentViewController != nil {
        oldContentViewController.willMove(toParentViewController: nil)
        oldContentViewController.view.removeFromSuperview()
        oldContentViewController.didMove(toParentViewController: nil)
      }

      contentViewController.willMove(toParentViewController: self)
      contentView.addSubview(contentViewController.view)
      contentViewController.didMove(toParentViewController: self)

      UIView.animate(withDuration: 0.25, animations: {
        self.contentLeftMarginConstraint.constant = 0
        self.view.layoutIfNeeded()
      })
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()


  }

  @IBAction func panContentView(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    let velocity = sender.velocity(in: view)

    if sender.state == .began {
      originalContentLeftMargin = contentLeftMarginConstraint.constant
    } else if sender.state == .changed {
      if contentLeftMarginConstraint.constant != 0 || velocity.x > 0 {
        contentLeftMarginConstraint.constant = originalContentLeftMargin +
            translation.x
      }
    } else if sender.state == .ended {
      UIView.animate(withDuration: 0.25, animations: {
        if velocity.x > 0 {
          self.contentLeftMarginConstraint.constant =
              self.view.frame.size.width - 50
        } else {
          self.contentLeftMarginConstraint.constant = 0
        }
        self.view.layoutIfNeeded()
      })
    }
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
