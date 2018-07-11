//
//  CALibraryExpandTableViewCell.swift
//  CoreApplication
//
//  Created by apple on 4/23/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CALibraryExpandTableViewCell: UITableViewCell {
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var playNowButton: UIButton!
    @IBOutlet weak var readTextButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var addToPlayListButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
