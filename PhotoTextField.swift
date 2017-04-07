//
//  PhotoTextField.swift
//  ColorMaker
//
//  Created by fullmoon on 3/26/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

class PhotoTextField: UITextField {

    var textAttributes:[String:Any] = [
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        ]
 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.defaultTextAttributes = textAttributes
    }
    
 
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch! = touches.first! as UITouch
        self.center = touch.location(in: self.superview)
    }
 

}
