//
//  EntryCell.swift
//  TravelBros
//
//  Created by Edvard Hedlund on 2018-09-27.
//  Copyright © 2018 Edvard Hedlund. All rights reserved.
//

import UIKit

//hanterar individuella celler i inläggslistan
class EntryCell: UITableViewCell {
    
    
    @IBOutlet weak var entryLabel: UILabel!
    
//    @IBOutlet weak var entryImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//       entryImage.layer.cornerRadius = 20
//       entryImage.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
