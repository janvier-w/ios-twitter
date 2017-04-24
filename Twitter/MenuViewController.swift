//
//  MenuViewController.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/22/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!

  var hamburgerViewController: HamburgerViewController!

  var viewControllers = [UIViewController]()

  let menuItemTitles = ["Timeline", "Mentions", "Profile"]

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    /*
    tableView.register(UITableViewHeaderFooterView.self,
        forHeaderFooterViewReuseIdentifier: "TableViewHeaderCell")
    tableView.register(UITableViewCell.self,
        forCellReuseIdentifier: "TableViewCell")
    */

    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)

    viewControllers.append(storyboard.instantiateViewController(
        withIdentifier: "TweetsNavigationController"))
    viewControllers.append(storyboard.instantiateViewController(
        withIdentifier: "MentionsNavigationController"))
    viewControllers.append(storyboard.instantiateViewController(
        withIdentifier: "ProfileNavigationController"))

    hamburgerViewController.contentViewController = viewControllers[0]
  }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {
  /*
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
      -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(
        withIdentifier: "TableViewHeaderCell")!

    return header
  }

  func tableView(_ tableView: UITableView,
      heightForHeaderInSection section: Int) -> CGFloat {
    return 64
  }
  */

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
      -> Int {
    return menuItemTitles.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
      -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell",
        for: indexPath) as! MenuItemCell
    cell.title = menuItemTitles[indexPath.row]

    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 128
  }

  func tableView(_ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    hamburgerViewController.contentViewController =
        viewControllers[indexPath.row]
  }
}
