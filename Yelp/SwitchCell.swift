//
//  SwitchCell.swift
//  Yelp
//
//  Created by Jose Montes de Oca on 9/26/15.
//  Copyright © 2015 JoseOnline. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    optional func switchCell(switchCell: SwitchCell, didChangeValue: Bool)
}

class SwitchCell: UITableViewCell {
    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    weak var delegate: SwitchCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        onSwitch.addTarget(self, action: "onSwitchValueChange", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onSwitchValueChange() {
        delegate?.switchCell?(self, didChangeValue: onSwitch.on)
    }

}
