//
//  NowPlayingViewCell.swift
//  MovieViewer
//
//  Created by Patwardhan, Saurabh on 10/13/16.
//  Copyright © 2016 Saurabh Patwardhan. All rights reserved.
//

import UIKit

class NowPlayingViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
