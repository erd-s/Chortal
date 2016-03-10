//: Playground - noun: a place where people can play

import UIKit
import XCPlayground


let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
view.backgroundColor = .lightGrayColor()
view.alpha = 0.80
view.layer.cornerRadius = 5

let label = UILabel(frame: CGRect(x: 30, y: 0, width: 160, height: 30))
label.text = "Loading a bunch of tasks..."

let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
spinner.startAnimating()

view.addSubview(label)
view.addSubview(spinner)


XCPlaygroundPage.currentPage.liveView = view