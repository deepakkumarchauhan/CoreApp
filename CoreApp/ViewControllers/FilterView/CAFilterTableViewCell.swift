//
//  CAFilterTableViewCell.swift
//  CoreApp
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAFilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
