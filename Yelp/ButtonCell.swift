//
//  ButtonCell.swift
//  Yelp
//
//  Created by Mendoza, Alejandro on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol ButtonCellDelegate {
    @objc optional func buttonCell(buttonCell: ButtonCell, didTouchUpInside value: Bool)
}

class ButtonCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    //let isSelected = false
    weak var delegate: ButtonCellDelegate?
    var isChecked: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isChecked = false
        
        //checkImage.image = UIImage(named: "selectedCheck")
        
        checkButton.addTarget(self, action: #selector(ButtonCell.buttonTouched), for: UIControlEvents.touchUpInside)
        
        
       // checkButton.addTarget(self, action: #selector(ButtonCell.buttonValueChanged), for: UIControlEvents.valueChanged)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setSelectedImage() {
        checkImage.image = UIImage(named: "selectedCheck")
    }
    
    public func setDeselectedImage() {
        checkImage.image = UIImage(named: "unselectedCheck")
    }
    
    func buttonTouched() {
        print("something")
        if delegate != nil {
            delegate?.buttonCell?(buttonCell: self, didTouchUpInside: isChecked!)
        }
        
        if (isChecked)! {
            setSelectedImage()
        } else {
            setDeselectedImage()
        }
    }
    
//    func buttonValueChanged()
//    {
//        if delegate != nil {
//            delegate?.buttonCell?(buttonCell: self, didChangeValue: checkButton.isSelected)
//        }
//    }

}
