//
//  ProductTableViewCell.swift
//  Wishlist
//
//  Created by Alex Tavella on 08/10/17.
//  Copyright © 2017 Alex Tavella. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbValue: UILabel!
    @IBOutlet weak var lbState: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
