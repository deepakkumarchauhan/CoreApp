//
//  CALibraryTableViewCell.swift
//  CoreApplication
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CALibraryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var playNowButton: UIButton!
    @IBOutlet weak var addToPlaylistButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var readTextbutton: UIButton!
    @IBOutlet weak var cellBottomView: UIView!
    @IBOutlet weak var playingImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var typeImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
