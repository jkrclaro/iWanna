//
//  UILabelExtension.swift
//  iWanna
//
//  Created by John Claro on 24/03/2016.
//  Copyright © 2016 jkrclaro. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    func requiredHeight() -> CGFloat {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}