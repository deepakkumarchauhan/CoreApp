//
//  CASignupTableViewCell.swift
//  CoreApplication
//
//  Created by apple on 4/19/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CASignupTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dropDownImageView: UIImageView!
    @IBOutlet weak var signupTextField: CustomTextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
