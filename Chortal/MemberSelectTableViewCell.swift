//
//  MemberSelectTableViewCell.swift
//  Chortal
//
//  Created by Jonathan Jones on 2/26/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class MemberSelectTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
