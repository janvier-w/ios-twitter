//
//  ActivityIndicatorView.swift
//  Twitter
//
//  Created by Janvier Wijaya on 4/14/17.
//  Copyright © 2017 Janvier Wijaya. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {
  static let defaultHeight: CGFloat = 160.0

  let activityIndicatorView = UIActivityIndicatorView()

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupActivityIndicator()
  }

  override init(frame aRect: CGRect) {
    super.init(frame: aRect)
    setupActivityIndicator()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    activityIndicatorView.center = CGPoint(x: 0.5 * bounds.size.width,
        y: 0.5 * bounds.size.height)
  }

  func setupActivityIndicator() {
    activityIndicatorView.activityIndicatorViewStyle = .gray
    activityIndicatorView.hidesWhenStopped = true
    addSubview(activityIndicatorView)
  }

  func startAnimating() {
    isHidden = false
    activityIndicatorView.startAnimating()
  }

  func stopAnimating() {
    activityIndicatorView.stopAnimating()
    isHidden = true
  }
}
