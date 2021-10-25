//
//  LoadingButton.swift
//  BindID Example
//
//  Created by Shachar Udi on 20/10/2021.
//

import UIKit

class LoadingButton: UIButton {

    private var originalButtonText: String?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])

        return activityIndicator
    }()

    final public func setLoading(_ isLoading: Bool) {
        isEnabled = !isLoading

        if isLoading {
            originalButtonText = titleLabel?.text
            setTitle("", for: .normal)
            activityIndicator.startAnimating()
        } else {
            setTitle(originalButtonText, for: .normal)
            activityIndicator.stopAnimating()
        }
    }
}
