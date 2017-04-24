//
//  MenuItemCell.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/22/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!

  var title: String! {
    didSet {
      titleLabel.text = title
    }
  }
}
