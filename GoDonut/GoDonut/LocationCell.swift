//
//  LocationCell.swift
//  GoDonut
//
//  Created by Brandon Ballentine on 9/16/16.
//  Copyright © 2016 Brandon Ballentine. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var businessImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
