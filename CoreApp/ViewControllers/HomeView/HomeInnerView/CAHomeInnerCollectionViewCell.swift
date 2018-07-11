//
//  CAHomeInnerCollectionViewCell.swift
//  CoreApplication
//
//  Created by apple on 4/20/18.
//  Copyright © 2018 WonderPillars. All rights reserved.
//

import UIKit

class CAHomeInnerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var cellMainView: UIView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var readTextButton: UIButton!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
