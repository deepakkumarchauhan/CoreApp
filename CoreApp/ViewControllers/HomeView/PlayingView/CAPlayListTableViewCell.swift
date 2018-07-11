//
//  CAPlayListTableViewCell.swift
//  CoreApp
//
//  Created by apple on 5/7/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAPlayListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var playNowButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var readTextbutton: UIButton!
    @IBOutlet weak var cellBottomView: UIView!
    @IBOutlet weak var playingImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    @IBOutlet weak var downloadLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
