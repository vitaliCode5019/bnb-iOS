//
//  UIViewSupport.swift
//  rider
//
//  Created by admin on 1/2/17.
//  Copyright © 2017 BicycleBNB. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}

protocol PageViewControllerWithControlDelegate: class {
    func pageViewController(pageViewController: UIPageViewController,
                                     didUpdatePageCount count: Int)
    
    func pageViewController(pageViewController: UIPageViewController,
                                     didUpdatePageIndex index: Int)
}
